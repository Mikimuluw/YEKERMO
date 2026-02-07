import 'package:yekermo/core/transport/transport_client.dart';
import 'package:yekermo/data/dto/order_dto.dart';
import 'package:yekermo/data/dto/order_event_dto.dart';
import 'package:yekermo/data/repositories/orders_repository.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/order_draft.dart';
import 'package:yekermo/domain/order_failures.dart';
import 'package:yekermo/domain/payment_method.dart';

class ApiOrdersRepository implements OrdersRepository {
  ApiOrdersRepository(this.transportClient);

  final TransportClient transportClient;

  static List<Order> _parseOrderList(dynamic data) {
    if (data is! List) return const [];
    return data
        .map((e) => OrderDto.fromJson(e as Map<String, dynamic>).toModel())
        .toList();
  }

  static Order? _parseOrder(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    return OrderDto.fromJson(data).toModel();
  }

  @override
  Future<List<Order>> getOrders() async {
    try {
      final response = await transportClient.request<dynamic>(
        TransportRequest(
          method: 'GET',
          url: Uri(path: '/orders'),
          timeout: const Duration(seconds: 12),
        ),
      );
      return _parseOrderList(response.data);
    } on TransportError {
      return const [];
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<Order?> getOrder(String id) async {
    try {
      final response = await transportClient.request<dynamic>(
        TransportRequest(
          method: 'GET',
          url: Uri(path: '/orders/$id'),
          timeout: const Duration(seconds: 12),
        ),
      );
      return _parseOrder(response.data);
    } on TransportError {
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Order?> getLatestOrder() async {
    try {
      final response = await transportClient.request<dynamic>(
        TransportRequest(
          method: 'GET',
          url: Uri(path: '/orders/latest'),
          timeout: const Duration(seconds: 12),
        ),
      );
      return _parseOrder(response.data);
    } on TransportError {
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Order> placeOrder(
    OrderDraft draft, {
    required PaymentMethod paymentMethod,
  }) async {
    if (draft.items.isEmpty) {
      throw const PlaceOrderException(
        PlaceOrderFailure(PlaceOrderFailureCode.unknown),
      );
    }
    final restaurantId = draft.items.first.item.restaurantId;
    final body = <String, dynamic>{
      'restaurantId': restaurantId,
      'fulfillmentMode': draft.fulfillmentMode.name,
      'total': draft.fees.total,
      'subtotal': draft.fees.subtotal,
      'serviceFee': draft.fees.serviceFee,
      'deliveryFee': draft.fees.deliveryFee,
      'tax': draft.fees.tax,
      'items': draft.items
          .map((e) => {'menuItemId': e.item.id, 'quantity': e.quantity})
          .toList(),
      'paymentMethod': {'brand': paymentMethod.brand, 'last4': paymentMethod.last4},
    };
    if (draft.address != null) {
      body['addressId'] = draft.address!.id;
    }
    try {
      final response = await transportClient.request<dynamic>(
        TransportRequest(
          method: 'POST',
          url: Uri(path: '/orders'),
          body: body,
          timeout: const Duration(seconds: 15),
        ),
      );
      final order = _parseOrder(response.data);
      if (order == null) {
        throw const PlaceOrderException(
          PlaceOrderFailure(PlaceOrderFailureCode.unknown),
        );
      }
      return order;
    } on TransportError {
      throw const PlaceOrderException(
        PlaceOrderFailure(PlaceOrderFailureCode.unknown),
      );
    }
  }

  @override
  Future<OrderEventsResponse> getOrderEvents(String orderId, {int limit = 50, String? cursor}) async {
    try {
      final q = Uri(path: '/orders/$orderId/events').replace(
        queryParameters: {'limit': limit.toString(), if (cursor != null && cursor.isNotEmpty) 'cursor': cursor},
      );
      final response = await transportClient.request<dynamic>(
        TransportRequest(method: 'GET', url: q, timeout: const Duration(seconds: 12)),
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['events'] as List<dynamic>? ?? [];
      final events = list.map((e) => OrderEventDto.fromJson(e as Map<String, dynamic>)).toList();
      final nextCursor = data['nextCursor'] as String?;
      return OrderEventsResponse(events: events, nextCursor: nextCursor);
    } on TransportError {
      return const OrderEventsResponse(events: []);
    } catch (_) {
      return const OrderEventsResponse(events: []);
    }
  }

  @override
  Future<Order> cancelOrder(String orderId, {String? reason}) async {
    try {
      final response = await transportClient.request<dynamic>(
        TransportRequest(
          method: 'POST',
          url: Uri(path: '/orders/$orderId/cancel'),
          body: reason != null ? {'reason': reason} : null,
          timeout: const Duration(seconds: 12),
        ),
      );
      final order = _parseOrder(response.data);
      if (order == null) throw const PlaceOrderException(PlaceOrderFailure(PlaceOrderFailureCode.unknown));
      return order;
    } on TransportError {
      throw const PlaceOrderException(PlaceOrderFailure(PlaceOrderFailureCode.unknown));
    }
  }
}

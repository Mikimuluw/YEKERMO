import 'package:yekermo/core/transport/transport_client.dart';
import 'package:yekermo/data/repositories/orders_repository.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/order_draft.dart';
import 'package:yekermo/domain/payment_method.dart';

class ApiOrdersRepository implements OrdersRepository {
  ApiOrdersRepository(this.transportClient);

  final TransportClient transportClient;
  int _fallbackCounter = 1;

  @override
  Future<List<Order>> getOrders() async {
    try {
      final TransportResponse<List<Order>> response =
          await transportClient.request<List<Order>>(
        TransportRequest(
          method: 'GET',
          url: Uri(path: '/orders'),
          timeout: const Duration(seconds: 12),
        ),
      );
      return response.data;
    } on TransportError {
      return const [];
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<Order?> getOrder(String id) async {
    try {
      final TransportResponse<Order?> response =
          await transportClient.request<Order?>(
        TransportRequest(
          method: 'GET',
          url: Uri(path: '/orders/$id'),
          timeout: const Duration(seconds: 12),
        ),
      );
      return response.data;
    } on TransportError {
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Order?> getLatestOrder() async {
    try {
      final TransportResponse<Order?> response =
          await transportClient.request<Order?>(
        TransportRequest(
          method: 'GET',
          url: Uri(path: '/orders/latest'),
          timeout: const Duration(seconds: 12),
        ),
      );
      return response.data;
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
    try {
      final TransportResponse<Order> response =
          await transportClient.request<Order>(
        TransportRequest(
          method: 'POST',
          url: Uri(path: '/orders'),
          body: <String, Object?>{
            'items': draft.items
                .map(
                  (lineItem) => <String, Object?>{
                    'menuItemId': lineItem.item.id,
                    'quantity': lineItem.quantity,
                  },
                )
                .toList(),
            'fulfillmentMode': draft.fulfillmentMode.name,
            'fees': <String, Object?>{
              'subtotal': draft.fees.subtotal,
              'serviceFee': draft.fees.serviceFee,
              'deliveryFee': draft.fees.deliveryFee,
              'tax': draft.fees.tax,
            },
            'addressId': draft.address?.id,
            'notes': draft.notes,
            'paymentMethod': <String, Object?>{
              'brand': paymentMethod.brand,
              'last4': paymentMethod.last4,
            },
          },
          timeout: const Duration(seconds: 12),
        ),
      );
      return response.data;
    } on TransportError {
      return _fallbackOrder(draft, paymentMethod);
    } catch (_) {
      return _fallbackOrder(draft, paymentMethod);
    }
  }

  Order _fallbackOrder(OrderDraft draft, PaymentMethod paymentMethod) {
    final String restaurantId = draft.items.isEmpty
        ? ''
        : draft.items.first.item.restaurantId;
    return Order(
      id: 'order-${_fallbackCounter++}',
      restaurantId: restaurantId,
      items: draft.items
          .map(
            (lineItem) => OrderItem(
              menuItemId: lineItem.item.id,
              quantity: lineItem.quantity,
            ),
          )
          .toList(),
      total: draft.fees.total,
      status: OrderStatus.preparing,
      fulfillmentMode: draft.fulfillmentMode,
      paymentStatus: PaymentStatus.paid,
      paymentMethod: paymentMethod,
      feeBreakdown: draft.fees,
      paidAt: DateTime.now(),
      address: draft.address,
      placedAt: DateTime.now(),
      scheduledTime: null,
    );
  }
}

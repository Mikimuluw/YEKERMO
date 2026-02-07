import 'package:yekermo/data/dto/order_event_dto.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/order_draft.dart';
import 'package:yekermo/domain/payment_method.dart';

abstract class OrdersRepository {
  Future<List<Order>> getOrders();
  Future<Order?> getOrder(String id);
  Future<Order?> getLatestOrder();
  Future<Order> placeOrder(
    OrderDraft draft, {
    required PaymentMethod paymentMethod,
  });

  /// Phase-2: audit timeline for an order.
  Future<OrderEventsResponse> getOrderEvents(String orderId, {int limit = 50, String? cursor});

  /// Phase-2: cancel order (allowed only in NEW/ACCEPTED).
  Future<Order> cancelOrder(String orderId, {String? reason});
}

class OrderEventsResponse {
  const OrderEventsResponse({required this.events, this.nextCursor});
  final List<OrderEventDto> events;
  final String? nextCursor;
}

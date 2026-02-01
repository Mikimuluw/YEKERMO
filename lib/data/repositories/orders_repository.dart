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
}

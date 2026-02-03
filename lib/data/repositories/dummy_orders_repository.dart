import 'package:yekermo/core/time/restaurant_hours.dart';
import 'package:yekermo/data/repositories/orders_repository.dart';
import 'package:yekermo/data/seed/yyc_restaurants.dart';
import 'package:yekermo/domain/failure.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/order_draft.dart';
import 'package:yekermo/domain/payment_method.dart';

class DummyOrdersRepository implements OrdersRepository {
  DummyOrdersRepository({DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  final List<Order> _orders = [];
  int _counter = 1;

  @override
  Future<List<Order>> getOrders() async => List<Order>.unmodifiable(_orders);

  @override
  Future<Order?> getOrder(String id) async {
    for (final order in _orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  @override
  Future<Order?> getLatestOrder() async =>
      _orders.isEmpty ? null : _orders.first;

  @override
  Future<Order> placeOrder(
    OrderDraft draft, {
    required PaymentMethod paymentMethod,
  }) async {
    final String restaurantId = draft.items.isEmpty
        ? ''
        : draft.items.first.item.restaurantId;
    final YYCRestaurantSeed? seed = yycRestaurantById(restaurantId);
    if (seed != null && !isOpenNow(seed.hoursByWeekday, _now())) {
      throw const Failure('Restaurant is closed.');
    }
    final Order order = Order(
      id: 'order-${_counter++}',
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
      paidAt: _now(),
      address: draft.address,
      placedAt: _now(),
      scheduledTime: null,
    );
    _orders.insert(0, order);
    return order;
  }
}

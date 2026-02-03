import 'package:yekermo/core/time/clock.dart';
import 'package:yekermo/core/time/restaurant_hours.dart';
import 'package:yekermo/data/repositories/orders_repository.dart';
import 'package:yekermo/data/seed/yyc_restaurants.dart';
import 'package:yekermo/domain/failure.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/order_draft.dart';
import 'package:yekermo/domain/payment_method.dart';

class DummyOrdersRepository implements OrdersRepository {
  DummyOrdersRepository({
    Clock? clock,
    YYCRestaurantSeed? Function(String id)? restaurantLookup,
  })  : _clock = clock ?? const SystemClock(),
        _restaurantLookup = restaurantLookup ?? yycRestaurantById;

  final Clock _clock;
  final YYCRestaurantSeed? Function(String id) _restaurantLookup;
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
    final YYCRestaurantSeed? seed = _restaurantLookup(restaurantId);
    if (seed != null && !isOpenNow(seed.hoursByWeekday, _clock.now())) {
      throw const Failure('Restaurant is closed.');
    }
    if (seed != null &&
        draft.fulfillmentMode == FulfillmentMode.delivery &&
        !seed.serviceModes.contains(ServiceMode.delivery)) {
      throw const Failure('Unable to place order right now.');
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
      paidAt: _clock.now(),
      address: draft.address,
      placedAt: _clock.now(),
      scheduledTime: null,
    );
    _orders.insert(0, order);
    return order;
  }
}

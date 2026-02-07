import 'package:yekermo/core/time/clock.dart';
import 'package:yekermo/core/time/restaurant_hours.dart';
import 'package:yekermo/data/dto/order_event_dto.dart';
import 'package:yekermo/data/repositories/orders_repository.dart';
import 'package:yekermo/data/seed/yyc_restaurants.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/order_failures.dart';
import 'package:yekermo/domain/order_draft.dart';
import 'package:yekermo/domain/payment_method.dart';

class DummyOrdersRepository implements OrdersRepository {
  DummyOrdersRepository({
    Clock? clock,
    YYCRestaurantSeed? Function(String id)? restaurantLookup,
  }) : _clock = clock ?? const SystemClock(),
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
      throw const PlaceOrderException(
        PlaceOrderFailure(PlaceOrderFailureCode.restaurantClosed),
      );
    }
    if (seed != null &&
        draft.fulfillmentMode == FulfillmentMode.delivery &&
        !seed.serviceModes.contains(ServiceMode.delivery)) {
      throw const PlaceOrderException(
        PlaceOrderFailure(PlaceOrderFailureCode.serviceModeUnavailable),
      );
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

  @override
  Future<OrderEventsResponse> getOrderEvents(String orderId, {int limit = 50, String? cursor}) async {
    final order = await getOrder(orderId);
    if (order == null) return const OrderEventsResponse(events: []);
    final events = <OrderEventDto>[
      OrderEventDto(
        id: 'evt-1',
        orderId: orderId,
        type: 'ORDER_CREATED',
        toStatus: 'NEW',
        actorType: 'CUSTOMER',
        createdAt: order.placedAt ?? DateTime.now(),
      ),
    ];
    return OrderEventsResponse(events: events);
  }

  @override
  Future<Order> cancelOrder(String orderId, {String? reason}) async {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx < 0) throw const PlaceOrderException(PlaceOrderFailure(PlaceOrderFailureCode.unknown));
    final order = _orders[idx];
    if (order.status != OrderStatus.received) {
      throw const PlaceOrderException(PlaceOrderFailure(PlaceOrderFailureCode.unknown));
    }
    final cancelled = Order(
      id: order.id,
      restaurantId: order.restaurantId,
      items: order.items,
      total: order.total,
      status: OrderStatus.cancelled,
      fulfillmentMode: order.fulfillmentMode,
      paymentStatus: order.paymentStatus,
      paymentMethod: order.paymentMethod,
      feeBreakdown: order.feeBreakdown,
      paidAt: order.paidAt,
      address: order.address,
      placedAt: order.placedAt,
      scheduledTime: order.scheduledTime,
    );
    _orders[idx] = cancelled;
    return cancelled;
  }
}

import 'package:yekermo/data/repositories/orders_repository.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/order_draft.dart';

class DummyOrdersRepository implements OrdersRepository {
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
  Future<Order> placeOrder(OrderDraft draft) async {
    final String restaurantId =
        draft.items.isEmpty ? '' : draft.items.first.item.restaurantId;
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
      status: OrderStatus.received,
      fulfillmentMode: draft.fulfillmentMode,
      address: draft.address,
      placedAt: DateTime.now(),
      scheduledTime: null,
    );
    _orders.insert(0, order);
    return order;
  }
}

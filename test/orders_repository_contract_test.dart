import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/core/transport/fake_transport_client.dart';
import 'package:yekermo/core/transport/transport_client.dart';
import 'package:yekermo/data/repositories/api_orders_repository.dart';
import 'package:yekermo/data/repositories/dummy_orders_repository.dart';
import 'package:yekermo/data/repositories/orders_repository.dart';
import 'package:yekermo/domain/cart.dart';
import 'package:yekermo/domain/fees.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/order_draft.dart';
import 'package:yekermo/domain/payment_method.dart';

const PaymentMethod _paymentMethod = PaymentMethod(
  brand: 'Card',
  last4: '4242',
);

const MenuItem _menuItem = MenuItem(
  id: 'item-1',
  restaurantId: 'rest-1',
  categoryId: 'cat-1',
  name: 'Misir Comfort Bowl',
  description: 'Red lentils, warm spices.',
  price: 12.0,
  tags: [MenuItemTag.quickFilling],
);

const FeeBreakdown _fees = FeeBreakdown(
  subtotal: 12,
  serviceFee: 1,
  deliveryFee: 1,
  tax: 1,
);

OrderDraft _draft() => const OrderDraft(
  items: [CartLineItem(item: _menuItem, quantity: 1)],
  fulfillmentMode: FulfillmentMode.delivery,
  fees: _fees,
  address: Address(
    id: 'addr-1',
    label: AddressLabel.home,
    line1: '215 Riverstone Ave',
    city: 'YYC',
  ),
);

Order _sampleOrder() => Order(
  id: 'order-1',
  restaurantId: 'rest-1',
  items: const [OrderItem(menuItemId: 'item-1', quantity: 1)],
  total: _fees.total,
  status: OrderStatus.preparing,
  fulfillmentMode: FulfillmentMode.delivery,
  paymentStatus: PaymentStatus.paid,
  paymentMethod: _paymentMethod,
  feeBreakdown: _fees,
  address: const Address(
    id: 'addr-1',
    label: AddressLabel.home,
    line1: '215 Riverstone Ave',
    city: 'YYC',
  ),
  paidAt: DateTime(2025, 1, 1),
  placedAt: DateTime(2025, 1, 1),
);

void main() {
  group('OrdersRepository contract (dummy)', () {
    test('placeOrder returns preparing order and stores it', () async {
      final OrdersRepository repo = DummyOrdersRepository();
      final Order order = await repo.placeOrder(
        _draft(),
        paymentMethod: _paymentMethod,
      );
      expect(order.status, OrderStatus.preparing);
      expect(order.paymentStatus, PaymentStatus.paid);
      expect(order.paymentMethod?.last4, _paymentMethod.last4);
      expect(order.feeBreakdown?.total, _fees.total);

      final List<Order> orders = await repo.getOrders();
      expect(orders, isNotEmpty);
      expect(orders.first.id, order.id);
    });

    test('getOrder returns null for unknown id', () async {
      final OrdersRepository repo = DummyOrdersRepository();
      final Order? order = await repo.getOrder('missing');
      expect(order, isNull);
    });
  });

  group('OrdersRepository contract (api)', () {
    test('getOrders returns transport payload', () async {
      final FakeTransportClient transport = FakeTransportClient(
        response: TransportResponse<List<Order>>(
          data: [_sampleOrder()],
          statusCode: 200,
        ),
      );
      final OrdersRepository repo = ApiOrdersRepository(transport);
      final List<Order> orders = await repo.getOrders();
      expect(orders, hasLength(1));
      expect(orders.first.id, 'order-1');
    });

    test('getOrder returns transport payload', () async {
      final FakeTransportClient transport = FakeTransportClient(
        response: TransportResponse<Order?>(
          data: _sampleOrder(),
          statusCode: 200,
        ),
      );
      final OrdersRepository repo = ApiOrdersRepository(transport);
      final Order? order = await repo.getOrder('order-1');
      expect(order, isNotNull);
      expect(order?.id, 'order-1');
    });

    test('getLatestOrder returns transport payload', () async {
      final FakeTransportClient transport = FakeTransportClient(
        response: TransportResponse<Order?>(
          data: _sampleOrder(),
          statusCode: 200,
        ),
      );
      final OrdersRepository repo = ApiOrdersRepository(transport);
      final Order? order = await repo.getLatestOrder();
      expect(order, isNotNull);
      expect(order?.id, 'order-1');
    });

    test('transport errors map to empty list or null', () async {
      final FakeTransportClient transport = FakeTransportClient(
        scenario: FakeTransportScenario.network,
      );
      final OrdersRepository repo = ApiOrdersRepository(transport);
      final List<Order> orders = await repo.getOrders();
      final Order? order = await repo.getOrder('order-1');
      final Order? latest = await repo.getLatestOrder();
      expect(orders, isEmpty);
      expect(order, isNull);
      expect(latest, isNull);
    });
  });
}

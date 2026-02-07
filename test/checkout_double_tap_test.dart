import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/app/di.dart';
import 'package:yekermo/data/payments/payment_result.dart';
import 'package:yekermo/data/repositories/dummy_address_repository.dart';
import 'package:yekermo/data/repositories/dummy_cart_repository.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/order_draft.dart';
import 'package:yekermo/domain/payment_method.dart';
import 'package:yekermo/features/checkout/checkout_controller.dart';
import 'package:yekermo/data/repositories/orders_repository.dart';
import 'package:yekermo/data/repositories/payments_repository.dart';

/// Fake payments repo that returns success immediately.
class _ImmediatePaymentsRepository implements PaymentsRepository {
  int _callCount = 0;
  int get callCount => _callCount;

  @override
  Future<PaymentResult> processPayment(
    dynamic intent,
    PaymentMethod method,
  ) async {
    _callCount++;
    return const PaymentResult(
      status: PaymentResultStatus.success,
      transactionId: 'txn-immediate',
    );
  }
}

/// Fake orders repo that completes after a controlled delay.
class _DelayedOrdersRepository implements OrdersRepository {
  final Duration delay;
  int _placeOrderCallCount = 0;
  int get placeOrderCallCount => _placeOrderCallCount;

  _DelayedOrdersRepository({this.delay = const Duration(milliseconds: 200)});

  @override
  Future<List<Order>> getOrders() async => [];

  @override
  Future<Order?> getOrder(String id) async => null;

  @override
  Future<Order?> getLatestOrder() async => null;

  @override
  Future<Order> placeOrder(
    OrderDraft draft, {
    required PaymentMethod paymentMethod,
  }) async {
    _placeOrderCallCount++;
    await Future<void>.delayed(delay);
    return Order(
      id: 'order-${_placeOrderCallCount}',
      restaurantId: draft.items.first.item.restaurantId,
      items: draft.items
          .map(
            (line) =>
                OrderItem(menuItemId: line.item.id, quantity: line.quantity),
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

void main() {
  test(
    'double tap does not double fire: placeOrder called once',
    () async {
      final cartRepo = DummyCartRepository();
      cartRepo.addItem(
        const MenuItem(
          id: 'item-1',
          restaurantId: 'rest-1',
          categoryId: 'cat-1',
          name: 'Bowl',
          description: 'Good.',
          price: 10.00,
          tags: [MenuItemTag.quickFilling],
        ),
        1,
      );
      final addressRepo = DummyAddressRepository()
        ..save(
          const Address(
            id: 'addr-1',
            label: AddressLabel.home,
            line1: '215 Riverstone Ave',
            city: 'YYC',
          ),
        );
      final paymentsRepo = _ImmediatePaymentsRepository();
      final ordersRepo = _DelayedOrdersRepository();

      final container = ProviderContainer(
        overrides: [
          cartRepositoryProvider.overrideWithValue(cartRepo),
          addressRepositoryProvider.overrideWithValue(addressRepo),
          ordersRepositoryProvider.overrideWithValue(ordersRepo),
          paymentsRepositoryProvider.overrideWithValue(paymentsRepo),
        ],
      );
      addTearDown(container.dispose);

      final checkoutController = container.read(
        checkoutControllerProvider.notifier,
      );
      container.read(checkoutControllerProvider);

      const method = PaymentMethod(brand: 'Card', last4: '4242');
      const txnId = 'txn-double-tap';

      final first = checkoutController.payAndPlaceOrder(
        paymentMethod: method,
        paymentTransactionId: txnId,
      );
      final second = checkoutController.payAndPlaceOrder(
        paymentMethod: method,
        paymentTransactionId: txnId,
      );

      final results = await Future.wait<Order?>([first, second]);
      final nonNull = results.whereType<Order>().toList();

      expect(nonNull, hasLength(1));
      expect(ordersRepo.placeOrderCallCount, 1);
    },
    skip:
        'payAndPlaceOrder has no single-flight guard; phase10 executeCheckout not in merge',
  );
}

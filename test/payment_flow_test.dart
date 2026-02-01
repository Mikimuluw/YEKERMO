import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/app/di.dart';
import 'package:yekermo/data/repositories/dummy_address_repository.dart';
import 'package:yekermo/data/repositories/dummy_cart_repository.dart';
import 'package:yekermo/data/repositories/dummy_orders_repository.dart';
import 'package:yekermo/data/repositories/dummy_payments_repository.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/payment_method.dart';
import 'package:yekermo/features/checkout/checkout_controller.dart';
import 'package:yekermo/features/payments/payment_controller.dart';

void main() {
  test('payment success places order once', () async {
    final DummyCartRepository cartRepo = DummyCartRepository();
    cartRepo.addItem(
      const MenuItem(
        id: 'item-1',
        restaurantId: 'rest-1',
        categoryId: 'cat-1',
        name: 'Misir Comfort Bowl',
        description: 'Red lentils, warm spices.',
        price: 10.00,
        tags: [MenuItemTag.quickFilling],
      ),
      1,
    );
    final DummyAddressRepository addressRepo = DummyAddressRepository()
      ..save(
        const Address(
          id: 'addr-1',
          label: AddressLabel.home,
          line1: '215 Riverstone Ave',
          city: 'YYC',
        ),
      );
    final DummyOrdersRepository ordersRepo = DummyOrdersRepository();
    final DummyPaymentsRepository paymentsRepo = DummyPaymentsRepository();

    final ProviderContainer container = ProviderContainer(
      overrides: [
        cartRepositoryProvider.overrideWithValue(cartRepo),
        addressRepositoryProvider.overrideWithValue(addressRepo),
        ordersRepositoryProvider.overrideWithValue(ordersRepo),
        paymentsRepositoryProvider.overrideWithValue(paymentsRepo),
      ],
    );
    addTearDown(container.dispose);

    final PaymentController paymentController = container.read(
      paymentControllerProvider.notifier,
    );
    final CheckoutController checkoutController = container.read(
      checkoutControllerProvider.notifier,
    );

    const PaymentMethod method = PaymentMethod(brand: 'Card', last4: '4242');
    final paymentResult = await paymentController.processPayment(
      amount: 10.00,
      method: method,
    );
    expect(paymentResult.isSuccess, isTrue);

    final Order? order = await checkoutController.payAndPlaceOrder(
      paymentMethod: method,
      paymentTransactionId: paymentResult.transactionId,
    );
    expect(order, isNotNull);
    expect(order?.paymentStatus, PaymentStatus.paid);
    expect(order?.status, OrderStatus.preparing);
  });

  test('payment failure then retry creates one order', () async {
    final DummyCartRepository cartRepo = DummyCartRepository();
    cartRepo.addItem(
      const MenuItem(
        id: 'item-1',
        restaurantId: 'rest-1',
        categoryId: 'cat-1',
        name: 'Misir Comfort Bowl',
        description: 'Red lentils, warm spices.',
        price: 10.00,
        tags: [MenuItemTag.quickFilling],
      ),
      1,
    );
    final DummyAddressRepository addressRepo = DummyAddressRepository()
      ..save(
        const Address(
          id: 'addr-1',
          label: AddressLabel.home,
          line1: '215 Riverstone Ave',
          city: 'YYC',
        ),
      );
    final DummyOrdersRepository ordersRepo = DummyOrdersRepository();
    final DummyPaymentsRepository paymentsRepo = DummyPaymentsRepository();

    final ProviderContainer container = ProviderContainer(
      overrides: [
        cartRepositoryProvider.overrideWithValue(cartRepo),
        addressRepositoryProvider.overrideWithValue(addressRepo),
        ordersRepositoryProvider.overrideWithValue(ordersRepo),
        paymentsRepositoryProvider.overrideWithValue(paymentsRepo),
      ],
    );
    addTearDown(container.dispose);

    final PaymentController paymentController = container.read(
      paymentControllerProvider.notifier,
    );
    final CheckoutController checkoutController = container.read(
      checkoutControllerProvider.notifier,
    );

    const PaymentMethod failingMethod = PaymentMethod(
      brand: 'Card',
      last4: '0000',
    );
    final failureResult = await paymentController.processPayment(
      amount: 10.00,
      method: failingMethod,
    );
    expect(failureResult.isSuccess, isFalse);
    expect(await ordersRepo.getOrders(), isEmpty);

    const PaymentMethod method = PaymentMethod(brand: 'Card', last4: '4242');
    final successResult = await paymentController.processPayment(
      amount: 10.00,
      method: method,
    );
    expect(successResult.isSuccess, isTrue);

    final Order? order = await checkoutController.payAndPlaceOrder(
      paymentMethod: method,
      paymentTransactionId: successResult.transactionId,
    );
    expect(order, isNotNull);
    expect(await ordersRepo.getOrders(), hasLength(1));

    final Order? duplicate = await checkoutController.payAndPlaceOrder(
      paymentMethod: method,
      paymentTransactionId: successResult.transactionId,
    );
    expect(duplicate, isNull);
    expect(await ordersRepo.getOrders(), hasLength(1));
  });
}

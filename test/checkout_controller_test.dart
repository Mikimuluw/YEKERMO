import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/app/di.dart';
import 'package:yekermo/data/repositories/dummy_address_repository.dart';
import 'package:yekermo/data/repositories/dummy_cart_repository.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/order_draft.dart';
import 'package:yekermo/features/checkout/checkout_controller.dart';
import 'package:yekermo/shared/state/screen_state.dart';

void main() {
  test('delivery vs pickup updates fees', () {
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

    final ProviderContainer container = ProviderContainer(
      overrides: [
        cartRepositoryProvider.overrideWithValue(cartRepo),
        addressRepositoryProvider.overrideWithValue(addressRepo),
      ],
    );
    addTearDown(container.dispose);

    final CheckoutController controller =
        container.read(checkoutControllerProvider.notifier);

    controller.setFulfillment(FulfillmentMode.delivery);
    final ScreenState<OrderDraft> deliveryState =
        container.read(checkoutControllerProvider);
    final OrderDraft deliveryDraft =
        (deliveryState as SuccessState<OrderDraft>).data;

    controller.setFulfillment(FulfillmentMode.pickup);
    final ScreenState<OrderDraft> pickupState =
        container.read(checkoutControllerProvider);
    final OrderDraft pickupDraft =
        (pickupState as SuccessState<OrderDraft>).data;

    expect(deliveryDraft.fees.deliveryFee, greaterThan(0));
    expect(pickupDraft.fees.deliveryFee, 0);
  });

  test('missing address keeps draft with null address', () {
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
    final DummyAddressRepository addressRepo = DummyAddressRepository();

    final ProviderContainer container = ProviderContainer(
      overrides: [
        cartRepositoryProvider.overrideWithValue(cartRepo),
        addressRepositoryProvider.overrideWithValue(addressRepo),
      ],
    );
    addTearDown(container.dispose);

    final CheckoutController controller =
        container.read(checkoutControllerProvider.notifier);

    controller.setFulfillment(FulfillmentMode.delivery);
    final ScreenState<OrderDraft> state =
        container.read(checkoutControllerProvider);
    expect(state, isA<SuccessState<OrderDraft>>());
    final OrderDraft draft = (state as SuccessState<OrderDraft>).data;
    expect(draft.address, isNull);
  });
}

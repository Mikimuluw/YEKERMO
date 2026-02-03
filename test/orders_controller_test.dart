import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/app/di.dart';
import 'package:yekermo/app/reorder_signal_provider.dart';
import 'package:yekermo/data/repositories/dummy_address_repository.dart';
import 'package:yekermo/data/repositories/dummy_cart_repository.dart';
import 'package:yekermo/data/repositories/dummy_orders_repository.dart';
import 'package:yekermo/data/repositories/restaurant_repository.dart';
import 'package:yekermo/data/result.dart';
import 'package:yekermo/domain/cart.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/payment_method.dart';
import 'package:yekermo/domain/restaurant_menu.dart';
import 'package:yekermo/features/checkout/checkout_controller.dart';
import 'package:yekermo/features/orders/orders_controller.dart';
import 'helpers/fake_reorder_signal_store.dart';

class _TestRestaurantRepository implements RestaurantRepository {
  @override
  Future<Result<RestaurantMenu>> fetchRestaurantMenu(
    String restaurantId,
  ) async {
    return Result.success(
      const RestaurantMenu(
        restaurant: Restaurant(
          id: 'rest-1',
          name: 'Teff & Timber',
          tagline: 'Warm bowls, quick pickup',
          prepTimeBand: PrepTimeBand.fast,
          serviceModes: [ServiceMode.pickup, ServiceMode.delivery],
          tags: [RestaurantTag.quickFilling],
          trustCopy: 'Popular with returning guests',
          dishNames: ['Misir Comfort Bowl'],
        ),
        categories: [MenuCategory(id: 'cat-1', title: 'Bowls')],
        items: [
          MenuItem(
            id: 'item-1',
            restaurantId: 'rest-1',
            categoryId: 'cat-1',
            name: 'Misir Comfort Bowl',
            description: 'Red lentils, warm spices.',
            price: 10.00,
            tags: [MenuItemTag.quickFilling],
          ),
        ],
      ),
    );
  }
}

void main() {
  test('placing an order stores it and clears the cart', () async {
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
      2,
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

    final ProviderContainer container = ProviderContainer(
      overrides: [
        cartRepositoryProvider.overrideWithValue(cartRepo),
        addressRepositoryProvider.overrideWithValue(addressRepo),
        ordersRepositoryProvider.overrideWithValue(ordersRepo),
      ],
    );
    addTearDown(container.dispose);

    final CheckoutController controller = container.read(
      checkoutControllerProvider.notifier,
    );
    controller.setFulfillment(FulfillmentMode.delivery);

    final Order? order = await controller.payAndPlaceOrder(
      paymentMethod: const PaymentMethod(brand: 'Card', last4: '4242'),
      paymentTransactionId: 'txn-1',
    );
    expect(order, isNotNull);

    final List<Order> orders = await ordersRepo.getOrders();
    expect(orders, hasLength(1));
    expect(orders.first.status, OrderStatus.preparing);
    expect(orders.first.placedAt, isNotNull);
    expect(orders.first.paymentStatus, PaymentStatus.paid);
    expect(cartRepo.getItems(), isEmpty);
  });

  test('reorder fills cart and flags missing items', () async {
    final DummyCartRepository cartRepo = DummyCartRepository();
    final ProviderContainer container = ProviderContainer(
      overrides: [
        cartRepositoryProvider.overrideWithValue(cartRepo),
        restaurantRepositoryProvider.overrideWithValue(
          _TestRestaurantRepository(),
        ),
        reorderSignalStoreProvider.overrideWithValue(FakeReorderSignalStore()),
      ],
    );
    addTearDown(container.dispose);

    final OrdersController controller = container.read(
      ordersControllerProvider.notifier,
    );
    const Order order = Order(
      id: 'order-1',
      restaurantId: 'rest-1',
      items: [
        OrderItem(menuItemId: 'item-1', quantity: 2),
        OrderItem(menuItemId: 'item-2', quantity: 1),
      ],
      total: 25.00,
      status: OrderStatus.completed,
      fulfillmentMode: FulfillmentMode.delivery,
      address: null,
      placedAt: null,
      scheduledTime: null,
    );

    final ReorderResult result = await controller.reorder(order);
    final List<CartLineItem> items = cartRepo.getItems();

    expect(result.hasItems, isTrue);
    expect(result.hasMissing, isTrue);
    expect(items, hasLength(1));
    expect(items.first.item.id, 'item-1');
    expect(items.first.quantity, 2);
  });
}

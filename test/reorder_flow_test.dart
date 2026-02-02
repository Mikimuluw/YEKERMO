import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/app/providers.dart';
import 'package:yekermo/app/router.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/data/repositories/dummy_address_repository.dart';
import 'package:yekermo/data/repositories/dummy_cart_repository.dart';
import 'package:yekermo/data/repositories/dummy_orders_repository.dart';
import 'package:yekermo/data/repositories/meals_repository.dart';
import 'package:yekermo/data/repositories/restaurant_repository.dart';
import 'package:yekermo/data/result.dart';
import 'package:yekermo/domain/discovery_filters.dart';
import 'package:yekermo/domain/home_feed.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/restaurant_menu.dart';
import 'package:yekermo/features/orders/order_detail_controller.dart';

class _FlowMealsRepository implements MealsRepository {
  @override
  Future<Result<HomeFeed>> fetchHomeFeed() async {
    return Result.success(
      const HomeFeed(
        customer: Customer(
          id: 'cust-1',
          name: 'Mina',
          primaryAddressId: 'addr-1',
          preference: Preference(
            favoriteCuisines: ['Ethiopian'],
            dietaryTags: ['Family-friendly'],
          ),
        ),
        primaryAddress: Address(
          id: 'addr-1',
          label: AddressLabel.home,
          line1: '215 Riverstone Ave',
          city: 'YYC',
        ),
        pastOrders: [],
        trustedRestaurants: [
          Restaurant(
            id: 'rest-1',
            name: 'Teff & Timber',
            address: '120 King St W, Toronto, ON',
            tagline: 'Warm bowls, quick pickup',
            prepTimeBand: PrepTimeBand.fast,
            serviceModes: [ServiceMode.pickup, ServiceMode.delivery],
            tags: [RestaurantTag.quickFilling],
            trustCopy: 'Popular with returning guests',
            dishNames: ['Misir Comfort Bowl'],
          ),
        ],
        allRestaurants: [
          Restaurant(
            id: 'rest-1',
            name: 'Teff & Timber',
            address: '120 King St W, Toronto, ON',
            tagline: 'Warm bowls, quick pickup',
            prepTimeBand: PrepTimeBand.fast,
            serviceModes: [ServiceMode.pickup, ServiceMode.delivery],
            tags: [RestaurantTag.quickFilling],
            trustCopy: 'Popular with returning guests',
            dishNames: ['Misir Comfort Bowl'],
          ),
        ],
      ),
    );
  }

  @override
  Future<Result<List<Restaurant>>> fetchDiscovery({
    DiscoveryFilters? filters,
    String? query,
  }) async {
    return Result.success(const []);
  }
}

class _FlowRestaurantRepository implements RestaurantRepository {
  @override
  Future<Result<RestaurantMenu>> fetchRestaurantMenu(
    String restaurantId,
  ) async {
    return Result.success(
      const RestaurantMenu(
        restaurant: Restaurant(
          id: 'rest-1',
          name: 'Teff & Timber',
          address: '120 King St W, Toronto, ON',
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
  testWidgets('Place order flow updates confirmation and home', (tester) async {
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cartRepositoryProvider.overrideWithValue(cartRepo),
          addressRepositoryProvider.overrideWithValue(addressRepo),
          ordersRepositoryProvider.overrideWithValue(ordersRepo),
          mealsRepositoryProvider.overrideWithValue(_FlowMealsRepository()),
          restaurantRepositoryProvider.overrideWithValue(
            _FlowRestaurantRepository(),
          ),
          orderDetailsQueryProvider.overrideWithValue(
            const OrderDetailsQuery(orderId: 'order-1'),
          ),
        ],
        child: MaterialApp.router(routerConfig: appRouter),
      ),
    );

    appRouter.go(Routes.cart);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Review order'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Payment'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    final Finder cardNumberField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.hintText == 'Card number',
    );
    final Finder expiryField = find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.hintText == 'MM/YY',
    );
    final Finder cvcField = find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.hintText == 'CVC',
    );

    await tester.scrollUntilVisible(
      cardNumberField,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(cardNumberField, '4242 4242 4242 4242');
    await tester.enterText(expiryField, '12/30');
    await tester.enterText(cvcField, '123');

    await tester.scrollUntilVisible(
      find.text('Pay and place order'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Pay and place order'));
    await tester.pumpAndSettle();

    expect(find.text('Order confirmed.'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Back to home'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Back to home'));
    await tester.pumpAndSettle();
    appRouter.go(Routes.home);
    await tester.pumpAndSettle();

    expect(find.text('Your usual'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('Teff & Timber', skipOffstage: false), findsWidgets);
  });
}

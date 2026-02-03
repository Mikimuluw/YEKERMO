import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/app/di.dart';
import 'package:yekermo/app/router.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/data/repositories/cart_repository.dart';
import 'package:yekermo/data/repositories/dummy_cart_repository.dart';
import 'package:yekermo/data/repositories/meals_repository.dart';
import 'package:yekermo/data/repositories/restaurant_repository.dart';
import 'package:yekermo/data/result.dart';
import 'package:yekermo/domain/discovery_filters.dart';
import 'package:yekermo/domain/home_feed.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/user_preferences.dart';
import 'package:yekermo/domain/restaurant_menu.dart';
import 'package:yekermo/features/discovery/discovery_controller.dart';
import 'package:yekermo/features/home/home_controller.dart';
import 'package:yekermo/features/restaurant/restaurant_controller.dart';
import 'package:yekermo/shared/state/screen_state.dart';

class _FastMealsRepository implements MealsRepository {
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
        pastOrders: [
          Order(
            id: 'order-1',
            restaurantId: 'rest-1',
            items: [OrderItem(menuItemId: 'item-1', quantity: 2)],
            total: 28.50,
            status: OrderStatus.completed,
            fulfillmentMode: FulfillmentMode.delivery,
            address: null,
            placedAt: null,
          ),
        ],
        trustedRestaurants: [
          Restaurant(
            id: 'rest-1',
            name: 'Teff & Timber',
            tagline: 'Warm bowls, quick pickup',
            prepTimeBand: PrepTimeBand.fast,
            serviceModes: [ServiceMode.pickup, ServiceMode.delivery],
            tags: [RestaurantTag.quickFilling, RestaurantTag.pickupFriendly],
            trustCopy: 'Popular with returning guests',
            dishNames: ['Misir Comfort Bowl'],
          ),
        ],
        allRestaurants: [],
      ),
    );
  }

  @override
  Future<Result<List<Restaurant>>> fetchDiscovery({
    DiscoveryFilters? filters,
    String? query,
    required UserPreferences preferences,
    Map<String, int> reorderCountByRestaurant = const {},
    bool enableReorderPersonalization = true,
  }) async {
    return Result.success(const [
      Restaurant(
        id: 'rest-1',
        name: 'Teff & Timber',
        tagline: 'Warm bowls, quick pickup',
        prepTimeBand: PrepTimeBand.fast,
        serviceModes: [ServiceMode.pickup, ServiceMode.delivery],
        tags: [RestaurantTag.quickFilling, RestaurantTag.pickupFriendly],
        trustCopy: 'Popular with returning guests',
        dishNames: ['Misir Comfort Bowl'],
      ),
    ]);
  }
}

class _FastRestaurantRepository implements RestaurantRepository {
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
          tags: [RestaurantTag.quickFilling, RestaurantTag.pickupFriendly],
          trustCopy: 'Popular with returning guests',
          dishNames: ['Misir Comfort Bowl'],
        ),
        categories: [MenuCategory(id: 'cat-1', title: 'Comfort bowls')],
        items: [
          MenuItem(
            id: 'item-1',
            restaurantId: 'rest-1',
            categoryId: 'cat-1',
            name: 'Misir Comfort Bowl',
            description: 'Red lentils, warm spices, citrus finish.',
            price: 14.25,
            tags: [MenuItemTag.quickFilling],
          ),
        ],
      ),
    );
  }
}

class _StaticHomeController extends HomeController {
  _StaticHomeController(this.feed);

  final HomeFeed feed;

  @override
  ScreenState<HomeFeed> build() {
    return ScreenState.success(feed);
  }
}

void main() {
  testWidgets('Discovery to cart badge flow', (tester) async {
    final CartRepository cartRepo = DummyCartRepository();
    const HomeFeed feed = HomeFeed(
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
      trustedRestaurants: [],
      allRestaurants: [],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mealsRepositoryProvider.overrideWithValue(_FastMealsRepository()),
          restaurantRepositoryProvider.overrideWithValue(
            _FastRestaurantRepository(),
          ),
          cartRepositoryProvider.overrideWithValue(cartRepo),
          discoveryQueryProvider.overrideWithValue(
            const DiscoveryQuery(
              filters: DiscoveryFilters(intent: 'quick_filling'),
            ),
          ),
          restaurantQueryProvider.overrideWithValue(
            const RestaurantQuery(restaurantId: 'rest-1'),
          ),
          homeControllerProvider.overrideWith(
            () => _StaticHomeController(feed),
          ),
        ],
        child: MaterialApp.router(routerConfig: appRouter),
      ),
    );

    Future<void> settle() async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    appRouter.go(Routes.discoveryWithFilters(intent: 'quick_filling'));
    await settle();

    await tester.tap(find.text('Teff & Timber'));
    await settle();

    await tester.tap(find.text('Misir Comfort Bowl').first);
    await settle();

    await tester.tap(find.text('Add to cart'));
    await settle();

    final Finder badge = find.byKey(const ValueKey('cart_badge'));
    expect(badge, findsOneWidget);
    expect(
      find.descendant(of: badge, matching: find.text('2')),
      findsOneWidget,
    );
  });
}

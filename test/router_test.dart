import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/app/di.dart';
import 'package:yekermo/app/providers.dart';
import 'package:yekermo/app/router.dart';
import 'package:yekermo/app/routes.dart';
import 'helpers/fake_welcome_storage.dart';
import 'package:yekermo/data/repositories/meals_repository.dart';
import 'package:yekermo/data/repositories/restaurant_repository.dart';
import 'package:yekermo/data/result.dart';
import 'package:yekermo/domain/discovery_filters.dart';
import 'package:yekermo/domain/home_feed.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/restaurant_menu.dart';
import 'package:yekermo/domain/user_preferences.dart';
import 'package:yekermo/features/home/home_controller.dart';
import 'package:yekermo/features/restaurant/restaurant_controller.dart';
import 'package:yekermo/shared/state/screen_state.dart';
import 'package:yekermo/shared/widgets/app_text_field.dart';
import 'support/test_fixtures.dart';

class _FastMealsRepository implements MealsRepository {
  const _FastMealsRepository();

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
            tagline: 'Warm bowls, quick pickup',
            prepTimeBand: PrepTimeBand.fast,
            serviceModes: [ServiceMode.pickup, ServiceMode.delivery],
            tags: [RestaurantTag.quickFilling, RestaurantTag.pickupFriendly],
            trustCopy: 'Popular with returning guests',
            dishNames: ['Misir Comfort Bowl'],
            address: kTestRestaurantAddress,
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
    return Result.success(const []);
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
          address: kTestRestaurantAddress,
        ),
        categories: [MenuCategory(id: 'cat-1', title: 'Comfort bowls')],
        items: [
          MenuItem(
            id: 'item-1',
            restaurantId: 'rest-1',
            categoryId: 'cat-1',
            name: 'Misir Comfort Bowl',
            description: 'Red lentils, warm spices.',
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
  testWidgets('Tab navigation preserves branch history', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          welcomeStorageProvider.overrideWithValue(FakeWelcomeStorage()),
          mealsRepositoryProvider.overrideWithValue(
            const _FastMealsRepository(),
          ),
          restaurantRepositoryProvider.overrideWithValue(
            _FastRestaurantRepository(),
          ),
          restaurantQueryProvider.overrideWithValue(
            const RestaurantQuery(restaurantId: 'rest-1'),
          ),
          homeControllerProvider.overrideWith(
            () => _StaticHomeController(
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
                    tagline: 'Warm bowls, quick pickup',
                    prepTimeBand: PrepTimeBand.fast,
                    serviceModes: [ServiceMode.pickup, ServiceMode.delivery],
                    tags: [
                      RestaurantTag.quickFilling,
                      RestaurantTag.pickupFriendly,
                    ],
                    trustCopy: 'Popular with returning guests',
                    dishNames: ['Misir Comfort Bowl'],
                    address: kTestRestaurantAddress,
                  ),
                ],
                allRestaurants: [],
              ),
            ),
          ),
        ],
        child: MaterialApp.router(routerConfig: appRouter),
      ),
    );

    appRouter.go(Routes.home);
    await tester.pumpAndSettle();

    appRouter.go(Routes.restaurantDetails('rest-1'));
    await tester.pumpAndSettle();
    expect(find.text('Menu'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.search_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(AppTextField), findsOneWidget);

    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Menu'), findsOneWidget);
  });
}

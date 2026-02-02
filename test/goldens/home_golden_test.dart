import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/app/di.dart';
import 'package:yekermo/data/repositories/meals_repository.dart';
import 'package:yekermo/data/result.dart';
import 'package:yekermo/domain/discovery_filters.dart';
import 'package:yekermo/domain/home_feed.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/features/home/home_controller.dart';
import 'package:yekermo/features/home/home_screen.dart';
import 'package:yekermo/shared/state/screen_state.dart';
import '../support/test_fixtures.dart';

class _GoldenMealsRepository implements MealsRepository {
  const _GoldenMealsRepository();

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
            items: [OrderItem(menuItemId: 'item-1', quantity: 1)],
            total: 21.75,
            status: OrderStatus.completed,
            fulfillmentMode: FulfillmentMode.delivery,
            address: null,
            placedAt: null,
            scheduledTime: null,
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
            address: kTestRestaurantAddress,
          ),
        ],
        allRestaurants: [
          Restaurant(
            id: 'rest-2',
            name: 'Meskela Kitchen',
            tagline: 'Slow-simmered classics',
            prepTimeBand: PrepTimeBand.standard,
            serviceModes: [ServiceMode.delivery],
            tags: [RestaurantTag.familySize],
            trustCopy: 'Family-size favorites',
            dishNames: ['Family Feast Platter'],
            address: kTestRestaurantAddress,
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

class _StaticHomeController extends HomeController {
  _StaticHomeController(this.feed);

  final HomeFeed feed;

  @override
  ScreenState<HomeFeed> build() {
    return ScreenState.success(feed);
  }
}

void main() {
  testWidgets('Home signature layout golden', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mealsRepositoryProvider.overrideWithValue(
            const _GoldenMealsRepository(),
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
                pastOrders: [
                  Order(
                    id: 'order-1',
                    restaurantId: 'rest-1',
                    items: [OrderItem(menuItemId: 'item-1', quantity: 1)],
                    total: 21.75,
                    status: OrderStatus.completed,
                    fulfillmentMode: FulfillmentMode.delivery,
                    address: null,
                    placedAt: null,
                    scheduledTime: null,
                  ),
                ],
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
                allRestaurants: [
                  Restaurant(
                    id: 'rest-2',
                    name: 'Meskela Kitchen',
                    tagline: 'Slow-simmered classics',
                    prepTimeBand: PrepTimeBand.standard,
                    serviceModes: [ServiceMode.delivery],
                    tags: [RestaurantTag.familySize],
                    trustCopy: 'Family-size favorites',
                    dishNames: ['Family Feast Platter'],
                    address: kTestRestaurantAddress,
                  ),
                ],
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/home.png'),
    );
  }, skip: true);
}

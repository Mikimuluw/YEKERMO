import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/app/di.dart';
import 'package:yekermo/data/repositories/meals_repository.dart';
import 'package:yekermo/data/result.dart';
import 'package:yekermo/domain/discovery_filters.dart';
import 'package:yekermo/domain/home_feed.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/user_preferences.dart';
import 'package:yekermo/features/home/home_controller.dart';
import 'package:yekermo/features/home/home_screen.dart';
import 'package:yekermo/shared/state/screen_state.dart';

class _FakeMealsRepository implements MealsRepository {
  _FakeMealsRepository(this.feed);

  final HomeFeed feed;

  @override
  Future<Result<HomeFeed>> fetchHomeFeed() async {
    return Result.success(feed);
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

class _StaticHomeController extends HomeController {
  _StaticHomeController(this.feed);

  final HomeFeed feed;

  @override
  ScreenState<HomeFeed> build() {
    return ScreenState.success(feed);
  }
}

void main() {
  testWidgets('Home renders core sections', (tester) async {
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
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mealsRepositoryProvider.overrideWithValue(_FakeMealsRepository(feed)),
          homeControllerProvider.overrideWith(
            () => _StaticHomeController(feed),
          ),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Good evening, Mina'), findsOneWidget);
    expect(find.text('Your usual'), findsOneWidget);
    expect(
      find.byType(RestaurantSection, skipOffstage: false),
      findsAtLeastNWidgets(1),
    );
    expect(
      find.byType(RestaurantCard, skipOffstage: false),
      findsAtLeastNWidgets(1),
    );
  });
}

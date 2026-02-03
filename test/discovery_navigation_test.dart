import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/app/di.dart';
import 'package:yekermo/app/router.dart';
import 'package:yekermo/data/repositories/meals_repository.dart';
import 'package:yekermo/data/result.dart';
import 'package:yekermo/domain/discovery_filters.dart';
import 'package:yekermo/domain/failure.dart';
import 'package:yekermo/domain/home_feed.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/user_preferences.dart';
import 'package:yekermo/features/discovery/discovery_controller.dart';
import 'package:yekermo/features/home/home_controller.dart';
import 'package:yekermo/shared/state/screen_state.dart';

class _StaticHomeController extends HomeController {
  _StaticHomeController(this.feed);

  final HomeFeed feed;

  @override
  ScreenState<HomeFeed> build() {
    return ScreenState.success(feed);
  }
}

class _DiscoveryMealsRepository implements MealsRepository {
  @override
  Future<Result<HomeFeed>> fetchHomeFeed() async {
    return Result.failure(const Failure('unused'));
  }

  @override
  Future<Result<List<Restaurant>>> fetchDiscovery({
    DiscoveryFilters? filters,
    String? query,
    required UserPreferences preferences,
  }) async {
    return Result.success(const [
      Restaurant(
        id: 'rest-1',
        name: 'Teff & Timber',
        tagline: 'Warm bowls, quick pickup',
        prepTimeBand: PrepTimeBand.fast,
        serviceModes: [ServiceMode.pickup, ServiceMode.delivery],
        tags: [RestaurantTag.quickFilling],
        trustCopy: 'Popular with returning guests',
        dishNames: ['Misir Comfort Bowl'],
      ),
    ]);
  }
}

void main() {
  testWidgets('Intent chip routes to discovery', (tester) async {
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
      trustedRestaurants: [
        Restaurant(
          id: 'rest-1',
          name: 'Teff & Timber',
          tagline: 'Warm bowls, quick pickup',
          prepTimeBand: PrepTimeBand.fast,
          serviceModes: [ServiceMode.pickup, ServiceMode.delivery],
          tags: [RestaurantTag.quickFilling],
          trustCopy: 'Popular with returning guests',
          dishNames: ['Misir Comfort Bowl'],
        ),
      ],
      allRestaurants: [],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mealsRepositoryProvider.overrideWithValue(
            _DiscoveryMealsRepository(),
          ),
          homeControllerProvider.overrideWith(
            () => _StaticHomeController(feed),
          ),
          discoveryQueryProvider.overrideWithValue(
            const DiscoveryQuery(
              filters: DiscoveryFilters(intent: 'quick_filling'),
            ),
          ),
        ],
        child: MaterialApp.router(routerConfig: appRouter),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Quick & filling'));
    await tester.pumpAndSettle();

    expect(find.text('Discovery'), findsOneWidget);
  });
}

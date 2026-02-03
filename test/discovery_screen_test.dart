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
import 'package:yekermo/features/discovery/discovery_controller.dart';
import 'package:yekermo/features/discovery/discovery_screen.dart';

class _DiscoveryMealsRepository implements MealsRepository {
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
        trustedRestaurants: [],
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
  testWidgets('Discovery renders restaurants', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mealsRepositoryProvider.overrideWithValue(
            _DiscoveryMealsRepository(),
          ),
          discoveryQueryProvider.overrideWithValue(
            const DiscoveryQuery(filters: DiscoveryFilters()),
          ),
        ],
        child: const MaterialApp(home: DiscoveryScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Teff & Timber'), findsOneWidget);
    expect(find.text('Discovery'), findsOneWidget);
  });
}

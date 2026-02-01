import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/app/di.dart';
import 'package:yekermo/app/router.dart';
import 'package:yekermo/data/repositories/meals_repository.dart';
import 'package:yekermo/data/result.dart';
import 'package:yekermo/domain/discovery_filters.dart';
import 'package:yekermo/domain/home_feed.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/features/home/home_controller.dart';
import 'package:yekermo/shared/state/screen_state.dart';

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
        trustedRestaurants: [],
        allRestaurants: [],
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
  testWidgets('Unknown route shows NotFound', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mealsRepositoryProvider.overrideWithValue(
            const _FastMealsRepository(),
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
                trustedRestaurants: [],
                allRestaurants: [],
              ),
            ),
          ),
        ],
        child: MaterialApp.router(routerConfig: appRouter),
      ),
    );

    appRouter.go('/unknown');
    await tester.pumpAndSettle();

    expect(find.text('Not found'), findsOneWidget);
  });
}

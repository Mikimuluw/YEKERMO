import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/app/di.dart';
import 'package:yekermo/app/providers.dart';
import 'package:yekermo/app/router.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/data/repositories/meals_repository.dart';
import 'package:yekermo/data/result.dart';
import 'package:yekermo/domain/discovery_filters.dart';
import 'package:yekermo/domain/home_feed.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/user_preferences.dart';
import 'package:yekermo/features/common/welcome_screen.dart';
import 'package:yekermo/features/home/home_controller.dart';
import 'package:yekermo/shared/state/screen_state.dart';
import 'helpers/fake_welcome_storage.dart';

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
  ScreenState<HomeFeed> build() => ScreenState.success(feed);
}

void main() {
  testWidgets('Welcome screen shows app name, value copy, and Continue', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          welcomeStorageProvider.overrideWithValue(
            FakeWelcomeStorage(seen: false),
          ),
        ],
        child: MaterialApp.router(routerConfig: appRouter),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(WelcomeScreen.appName), findsOneWidget);
    expect(find.text(WelcomeScreen.valueCopy), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Continue'), findsOneWidget);
  });

  testWidgets('Continue marks seen and navigates to home', (tester) async {
    final storage = FakeWelcomeStorage(seen: false);
    const feed = HomeFeed(
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
          welcomeStorageProvider.overrideWithValue(storage),
          mealsRepositoryProvider.overrideWithValue(
            const _FastMealsRepository(),
          ),
          homeControllerProvider.overrideWith(
            () => _StaticHomeController(feed),
          ),
        ],
        child: MaterialApp.router(routerConfig: appRouter),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(await storage.hasSeen(), isTrue);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/app/di.dart';
import 'package:yekermo/data/datasources/dummy_meals_datasource.dart';
import 'package:yekermo/data/repositories/dummy_meals_repository.dart';
import 'package:yekermo/data/repositories/meals_repository.dart';
import 'package:yekermo/data/result.dart';
import 'package:yekermo/domain/discovery_filters.dart';
import 'package:yekermo/domain/failure.dart';
import 'package:yekermo/domain/home_feed.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/user_preferences.dart';
import 'package:yekermo/shared/state/screen_state.dart';

class _EmptyMealsRepository implements MealsRepository {
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

class _FailureMealsRepository implements MealsRepository {
  @override
  Future<Result<HomeFeed>> fetchHomeFeed() async {
    return Result.failure(const Failure('Boom'));
  }

  @override
  Future<Result<List<Restaurant>>> fetchDiscovery({
    DiscoveryFilters? filters,
    String? query,
    required UserPreferences preferences,
    Map<String, int> reorderCountByRestaurant = const {},
    bool enableReorderPersonalization = true,
  }) async {
    return Result.failure(const Failure('Boom'));
  }
}

void main() {
  test('maps DTO to domain', () async {
    const DummyMealsRepository repo = DummyMealsRepository(
      DummyMealsDataSource(),
    );
    final Result<HomeFeed> result = await repo.fetchHomeFeed();

    expect(result, isA<Success<HomeFeed>>());
    final HomeFeed data = (result as Success<HomeFeed>).data;
    expect(data.customer.name, 'Mina');
    expect(data.primaryAddress.id, data.customer.primaryAddressId);
    expect(data.trustedRestaurants, isNotEmpty);
    expect(data.trustedRestaurants.first.prepTimeBand, isNotNull);
    expect(data.trustedRestaurants.first.serviceModes, isNotEmpty);
    expect(data.trustedRestaurants.first.trustCopy, isNotEmpty);
  });

  test('empty list returns ScreenState.empty', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        mealsRepositoryProvider.overrideWithValue(_EmptyMealsRepository()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(homeControllerProvider.notifier).load();

    final ScreenState<HomeFeed> state = container.read(homeControllerProvider);
    expect(state, isA<EmptyState<HomeFeed>>());
  });

  test('exceptions become ScreenState.error', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        mealsRepositoryProvider.overrideWithValue(_FailureMealsRepository()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(homeControllerProvider.notifier).load();

    final ScreenState<HomeFeed> state = container.read(homeControllerProvider);
    expect(state, isA<ErrorState<HomeFeed>>());
  });

  test('filters return expected subset', () async {
    const DummyMealsRepository repo = DummyMealsRepository(
      DummyMealsDataSource(),
    );
    final Result<List<Restaurant>> result = await repo.fetchDiscovery(
      filters: const DiscoveryFilters(pickupFriendly: true),
      preferences: UserPreferences.defaults,
    );

    expect(result, isA<Success<List<Restaurant>>>());
    final List<Restaurant> data = (result as Success<List<Restaurant>>).data;
    expect(
      data.every((r) => r.tags.contains(RestaurantTag.pickupFriendly)),
      isTrue,
    );
  });
}

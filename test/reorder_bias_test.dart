import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/data/datasources/dummy_meals_datasource.dart';
import 'package:yekermo/data/repositories/dummy_meals_repository.dart';
import 'package:yekermo/data/result.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/user_preferences.dart';

/// Reorder score only applies when count >= 2.
void main() {
  late DummyMealsRepository repo;

  setUp(() {
    repo = DummyMealsRepository(DummyMealsDataSource());
  });

  test('count 0 and 1 give no reorder boost', () async {
    final Result<List<Restaurant>> result0 = await repo.fetchDiscovery(
      filters: null,
      query: null,
      preferences: UserPreferences.defaults,
      reorderCountByRestaurant: {'r_any': 0},
    );
    final Result<List<Restaurant>> result1 = await repo.fetchDiscovery(
      filters: null,
      query: null,
      preferences: UserPreferences.defaults,
      reorderCountByRestaurant: {'r_any': 1},
    );

    expect(result0, isA<Success<List<Restaurant>>>());
    expect(result1, isA<Success<List<Restaurant>>>());

    final List<Restaurant> list0 = (result0 as Success<List<Restaurant>>).data;
    final List<Restaurant> list1 = (result1 as Success<List<Restaurant>>).data;

    expect(list0.map((r) => r.id).toList(), list1.map((r) => r.id).toList(),
        reason: 'Order must be identical when count 0 vs 1 (no boost)');
  });

  test('count 2 gives reorder boost so that restaurant rises', () async {
    final Result<List<Restaurant>> resultNoBoost = await repo.fetchDiscovery(
      filters: null,
      query: null,
      preferences: UserPreferences.defaults,
      reorderCountByRestaurant: {},
    );
    expect(resultNoBoost, isA<Success<List<Restaurant>>>());
    final List<Restaurant> baseOrder =
        (resultNoBoost as Success<List<Restaurant>>).data;
    if (baseOrder.length < 2) return;

    final String lastId = baseOrder.last.id;
    final Result<List<Restaurant>> resultBoost = await repo.fetchDiscovery(
      filters: null,
      query: null,
      preferences: UserPreferences.defaults,
      reorderCountByRestaurant: {lastId: 2},
    );
    expect(resultBoost, isA<Success<List<Restaurant>>>());
    final List<Restaurant> boostOrder =
        (resultBoost as Success<List<Restaurant>>).data;

    expect(boostOrder.first.id, lastId,
        reason: 'Restaurant with count 2 should be first');
  });
}

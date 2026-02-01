import 'dart:async';

import 'package:yekermo/data/datasources/dummy_search_datasource.dart';
import 'package:yekermo/data/repositories/search_repository.dart';
import 'package:yekermo/data/result.dart';
import 'package:yekermo/domain/discovery_filters.dart';
import 'package:yekermo/domain/failure.dart';
import 'package:yekermo/domain/models.dart';

class DummySearchRepository implements SearchRepository {
  const DummySearchRepository(this.dataSource);

  final DummySearchDataSource dataSource;

  @override
  Future<Result<List<Restaurant>>> search({
    String? query,
    DiscoveryFilters? filters,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 280));
    try {
      final results = dataSource
          .search(query)
          .map((dto) => dto.toModel())
          .toList();
      final List<Restaurant> filtered = _applyFilters(results, filters);
      return Result.success(filtered);
    } catch (error) {
      return Result.failure(const Failure('Search is unavailable right now.'));
    }
  }

  List<Restaurant> _applyFilters(
    List<Restaurant> restaurants,
    DiscoveryFilters? filters,
  ) {
    if (filters == null || !filters.hasAny) {
      return restaurants;
    }
    RestaurantTag? intentTag;
    if (filters.intent == 'quick_filling') {
      intentTag = RestaurantTag.quickFilling;
    }
    return restaurants.where((restaurant) {
      if (intentTag != null && !restaurant.tags.contains(intentTag)) {
        return false;
      }
      if (filters.pickupFriendly &&
          !restaurant.tags.contains(RestaurantTag.pickupFriendly)) {
        return false;
      }
      if (filters.familySize &&
          !restaurant.tags.contains(RestaurantTag.familySize)) {
        return false;
      }
      if (filters.fastingFriendly &&
          !restaurant.tags.contains(RestaurantTag.fastingFriendly)) {
        return false;
      }
      return true;
    }).toList();
  }
}

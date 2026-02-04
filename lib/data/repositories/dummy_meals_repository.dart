import 'dart:async';

import 'package:yekermo/core/ranking/preference_scoring.dart';
import 'package:yekermo/core/ranking/reorder_personalization.dart';
import 'package:yekermo/data/datasources/dummy_meals_datasource.dart';
import 'package:yekermo/data/dto/home_feed_dto.dart';
import 'package:yekermo/data/repositories/meals_repository.dart';
import 'package:yekermo/data/result.dart';
import 'package:yekermo/domain/discovery_filters.dart';
import 'package:yekermo/domain/failure.dart';
import 'package:yekermo/domain/home_feed.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/user_preferences.dart';

class DummyMealsRepository implements MealsRepository {
  const DummyMealsRepository(this.dataSource);

  final DummyMealsDataSource dataSource;

  @override
  Future<Result<HomeFeed>> fetchHomeFeed() async {
    await Future<void>.delayed(const Duration(milliseconds: 320));
    try {
      final HomeFeedDto dto = dataSource.fetchHomeFeed();
      final primaryAddress = dto.addresses.firstWhere(
        (item) => item.id == dto.customer.primaryAddressId,
      );
      final List<Restaurant> allRestaurants = [
        ...dto.trustedRestaurants.map((item) => item.toModel()),
        ...dto.allRestaurants.map((item) => item.toModel()),
      ];
      final DateTime now = DateTime.now();
      final List<Restaurant> trustedRestaurants = _computeTrustedSubset(
        allRestaurants,
        now,
      );
      final List<Restaurant> orderedAll = _applyWeatherBias(
        allRestaurants,
        now,
      );
      return Result.success(
        HomeFeed(
          customer: dto.customer.toModel(),
          primaryAddress: primaryAddress.toModel(),
          pastOrders: dto.pastOrders.map((item) => item.toModel()).toList(),
          trustedRestaurants: trustedRestaurants,
          allRestaurants: orderedAll,
        ),
      );
    } catch (error) {
      return Result.failure(const Failure('Unable to load home feed.'));
    }
  }

  @override
  Future<Result<List<Restaurant>>> fetchDiscovery({
    DiscoveryFilters? filters,
    String? query,
    required UserPreferences preferences,
    Map<String, int> reorderCountByRestaurant = const {},
    bool enableReorderPersonalization = true,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 320));
    try {
      final HomeFeedDto dto = dataSource.fetchHomeFeed();
      final List<Restaurant> allRestaurants = [
        ...dto.trustedRestaurants.map((item) => item.toModel()),
        ...dto.allRestaurants.map((item) => item.toModel()),
      ];
      final DateTime now = DateTime.now();
      final List<Restaurant> filtered = _applyFilters(
        allRestaurants,
        filters,
        query,
      );
      final List<Restaurant> adjusted = _applyBehavioralCopy(filtered, now);
      final List<Restaurant> weatherBiased = _applyWeatherBias(adjusted, now);
      final List<Restaurant> preferenceOrdered = _applyPreferenceOrdering(
        weatherBiased,
        preferences,
        reorderCountByRestaurant,
        enableReorderPersonalization,
      );
      return Result.success(preferenceOrdered);
    } catch (error) {
      return Result.failure(const Failure('Unable to load discovery.'));
    }
  }

  /// Stable sort by preference + reorder score (higher first); reorder only if count >= 2 and enabled.
  List<Restaurant> _applyPreferenceOrdering(
    List<Restaurant> restaurants,
    UserPreferences preferences,
    Map<String, int> reorderCountByRestaurant,
    bool enableReorderPersonalization,
  ) {
    final List<(Restaurant, int)> withScores = restaurants.map((r) {
      final prefScore = preferenceScore(
        prefs: preferences,
        supportsPickup: r.serviceModes.contains(ServiceMode.pickup),
        isFastingFriendly: r.tags.contains(RestaurantTag.fastingFriendly),
        isVegetarian: false,
      );
      final count = reorderCountByRestaurant[r.id] ?? 0;
      final reordScore = enableReorderPersonalization ? reorderScore(count) : 0;
      return (r, prefScore + reordScore);
    }).toList();
    withScores.sort((a, b) => b.$2.compareTo(a.$2));
    return withScores.map((e) => e.$1).toList();
  }

  List<Restaurant> _applyFilters(
    List<Restaurant> restaurants,
    DiscoveryFilters? filters,
    String? query,
  ) {
    final String normalized = (query ?? '').trim().toLowerCase();
    RestaurantTag? intentTag;
    if (filters?.intent == 'quick_filling') {
      intentTag = RestaurantTag.quickFilling;
    }
    return restaurants.where((restaurant) {
      if (normalized.isNotEmpty) {
        final bool matchesQuery =
            restaurant.name.toLowerCase().contains(normalized) ||
            restaurant.tagline.toLowerCase().contains(normalized) ||
            restaurant.dishNames.any(
              (dish) => dish.toLowerCase().contains(normalized),
            );
        if (!matchesQuery) return false;
      }
      if (intentTag != null && !restaurant.tags.contains(intentTag)) {
        return false;
      }
      if (filters?.pickupFriendly == true &&
          !restaurant.tags.contains(RestaurantTag.pickupFriendly)) {
        return false;
      }
      if (filters?.familySize == true &&
          !restaurant.tags.contains(RestaurantTag.familySize)) {
        return false;
      }
      if (filters?.fastingFriendly == true &&
          !restaurant.tags.contains(RestaurantTag.fastingFriendly)) {
        return false;
      }
      return true;
    }).toList();
  }

  List<Restaurant> _computeTrustedSubset(
    List<Restaurant> restaurants,
    DateTime now,
  ) {
    final bool isPeak = _isPeakHour(now);
    final RestaurantTag preferredTag = isPeak
        ? RestaurantTag.pickupFriendly
        : RestaurantTag.quickFilling;
    final List<Restaurant> preferred = restaurants
        .where((item) => item.tags.contains(preferredTag))
        .toList();
    if (preferred.isNotEmpty) {
      return preferred.take(2).toList();
    }
    return restaurants.take(2).toList();
  }

  List<Restaurant> _applyBehavioralCopy(
    List<Restaurant> restaurants,
    DateTime now,
  ) {
    final bool isPeak = _isPeakHour(now);
    final bool deliveryTight = _isDeliveryTight(now);
    return restaurants.map((restaurant) {
      String trustCopy = restaurant.trustCopy;
      if (isPeak) {
        trustCopy = 'Busy right now';
      }
      if (deliveryTight &&
          restaurant.serviceModes.contains(ServiceMode.pickup)) {
        trustCopy = 'Pickup stays quicker right now';
      }
      return Restaurant(
        id: restaurant.id,
        name: restaurant.name,
        address: restaurant.address,
        tagline: restaurant.tagline,
        prepTimeBand: restaurant.prepTimeBand,
        serviceModes: restaurant.serviceModes,
        tags: restaurant.tags,
        trustCopy: trustCopy,
        dishNames: restaurant.dishNames,
      );
    }).toList();
  }

  List<Restaurant> _applyWeatherBias(
    List<Restaurant> restaurants,
    DateTime now,
  ) {
    final bool coldSeason = now.month >= 11 || now.month <= 3;
    if (!coldSeason) return restaurants;
    final List<Restaurant> filling = restaurants
        .where((item) => item.tags.contains(RestaurantTag.quickFilling))
        .toList();
    final List<Restaurant> others = restaurants
        .where((item) => !item.tags.contains(RestaurantTag.quickFilling))
        .toList();
    return [...filling, ...others];
  }

  bool _isPeakHour(DateTime now) {
    final int hour = now.hour;
    return (hour >= 11 && hour <= 13) || (hour >= 17 && hour <= 19);
  }

  bool _isDeliveryTight(DateTime now) {
    final int hour = now.hour;
    return hour >= 17 && hour <= 20;
  }
}

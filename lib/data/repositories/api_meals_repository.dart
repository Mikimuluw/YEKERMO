import 'dart:async';

import 'package:yekermo/core/ranking/preference_scoring.dart';
import 'package:yekermo/core/ranking/reorder_personalization.dart';
import 'package:yekermo/core/transport/transport_client.dart';
import 'package:yekermo/data/dto/address_dto.dart';
import 'package:yekermo/data/dto/customer_dto.dart';
import 'package:yekermo/data/dto/restaurant_dto.dart';
import 'package:yekermo/data/repositories/meals_repository.dart';
import 'package:yekermo/data/result.dart';
import 'package:yekermo/domain/discovery_filters.dart';
import 'package:yekermo/domain/failure.dart';
import 'package:yekermo/domain/home_feed.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/user_preferences.dart';

class ApiMealsRepository implements MealsRepository {
  ApiMealsRepository(this.transportClient);

  final TransportClient transportClient;

  @override
  Future<Result<HomeFeed>> fetchHomeFeed() async {
    try {
      final meResult = await _fetchMe();
      if (meResult == null) return Result.failure(const Failure('Unable to load home feed.'));
      final restaurantsResult = await _fetchRestaurants();
      if (restaurantsResult == null) return Result.failure(const Failure('Unable to load home feed.'));
      final customer = meResult.customer.toModel();
      final addresses = meResult.addresses.map((a) => a.toModel()).toList();
      if (addresses.isEmpty) {
        return Result.failure(const Failure('Add an address in Account to continue.'));
      }
      final match = addresses.where((a) => a.id == customer.primaryAddressId);
      final primaryAddress = match.isEmpty ? addresses.first : match.first;
      final allRestaurants = restaurantsResult.map((r) => r.toModel()).toList();
      final now = DateTime.now();
      final trustedRestaurants = _computeTrustedSubset(allRestaurants, now);
      final orderedAll = _applyWeatherBias(allRestaurants, now);
      return Result.success(
        HomeFeed(
          customer: customer,
          primaryAddress: primaryAddress,
          pastOrders: [],
          trustedRestaurants: trustedRestaurants,
          allRestaurants: orderedAll,
        ),
      );
    } on TransportError catch (e) {
      if (e.statusCode == 401) {
        return Result.failure(const Failure('Sign in to see your home feed.'));
      }
      if (e.kind == TransportErrorKind.network || e.kind == TransportErrorKind.timeout) {
        return Result.failure(const Failure(
          'Check your connection and try again. If the problem continues, the server may be unavailable.',
        ));
      }
      return Result.failure(Failure(e.message));
    } on Exception catch (e) {
      return Result.failure(Failure('Unable to load home feed: $e'));
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
    try {
      final restaurantsResult = await _fetchRestaurants();
      if (restaurantsResult == null) return Result.failure(const Failure('Unable to load discovery.'));
      final allRestaurants = restaurantsResult.map((r) => r.toModel()).toList();
      final now = DateTime.now();
      final filtered = _applyFilters(allRestaurants, filters, query);
      final adjusted = _applyBehavioralCopy(filtered, now);
      final weatherBiased = _applyWeatherBias(adjusted, now);
      final preferenceOrdered = _applyPreferenceOrdering(
        weatherBiased,
        preferences,
        reorderCountByRestaurant,
        enableReorderPersonalization,
      );
      return Result.success(preferenceOrdered);
    } on TransportError catch (e) {
      if (e.kind == TransportErrorKind.network || e.kind == TransportErrorKind.timeout) {
        return Result.failure(const Failure(
          'Check your connection and try again. If the problem continues, the server may be unavailable.',
        ));
      }
      return Result.failure(Failure(e.message));
    } on Exception catch (e) {
      return Result.failure(Failure('Unable to load discovery: $e'));
    }
  }

  Future<({CustomerDto customer, List<AddressDto> addresses})?> _fetchMe() async {
    try {
      final response = await transportClient.request<Map<String, dynamic>>(
        TransportRequest(
          method: 'GET',
          url: Uri(path: '/me'),
          timeout: const Duration(seconds: 12),
        ),
      );
      final data = response.data;
      final customer = CustomerDto.fromJson(data);
      final addressesList = data['addresses'] as List<dynamic>? ?? [];
      final addresses = addressesList
          .map((e) => AddressDto.fromJson(e as Map<String, dynamic>))
          .toList();
      return (customer: customer, addresses: addresses);
    } on TransportError {
      rethrow;
    } on Exception {
      return null;
    }
  }

  Future<List<RestaurantDto>?> _fetchRestaurants() async {
    try {
      final response = await transportClient.request<List<dynamic>>(
        TransportRequest(
          method: 'GET',
          url: Uri(path: '/restaurants'),
          timeout: const Duration(seconds: 12),
        ),
      );
      final data = response.data;
      return data.map((e) => RestaurantDto.fromJson(e as Map<String, dynamic>)).toList();
    } on TransportError {
      rethrow;
    } on Exception {
      return null;
    }
  }

  List<Restaurant> _applyPreferenceOrdering(
    List<Restaurant> restaurants,
    UserPreferences preferences,
    Map<String, int> reorderCountByRestaurant,
    bool enableReorderPersonalization,
  ) {
    final withScores = restaurants.map((r) {
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
    final normalized = (query ?? '').trim().toLowerCase();
    RestaurantTag? intentTag;
    if (filters?.intent == 'quick_filling') intentTag = RestaurantTag.quickFilling;
    return restaurants.where((restaurant) {
      if (normalized.isNotEmpty) {
        final matchesQuery = restaurant.name.toLowerCase().contains(normalized) ||
            restaurant.tagline.toLowerCase().contains(normalized) ||
            restaurant.dishNames.any((dish) => dish.toLowerCase().contains(normalized));
        if (!matchesQuery) return false;
      }
      if (intentTag != null && !restaurant.tags.contains(intentTag)) return false;
      if (filters?.pickupFriendly == true && !restaurant.tags.contains(RestaurantTag.pickupFriendly)) return false;
      if (filters?.familySize == true && !restaurant.tags.contains(RestaurantTag.familySize)) return false;
      if (filters?.fastingFriendly == true && !restaurant.tags.contains(RestaurantTag.fastingFriendly)) return false;
      return true;
    }).toList();
  }

  List<Restaurant> _computeTrustedSubset(List<Restaurant> restaurants, DateTime now) {
    final isPeak = _isPeakHour(now);
    final preferredTag = isPeak ? RestaurantTag.pickupFriendly : RestaurantTag.quickFilling;
    final preferred = restaurants.where((r) => r.tags.contains(preferredTag)).toList();
    if (preferred.isNotEmpty) return preferred.take(2).toList();
    return restaurants.take(2).toList();
  }

  List<Restaurant> _applyBehavioralCopy(List<Restaurant> restaurants, DateTime now) {
    final isPeak = _isPeakHour(now);
    final deliveryTight = _isDeliveryTight(now);
    return restaurants.map((restaurant) {
      String trustCopy = restaurant.trustCopy;
      if (isPeak) trustCopy = 'Busy right now';
      if (deliveryTight && restaurant.serviceModes.contains(ServiceMode.pickup)) {
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
        hoursByWeekday: restaurant.hoursByWeekday,
        rating: restaurant.rating,
        maxMinutes: restaurant.maxMinutes,
      );
    }).toList();
  }

  List<Restaurant> _applyWeatherBias(List<Restaurant> restaurants, DateTime now) {
    final coldSeason = now.month >= 11 || now.month <= 3;
    if (!coldSeason) return restaurants;
    final filling = restaurants.where((r) => r.tags.contains(RestaurantTag.quickFilling)).toList();
    final others = restaurants.where((r) => !r.tags.contains(RestaurantTag.quickFilling)).toList();
    return [...filling, ...others];
  }

  bool _isPeakHour(DateTime now) {
    final hour = now.hour;
    return (hour >= 11 && hour <= 13) || (hour >= 17 && hour <= 19);
  }

  bool _isDeliveryTight(DateTime now) {
    final hour = now.hour;
    return hour >= 17 && hour <= 20;
  }
}

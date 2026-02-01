class Routes {
  static const String home = '/';
  static const String discovery = '/discover';
  static const String search = '/search';
  static const String orders = '/orders';
  static const String favorites = '/favorites';
  static const String profile = '/profile';

  static const String restaurant = '/restaurant/:id';
  static const String restaurantSegment = 'restaurant/:id';
  static const String discoverySegment = 'discover';
  static const String meal = '/meal/:id';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderTracking = '/order-tracking/:id';
  static const String orderDetailsPath = '/orders/:id';
  static const String orderDetailsSegment = ':id';
  static const String orderConfirmationPath = '/orders/confirmation/:id';
  static const String orderConfirmationSegment = 'confirmation/:id';
  static const String addressManager = '/address-manager';
  static const String notFound = '/not-found';

  static String restaurantDetails(String id) => '/restaurant/$id';
  static String restaurantDetailsWithIntent(String id, {String? intent}) {
    final Map<String, String> params = {};
    if (intent != null && intent.isNotEmpty) params['intent'] = intent;
    final uri = Uri(
      path: restaurantDetails(id),
      queryParameters: params.isEmpty ? null : params,
    );
    return uri.toString();
  }

  static String mealDetails(String id) => '/meal/$id';
  static String orderTrackingDetails(String id) => '/order-tracking/$id';
  static String orderDetails(String id) => '/orders/$id';
  static String orderConfirmation(String id) => '/orders/confirmation/$id';

  static String discoveryWithFilters({
    String? intent,
    bool? pickupFriendly,
    bool? familySize,
    bool? fastingFriendly,
    String? query,
  }) {
    final Map<String, String> params = {};
    if (intent != null && intent.isNotEmpty) params['intent'] = intent;
    if (pickupFriendly != null) params['pickup'] = pickupFriendly.toString();
    if (familySize != null) params['family'] = familySize.toString();
    if (fastingFriendly != null) {
      params['fasting'] = fastingFriendly.toString();
    }
    if (query != null && query.isNotEmpty) params['q'] = query;
    final uri = Uri(
      path: discovery,
      queryParameters: params.isEmpty ? null : params,
    );
    return uri.toString();
  }
}

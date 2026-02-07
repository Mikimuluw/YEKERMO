class Routes {
  static const String home = '/';
  static const String discovery = '/discover';
  static const String search = '/search';
  static const String orders = '/orders';

  /// Account (shell tab). Prefer [account]; [profile] redirects here for backwards compatibility.
  static const String account = '/account';

  @Deprecated('Use Routes.account. Redirects to /account.')
  static const String profile = '/profile';

  static const String settings = '/settings';
  static const String preferences = '/settings/preferences';

  static const String restaurant = '/restaurant/:id';
  static const String restaurantSegment = 'restaurant/:id';
  static const String restaurantDetail = '/restaurant-detail/:id';
  static const String restaurantDetailSegment = 'restaurant-detail/:id';
  static const String discoverySegment = 'discover';
  @Deprecated('Meal route removed Phase 11.1')
  static const String meal = '/meal/:id';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderTracking = '/order-tracking/:id';
  static const String orderDetailsPath = '/orders/:id';
  static const String orderDetailsSegment = ':id';
  static const String orderConfirmationPath = '/orders/confirmation/:id';
  static const String orderConfirmationSegment = 'confirmation/:id';
  static const String orderSupportPath = '/orders/support/:id';
  static const String orderSupportSegment = 'support/:id';
  static const String orderReceiptPath = '/orders/receipt/:id';
  static const String orderReceiptSegment = 'receipt/:id';
  static const String addressManager = '/address-manager';
  static const String welcome = '/welcome';
  static const String signIn = '/sign-in';
  static const String notFound = '/not-found';

  static String restaurantDetails(String id) => '/restaurant/$id';
  static String restaurantDetailById(String id) => '/restaurant-detail/$id';
  static String restaurantDetailsWithIntent(String id, {String? intent}) {
    final Map<String, String> params = {};
    if (intent != null && intent.isNotEmpty) params['intent'] = intent;
    final uri = Uri(
      path: restaurantDetails(id),
      queryParameters: params.isEmpty ? null : params,
    );
    return uri.toString();
  }

  @Deprecated('Meal route removed Phase 11.1')
  static String mealDetails(String id) => '/meal/$id';
  static String orderTrackingDetails(String id) => '/order-tracking/$id';
  static String orderDetails(String id) => '/orders/$id';
  static String orderConfirmation(String id) => '/orders/confirmation/$id';
  static String orderSupport(String id) => '/orders/support/$id';
  static String orderReceipt(String id) => '/orders/receipt/$id';

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

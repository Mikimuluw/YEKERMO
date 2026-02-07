import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/features/restaurant/restaurant_controller.dart';
import 'package:yekermo/features/restaurant/restaurant_detail_controller.dart';
import 'package:yekermo/features/restaurant/restaurant_detail_screen.dart';
import 'package:yekermo/features/restaurant/restaurant_screen.dart';

/// FEATURE ROUTE OWNERSHIP
/// This file is the single source of truth for restaurant routes.
/// Screens must NOT define routes elsewhere.
GoRoute restaurantRoute() {
  return GoRoute(
    path: Routes.restaurantSegment,
    builder: (context, state) {
      final String restaurantId = state.pathParameters['id'] ?? '';
      final String? intent = state.uri.queryParameters['intent'];
      return ProviderScope(
        overrides: [
          restaurantQueryProvider.overrideWithValue(
            RestaurantQuery(restaurantId: restaurantId, intent: intent),
          ),
        ],
        child: RestaurantScreen(restaurantId: restaurantId, intent: intent),
      );
    },
  );
}

GoRoute restaurantDetailRoute() {
  return GoRoute(
    path: Routes.restaurantDetailSegment,
    builder: (context, state) {
      final String id = state.pathParameters['id'] ?? '';
      return ProviderScope(
        overrides: [
          restaurantDetailQueryProvider.overrideWithValue(
            RestaurantDetailQuery(restaurantId: id),
          ),
        ],
        child: const RestaurantDetailScreen(),
      );
    },
  );
}

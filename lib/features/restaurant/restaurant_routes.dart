import 'package:go_router/go_router.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/features/restaurant/restaurant_screen.dart';

/// FEATURE ROUTE OWNERSHIP
/// This file is the single source of truth for restaurant routes.
/// Screens must NOT define routes elsewhere.
GoRoute restaurantRoute() {
  return GoRoute(
    path: Routes.restaurantSegment,
    builder: (context, state) => RestaurantScreen(
      restaurantId: state.pathParameters['id'] ?? '',
    ),
  );
}

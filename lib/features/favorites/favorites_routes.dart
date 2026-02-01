import 'package:go_router/go_router.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/features/favorites/favorites_screen.dart';

/// FEATURE ROUTE OWNERSHIP
/// This file is the single source of truth for favorites routes.
/// Screens must NOT define routes elsewhere.
GoRoute favoritesRoute() {
  return GoRoute(
    path: Routes.favorites,
    builder: (context, state) => const FavoritesScreen(),
  );
}

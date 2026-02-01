import 'package:go_router/go_router.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/features/search/search_screen.dart';

/// FEATURE ROUTE OWNERSHIP
/// This file is the single source of truth for search routes.
/// Screens must NOT define routes elsewhere.
GoRoute searchRoute() {
  return GoRoute(
    path: Routes.search,
    builder: (context, state) => const SearchScreen(),
  );
}

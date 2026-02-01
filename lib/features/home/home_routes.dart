import 'package:go_router/go_router.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/features/home/home_screen.dart';

/// FEATURE ROUTE OWNERSHIP
/// This file is the single source of truth for home routes.
/// Screens must NOT define routes elsewhere.
GoRoute homeRoute({List<GoRoute> routes = const []}) {
  return GoRoute(
    path: Routes.home,
    builder: (context, state) => const HomeScreen(),
    routes: routes,
  );
}

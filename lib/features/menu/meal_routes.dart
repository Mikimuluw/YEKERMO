import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/features/menu/menu_item_screen.dart';

/// FEATURE ROUTE OWNERSHIP
/// This file is the single source of truth for meal routes.
/// Screens must NOT define routes elsewhere.
GoRoute mealRoute({GlobalKey<NavigatorState>? parentNavigatorKey}) {
  return GoRoute(
    parentNavigatorKey: parentNavigatorKey,
    path: Routes.meal,
    builder: (context, state) =>
        MenuItemScreen(itemId: state.pathParameters['id'] ?? ''),
  );
}

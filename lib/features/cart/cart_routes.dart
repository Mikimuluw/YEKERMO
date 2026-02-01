import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/features/cart/cart_screen.dart';

/// FEATURE ROUTE OWNERSHIP
/// This file is the single source of truth for cart routes.
/// Screens must NOT define routes elsewhere.
GoRoute cartRoute({GlobalKey<NavigatorState>? parentNavigatorKey}) {
  return GoRoute(
    parentNavigatorKey: parentNavigatorKey,
    path: Routes.cart,
    builder: (context, state) => const CartScreen(),
  );
}

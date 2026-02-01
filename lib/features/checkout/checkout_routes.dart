import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/features/checkout/checkout_screen.dart';

/// FEATURE ROUTE OWNERSHIP
/// This file is the single source of truth for checkout routes.
/// Screens must NOT define routes elsewhere.
GoRoute checkoutRoute({GlobalKey<NavigatorState>? parentNavigatorKey}) {
  return GoRoute(
    parentNavigatorKey: parentNavigatorKey,
    path: Routes.checkout,
    builder: (context, state) => const CheckoutScreen(),
  );
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/features/order_tracking/order_tracking_screen.dart';

/// FEATURE ROUTE OWNERSHIP
/// This file is the single source of truth for order tracking routes.
/// Screens must NOT define routes elsewhere.
GoRoute orderTrackingRoute({GlobalKey<NavigatorState>? parentNavigatorKey}) {
  return GoRoute(
    parentNavigatorKey: parentNavigatorKey,
    path: Routes.orderTracking,
    builder: (context, state) =>
        OrderTrackingScreen(orderId: state.pathParameters['id'] ?? ''),
  );
}

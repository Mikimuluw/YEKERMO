import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/features/orders/order_confirmation_screen.dart';
import 'package:yekermo/features/orders/order_detail_controller.dart';
import 'package:yekermo/features/orders/order_detail_screen.dart';
import 'package:yekermo/features/orders/orders_screen.dart';
import 'package:yekermo/features/orders/support_request_screen.dart';

/// FEATURE ROUTE OWNERSHIP
/// This file is the single source of truth for orders routes.
/// Screens must NOT define routes elsewhere.
GoRoute ordersRoute() {
  return GoRoute(
    path: Routes.orders,
    builder: (context, state) => const OrdersScreen(),
    routes: [
      GoRoute(
        path: Routes.orderConfirmationSegment,
        builder: (context, state) => ProviderScope(
          overrides: [
            orderDetailsQueryProvider.overrideWithValue(
              OrderDetailsQuery(orderId: state.pathParameters['id'] ?? ''),
            ),
          ],
          child: const OrderConfirmationScreen(),
        ),
      ),
      GoRoute(
        path: Routes.orderDetailsSegment,
        builder: (context, state) => ProviderScope(
          overrides: [
            orderDetailsQueryProvider.overrideWithValue(
              OrderDetailsQuery(orderId: state.pathParameters['id'] ?? ''),
            ),
          ],
          child: const OrderDetailScreen(),
        ),
      ),
      GoRoute(
        path: Routes.orderSupportSegment,
        builder: (context, state) =>
            SupportRequestScreen(orderId: state.pathParameters['id'] ?? ''),
      ),
    ],
  );
}

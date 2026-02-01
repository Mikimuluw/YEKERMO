import 'package:go_router/go_router.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/features/orders/order_detail_screen.dart';
import 'package:yekermo/features/orders/orders_screen.dart';

/// FEATURE ROUTE OWNERSHIP
/// This file is the single source of truth for orders routes.
/// Screens must NOT define routes elsewhere.
GoRoute ordersRoute() {
  return GoRoute(
    path: Routes.orders,
    builder: (context, state) => const OrdersScreen(),
    routes: [
      GoRoute(
        path: Routes.orderDetailsSegment,
        builder: (context, state) => OrderDetailScreen(
          orderId: state.pathParameters['id'] ?? '',
        ),
      ),
    ],
  );
}

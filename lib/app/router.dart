import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/features/address/address_routes.dart';
import 'package:yekermo/features/cart/cart_routes.dart';
import 'package:yekermo/features/checkout/checkout_routes.dart';
import 'package:yekermo/features/common/not_found_screen.dart';
import 'package:yekermo/features/discovery/discovery_routes.dart';
import 'package:yekermo/features/favorites/favorites_routes.dart';
import 'package:yekermo/features/home/home_routes.dart';
import 'package:yekermo/features/menu/meal_routes.dart';
import 'package:yekermo/features/order_tracking/order_tracking_routes.dart';
import 'package:yekermo/features/orders/orders_routes.dart';
import 'package:yekermo/features/profile/profile_routes.dart';
import 'package:yekermo/features/restaurant/restaurant_routes.dart';
import 'package:yekermo/features/search/search_routes.dart';
import 'package:yekermo/features/settings/settings_routes.dart';
import 'package:yekermo/features/shell/app_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _searchNavigatorKey =
    GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _cartNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _ordersNavigatorKey =
    GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _favoritesNavigatorKey =
    GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _profileNavigatorKey =
    GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: Routes.home,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: [
            homeRoute(routes: [restaurantRoute(), discoveryRoute()]),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _searchNavigatorKey,
          routes: [searchRoute()],
        ),
        StatefulShellBranch(
          navigatorKey: _cartNavigatorKey,
          routes: [cartRoute()],
        ),
        StatefulShellBranch(
          navigatorKey: _ordersNavigatorKey,
          routes: [ordersRoute()],
        ),
        StatefulShellBranch(
          navigatorKey: _favoritesNavigatorKey,
          routes: [favoritesRoute()],
        ),
        StatefulShellBranch(
          navigatorKey: _profileNavigatorKey,
          routes: [profileRoute()],
        ),
      ],
    ),
    mealRoute(parentNavigatorKey: _rootNavigatorKey),
    checkoutRoute(parentNavigatorKey: _rootNavigatorKey),
    orderTrackingRoute(parentNavigatorKey: _rootNavigatorKey),
    addressManagerRoute(parentNavigatorKey: _rootNavigatorKey),
    settingsRoute(),
    GoRoute(
      path: Routes.notFound,
      builder: (context, state) => const NotFoundScreen(),
    ),
  ],
  errorBuilder: (context, state) => NotFoundScreen(
    message: state.error?.toString() ?? 'Unknown route: ${state.uri}',
  ),
);

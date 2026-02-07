import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yekermo/app/providers.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/features/address/address_routes.dart';
import 'package:yekermo/features/account/sign_in_screen.dart';
import 'package:yekermo/features/common/welcome_screen.dart';
import 'package:yekermo/features/cart/cart_routes.dart';
import 'package:yekermo/features/checkout/checkout_routes.dart';
import 'package:yekermo/features/common/not_found_screen.dart';
import 'package:yekermo/features/discovery/discovery_routes.dart';
import 'package:yekermo/features/home/home_routes.dart';
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
final GlobalKey<NavigatorState> _profileNavigatorKey =
    GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: Routes.home,
  redirect: (context, state) async {
    final container = ProviderScope.containerOf(context);
    final storage = container.read(welcomeStorageProvider);
    final seen = await storage.hasSeen();
    final location = state.matchedLocation;
    if (!seen && location != Routes.welcome) return Routes.welcome;
    if (seen && location == Routes.welcome) {
      final useRealBackend = container.read(appConfigProvider).useRealBackend;
      if (useRealBackend) {
        final session = await container.read(authStorageProvider).getSession();
        if (session == null) return Routes.signIn;
      }
      return Routes.home;
    }
    final useRealBackend = container.read(appConfigProvider).useRealBackend;
    if (useRealBackend) {
      final session = await container.read(authStorageProvider).getSession();
      if (session == null && location != Routes.signIn) return Routes.signIn;
    }
    if (location == Routes.profile) return Routes.account;
    return null;
  },
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: [
            homeRoute(
              routes: [
                restaurantRoute(),
                restaurantDetailRoute(),
                discoveryRoute(),
              ],
            ),
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
          navigatorKey: _profileNavigatorKey,
          routes: [profileRoute()],
        ),
      ],
    ),
    checkoutRoute(parentNavigatorKey: _rootNavigatorKey),
    orderTrackingRoute(parentNavigatorKey: _rootNavigatorKey),
    addressManagerRoute(parentNavigatorKey: _rootNavigatorKey),
    settingsRoute(),
    GoRoute(
      path: Routes.welcome,
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: Routes.signIn,
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: Routes.notFound,
      builder: (context, state) => const NotFoundScreen(),
    ),
  ],
  errorBuilder: (context, state) =>
      NotFoundScreen(message: 'We could not find that page.'),
);

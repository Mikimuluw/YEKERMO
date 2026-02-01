import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/features/address/address_manager_screen.dart';

/// FEATURE ROUTE OWNERSHIP
/// This file is the single source of truth for address routes.
/// Screens must NOT define routes elsewhere.
GoRoute addressManagerRoute({GlobalKey<NavigatorState>? parentNavigatorKey}) {
  return GoRoute(
    parentNavigatorKey: parentNavigatorKey,
    path: Routes.addressManager,
    builder: (context, state) => const AddressManagerScreen(),
  );
}

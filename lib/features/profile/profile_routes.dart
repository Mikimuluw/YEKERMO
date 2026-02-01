import 'package:go_router/go_router.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/features/profile/profile_screen.dart';

/// FEATURE ROUTE OWNERSHIP
/// This file is the single source of truth for profile routes.
/// Screens must NOT define routes elsewhere.
GoRoute profileRoute() {
  return GoRoute(
    path: Routes.profile,
    builder: (context, state) => const ProfileScreen(),
  );
}

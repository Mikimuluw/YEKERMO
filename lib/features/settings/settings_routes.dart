import 'package:go_router/go_router.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/features/settings/preferences_screen.dart';
import 'package:yekermo/features/settings/settings_screen.dart';

/// FEATURE ROUTE OWNERSHIP
/// This file is the single source of truth for settings routes.
GoRoute settingsRoute() {
  return GoRoute(
    path: Routes.settings,
    builder: (context, state) => const SettingsScreen(),
    routes: [
      GoRoute(
        path: 'preferences',
        builder: (context, state) => const PreferencesScreen(),
      ),
    ],
  );
}

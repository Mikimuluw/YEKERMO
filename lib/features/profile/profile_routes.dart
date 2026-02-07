import 'package:go_router/go_router.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/features/account/account_screen.dart';

/// FEATURE ROUTE OWNERSHIP
/// Shell tab "Account" shows [AccountScreen] at [Routes.account].
/// Redirect /profile → /account in router for backwards compatibility.
GoRoute profileRoute() {
  return GoRoute(
    path: Routes.account,
    builder: (context, state) => const AccountScreen(),
  );
}

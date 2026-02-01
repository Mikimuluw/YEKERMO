import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/domain/discovery_filters.dart';
import 'package:yekermo/features/discovery/discovery_controller.dart';
import 'package:yekermo/features/discovery/discovery_screen.dart';

/// FEATURE ROUTE OWNERSHIP
/// This file is the single source of truth for discovery routes.
/// Screens must NOT define routes elsewhere.
GoRoute discoveryRoute() {
  return GoRoute(
    path: Routes.discoverySegment,
    builder: (context, state) {
      final DiscoveryFilters filters = DiscoveryFilters(
        intent: state.uri.queryParameters['intent'],
        pickupFriendly: state.uri.queryParameters['pickup'] == 'true',
        familySize: state.uri.queryParameters['family'] == 'true',
        fastingFriendly: state.uri.queryParameters['fasting'] == 'true',
      );
      final DiscoveryQuery query = DiscoveryQuery(
        filters: filters,
        query: state.uri.queryParameters['q'],
      );
      return ProviderScope(
        overrides: [discoveryQueryProvider.overrideWithValue(query)],
        child: DiscoveryScreen(
          intent: filters.intent,
          pickupFriendly: filters.pickupFriendly,
          familySize: filters.familySize,
          fastingFriendly: filters.fastingFriendly,
          query: query.query,
        ),
      );
    },
  );
}

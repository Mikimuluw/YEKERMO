import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yekermo/app/providers.dart';
import 'package:yekermo/app/reorder_signal_provider.dart';
import 'package:yekermo/app/user_preferences_provider.dart';
import 'package:yekermo/data/result.dart';
import 'package:yekermo/domain/discovery_filters.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/shared/state/screen_state.dart';

final discoveryQueryProvider = Provider<DiscoveryQuery>(
  (_) => throw UnimplementedError('DiscoveryQuery must be overridden.'),
);

final discoveryControllerProvider =
    NotifierProvider<DiscoveryController, ScreenState<DiscoveryVm>>(
      DiscoveryController.new,
    );

class DiscoveryController extends Notifier<ScreenState<DiscoveryVm>> {
  int _requestId = 0;

  @override
  ScreenState<DiscoveryVm> build() {
    state = ScreenState.loading();
    Future<void>.microtask(_loadLatest);
    return state;
  }

  Future<void> refresh() => _loadLatest();

  Future<void> _loadLatest() async {
    final int requestId = ++_requestId;
    final DiscoveryQuery query = ref.read(discoveryQueryProvider);
    final Result<List<Restaurant>> result = await ref
        .read(mealsRepositoryProvider)
        .fetchDiscovery(
          filters: query.filters,
          query: query.query,
          preferences: ref.read(userPreferencesProvider),
          reorderCountByRestaurant: ref.read(reorderSignalProvider).counts,
        );

    if (requestId != _requestId) return;
    switch (result) {
      case Success<List<Restaurant>>(:final data):
        if (data.isEmpty) {
          state = ScreenState.empty(
            'Nothing fits that yet — try another filter.',
          );
        } else {
          state = ScreenState.success(
            DiscoveryVm(
              query: query.query,
              filters: query.filters,
              restaurants: data,
            ),
          );
        }
      case FailureResult<List<Restaurant>>(:final failure):
        state = ScreenState.error(failure);
    }
  }
}

class DiscoveryQuery {
  const DiscoveryQuery({required this.filters, this.query});

  final DiscoveryFilters filters;
  final String? query;
}

class DiscoveryVm {
  const DiscoveryVm({
    required this.filters,
    required this.restaurants,
    this.query,
  });

  final DiscoveryFilters filters;
  final List<Restaurant> restaurants;
  final String? query;
}

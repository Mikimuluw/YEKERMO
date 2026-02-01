import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yekermo/app/providers.dart';
import 'package:yekermo/data/result.dart';
import 'package:yekermo/domain/discovery_filters.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/shared/state/screen_state.dart';

class SearchController extends Notifier<ScreenState<SearchVm>> {
  @override
  ScreenState<SearchVm> build() {
    return ScreenState.empty('Start typing to search.');
  }

  Future<void> search(String query) async {
    final DiscoveryFilters filters = _currentFilters();
    await _searchWithFilters(query, filters);
  }

  void togglePickup() => _toggle((filters) => DiscoveryFilters(
        intent: filters.intent,
        pickupFriendly: !filters.pickupFriendly,
        familySize: filters.familySize,
        fastingFriendly: filters.fastingFriendly,
      ));

  void toggleFamily() => _toggle((filters) => DiscoveryFilters(
        intent: filters.intent,
        pickupFriendly: filters.pickupFriendly,
        familySize: !filters.familySize,
        fastingFriendly: filters.fastingFriendly,
      ));

  void toggleFasting() => _toggle((filters) => DiscoveryFilters(
        intent: filters.intent,
        pickupFriendly: filters.pickupFriendly,
        familySize: filters.familySize,
        fastingFriendly: !filters.fastingFriendly,
      ));

  void _toggle(DiscoveryFilters Function(DiscoveryFilters current) update) {
    final DiscoveryFilters next = update(_currentFilters());
    final String query = _currentQuery();
    if (query.isEmpty) {
      state = ScreenState.empty('Start typing to search.');
      return;
    }
    _searchWithFilters(query, next);
  }

  Future<void> _searchWithFilters(
    String query,
    DiscoveryFilters filters,
  ) async {
    state = ScreenState.loading();
    final Result<List<Restaurant>> result = await ref
        .read(searchRepositoryProvider)
        .search(query: query, filters: filters);
    switch (result) {
      case Success<List<Restaurant>>(:final data):
        if (data.isEmpty) {
          state = ScreenState.empty('No matches yet. Try a shorter search.');
        } else {
          state = ScreenState.success(
            SearchVm(
              query: query,
              filters: filters,
              results: data,
            ),
          );
        }
      case FailureResult<List<Restaurant>>(:final failure):
        state = ScreenState.error(failure);
    }
  }

  DiscoveryFilters _currentFilters() {
    return switch (state) {
      SuccessState<SearchVm>(:final data) => data.filters,
      _ => const DiscoveryFilters(),
    };
  }

  String _currentQuery() {
    return switch (state) {
      SuccessState<SearchVm>(:final data) => data.query,
      _ => '',
    };
  }
}

class SearchVm {
  const SearchVm({
    required this.query,
    required this.filters,
    required this.results,
  });

  final String query;
  final DiscoveryFilters filters;
  final List<Restaurant> results;
}

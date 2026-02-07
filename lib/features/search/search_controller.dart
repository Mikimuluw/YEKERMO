import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yekermo/app/providers.dart';
import 'package:yekermo/data/result.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/shared/state/screen_state.dart';

/// Form state for search bar and chips so the UI can show them during loading.
/// Default filter is Ethiopian so the default state shows curated Ethiopian kitchens.
class SearchForm {
  const SearchForm({this.query = '', this.filterIndex = 1});
  final String query;
  final int filterIndex;
}

class SearchFormNotifier extends Notifier<SearchForm> {
  @override
  SearchForm build() => const SearchForm();

  void setQuery(String query) {
    state = SearchForm(query: query.trim(), filterIndex: state.filterIndex);
  }

  void setFilterIndex(int index) {
    state = SearchForm(query: state.query, filterIndex: index);
  }
}

final searchFormProvider = NotifierProvider<SearchFormNotifier, SearchForm>(
  SearchFormNotifier.new,
);

class SearchController extends Notifier<ScreenState<SearchVm>> {
  @override
  ScreenState<SearchVm> build() {
    return ScreenState.initial();
  }

  void setQuery(String query) {
    final form = ref.read(searchFormProvider);
    ref.read(searchFormProvider.notifier).setQuery(query);
    _search(query.trim(), form.filterIndex);
  }

  void setFilterIndex(int index) {
    final form = ref.read(searchFormProvider);
    ref.read(searchFormProvider.notifier).setFilterIndex(index);
    _search(form.query, index);
  }

  Future<void> _search(String query, int filterIndex) async {
    state = ScreenState.loading();
    final Result<List<Restaurant>> result = await ref
        .read(searchRepositoryProvider)
        .search(query: query.isEmpty ? null : query, filters: null);
    switch (result) {
      case Success<List<Restaurant>>(:final data):
        final filtered = _applyChipFilter(data, filterIndex);
        if (filtered.isEmpty) {
          state = query.isEmpty
              ? ScreenState.success(
                  SearchVm(
                    query: query,
                    filterIndex: filterIndex,
                    results: [],
                  ),
                )
              : ScreenState.empty('No matches.');
        } else {
          state = ScreenState.success(
            SearchVm(query: query, filterIndex: filterIndex, results: filtered),
          );
        }
      case FailureResult<List<Restaurant>>(:final failure):
        state = ScreenState.error(failure);
    }
  }

  List<Restaurant> _applyChipFilter(List<Restaurant> list, int filterIndex) {
    switch (filterIndex) {
      case 1: // Ethiopian
        return list
            .where(
              (r) =>
                  r.tagline.toLowerCase().contains('ethiopian') ||
                  r.name.toLowerCase().contains('ethiopian'),
            )
            .toList();
      case 2: // Under 30 min
        return list.where((r) => (r.maxMinutes ?? 999) <= 30).toList();
      case 3: // Top rated
        return list.where((r) => (r.rating ?? 0) >= 4.8).toList();
      default: // 0 = All
        return list;
    }
  }
}

class SearchVm {
  const SearchVm({
    required this.query,
    required this.filterIndex,
    required this.results,
  });

  final String query;
  final int filterIndex;
  final List<Restaurant> results;
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yekermo/app/di.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/features/search/search_controller.dart' as search;
import 'package:yekermo/shared/state/screen_state.dart';
import 'package:yekermo/shared/tokens/app_spacing.dart';
import 'package:yekermo/shared/widgets/app_error_view.dart';
import 'package:yekermo/shared/widgets/app_loading.dart';
import 'package:yekermo/shared/widgets/app_text_field.dart';
import 'package:yekermo/ui/app_card.dart';
import 'package:yekermo/ui/app_filter_chip.dart';
import 'package:yekermo/ui/app_scaffold.dart';
import 'package:yekermo/shared/extensions/context_extensions.dart';
import 'package:yekermo/ui/empty_state.dart' as ui;
import 'package:yekermo/ui/image_placeholder.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _textController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchControllerProvider.notifier).setFilterIndex(1);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref
          .read(searchControllerProvider.notifier)
          .setQuery(_textController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(search.searchFormProvider);
    final state = ref.watch(searchControllerProvider);

    return AppScaffold(
      title: 'Search',
      body: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          AppTextField(
            controller: _textController,
            hintText: 'Search for restaurants or dishes',
            prefixIcon: Icons.search,
            onSubmitted: (_) {
              _debounce?.cancel();
              ref
                  .read(searchControllerProvider.notifier)
                  .setQuery(_textController.text);
            },
          ),
          AppSpacing.vMd,
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                AppFilterChip(
                  label: 'All',
                  selected: form.filterIndex == 0,
                  onTap: () => ref
                      .read(searchControllerProvider.notifier)
                      .setFilterIndex(0),
                ),
                AppSpacing.hSm,
                AppFilterChip(
                  label: 'Ethiopian',
                  selected: form.filterIndex == 1,
                  onTap: () => ref
                      .read(searchControllerProvider.notifier)
                      .setFilterIndex(1),
                ),
                AppSpacing.hSm,
                AppFilterChip(
                  label: 'Under 30 min',
                  selected: form.filterIndex == 2,
                  onTap: () => ref
                      .read(searchControllerProvider.notifier)
                      .setFilterIndex(2),
                ),
                AppSpacing.hSm,
                AppFilterChip(
                  label: 'Top rated',
                  selected: form.filterIndex == 3,
                  onTap: () => ref
                      .read(searchControllerProvider.notifier)
                      .setFilterIndex(3),
                ),
              ],
            ),
          ),
          AppSpacing.vLg,
          _SearchBody(state: state),
          AppSpacing.vXl,
        ],
      ),
    );
  }
}

class _SearchBody extends StatelessWidget {
  const _SearchBody({required this.state});

  final ScreenState<search.SearchVm> state;

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case InitialState<search.SearchVm>():
        return const AppLoading();
      case LoadingState<search.SearchVm>():
        return const AppLoading();
      case StaleLoadingState<search.SearchVm>():
        return const AppLoading();
      case EmptyState<search.SearchVm>(:final message):
        return ui.EmptyState(title: message ?? 'No results.');
      case SuccessState<search.SearchVm>(:final data) when data.results.isEmpty:
        return ui.EmptyState(title: 'No kitchens match.');
      case ErrorState<search.SearchVm>(:final failure):
        return AppErrorView(message: failure.message);
      case SuccessState<search.SearchVm>(:final data):
        final results = data.results;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: results
              .map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _SearchResultCard(
                    restaurant: r,
                    onTap: () =>
                        context.push(Routes.restaurantDetailById(r.id)),
                  ),
                ),
              )
              .toList(),
        );
    }
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({required this.restaurant, this.onTap});

  final Restaurant restaurant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = context.text;
    final String meta = restaurant.tagline;
    final bool hasRating = restaurant.rating != null;

    return AppCard(
      onTap: onTap,
      padding: AppSpacing.cardPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ImagePlaceholder(width: 72, height: 72),
          AppSpacing.hMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(restaurant.name, style: text.titleSmall),
                AppSpacing.vXs,
                Text(
                  meta,
                  style: text.bodySmall?.copyWith(color: context.muted),
                ),
                AppSpacing.vSm,
                Row(
                  children: [
                    Icon(
                      hasRating ? Icons.star_rounded : Icons.star_outline,
                      size: 18,
                      color: context.muted,
                    ),
                    AppSpacing.hXs,
                    Text(
                      hasRating ? restaurant.rating!.toString() : '—',
                      style: text.bodySmall?.copyWith(color: context.muted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

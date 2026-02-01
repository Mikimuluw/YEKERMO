import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yekermo/app/di.dart';
import 'package:yekermo/domain/discovery_filters.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/features/search/search_controller.dart';
import 'package:yekermo/shared/extensions/context_extensions.dart';
import 'package:yekermo/shared/state/screen_state.dart';
import 'package:yekermo/shared/tokens/app_spacing.dart';
import 'package:yekermo/shared/widgets/app_chip.dart';
import 'package:yekermo/shared/widgets/app_list_tile.dart';
import 'package:yekermo/shared/widgets/app_scaffold.dart';
import 'package:yekermo/shared/widgets/app_section_header.dart';
import 'package:yekermo/shared/widgets/app_text_field.dart';
import 'package:yekermo/shared/widgets/async_state_view.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ScreenState<SearchVm> state = ref.watch(searchControllerProvider);
    return AppScaffold(
      title: 'Search',
      body: AsyncStateView<SearchVm>(
        state: state,
        emptyBuilder: (_) => _SearchShell(
          controller: _controller,
          filters: _filtersFromState(state),
          onSearch: _submit,
          onTogglePickup: () =>
              ref.read(searchControllerProvider.notifier).togglePickup(),
          onToggleFamily: () =>
              ref.read(searchControllerProvider.notifier).toggleFamily(),
          onToggleFasting: () =>
              ref.read(searchControllerProvider.notifier).toggleFasting(),
          message: _messageFromState(state),
        ),
        dataBuilder: (context, data) => _SearchResults(
          controller: _controller,
          vm: data,
          onSearch: _submit,
          onTogglePickup: () =>
              ref.read(searchControllerProvider.notifier).togglePickup(),
          onToggleFamily: () =>
              ref.read(searchControllerProvider.notifier).toggleFamily(),
          onToggleFasting: () =>
              ref.read(searchControllerProvider.notifier).toggleFasting(),
        ),
      ),
    );
  }

  void _submit(String value) {
    ref.read(searchControllerProvider.notifier).search(value);
  }

  DiscoveryFilters _filtersFromState(ScreenState<SearchVm> state) {
    return switch (state) {
      SuccessState<SearchVm>(:final data) => data.filters,
      _ => const DiscoveryFilters(),
    };
  }

  String? _messageFromState(ScreenState<SearchVm> state) {
    return switch (state) {
      EmptyState<SearchVm>(:final message) => message,
      _ => null,
    };
  }
  }

class _SearchShell extends StatelessWidget {
  const _SearchShell({
    required this.controller,
    required this.filters,
    required this.onSearch,
    required this.onTogglePickup,
    required this.onToggleFamily,
    required this.onToggleFasting,
    this.message,
  });

  final TextEditingController controller;
  final DiscoveryFilters filters;
  final ValueChanged<String> onSearch;
  final VoidCallback onTogglePickup;
  final VoidCallback onToggleFamily;
  final VoidCallback onToggleFasting;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            controller: controller,
            hintText: 'Search restaurants or dishes',
            prefixIcon: Icons.search,
            onSubmitted: onSearch,
          ),
          AppSpacing.vMd,
          const AppSectionHeader(title: 'Filters'),
          AppSpacing.vSm,
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppChip(
                label: 'Pickup friendly',
                onPressed: onTogglePickup,
              ),
              AppChip(
                label: 'Family size',
                onPressed: onToggleFamily,
              ),
              AppChip(
                label: 'Fasting friendly',
                onPressed: onToggleFasting,
              ),
            ],
          ),
          AppSpacing.vLg,
          Text(
            message ?? 'Start typing to search.',
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.controller,
    required this.vm,
    required this.onSearch,
    required this.onTogglePickup,
    required this.onToggleFamily,
    required this.onToggleFasting,
  });

  final TextEditingController controller;
  final SearchVm vm;
  final ValueChanged<String> onSearch;
  final VoidCallback onTogglePickup;
  final VoidCallback onToggleFamily;
  final VoidCallback onToggleFasting;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        AppTextField(
          controller: controller,
          hintText: 'Search restaurants or dishes',
          prefixIcon: Icons.search,
          onSubmitted: onSearch,
        ),
        AppSpacing.vMd,
        const AppSectionHeader(title: 'Filters'),
        AppSpacing.vSm,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            AppChip(
              label: 'Pickup friendly',
              onPressed: onTogglePickup,
            ),
            AppChip(
              label: 'Family size',
              onPressed: onToggleFamily,
            ),
            AppChip(
              label: 'Fasting friendly',
              onPressed: onToggleFasting,
            ),
          ],
        ),
        AppSpacing.vLg,
        const AppSectionHeader(title: 'Results'),
        AppSpacing.vSm,
        ...vm.results.map(
          (restaurant) => AppListTile(
            title: restaurant.name,
            subtitle: '${restaurant.prepTimeBand.label} • ${restaurant.trustCopy}',
            onTap: () {},
          ),
        ),
      ],
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yekermo/app/clock_provider.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/core/time/restaurant_hours.dart';
import 'package:yekermo/domain/discovery_filters.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/features/discovery/discovery_controller.dart';
import 'package:yekermo/shared/extensions/context_extensions.dart';
import 'package:yekermo/shared/state/screen_state.dart';
import 'package:yekermo/shared/tokens/app_spacing.dart';
import 'package:yekermo/shared/widgets/app_chip.dart';
import 'package:yekermo/shared/widgets/async_state_view.dart';
import 'package:yekermo/ui/app_card.dart';
import 'package:yekermo/ui/app_scaffold.dart';
import 'package:yekermo/ui/app_section_header.dart';

class DiscoveryScreen extends ConsumerWidget {
  const DiscoveryScreen({
    super.key,
    this.intent,
    this.pickupFriendly = false,
    this.familySize = false,
    this.fastingFriendly = false,
    this.query,
  });

  final String? intent;
  final bool pickupFriendly;
  final bool familySize;
  final bool fastingFriendly;
  final String? query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DiscoveryFilters filters = DiscoveryFilters(
      intent: intent,
      pickupFriendly: pickupFriendly,
      familySize: familySize,
      fastingFriendly: fastingFriendly,
    );
    final ScreenState<DiscoveryVm> state = ref.watch(
      discoveryControllerProvider,
    );

    return AppScaffold(
      title: 'Discovery',
      body: AsyncStateView<DiscoveryVm>(
        state: state,
        emptyBuilder: (_) => _DiscoveryEmpty(filters: filters),
        dataBuilder: (context, data) => _DiscoveryResults(vm: data),
      ),
    );
  }
}

class _DiscoveryEmpty extends StatelessWidget {
  const _DiscoveryEmpty({required this.filters});

  final DiscoveryFilters filters;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        const AppSectionHeader(title: 'Active filters'),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _filterChips(filters),
        ),
        AppSpacing.vLg,
        Text(
          'Nothing fits that yet.',
          style: context.text.bodyMedium?.copyWith(
            color: context.textMuted,
          ),
        ),
      ],
    );
  }
}

class _DiscoveryResults extends ConsumerWidget {
  const _DiscoveryResults({required this.vm});

  final DiscoveryVm vm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime now = ref.watch(clockProvider).now();
    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        const AppSectionHeader(title: 'Active filters'),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _filterChips(vm.filters),
        ),
        AppSpacing.vSection,
        const AppSectionHeader(title: 'Restaurants'),
        ...vm.restaurants.map(
          (restaurant) {
            final bool? isOpen = restaurant.hoursByWeekday != null
                ? isOpenNow(restaurant.hoursByWeekday!, now)
                : null;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                padding: AppSpacing.cardPadding,
                onTap: () => context.push(
                  Routes.restaurantDetailsWithIntent(
                    restaurant.id,
                    intent: _intentFromFilters(vm.filters),
                  ),
                ),
                child: _DiscoveryCard(
                  restaurant: restaurant,
                  isOpenNow: isOpen,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _DiscoveryCard extends StatelessWidget {
  const _DiscoveryCard({
    required this.restaurant,
    this.isOpenNow,
  });

  final Restaurant restaurant;
  /// When non-null, shows "Open now" or "Closed". Null when hours unknown.
  final bool? isOpenNow;

  @override
  Widget build(BuildContext context) {
    final String openClosed = isOpenNow == null
        ? ''
        : isOpenNow!
            ? 'Open now'
            : 'Closed';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(restaurant.name, style: context.text.titleMedium),
        AppSpacing.vXs,
        Text(
          [
            if (openClosed.isNotEmpty) openClosed,
            _serviceModesLabel(restaurant.serviceModes),
          ].join(' • '),
          style: context.text.labelMedium?.copyWith(color: context.muted),
        ),
        AppSpacing.vXs,
        Text(
          restaurant.trustCopy,
          style: context.text.bodySmall?.copyWith(color: context.muted),
        ),
      ],
    );
  }
}

List<Widget> _filterChips(DiscoveryFilters filters) {
  final List<Widget> chips = [];
  if (filters.intent != null && filters.intent!.isNotEmpty) {
    chips.add(AppChip(label: _intentLabel(filters.intent!)));
  }
  if (filters.pickupFriendly) {
    chips.add(const AppChip(label: 'Pickup friendly'));
  }
  if (filters.familySize) {
    chips.add(const AppChip(label: 'Family size'));
  }
  if (filters.fastingFriendly) {
    chips.add(const AppChip(label: 'Fasting friendly'));
  }
  if (chips.isEmpty) {
    chips.add(const AppChip(label: 'All'));
  }
  return chips;
}

String? _intentFromFilters(DiscoveryFilters filters) {
  if (filters.intent != null && filters.intent!.isNotEmpty) {
    return filters.intent;
  }
  if (filters.familySize) return 'family_size';
  if (filters.fastingFriendly) return 'fasting_friendly';
  return null;
}

String _intentLabel(String intent) {
  switch (intent) {
    case 'quick_filling':
      return 'Quick & filling';
    case 'family_size':
      return 'Family size';
    case 'fasting_friendly':
      return 'Fasting friendly';
    default:
      return intent;
  }
}

String _serviceModesLabel(List<ServiceMode> modes) {
  final bool pickup = modes.contains(ServiceMode.pickup);
  final bool delivery = modes.contains(ServiceMode.delivery);
  if (pickup && delivery) return 'Pickup • Delivery';
  if (pickup) return 'Pickup';
  if (delivery) return 'Delivery';
  return 'Unavailable';
}

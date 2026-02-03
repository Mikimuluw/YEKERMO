import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yekermo/app/di.dart';
import 'package:yekermo/app/reorder_signal_provider.dart';
import 'package:yekermo/core/ranking/reorder_personalization.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/features/restaurant/restaurant_controller.dart';
import 'package:yekermo/shared/extensions/context_extensions.dart';
import 'package:yekermo/shared/state/screen_state.dart';
import 'package:yekermo/shared/tokens/app_spacing.dart';
import 'package:yekermo/shared/widgets/app_button.dart';
import 'package:yekermo/shared/widgets/app_card.dart';
import 'package:yekermo/shared/widgets/app_chip.dart';
import 'package:yekermo/shared/widgets/app_scaffold.dart';
import 'package:yekermo/shared/widgets/app_section_header.dart';
import 'package:yekermo/shared/widgets/async_state_view.dart';

class RestaurantScreen extends ConsumerWidget {
  const RestaurantScreen({super.key, required this.restaurantId, this.intent});

  final String restaurantId;
  final String? intent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ScreenState<RestaurantVm> state = ref.watch(
      restaurantControllerProvider,
    );

    final int reorderCount = ref
        .watch(reorderSignalProvider)
        .countForRestaurant(restaurantId);

    return AppScaffold(
      title: 'Restaurant',
      body: AsyncStateView<RestaurantVm>(
        state: state,
        emptyBuilder: (_) => const _RestaurantEmpty(),
        dataBuilder: (context, data) => _RestaurantBody(
          vm: data,
          reorderCount: reorderCount,
          onMealTap: (item) => _showMealSheet(context, ref, data, item),
        ),
      ),
    );
  }
}

class _RestaurantEmpty extends StatelessWidget {
  const _RestaurantEmpty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Text(
        'Menu isn’t ready yet — check back soon.',
        style: context.text.bodyMedium?.copyWith(
          color: context.colors.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

class _RestaurantBody extends StatelessWidget {
  const _RestaurantBody({
    required this.vm,
    required this.reorderCount,
    required this.onMealTap,
  });

  final RestaurantVm vm;
  final int reorderCount;
  final ValueChanged<MenuItem> onMealTap;

  @override
  Widget build(BuildContext context) {
    final Map<String, List<MenuItem>> byCategory = _groupByCategory(vm.items);
    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        Text(vm.restaurant.name, style: context.text.headlineSmall),
        AppSpacing.vXs,
        Text(vm.headerTitle, style: context.text.titleMedium),
        AppSpacing.vXs,
        Text(
          vm.headerSubtitle,
          style: context.text.bodyMedium?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.7),
          ),
        ),
        if (canPersonalizeReorder(reorderCount)) ...[
          AppSpacing.vXs,
          Text(
            'Because you reorder',
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
        AppSpacing.vMd,
        if (vm.forYouItems.isNotEmpty) ...[
          const AppSectionHeader(title: 'For you'),
          AppSpacing.vSm,
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: vm.forYouItems.length,
              separatorBuilder: (_, __) => AppSpacing.hSm,
              itemBuilder: (context, index) {
                final MenuItem item = vm.forYouItems[index];
                return SizedBox(
                  width: 220,
                  child: AppCard(
                    padding: AppSpacing.cardPadding,
                    onTap: () => onMealTap(item),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: context.text.titleMedium),
                        AppSpacing.vXs,
                        Text(
                          item.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodySmall?.copyWith(
                            color: context.colors.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                        AppSpacing.vXs,
                        Text(
                          '\$${item.price.toStringAsFixed(2)}',
                          style: context.text.labelLarge,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          AppSpacing.vLg,
        ],
        const AppSectionHeader(title: 'Menu'),
        AppSpacing.vSm,
        ...vm.categories.expand((category) {
          final List<MenuItem> items = byCategory[category.id] ?? [];
          if (items.isEmpty) return const <Widget>[];
          return [
            Text(category.title, style: context.text.titleSmall),
            AppSpacing.vSm,
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AppCard(
                  padding: AppSpacing.cardPadding,
                  onTap: () => onMealTap(item),
                  child: _MealCard(item: item),
                ),
              ),
            ),
            AppSpacing.vMd,
          ];
        }),
      ],
    );
  }

  Map<String, List<MenuItem>> _groupByCategory(List<MenuItem> items) {
    final Map<String, List<MenuItem>> grouped = {};
    for (final MenuItem item in items) {
      grouped.putIfAbsent(item.categoryId, () => []).add(item);
    }
    return grouped;
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.item});

  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.name, style: context.text.titleMedium),
        AppSpacing.vXs,
        Text(
          item.description,
          style: context.text.bodySmall?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.7),
          ),
        ),
        AppSpacing.vSm,
        Text(
          '\$${item.price.toStringAsFixed(2)}',
          style: context.text.labelLarge,
        ),
      ],
    );
  }
}

void _showMealSheet(
  BuildContext context,
  WidgetRef ref,
  RestaurantVm vm,
  MenuItem item,
) {
  final int pastQuantity = vm.pastOrderQuantities[item.id] ?? 0;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      int quantity = pastQuantity > 0 ? pastQuantity : 1;
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: AppSpacing.lg,
              bottom: AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: context.text.titleLarge),
                AppSpacing.vXs,
                Text(
                  item.description,
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                AppSpacing.vSm,
                if (pastQuantity > 0) ...[
                  const AppChip(label: "You've had this before"),
                  AppSpacing.vSm,
                ],
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: context.text.titleMedium,
                ),
                AppSpacing.vMd,
                Row(
                  children: [
                    IconButton(
                      onPressed: quantity > 1
                          ? () => setState(() => quantity -= 1)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text(quantity.toString(), style: context.text.titleMedium),
                    IconButton(
                      onPressed: () => setState(() => quantity += 1),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                    const Spacer(),
                    AppButton(
                      label: 'Add to cart',
                      onPressed: () {
                        ref
                            .read(cartControllerProvider.notifier)
                            .addItem(item, quantity);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

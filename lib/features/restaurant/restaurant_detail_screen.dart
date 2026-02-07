import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yekermo/app/di.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/features/restaurant/restaurant_detail_controller.dart';
import 'package:yekermo/features/restaurant/restaurant_detail_input.dart';
import 'package:yekermo/shared/extensions/context_extensions.dart';
import 'package:yekermo/shared/state/screen_state.dart';
import 'package:yekermo/shared/widgets/app_loading.dart';
import 'package:yekermo/theme/radii.dart';
import 'package:yekermo/theme/spacing.dart';
import 'package:yekermo/ui/app_card.dart';
import 'package:yekermo/ui/app_scaffold.dart';
import 'package:yekermo/ui/image_placeholder.dart';

class RestaurantDetailScreen extends ConsumerStatefulWidget {
  const RestaurantDetailScreen({super.key, this.restaurant});

  final RestaurantDetailInput? restaurant;

  @override
  ConsumerState<RestaurantDetailScreen> createState() =>
      _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState
    extends ConsumerState<RestaurantDetailScreen> {
  RestaurantDetailInput? get _restaurant {
    if (widget.restaurant != null) return widget.restaurant;
    final state = ref.watch(restaurantDetailControllerProvider);
    return switch (state) {
      SuccessState<RestaurantDetailInput>(:final data) => data,
      _ => null,
    };
  }

  void _addToCart(RestaurantDetailInput restaurant, DishDetailInput dish) {
    final MenuItem item = MenuItem(
      id: dish.id,
      restaurantId: restaurant.restaurantId,
      categoryId: 'popular',
      name: dish.name,
      description: dish.description,
      price: dish.price,
      tags: const [],
    );
    final bool didReplace = ref
        .read(cartControllerProvider.notifier)
        .addItem(item, 1);
    if (mounted) {
      final String message = didReplace
          ? 'Cart updated for ${restaurant.name}.'
          : 'Added to cart';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme colors = Theme.of(context).colorScheme;
    final RestaurantDetailInput? r = _restaurant;
    final ScreenState<RestaurantDetailInput>? detailState =
        widget.restaurant == null
        ? ref.watch(restaurantDetailControllerProvider)
        : null;

    if (r == null) {
      return AppScaffold(
        title: null,
        body: switch (detailState) {
          InitialState<RestaurantDetailInput>() => const AppLoading(),
          LoadingState<RestaurantDetailInput>() => const AppLoading(),
          StaleLoadingState<RestaurantDetailInput>() => const AppLoading(),
          EmptyState<RestaurantDetailInput>() => Center(
            child: Padding(
              padding: AppSpacing.pagePadding,
              child: Text(
                'Restaurant not found.',
                style: text.bodyMedium?.copyWith(
                  color: context.textMuted,
                ),
              ),
            ),
          ),
          ErrorState<RestaurantDetailInput>(:final failure) => Center(
            child: Padding(
              padding: AppSpacing.pagePadding,
              child: Text(
                failure.message,
                style: text.bodyMedium?.copyWith(
                  color: context.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          _ => const AppLoading(),
        },
      );
    }

    return AppScaffold(
      title: null,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Stack(
            children: [
              ImagePlaceholder(
                height: 200,
                width: double.infinity,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(AppRadii.r16),
                ),
              ),
              Positioned(
                left: AppSpacing.md,
                top: MediaQuery.of(context).padding.top + AppSpacing.sm,
                child: Material(
                  color: colors.surface.withValues(alpha: 0.9),
                  borderRadius: AppRadii.br12,
                  child: IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Back',
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: AppSpacing.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.name, style: text.headlineSmall),
                AppSpacing.vSm,
                Text(
                  r.meta,
                  style: text.bodyMedium?.copyWith(color: context.muted),
                ),
                AppSpacing.vSm,
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 20, color: context.muted),
                    AppSpacing.hXs,
                    Text(
                      r.ratingLabel,
                      style: text.bodySmall?.copyWith(color: context.muted),
                    ),
                  ],
                ),
                AppSpacing.vSection,
                Text('Popular dishes', style: text.titleMedium),
                AppSpacing.vSectionTitle,
                ...r.dishes.map(
                  (dish) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _DishCard(
                      dish: dish,
                      onAdd: () => _addToCart(r, dish),
                    ),
                  ),
                ),
                AppSpacing.vXl,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Helper widgets (guardrails: one primary CTA per row; spacing over chrome) ---

class _DishCard extends StatelessWidget {
  const _DishCard({required this.dish, required this.onAdd});

  final DishDetailInput dish;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = context.text;
    final ColorScheme colors = context.colors;
    return AppCard(
      padding: AppSpacing.cardPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dish.name, style: text.titleSmall),
                AppSpacing.vXs,
                Text(
                  dish.description,
                  style: text.bodySmall?.copyWith(color: context.muted),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.vSm,
                Text(
                  '\$${dish.price.toStringAsFixed(2)}',
                  style: text.bodyMedium?.copyWith(color: context.muted),
                ),
              ],
            ),
          ),
          AppSpacing.hMd,
          Material(
            color: colors.primary,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onAdd,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: Text(
                    '+',
                    style: context.text.headlineMedium?.copyWith(
                      color: colors.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

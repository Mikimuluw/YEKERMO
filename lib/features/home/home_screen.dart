import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yekermo/app/di.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/domain/home_feed.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/shared/state/screen_state.dart';
import 'package:yekermo/shared/widgets/async_state_view.dart';
import 'package:yekermo/shared/widgets/app_loading.dart';
import 'package:yekermo/theme/radii.dart';
import 'package:yekermo/theme/spacing.dart';
import 'package:yekermo/shared/extensions/context_extensions.dart';
import 'package:yekermo/shared/widgets/app_error_view.dart';
import 'package:yekermo/ui/app_card.dart';
import 'package:yekermo/ui/app_scaffold.dart';
import 'package:yekermo/ui/image_placeholder.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ScreenState<HomeFeed> state = ref.watch(homeControllerProvider);
    return AppScaffold(
      title: 'Yekermo',
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: Material(
            color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.18),
            borderRadius: AppRadii.br12,
            child: IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notifications coming soon'),
                  ),
                );
              },
              icon: const Icon(Icons.notifications_outlined),
              tooltip: 'Notifications',
            ),
          ),
        ),
      ],
      body: AsyncStateView<HomeFeed>(
        state: state,
        loadingBuilder: (_) => const AppLoading(),
        emptyBuilder: (_) => _HomeEmpty(),
        errorBuilder: (context, message) {
          final isSignInPrompt = message.contains('Sign in');
          return AppErrorView(
            message: message,
            onRetry: isSignInPrompt
                ? () => context.push(Routes.signIn)
                : () => ref.read(homeControllerProvider.notifier).load(),
          );
        },
        dataBuilder: (context, feed) => _HomeContent(feed: feed),
      ),
    );
  }
}

class _HomeEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Text(
          'No recommendations right now.',
          style: context.text.bodyMedium?.copyWith(
            color: context.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.feed});

  final HomeFeed feed;

  static String _addressLine(Address a) => '${a.line1}, ${a.city}';

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final String deliveryAddress = _addressLine(feed.primaryAddress);

    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        Text(
          'Good evening',
          style: text.bodyMedium?.copyWith(color: context.muted),
        ),
        AppSpacing.vXs,
        Text('Yekermo', style: text.headlineMedium),
        AppSpacing.vMd,
        _DeliveryAddressCard(title: 'Delivering to', value: deliveryAddress),
        AppSpacing.vSection,
        Text('Your usual', style: text.titleMedium),
        AppSpacing.vXs,
        Text(
          'Places you love',
          style: text.bodySmall?.copyWith(color: context.muted),
        ),
        AppSpacing.vSectionTitle,
        ...feed.trustedRestaurants.map(
          (r) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _YourUsualCard(
              restaurant: r,
              onTap: () => context.push(Routes.restaurantDetailById(r.id)),
            ),
          ),
        ),
        AppSpacing.vSection,
        Text('Nearby Ethiopian kitchens', style: text.titleMedium),
        AppSpacing.vSectionTitle,
        ...feed.allRestaurants.map(
          (r) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _NearbyRestaurantCard(
              restaurant: r,
              onTap: () => context.push(Routes.restaurantDetailById(r.id)),
            ),
          ),
        ),
        AppSpacing.vXl,
      ],
    );
  }
}

class _DeliveryAddressCard extends StatelessWidget {
  const _DeliveryAddressCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = context.text;
    return AppCard(
      onTap: () {},
      child: Row(
        children: [
          Icon(Icons.location_on_outlined, size: 22, color: context.muted),
          AppSpacing.hSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.labelMedium?.copyWith(color: context.muted)),
                AppSpacing.vXs,
                Text(value, style: text.titleSmall),
              ],
            ),
          ),
          Icon(Icons.keyboard_arrow_down, color: context.muted),
        ],
      ),
    );
  }
}

class _YourUsualCard extends StatelessWidget {
  const _YourUsualCard({required this.restaurant, this.onTap});

  final Restaurant restaurant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final bool hasRating = restaurant.rating != null;
    return AppCard(
      onTap: onTap,
      padding: AppSpacing.cardPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ImagePlaceholder(width: 80, height: 80),
          AppSpacing.hMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(restaurant.name, style: text.titleSmall),
                AppSpacing.vXs,
                Text(
                  restaurant.tagline,
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

class _NearbyRestaurantCard extends StatelessWidget {
  const _NearbyRestaurantCard({required this.restaurant, this.onTap});

  final Restaurant restaurant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = context.text;
    final bool hasRating = restaurant.rating != null;
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ImagePlaceholder(
            height: 140,
            width: double.infinity,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadii.r16),
            ),
          ),
          Padding(
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(restaurant.name, style: text.titleSmall),
                AppSpacing.vXs,
                Text(
                  restaurant.tagline,
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
                    AppSpacing.hMd,
                    Text(
                      r'$$',
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

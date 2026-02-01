import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yekermo/app/di.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/domain/home_feed.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/shared/extensions/context_extensions.dart';
import 'package:yekermo/shared/state/screen_state.dart';
import 'package:yekermo/shared/tokens/app_spacing.dart';
import 'package:yekermo/shared/widgets/app_button.dart';
import 'package:yekermo/shared/widgets/app_card.dart';
import 'package:yekermo/shared/widgets/app_chip.dart';
import 'package:yekermo/shared/widgets/app_scaffold.dart';
import 'package:yekermo/shared/widgets/app_section_header.dart';
import 'package:yekermo/shared/widgets/async_state_view.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ScreenState<HomeFeed> state = ref.watch(homeControllerProvider);
    return AsyncStateView<HomeFeed>(
      state: state,
      loadingBuilder: (context) => const HomeScaffold(
        body: HomeSkeleton(),
      ),
      errorBuilder: (context, message) => HomeScaffold(
        body: _HomeMessage(
          message: message,
        ),
      ),
      dataBuilder: (context, data) => HomeScaffold(
        body: HomeContent(feed: data),
      ),
    );
  }

}

String _labelText(AddressLabel label) {
  return label == AddressLabel.home ? 'Home' : 'Work';
}

class GreetingSection extends StatelessWidget {
  const GreetingSection({
    super.key,
    required this.name,
    required this.addressLabel,
  });

  final String name;
  final String addressLabel;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = context.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good evening, $name',
          style: textTheme.headlineSmall,
        ),
        AppSpacing.vSm,
        AppChip(
          label: 'Delivering to $addressLabel',
          onPressed: () => context.push(Routes.addressManager),
          icon: Icons.home_outlined,
        ),
      ],
    );
  }
}

class YourUsualSection extends StatelessWidget {
  const YourUsualSection({
    super.key,
    required this.orders,
    required this.restaurants,
  });

  final List<Order> orders;
  final List<Restaurant> restaurants;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = context.text;
    final ColorScheme scheme = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(title: 'Your usual'),
        AppSpacing.vSm,
        if (orders.isEmpty)
          Text(
            'Save time next time — your usual shows up here.',
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
          )
        else
          ReorderCard(
            order: orders.first,
            restaurant: restaurants.firstWhere(
              (item) => item.id == orders.first.restaurantId,
              orElse: () => restaurants.first,
            ),
          ),
      ],
    );
  }
}

class ReorderCard extends ConsumerWidget {
  const ReorderCard({
    super.key,
    required this.order,
    required this.restaurant,
  });

  final Order order;
  final Restaurant restaurant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme scheme = context.colors;

    return AppCard(
      onTap: () => context.push(Routes.orderDetails(order.id)),
      padding: AppSpacing.cardPadding,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant.name,
                  style: context.text.titleMedium,
                ),
                AppSpacing.vXs,
                Text(
                  restaurant.tagline,
                  style: context.text.bodyMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                AppSpacing.vSm,
                Text(
                  'Total • \$${order.total.toStringAsFixed(2)}',
                  style: context.text.labelLarge,
                ),
              ],
            ),
          ),
          AppSpacing.hSm,
          AppButton(
            label: 'Reorder',
            onPressed: () async {
              final result =
                  await ref.read(ordersControllerProvider.notifier).reorder(order);
              ref.read(cartControllerProvider.notifier).refresh();
              if (result.hasItems && context.mounted) {
                context.go(Routes.checkout);
              }
              if (!context.mounted) return;
              if (result.hasMissing) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Some items have changed.'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class IntentChipsSection extends StatelessWidget {
  const IntentChipsSection({super.key});

  static const List<IntentChip> intents = [
    IntentChip(
      label: 'Quick & filling',
      intent: 'quick_filling',
    ),
    IntentChip(
      label: 'Family size',
      familySize: true,
    ),
    IntentChip(
      label: 'Pickup friendly',
      pickupFriendly: true,
    ),
    IntentChip(
      label: 'Fasting friendly',
      fastingFriendly: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(title: 'Intent'),
        AppSpacing.vSm,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: intents
              .map(
                (intent) => AppChip(
                  label: intent.label,
                  onPressed: () => context.push(
                    Routes.discoveryWithFilters(
                      intent: intent.intent,
                      pickupFriendly: intent.pickupFriendly,
                      familySize: intent.familySize,
                      fastingFriendly: intent.fastingFriendly,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class IntentChip {
  const IntentChip({
    required this.label,
    this.intent,
    this.pickupFriendly,
    this.familySize,
    this.fastingFriendly,
  });

  final String label;
  final String? intent;
  final bool? pickupFriendly;
  final bool? familySize;
  final bool? fastingFriendly;
}

class RestaurantSection extends StatelessWidget {
  const RestaurantSection({
    super.key,
    required this.title,
    required this.restaurants,
  });

  final String title;
  final List<Restaurant> restaurants;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(title: title),
        AppSpacing.vSm,
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => RestaurantCard(
              restaurant: restaurants[index],
            ),
            separatorBuilder: (_, __) => AppSpacing.hSm,
            itemCount: restaurants.length,
          ),
        ),
      ],
    );
  }
}

class RestaurantCard extends StatelessWidget {
  const RestaurantCard({super.key, required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colors;
    return SizedBox(
      width: 220,
      child: AppCard(
        onTap: () => context.push(Routes.restaurantDetails(restaurant.id)),
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              restaurant.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.titleMedium,
            ),
            AppSpacing.vXs,
            Expanded(
              child: Text(
                restaurant.tagline,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodyMedium?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.65),
                ),
              ),
            ),
            AppSpacing.vSm,
            Row(
              children: [
                Text(
                  restaurant.prepTimeBand.label,
                  style: context.text.labelLarge?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.75),
                  ),
                ),
                AppSpacing.hSm,
                Text(
                  _serviceModesLabel(restaurant.serviceModes),
                  style: context.text.labelLarge?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            AppSpacing.vXs,
            Text(
              restaurant.trustCopy,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodySmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
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

class HomeScaffold extends StatelessWidget {
  const HomeScaffold({super.key, required this.body});

  final Widget body;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Yekermo',
      actions: [
        IconButton(
          onPressed: () => context.push(Routes.addressManager),
          icon: const Icon(Icons.place_outlined),
          tooltip: 'Address manager',
        ),
      ],
      body: body,
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key, required this.feed});

  final HomeFeed feed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colors;
    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        GreetingSection(
          name: feed.customer.name,
          addressLabel: _labelText(feed.primaryAddress.label),
        ),
        AppSpacing.vMd,
        YourUsualSection(
          orders: feed.pastOrders,
          restaurants: [
            ...feed.trustedRestaurants,
            ...feed.allRestaurants,
          ],
        ),
        AppSpacing.vMd,
        const IntentChipsSection(),
        AppSpacing.vLg,
        RestaurantSection(
          title: 'Trusted restaurants',
          restaurants: feed.trustedRestaurants,
        ),
        AppSpacing.vLg,
        RestaurantSection(
          title: 'All restaurants',
          restaurants: feed.allRestaurants,
        ),
        AppSpacing.vXl,
        Text(
          'Warm indoor picks, ready when you are.',
          style: context.text.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
        ),
      ],
    );
  }
}

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colors;
    final Color fill = scheme.surfaceContainerHighest;

    Widget block({double height = 16, double width = double.infinity}) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(12),
        ),
      );
    }

    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        block(height: 28, width: 200),
        AppSpacing.vSm,
        block(height: 34, width: 170),
        AppSpacing.vMd,
        block(height: 140),
        AppSpacing.vMd,
        block(height: 22, width: 120),
        AppSpacing.vSm,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: List.generate(
            4,
            (index) => block(height: 36, width: 120),
          ),
        ),
        AppSpacing.vLg,
        block(height: 22, width: 180),
        AppSpacing.vSm,
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => block(height: 150, width: 220),
            separatorBuilder: (_, __) => AppSpacing.hSm,
            itemCount: 3,
          ),
        ),
      ],
    );
  }
}

class _HomeMessage extends StatelessWidget {
  const _HomeMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colors;
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Text(
          message,
          style: context.text.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

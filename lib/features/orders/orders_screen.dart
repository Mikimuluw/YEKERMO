import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yekermo/app/di.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/features/orders/orders_controller.dart';
import 'package:yekermo/shared/extensions/context_extensions.dart';
import 'package:yekermo/shared/state/screen_state.dart';
import 'package:yekermo/shared/tokens/app_spacing.dart';
import 'package:yekermo/shared/widgets/app_button.dart';
import 'package:yekermo/shared/widgets/app_card.dart';
import 'package:yekermo/shared/widgets/app_scaffold.dart';
import 'package:yekermo/shared/widgets/async_state_view.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ScreenState<OrdersVm> state = ref.watch(ordersControllerProvider);
    return AppScaffold(
      title: 'Orders',
      body: AsyncStateView<OrdersVm>(
        state: state,
        emptyBuilder: (context) => Padding(
          padding: AppSpacing.pagePadding,
          child: Text(
            'Your past orders will show up here.',
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        dataBuilder: (context, data) => ListView.builder(
          padding: AppSpacing.pagePadding,
          itemCount: data.summaries.length,
          itemBuilder: (context, index) {
            final OrderSummary summary = data.summaries[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _OrderCard(summary: summary),
            );
          },
        ),
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  const _OrderCard({required this.summary});

  final OrderSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Order order = summary.order;
    final String restaurantName = summary.restaurant?.name ?? 'Restaurant';
    return AppCard(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(restaurantName, style: context.text.titleSmall),
          AppSpacing.vXs,
          Text(
            order.status.label,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          AppSpacing.vSm,
          Text(
            _summary(order),
            style: context.text.bodySmall,
          ),
          AppSpacing.vSm,
          Row(
            children: [
              AppButton(
                label: 'Reorder',
                onPressed: () async {
                  final ReorderResult result = await ref
                      .read(ordersControllerProvider.notifier)
                      .reorder(order);
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
              AppSpacing.hSm,
              AppButton(
                label: 'View order',
                onPressed: () => context.go(Routes.orderDetails(order.id)),
                style: AppButtonStyle.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _summary(Order order) {
    final int itemCount =
        order.items.fold(0, (sum, item) => sum + item.quantity);
    final String fulfillment =
        order.fulfillmentMode == FulfillmentMode.delivery ? 'Delivery' : 'Pickup';
    return '$itemCount items • $fulfillment';
  }
}

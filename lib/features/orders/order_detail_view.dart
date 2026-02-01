import 'package:flutter/material.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/features/orders/order_detail_controller.dart';
import 'package:yekermo/shared/extensions/context_extensions.dart';
import 'package:yekermo/shared/tokens/app_spacing.dart';
import 'package:yekermo/shared/widgets/app_button.dart';
import 'package:yekermo/shared/widgets/app_card.dart';
import 'package:yekermo/shared/widgets/app_section_header.dart';

class OrderDetailContent extends StatelessWidget {
  const OrderDetailContent({
    super.key,
    required this.viewModel,
    this.showConfirmationHeader = false,
    this.showActions = false,
    this.onBackHome,
    this.onViewOrder,
  });

  final OrderDetailVm viewModel;
  final bool showConfirmationHeader;
  final bool showActions;
  final VoidCallback? onBackHome;
  final VoidCallback? onViewOrder;

  @override
  Widget build(BuildContext context) {
    final Order order = viewModel.order;
    final Restaurant? restaurant = viewModel.restaurant;
    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        if (showConfirmationHeader) ...[
          Text(
            'Order received.',
            style: context.text.headlineSmall,
          ),
          AppSpacing.vXs,
          Text(
            "We'll keep you posted.",
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          AppSpacing.vMd,
        ],
        Text(
          restaurant?.name ?? 'Your order',
          style: context.text.titleLarge,
        ),
        AppSpacing.vSm,
        Text(
          'Order #${order.id}',
          style: context.text.bodySmall?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.7),
          ),
        ),
        AppSpacing.vSm,
        AppCard(
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status', style: context.text.titleSmall),
              AppSpacing.vXs,
              Text(
                order.status.label,
                style: context.text.bodyMedium,
              ),
              AppSpacing.vXs,
              Text(
                'Status updates will appear here.',
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        if (showConfirmationHeader) ...[
          AppSpacing.vSm,
          Text(
            'Estimated timing: 25-35 min',
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
        AppSpacing.vMd,
        const AppSectionHeader(title: 'Items'),
        AppSpacing.vSm,
        ...viewModel.lines.map(
          (line) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AppCard(
              padding: AppSpacing.cardPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      line.itemName,
                      style: context.text.bodyMedium,
                    ),
                  ),
                  Text('x${line.quantity}', style: context.text.bodySmall),
                ],
              ),
            ),
          ),
        ),
        AppSpacing.vMd,
        const AppSectionHeader(title: 'Fulfillment'),
        AppSpacing.vSm,
        Text(
          order.fulfillmentMode == FulfillmentMode.delivery
              ? 'Delivery'
              : 'Pickup',
          style: context.text.bodyMedium,
        ),
        if (order.fulfillmentMode == FulfillmentMode.delivery &&
            order.address != null) ...[
          AppSpacing.vXs,
          Text(
            '${_label(order.address!.label)} • ${order.address!.line1}',
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
        AppSpacing.vMd,
        const AppSectionHeader(title: 'Total'),
        AppSpacing.vSm,
        Text('\$${order.total.toStringAsFixed(2)}',
            style: context.text.titleMedium),
        if (showActions) ...[
          AppSpacing.vLg,
          AppButton(
            label: 'Back to home',
            onPressed: onBackHome,
          ),
          AppSpacing.vSm,
          AppButton(
            label: 'View order',
            onPressed: onViewOrder,
            style: AppButtonStyle.secondary,
          ),
        ],
      ],
    );
  }

  String _label(AddressLabel label) {
    switch (label) {
      case AddressLabel.home:
        return 'Home';
      case AddressLabel.work:
        return 'Work';
    }
  }
}

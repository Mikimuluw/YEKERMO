import 'package:flutter/material.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/features/orders/order_detail_controller.dart';
import 'package:yekermo/shared/extensions/context_extensions.dart';
import 'package:yekermo/shared/tokens/app_spacing.dart';
import 'package:yekermo/ui/app_button.dart';
import 'package:yekermo/ui/app_card.dart';
import 'package:yekermo/ui/app_section_header.dart';
import 'package:yekermo/ui/price_row.dart';

class OrderDetailContent extends StatelessWidget {
  const OrderDetailContent({
    super.key,
    required this.viewModel,
    this.showConfirmationHeader = false,
    this.headerTitle,
    this.headerSubtitle,
    this.showActions = false,
    this.onBackHome,
    this.onViewOrder,
    this.onInviteSomeone,
    this.onViewReceipt,
    this.onGetHelp,
  });

  final OrderDetailVm viewModel;
  final bool showConfirmationHeader;
  final String? headerTitle;
  final String? headerSubtitle;
  final bool showActions;
  final VoidCallback? onBackHome;
  final VoidCallback? onViewOrder;
  final VoidCallback? onInviteSomeone;
  final VoidCallback? onViewReceipt;
  final VoidCallback? onGetHelp;

  @override
  Widget build(BuildContext context) {
    final Order order = viewModel.order;
    final Restaurant? restaurant = viewModel.restaurant;
    final bool isStatusStale = _isStatusStale(order);
    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        if (showConfirmationHeader) ...[
          Text(
            headerTitle ?? 'Order received.',
            style: context.text.headlineSmall,
          ),
          AppSpacing.vXs,
          Text(
            headerSubtitle ?? "We'll keep you posted.",
            style: context.text.bodyMedium?.copyWith(
              color: context.textMuted,
            ),
          ),
          AppSpacing.vMd,
        ],
        Text(restaurant?.name ?? 'Your order', style: context.text.titleLarge),
        AppSpacing.vSm,
        Text(
          'Order #${order.id}',
          style: context.text.bodySmall?.copyWith(
            color: context.textMuted,
          ),
        ),
        AppSpacing.vSm,
        // Status card: always current state; never animate indefinitely (Phase 10.4 / PRD §4.2).
        AppCard(
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status', style: context.text.titleSmall),
              AppSpacing.vXs,
              Text(
                order.status.displayLabel(order.fulfillmentMode),
                style: context.text.bodyMedium,
              ),
              AppSpacing.vXs,
              if (isStatusStale) ...[
                Text(
                  "We're checking on this.",
                  style: context.text.bodySmall?.copyWith(
                    color: context.textMuted,
                  ),
                ),
                Text(
                  'No action needed right now.',
                  style: context.text.bodySmall?.copyWith(
                    color: context.textMuted,
                  ),
                ),
              ] else
                Text(
                  _statusSubtext(order.status),
                  style: context.text.bodySmall?.copyWith(
                    color: context.textMuted,
                  ),
                ),
            ],
          ),
        ),
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
                    child: Text(line.itemName, style: context.text.bodyMedium),
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
              color: context.textMuted,
            ),
          ),
        ],
        AppSpacing.vMd,
        const AppSectionHeader(title: 'Total'),
        AppSpacing.vSm,
        Text(
          '\$${order.total.toStringAsFixed(2)}',
          style: context.text.titleMedium,
        ),
        if (order.feeBreakdown != null && order.paymentMethod != null) ...[
          AppSpacing.vMd,
          const AppSectionHeader(title: 'Receipt'),
          AppSpacing.vSm,
          PriceRow(label: 'Subtotal', value: order.feeBreakdown!.subtotal),
          PriceRow(label: 'Service fee', value: order.feeBreakdown!.serviceFee),
          PriceRow(
            label: 'Delivery fee',
            value: order.feeBreakdown!.deliveryFee,
          ),
          PriceRow(label: 'Tax', value: order.feeBreakdown!.tax),
          AppSpacing.vSm,
          PriceRow(
            label: 'Total paid',
            value: order.feeBreakdown!.total,
            emphasize: true,
          ),
          AppSpacing.vSm,
          Text(
            order.paymentMethod!.label,
            style: context.text.bodySmall?.copyWith(
              color: context.textMuted,
            ),
          ),
          if (onViewReceipt != null) ...[
            AppSpacing.vSm,
            AppButton(label: 'View receipt', onPressed: onViewReceipt),
          ],
        ],
        if (onGetHelp != null) ...[
          AppSpacing.vLg,
          TextButton(
            onPressed: onGetHelp,
            child: Text(
              'Get help',
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.primary,
              ),
            ),
          ),
        ],
        if (showActions) ...[
          AppSpacing.vLg,
          if (onInviteSomeone != null) ...[
            InkWell(
              onTap: onInviteSomeone,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Text(
                  'Invite someone',
                  style: context.text.bodyMedium?.copyWith(
                    color: context.textMuted,
                  ),
                ),
              ),
            ),
            AppSpacing.vSm,
          ],
          AppButton(label: 'Back to home', onPressed: onBackHome),
          AppSpacing.vSm,
          TextButton(
            onPressed: onViewOrder,
            child: Text(
              'View order',
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.primary,
              ),
            ),
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

  String _statusSubtext(OrderStatus status) {
    switch (status) {
      case OrderStatus.received:
        return 'The restaurant has received your order.';
      case OrderStatus.preparing:
      case OrderStatus.ready:
        return 'Status updates will appear here.';
      case OrderStatus.completed:
        return 'Thank you for your order.';
      case OrderStatus.cancelled:
        return 'This order was cancelled.';
      case OrderStatus.failed:
        return 'This order could not be completed.';
      case OrderStatus.refunded:
        return 'This order was refunded.';
    }
  }

  bool _isStatusStale(Order order) {
    final DateTime? placedAt = order.placedAt ?? order.paidAt;
    if (placedAt == null) return false;
    if (order.status.isTerminal) return false;
    return DateTime.now().difference(placedAt) > const Duration(minutes: 20);
  }
}

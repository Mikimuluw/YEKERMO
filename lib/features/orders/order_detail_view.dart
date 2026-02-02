import 'package:flutter/material.dart';
import 'package:yekermo/core/copy/trust_copy.dart';
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
    this.headerTitle,
    this.headerSubtitle,
    this.showActions = false,
    this.onBackHome,
    this.onViewOrder,
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
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          AppSpacing.vMd,
        ],
        Text(restaurant?.name ?? 'Your order', style: context.text.titleLarge),
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
              Text(order.status.label, style: context.text.bodyMedium),
              AppSpacing.vXs,
              if (isStatusStale) ...[
                Text(
                  TrustCopy.orderStatusChecking,
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  TrustCopy.orderStatusNoAction,
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ] else
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
              color: context.colors.onSurface.withValues(alpha: 0.7),
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
          _ReceiptRow(label: 'Subtotal', value: order.feeBreakdown!.subtotal),
          _ReceiptRow(
            label: 'Service fee',
            value: order.feeBreakdown!.serviceFee,
          ),
          _ReceiptRow(
            label: 'Delivery fee',
            value: order.feeBreakdown!.deliveryFee,
          ),
          _ReceiptRow(label: 'Tax', value: order.feeBreakdown!.tax),
          AppSpacing.vSm,
          _ReceiptRow(
            label: 'Total paid',
            value: order.feeBreakdown!.total,
            emphasize: true,
          ),
          AppSpacing.vSm,
          Text(
            order.paymentMethod!.label,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          if (onViewReceipt != null) ...[
            AppSpacing.vSm,
            AppButton(label: 'View receipt', onPressed: onViewReceipt),
          ],
        ],
        if (onGetHelp != null) ...[
          AppSpacing.vLg,
          AppButton(
            label: 'Get help',
            onPressed: onGetHelp,
            style: AppButtonStyle.secondary,
          ),
        ],
        if (showActions) ...[
          AppSpacing.vLg,
          AppButton(label: 'Back to home', onPressed: onBackHome),
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

  bool _isStatusStale(Order order) {
    final DateTime? placedAt = order.placedAt ?? order.paidAt;
    if (placedAt == null) return false;
    if (order.status == OrderStatus.completed) return false;
    return DateTime.now().difference(placedAt) >
        TrustCopy.orderStatusStaleThreshold;
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final double value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = emphasize
        ? context.text.titleSmall
        : context.text.bodySmall?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.7),
          );
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text('\$${value.toStringAsFixed(2)}', style: style),
        ],
      ),
    );
  }
}

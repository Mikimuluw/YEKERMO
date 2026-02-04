import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:yekermo/app/providers.dart';
import 'package:yekermo/domain/fees.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/features/orders/order_detail_controller.dart';
import 'package:yekermo/observability/analytics.dart';
import 'package:yekermo/shared/extensions/context_extensions.dart';
import 'package:yekermo/shared/state/screen_state.dart';
import 'package:yekermo/shared/tokens/app_spacing.dart';
import 'package:yekermo/shared/widgets/app_button.dart';
import 'package:yekermo/shared/widgets/app_card.dart';
import 'package:yekermo/shared/widgets/app_scaffold.dart';
import 'package:yekermo/shared/widgets/app_section_header.dart';
import 'package:yekermo/shared/widgets/async_state_view.dart';

class ReceiptScreen extends ConsumerStatefulWidget {
  const ReceiptScreen({super.key});

  @override
  ConsumerState<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends ConsumerState<ReceiptScreen> {
  bool _tracked = false;

  @override
  Widget build(BuildContext context) {
    final ScreenState<OrderDetailVm> state = ref.watch(
      orderDetailControllerProvider,
    );
    if (!_tracked && state is SuccessState<OrderDetailVm>) {
      ref
          .read(analyticsProvider)
          .track(
            AnalyticsEvents.receiptViewed,
            properties: {'orderId': state.data.order.id},
          );
      _tracked = true;
    }
    final String title = state is SuccessState<OrderDetailVm>
        ? 'Receipt - Order #${state.data.order.id}'
        : 'Receipt';
    return AppScaffold(
      title: title,
      body: AsyncStateView<OrderDetailVm>(
        state: state,
        emptyBuilder: (context) => const _ReceiptEmptyState(),
        dataBuilder: (context, data) => _ReceiptBody(viewModel: data),
      ),
    );
  }
}

class _ReceiptEmptyState extends StatelessWidget {
  const _ReceiptEmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Text(
        'Receipt details will appear here.',
        style: context.text.bodyMedium?.copyWith(
          color: context.colors.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

class _ReceiptBody extends StatelessWidget {
  const _ReceiptBody({required this.viewModel});

  final OrderDetailVm viewModel;

  @override
  Widget build(BuildContext context) {
    final Order order = viewModel.order;
    final Restaurant? restaurant = viewModel.restaurant;
    final FeeBreakdown? fees = order.feeBreakdown;
    final bool hasMissingPrices = viewModel.lines.any(
      (line) => line.price <= 0,
    );
    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        Text(restaurant?.name ?? 'Restaurant', style: context.text.titleLarge),
        AppSpacing.vXs,
        Text(
          restaurant?.address ?? 'Address on file',
          style: context.text.bodySmall?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.7),
          ),
        ),
        AppSpacing.vSm,
        AppCard(
          padding: AppSpacing.cardPadding,
          child: Text('Order #${order.id}', style: context.text.titleSmall),
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
                    child: Text(
                      '${line.itemName} x${line.quantity}',
                      style: context.text.bodyMedium,
                    ),
                  ),
                  Text(
                    '\$${line.lineTotal.toStringAsFixed(2)}',
                    style: context.text.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (hasMissingPrices) ...[
          AppSpacing.vXs,
          Text(
            'Some item prices may be unavailable.',
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
        AppSpacing.vMd,
        const AppSectionHeader(title: 'Fees'),
        AppSpacing.vSm,
        if (fees != null) ...[
          _ReceiptRow(label: 'Subtotal', value: fees.subtotal),
          _ReceiptRow(label: 'Service fee', value: fees.serviceFee),
          _ReceiptRow(label: 'Delivery fee', value: fees.deliveryFee),
          _ReceiptRow(label: 'Tax', value: fees.tax),
          AppSpacing.vSm,
          _ReceiptRow(label: 'Total paid', value: fees.total, emphasize: true),
        ] else
          Text(
            'Fee details are not available yet.',
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
        AppSpacing.vSm,
        if (order.paymentMethod != null)
          Text(
            order.paymentMethod!.label,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
        AppSpacing.vLg,
        AppButton(
          label: 'Share',
          style: AppButtonStyle.secondary,
          onPressed: () => _shareReceipt(order, restaurant, fees),
        ),
        AppSpacing.vSm,
        AppButton(
          label: 'Download PDF',
          style: AppButtonStyle.secondary,
          onPressed: () => _stubDownload(context),
        ),
      ],
    );
  }

  void _shareReceipt(Order order, Restaurant? restaurant, FeeBreakdown? fees) {
    final String total = fees == null
        ? '\$${order.total.toStringAsFixed(2)}'
        : '\$${fees.total.toStringAsFixed(2)}';
    final String message = [
      'Receipt for ${restaurant?.name ?? 'your order'}',
      'Order #${order.id}',
      'Total paid: $total',
    ].join('\n');
    Share.share(message);
  }

  void _stubDownload(BuildContext context) {
    // TODO(phase8): replace stub with PDF generation and download.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF download is coming soon.')),
    );
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

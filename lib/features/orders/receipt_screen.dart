import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/features/orders/order_detail_controller.dart';
import 'package:yekermo/shared/extensions/context_extensions.dart';
import 'package:yekermo/shared/state/screen_state.dart';
import 'package:yekermo/shared/tokens/app_spacing.dart';
import 'package:yekermo/shared/widgets/app_loading.dart';
import 'package:yekermo/ui/app_button.dart';
import 'package:yekermo/ui/app_card.dart';
import 'package:yekermo/ui/link_button.dart';
import 'package:yekermo/ui/screen_with_back.dart';

/// Receipt screen. Loads order by id from route (orderDetailsQueryProvider override).
class ReceiptScreen extends ConsumerWidget {
  const ReceiptScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ScreenState<OrderDetailVm> state = ref.watch(
      orderDetailControllerProvider,
    );
    return ScreenWithBack(
      title: 'Receipt',
      children: [
        switch (state) {
          InitialState<OrderDetailVm>() => const AppLoading(),
          LoadingState<OrderDetailVm>() => const AppLoading(),
          StaleLoadingState<OrderDetailVm>() => const AppLoading(),
          EmptyState<OrderDetailVm>() => _ReceiptEmpty(),
          ErrorState<OrderDetailVm>(:final failure) => _ReceiptError(
            message: failure.message,
          ),
          SuccessState<OrderDetailVm>(:final data) => _ReceiptContent(vm: data),
        },
      ],
    );
  }
}

class _ReceiptEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Text(
          'Order details will appear here.',
          style: context.text.bodyMedium?.copyWith(
            color: context.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ReceiptError extends StatelessWidget {
  const _ReceiptError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Text(
          message,
          style: context.text.bodyMedium?.copyWith(
            color: context.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ReceiptContent extends StatelessWidget {
  const _ReceiptContent({required this.vm});

  final OrderDetailVm vm;

  static String _formatDate(DateTime? d) {
    if (d == null) return '—';
    final h = d.hour == 0 ? 12 : (d.hour > 12 ? d.hour - 12 : d.hour);
    final am = d.hour < 12;
    return '${d.month}/${d.day}/${d.year}, $h:${d.minute.toString().padLeft(2, '0')} ${am ? 'AM' : 'PM'}';
  }

  @override
  Widget build(BuildContext context) {
    final Order order = vm.order;
    final String orderNumber = order.id;
    final String date = _formatDate(order.placedAt ?? order.paidAt);
    final String restaurant = vm.restaurant?.name ?? 'Restaurant';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _ReceiptStatusHeader(order: order),
        AppSpacing.vMd,
        _DetailsCard(
          orderNumber: orderNumber,
          date: date,
          restaurant: restaurant,
        ),
        AppSpacing.vMd,
        _ItemsCard(lines: vm.lines),
        AppSpacing.vLg,
        AppButton(label: 'Order again', onPressed: () {}),
        AppSpacing.vSm,
        LinkButton(label: 'Get help', onPressed: () {}),
        AppSpacing.vXl,
      ],
    );
  }
}

class _ReceiptStatusHeader extends StatelessWidget {
  const _ReceiptStatusHeader({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final String title = order.status.receiptHeaderTitle;
    final String subtitle = order.status.isTerminal
        ? 'Thank you for your order'
        : order.status.displayLabel(order.fulfillmentMode);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: context.colors.primary,
          ),
          AppSpacing.vSm,
          Text(title, style: context.text.titleLarge),
          AppSpacing.vXs,
          Text(
            subtitle,
            style: context.text.bodyMedium?.copyWith(color: context.muted),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({
    required this.orderNumber,
    required this.date,
    required this.restaurant,
  });

  final String orderNumber;
  final String date;
  final String restaurant;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          _DetailRow(label: 'Order number', value: orderNumber),
          _DetailRow(label: 'Date', value: date),
          _DetailRow(label: 'Restaurant', value: restaurant, isLast: true),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.text.bodyMedium?.copyWith(
              color: context.textMuted,
            ),
          ),
          Text(value, style: context.text.bodyMedium, textAlign: TextAlign.end),
        ],
      ),
    );
  }
}

class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.lines});

  final List<OrderLineView> lines;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Items', style: context.text.titleSmall),
          AppSpacing.vSm,
          ...lines.asMap().entries.map((e) {
            final line = e.value;
            final isLast = e.key == lines.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '${line.itemName} × ${line.quantity}',
                      style: context.text.bodyMedium,
                    ),
                  ),
                  Text(
                    '\$${line.lineTotal.toStringAsFixed(2)}',
                    style: context.text.bodyMedium,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

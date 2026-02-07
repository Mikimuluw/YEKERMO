import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/data/dto/order_event_dto.dart';
import 'package:yekermo/features/order_tracking/order_tracking_controller.dart';
import 'package:yekermo/shared/extensions/context_extensions.dart';
import 'package:yekermo/shared/tokens/app_spacing.dart';
import 'package:yekermo/shared/widgets/async_state_view.dart';
import 'package:yekermo/ui/app_button.dart';
import 'package:yekermo/ui/app_card.dart';
import 'package:yekermo/ui/screen_with_back.dart';

class OrderTrackingScreen extends ConsumerWidget {
  const OrderTrackingScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(orderTrackingControllerProvider);
    final titleOrderId = orderId.isNotEmpty ? orderId : '—';
    return ScreenWithBack(
      title: 'Order #$titleOrderId',
      children: [
        AsyncStateView<OrderTrackingUiModel>(
          state: state,
          dataBuilder: (context, ui) => _OrderTrackingContent(ui: ui),
        ),
      ],
    );
  }
}

class _OrderTrackingContent extends ConsumerWidget {
  const _OrderTrackingContent({required this.ui});

  final OrderTrackingUiModel ui;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ui.statusCard.statusLabel, style: context.text.titleLarge),
              AppSpacing.vXs,
              Text(
                ui.statusCard.supportiveSubtext,
                style: context.text.bodyMedium?.copyWith(color: context.textMuted),
              ),
            ],
          ),
        ),
        AppSpacing.vMd,
        const _DeliveryIconPlaceholder(),
        AppSpacing.vMd,
        _TimelineCard(
          restaurantName: ui.orderSummary.restaurantName,
          orderIdShort: ui.orderIdShort,
          steps: ui.steps,
          timelineEvents: ui.timelineEvents,
        ),
        AppSpacing.vLg,
        _PrimaryAction(ui: ui),
        AppSpacing.vXl,
      ],
    );
  }
}

class _DeliveryIconPlaceholder extends StatelessWidget {
  const _DeliveryIconPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(Icons.delivery_dining_outlined, size: 80, color: context.textTertiary),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({
    required this.restaurantName,
    required this.orderIdShort,
    required this.steps,
    required this.timelineEvents,
  });

  final String restaurantName;
  final String orderIdShort;
  final List<TrackingStep> steps;
  final List<OrderEventDto> timelineEvents;

  @override
  Widget build(BuildContext context) {
    final bool useEvents = timelineEvents.isNotEmpty;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(restaurantName, style: context.text.titleSmall),
          AppSpacing.vXs,
          Text(
            'Order $orderIdShort',
            style: context.text.bodySmall?.copyWith(color: context.textMuted),
          ),
          AppSpacing.vSm,
          if (useEvents)
            ...timelineEvents.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, size: 20, color: context.colors.primary),
                    AppSpacing.hSm,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.displayLabel, style: context.text.bodyMedium),
                          Text(
                            _formatTime(e.createdAt),
                            style: context.text.bodySmall?.copyWith(color: context.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...steps.asMap().entries.map(
                  (e) => _StepRow(
                    step: e.value,
                    hasBottomPadding: e.key < steps.length - 1,
                  ),
                ),
        ],
      ),
    );
  }

  static String _formatTime(DateTime d) {
    final now = DateTime.now();
    if (d.day == now.day && d.month == now.month && d.year == now.year) {
      return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    }
    return '${d.month}/${d.day} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step, this.hasBottomPadding = true});

  final TrackingStep step;
  final bool hasBottomPadding;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;
    TextStyle? labelStyle;
    switch (step.state) {
      case TrackingStepState.completed:
        icon = Icons.check_circle;
        iconColor = context.colors.primary;
        labelStyle = context.text.bodyMedium?.copyWith(color: context.textMuted);
        break;
      case TrackingStepState.active:
        icon = Icons.radio_button_checked;
        iconColor = context.colors.primary;
        labelStyle = context.text.titleSmall;
        break;
      case TrackingStepState.pending:
        icon = Icons.radio_button_unchecked;
        iconColor = context.textTertiary;
        labelStyle = context.text.bodyMedium?.copyWith(color: context.textTertiary);
        break;
    }
    return Padding(
      padding: EdgeInsets.only(bottom: hasBottomPadding ? AppSpacing.xs : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          AppSpacing.hSm,
          Expanded(child: Text(step.label, style: labelStyle)),
        ],
      ),
    );
  }
}

class _PrimaryAction extends ConsumerWidget {
  const _PrimaryAction({required this.ui});

  final OrderTrackingUiModel ui;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (ui.primaryAction) {
      case TrackingPrimaryAction.cancel:
        return AppButton(
          label: 'Cancel order',
          onPressed: ui.canCancel
              ? () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Cancel order?'),
                      content: const Text(
                        'This will cancel your order. You can place a new order anytime.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Keep order'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Cancel order'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await ref.read(orderTrackingControllerProvider.notifier).cancelOrder();
                  }
                }
              : null,
        );
      case TrackingPrimaryAction.viewReceipt:
        return AppButton(
          label: 'View receipt',
          onPressed: () {
            if (context.mounted) context.push(Routes.orderReceipt(ui.orderId));
          },
        );
      case TrackingPrimaryAction.getHelp:
        return AppButton(
          label: 'Contact support',
          onPressed: () {
            if (context.mounted) context.push(Routes.orderSupport(ui.orderId));
          },
        );
    }
  }
}

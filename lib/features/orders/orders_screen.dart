import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yekermo/app/di.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/features/orders/orders_controller.dart';
import 'package:yekermo/shared/extensions/context_extensions.dart';
import 'package:yekermo/shared/state/screen_state.dart';
import 'package:yekermo/theme/radii.dart';
import 'package:yekermo/theme/spacing.dart';
import 'package:yekermo/ui/app_button.dart';
import 'package:yekermo/ui/app_card.dart';
import 'package:yekermo/ui/app_scaffold.dart';
import 'package:yekermo/ui/empty_state.dart' as ui;
import 'package:yekermo/ui/link_button.dart';
import 'package:yekermo/ui/price_row.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  int _selectedTabIndex = 0; // 0 = Active, 1 = Past

  @override
  Widget build(BuildContext context) {
    final ScreenState<OrdersVm> state = ref.watch(ordersControllerProvider);
    final List<OrderSummary> all = switch (state) {
      SuccessState<OrdersVm>(:final data) => data.summaries,
      _ => [],
    };
    final now = DateTime.now();
    // Active = in progress only; Past = all terminal (completed, cancelled, failed, refunded).
    final active = all.where((s) => s.order.status.isInProgress).toList();
    final past = all.where((s) => s.order.status.isTerminal).toList();

    return AppScaffold(
      title: 'Orders',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppSpacing.pagePadding,
            child: _SegmentTabs(
              selectedIndex: _selectedTabIndex,
              labels: const ['Active', 'Past orders'],
              onSelected: (index) => setState(() => _selectedTabIndex = index),
            ),
          ),
          Expanded(
            child: switch (state) {
              InitialState<OrdersVm>() => const _OrdersLoading(),
              LoadingState<OrdersVm>() => const _OrdersLoading(),
              StaleLoadingState<OrdersVm>() => const _OrdersLoading(),
              EmptyState<OrdersVm>() => _OrdersEmpty(),
              ErrorState<OrdersVm>(:final failure) => _OrdersError(
                message: failure.message,
              ),
              SuccessState<OrdersVm>() =>
                _selectedTabIndex == 0
                    ? _ActiveOrdersContent(activeOrders: active, now: now)
                    : _PastOrdersContent(pastOrders: past, now: now),
            },
          ),
        ],
      ),
    );
  }
}

/// Assumes [d] is in local time. When backend sends UTC, convert to local before calling.
String _formatOrderDate(DateTime d, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final dDate = DateTime(d.year, d.month, d.day);
  final hour = d.hour;
  final minute = d.minute;
  final am = hour < 12;
  final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
  final timeStr = '$h:${minute.toString().padLeft(2, '0')} ${am ? 'AM' : 'PM'}';
  if (dDate == today) return 'Today, $timeStr';
  if (dDate == yesterday) return 'Yesterday, $timeStr';
  const months = 'JanFebMarAprMayJunJulAugSepOctNovDec';
  final mon = months.substring((d.month - 1) * 3, (d.month - 1) * 3 + 3);
  return '${_weekday(d.weekday)}, $mon ${d.day}';
}

String _weekday(int w) {
  switch (w) {
    case DateTime.monday:
      return 'Mon';
    case DateTime.tuesday:
      return 'Tue';
    case DateTime.wednesday:
      return 'Wed';
    case DateTime.thursday:
      return 'Thu';
    case DateTime.friday:
      return 'Fri';
    case DateTime.saturday:
      return 'Sat';
    case DateTime.sunday:
      return 'Sun';
    default:
      return '';
  }
}

class _OrdersLoading extends StatelessWidget {
  const _OrdersLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _OrdersEmpty extends StatelessWidget {
  const _OrdersEmpty();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: ui.EmptyState(title: 'Your past orders will show up here.'),
      ),
    );
  }
}

class _OrdersError extends StatelessWidget {
  const _OrdersError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: context.text.bodyMedium?.copyWith(
            color: context.textMuted,
          ),
        ),
      ),
    );
  }
}

// --- Helper widgets ---

class _SegmentTabs extends StatelessWidget {
  const _SegmentTabs({
    required this.selectedIndex,
    required this.labels,
    required this.onSelected,
  });

  final int selectedIndex;
  final List<String> labels;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: AppRadii.br12,
      ),
      child: Row(
        children: [
          for (int i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: _SegmentTab(
                label: labels[i],
                selected: i == selectedIndex,
                onTap: () => onSelected(i),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  const _SegmentTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    return Material(
      color: selected ? colors.surface : Colors.transparent,
      borderRadius: AppRadii.br12,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.br12,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Center(
            child: Text(
              label,
              style: text.labelLarge?.copyWith(
                color: selected
                    ? colors.onSurface
                    : context.textMuted,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveOrdersContent extends StatelessWidget {
  const _ActiveOrdersContent({required this.activeOrders, required this.now});

  final List<OrderSummary> activeOrders;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    if (activeOrders.isEmpty) {
      return const ui.EmptyState(
        title: 'No other active orders',
        icon: Icons.receipt_long_outlined,
      );
    }
    return ListView(
      padding: AppSpacing.pagePadding,
      children: activeOrders
          .map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _ActiveOrderCard(summary: s, now: now),
            ),
          )
          .toList(),
    );
  }
}

class _ActiveOrderCard extends StatelessWidget {
  const _ActiveOrderCard({required this.summary, required this.now});

  final OrderSummary summary;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final Order order = summary.order;
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme colors = Theme.of(context).colorScheme;
    final String restaurantName = summary.restaurant?.name ?? 'Restaurant';
    final String timeLabel = order.placedAt != null
        ? _formatOrderDate(order.placedAt!, now)
        : '—';
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(restaurantName, style: text.titleSmall),
          AppSpacing.vXs,
          Text(
            'Order #${order.id} • $timeLabel',
            style: text.bodySmall?.copyWith(
              color: context.textMuted,
            ),
          ),
          AppSpacing.vSm,
          Text(
            order.status.displayLabel(order.fulfillmentMode),
            style: text.bodyMedium?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          AppSpacing.vXs,
          Text(
            '—',
            style: text.bodySmall?.copyWith(
              color: context.textMuted,
            ),
          ),
          AppSpacing.vMd,
          AppButton(label: 'Track order', onPressed: () {}),
        ],
      ),
    );
  }
}

class _PastOrdersContent extends StatelessWidget {
  const _PastOrdersContent({required this.pastOrders, required this.now});

  final List<OrderSummary> pastOrders;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    if (pastOrders.isEmpty) {
      return const Center(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: ui.EmptyState(title: 'Your past orders will show up here.'),
        ),
      );
    }
    return ListView(
      padding: AppSpacing.pagePadding,
      children: pastOrders
          .map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _PastOrderCard(summary: s, now: now),
            ),
          )
          .toList(),
    );
  }
}

class _PastOrderCard extends StatelessWidget {
  const _PastOrderCard({required this.summary, required this.now});

  final OrderSummary summary;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final Order order = summary.order;
    final TextTheme text = Theme.of(context).textTheme;
    final String restaurantName = summary.restaurant?.name ?? 'Restaurant';
    final String dateTimeLabel = order.placedAt != null
        ? _formatOrderDate(order.placedAt!, now)
        : '—';
    final int itemCount = order.items.fold(0, (s, i) => s + i.quantity);
    final String mode = order.fulfillmentMode == FulfillmentMode.delivery
        ? 'Delivery'
        : 'Pickup';
    final String summaryLine =
        '$itemCount ${itemCount == 1 ? 'item' : 'items'} • $mode';
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(restaurantName, style: text.titleSmall),
                    AppSpacing.vXs,
                    Text(
                      dateTimeLabel,
                      style: text.bodySmall?.copyWith(
                        color: context.textMuted,
                      ),
                    ),
                    AppSpacing.vXs,
                    Text(
                      PriceRow.format(order.total),
                      style: text.bodyMedium?.copyWith(
                        color: context.textMuted,
                      ),
                    ),
                    if (order.status != OrderStatus.completed) ...[
                      AppSpacing.vXs,
                      Text(
                        order.status.label,
                        style: text.bodySmall?.copyWith(
                          color: context.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.vSm,
          Text(
            summaryLine,
            style: text.bodySmall?.copyWith(
              color: context.textMuted,
            ),
          ),
          AppSpacing.vSm,
          Align(
            alignment: Alignment.centerLeft,
            child: LinkButton(
              label: 'View receipt',
              onPressed: () => context.push(Routes.orderReceipt(order.id)),
            ),
          ),
        ],
      ),
    );
  }
}

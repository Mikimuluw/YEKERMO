import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yekermo/features/orders/order_detail_controller.dart';
import 'package:yekermo/features/orders/order_detail_view.dart';
import 'package:yekermo/shared/extensions/context_extensions.dart';
import 'package:yekermo/shared/state/screen_state.dart';
import 'package:yekermo/shared/tokens/app_spacing.dart';
import 'package:yekermo/shared/widgets/app_scaffold.dart';
import 'package:yekermo/shared/widgets/async_state_view.dart';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ScreenState<OrderDetailVm> state = ref.watch(
      orderDetailControllerProvider,
    );
    return AppScaffold(
      title: 'Order details',
      body: AsyncStateView<OrderDetailVm>(
        state: state,
        emptyBuilder: (context) => const _OrderEmptyState(),
        dataBuilder: (context, data) => OrderDetailContent(viewModel: data),
      ),
    );
  }
}

class _OrderEmptyState extends StatelessWidget {
  const _OrderEmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Text(
        'Order details will appear here.',
        style: context.text.bodyMedium?.copyWith(
          color: context.colors.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

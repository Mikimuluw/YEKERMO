import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/features/orders/order_detail_controller.dart';
import 'package:yekermo/features/orders/order_detail_view.dart';
import 'package:yekermo/shared/extensions/context_extensions.dart';
import 'package:yekermo/shared/state/screen_state.dart';
import 'package:yekermo/shared/tokens/app_spacing.dart';
import 'package:yekermo/shared/widgets/app_loading.dart';
import 'package:yekermo/ui/app_scaffold.dart';
import 'package:yekermo/shared/widgets/async_state_view.dart';

class OrderConfirmationScreen extends ConsumerWidget {
  const OrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ScreenState<OrderDetailVm> state = ref.watch(
      orderDetailControllerProvider,
    );
    return AppScaffold(
      title: 'Order confirmed.',
      body: AsyncStateView<OrderDetailVm>(
        state: state,
        loadingBuilder: (_) =>
            const AppLoading(textOnly: true, message: 'Loading order details.'),
        emptyBuilder: (context) => const _OrderConfirmationEmpty(),
        dataBuilder: (context, data) => OrderDetailContent(
          viewModel: data,
          showConfirmationHeader: true,
          headerTitle: 'Order confirmed.',
          headerSubtitle: 'Updates will appear here.',
          showActions: true,
          onBackHome: () => context.go(Routes.home),
          onViewOrder: () => context.go(Routes.orderTrackingDetails(data.order.id)),
          onInviteSomeone: null,
        ),
      ),
    );
  }
}

class _OrderConfirmationEmpty extends StatelessWidget {
  const _OrderConfirmationEmpty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Text(
        'We couldn\'t load this order.',
        style: context.text.bodyMedium?.copyWith(
          color: context.textMuted,
        ),
      ),
    );
  }
}

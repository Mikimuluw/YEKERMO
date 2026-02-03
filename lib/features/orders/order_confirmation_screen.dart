import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:yekermo/app/referral_provider.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/features/orders/order_detail_controller.dart';
import 'package:yekermo/features/orders/order_detail_view.dart';
import 'package:yekermo/features/referral/referral_share.dart';
import 'package:yekermo/shared/extensions/context_extensions.dart';
import 'package:yekermo/shared/state/screen_state.dart';
import 'package:yekermo/shared/tokens/app_spacing.dart';
import 'package:yekermo/shared/widgets/app_scaffold.dart';
import 'package:yekermo/shared/widgets/async_state_view.dart';

class OrderConfirmationScreen extends ConsumerWidget {
  const OrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ScreenState<OrderDetailVm> state = ref.watch(
      orderDetailControllerProvider,
    );
    final referral = ref.watch(referralProvider);
    final code = referral.code;
    final VoidCallback? onInviteSomeone = code.isEmpty
        ? null
        : () async {
            await Share.share(referralShareMessage(code));
            ref.read(referralProvider.notifier).incrementSent();
          };
    return AppScaffold(
      title: 'Order complete',
      body: AsyncStateView<OrderDetailVm>(
        state: state,
        emptyBuilder: (context) => const _OrderConfirmationEmpty(),
        dataBuilder: (context, data) => OrderDetailContent(
          viewModel: data,
          showConfirmationHeader: true,
          headerTitle: 'Order confirmed.',
          headerSubtitle: "We'll keep you posted.",
          showActions: true,
          onBackHome: () => context.go(Routes.home),
          onViewOrder: () => context.go(Routes.orderDetails(data.order.id)),
          onInviteSomeone: onInviteSomeone,
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
        'Order details will appear here.',
        style: context.text.bodyMedium?.copyWith(
          color: context.colors.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

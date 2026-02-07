import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yekermo/app/di.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/domain/cart.dart';
import 'package:yekermo/domain/fees.dart';
import 'package:yekermo/features/cart/cart_controller.dart';
import 'package:yekermo/shared/state/screen_state.dart';
import 'package:yekermo/shared/widgets/async_state_view.dart';
import 'package:yekermo/theme/color_tokens.dart';
import 'package:yekermo/theme/radii.dart';
import 'package:yekermo/theme/spacing.dart';
import 'package:yekermo/shared/extensions/context_extensions.dart';
import 'package:yekermo/ui/app_button.dart';
import 'package:yekermo/ui/app_card.dart';
import 'package:yekermo/ui/app_bar_with_back.dart';
import 'package:yekermo/ui/app_scaffold.dart';
import 'package:yekermo/ui/empty_state.dart' as ui;
import 'package:yekermo/ui/link_button.dart';
import 'package:yekermo/ui/price_row.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ScreenState<CartVm> state = ref.watch(cartControllerProvider);
    final double bottomPadding =
        AppSpacing.tapTarget +
        MediaQuery.paddingOf(context).bottom +
        AppSpacing.lg * 2;

    return AppScaffold(
      appBar: const AppBarWithBack(title: 'Your cart'),
      body: AsyncStateView<CartVm>(
        state: state,
        emptyBuilder: (_) => _CartEmpty(bottomPadding: bottomPadding),
        dataBuilder: (context, data) => _CartContent(
          vm: data,
          bottomPadding: bottomPadding,
          onCheckout: () => context.go(Routes.checkout),
          onMinus: (line) {
            final id = line.item.id;
            if (line.quantity > 1) {
              ref
                  .read(cartControllerProvider.notifier)
                  .updateQuantity(id, line.quantity - 1);
            } else {
              ref.read(cartControllerProvider.notifier).removeItem(id);
            }
          },
          onPlus: (line) {
            ref.read(cartControllerProvider.notifier).addItem(line.item, 1);
          },
        ),
      ),
    );
  }
}

class _CartEmpty extends StatelessWidget {
  const _CartEmpty({required this.bottomPadding});

  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: AppSpacing.pagePadding.copyWith(bottom: bottomPadding),
          children: [
            ui.EmptyState(
              title: 'Your cart is quiet for now.',
              action: LinkButton(label: 'Browse restaurants', onPressed: () {}),
            ),
            AppSpacing.vXl,
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            top: false,
            minimum: const EdgeInsets.only(top: AppSpacing.sm),
            child: Padding(
              padding: AppSpacing.pagePadding,
              child: AppButton(label: 'Checkout', onPressed: null),
            ),
          ),
        ),
      ],
    );
  }
}

class _CartContent extends StatelessWidget {
  const _CartContent({
    required this.vm,
    required this.bottomPadding,
    required this.onCheckout,
    required this.onMinus,
    required this.onPlus,
  });

  final CartVm vm;
  final double bottomPadding;
  final VoidCallback? onCheckout;
  final void Function(CartLineItem line) onMinus;
  final void Function(CartLineItem line) onPlus;

  @override
  Widget build(BuildContext context) {
    final FeeBreakdown f = vm.fees;
    return Stack(
      children: [
        ListView(
          padding: AppSpacing.pagePadding.copyWith(bottom: bottomPadding),
          children: [
            _RestaurantHeader(name: vm.restaurantName, meta: vm.restaurantMeta),
            AppSpacing.vMd,
            ...vm.items.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _CartItemRow(
                  line: line,
                  onMinus: () => onMinus(line),
                  onPlus: () => onPlus(line),
                ),
              ),
            ),
            AppSpacing.vMd,
            _FeeBreakdownCard(
              subtotal: f.subtotal,
              deliveryFee: f.deliveryFee,
              serviceFee: f.serviceFee,
              tax: f.tax,
              total: f.total,
            ),
            AppSpacing.vXl,
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            top: false,
            minimum: const EdgeInsets.only(top: AppSpacing.sm),
            child: Padding(
              padding: AppSpacing.pagePadding,
              child: AppButton(label: 'Checkout', onPressed: onCheckout),
            ),
          ),
        ),
      ],
    );
  }
}

class _RestaurantHeader extends StatelessWidget {
  const _RestaurantHeader({required this.name, required this.meta});

  final String name;
  final String meta;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final String display = meta.isEmpty ? name : '$name • $meta';
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: ColorTokens.surfaceVariant,
            borderRadius: AppRadii.br12,
          ),
        ),
        AppSpacing.hMd,
        Expanded(
          child: Text(
            display,
            style: text.bodyMedium?.copyWith(
              color: context.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class _CartItemRow extends StatelessWidget {
  const _CartItemRow({
    required this.line,
    required this.onMinus,
    required this.onPlus,
  });

  final CartLineItem line;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = context.text;
    return AppCard(
      padding: AppSpacing.cardPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line.item.name, style: text.titleSmall),
                AppSpacing.vXs,
                Text(
                  line.item.description,
                  style: text.bodySmall?.copyWith(
                    color: context.textMuted,
                  ),
                ),
                AppSpacing.vSm,
                Row(
                  children: [
                    IconButton(
                      onPressed: line.quantity > 1 ? onMinus : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                    SizedBox(
                      width: 28,
                      child: Text(
                        line.quantity.toString(),
                        style: text.titleSmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      onPressed: onPlus,
                      icon: const Icon(Icons.add_circle_outline),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.hMd,
          Text(
            PriceRow.format(line.total),
            style: text.titleSmall?.copyWith(
              color: context.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeeBreakdownCard extends StatelessWidget {
  const _FeeBreakdownCard({
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.tax,
    required this.total,
  });

  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double tax;
  final double total;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PriceRow(label: 'Subtotal', value: subtotal),
          PriceRow(label: 'Delivery fee', value: deliveryFee),
          PriceRow(label: 'Service fee', value: serviceFee),
          PriceRow(label: 'Estimated taxes', value: tax),
          AppSpacing.vXs,
          PriceRow(label: 'Total', value: total, emphasize: true),
        ],
      ),
    );
  }
}

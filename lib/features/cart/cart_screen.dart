import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yekermo/app/di.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/domain/cart.dart';
import 'package:yekermo/features/cart/cart_controller.dart';
import 'package:yekermo/shared/extensions/context_extensions.dart';
import 'package:yekermo/shared/state/screen_state.dart';
import 'package:yekermo/shared/tokens/app_spacing.dart';
import 'package:yekermo/shared/widgets/app_button.dart';
import 'package:yekermo/shared/widgets/app_card.dart';
import 'package:yekermo/shared/widgets/app_scaffold.dart';
import 'package:yekermo/shared/widgets/app_section_header.dart';
import 'package:yekermo/shared/widgets/async_state_view.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ScreenState<CartVm> state = ref.watch(cartControllerProvider);
    return AppScaffold(
      title: 'Cart',
      body: AsyncStateView<CartVm>(
        state: state,
        emptyBuilder: (_) => _CartEmpty(),
        dataBuilder: (context, data) => _CartBody(
          vm: data,
          onUpdate: (itemId, quantity) => ref
              .read(cartControllerProvider.notifier)
              .updateQuantity(itemId, quantity),
          onRemove: (itemId) =>
              ref.read(cartControllerProvider.notifier).removeItem(itemId),
        ),
      ),
    );
  }
}

class _CartEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Text(
        'Your cart is quiet for now.',
        style: context.text.bodyMedium?.copyWith(
          color: context.colors.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

class _CartBody extends StatelessWidget {
  const _CartBody({
    required this.vm,
    required this.onUpdate,
    required this.onRemove,
  });

  final CartVm vm;
  final void Function(String itemId, int quantity) onUpdate;
  final void Function(String itemId) onRemove;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        const AppSectionHeader(title: 'Items'),
        AppSpacing.vSm,
        Text(
          'You can change anything.',
          style: context.text.bodySmall?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.6),
          ),
        ),
        AppSpacing.vMd,
        ...vm.items.map(
          (lineItem) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AppCard(
              padding: AppSpacing.cardPadding,
              child: _CartLineItem(
                lineItem: lineItem,
                onUpdate: onUpdate,
                onRemove: onRemove,
              ),
            ),
          ),
        ),
        AppSpacing.vMd,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Subtotal', style: context.text.titleSmall),
            Text(
              '\$${vm.subtotal.toStringAsFixed(2)}',
              style: context.text.titleSmall,
            ),
          ],
        ),
        AppSpacing.vMd,
        AppButton(
          label: 'Review order',
          onPressed: () => context.push(Routes.checkout),
        ),
      ],
    );
  }
}

class _CartLineItem extends StatelessWidget {
  const _CartLineItem({
    required this.lineItem,
    required this.onUpdate,
    required this.onRemove,
  });

  final CartLineItem lineItem;
  final void Function(String itemId, int quantity) onUpdate;
  final void Function(String itemId) onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(lineItem.item.name, style: context.text.titleMedium),
        AppSpacing.vXs,
        Text(
          lineItem.item.description,
          style: context.text.bodySmall?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.7),
          ),
        ),
        AppSpacing.vSm,
        Row(
          children: [
            IconButton(
              onPressed: lineItem.quantity > 1
                  ? () => onUpdate(lineItem.item.id, lineItem.quantity - 1)
                  : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text(
              lineItem.quantity.toString(),
              style: context.text.titleMedium,
            ),
            IconButton(
              onPressed: () =>
                  onUpdate(lineItem.item.id, lineItem.quantity + 1),
              icon: const Icon(Icons.add_circle_outline),
            ),
            const Spacer(),
            AppButton(
              label: 'Remove',
              onPressed: () => onRemove(lineItem.item.id),
              style: AppButtonStyle.secondary,
            ),
          ],
        ),
      ],
    );
  }
}

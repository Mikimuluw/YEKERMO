import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yekermo/app/di.dart';
import 'package:yekermo/features/payments/payment_controller.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/order_draft.dart';
import 'package:yekermo/domain/payment_method.dart';
import 'package:yekermo/shared/state/screen_state.dart';
import 'package:yekermo/shared/widgets/app_loading.dart';
import 'package:yekermo/theme/color_tokens.dart';
import 'package:yekermo/theme/radii.dart';
import 'package:yekermo/theme/spacing.dart';
import 'package:yekermo/shared/extensions/context_extensions.dart';
import 'package:yekermo/ui/app_button.dart';
import 'package:yekermo/ui/app_bar_with_back.dart';
import 'package:yekermo/ui/app_card.dart';
import 'package:yekermo/ui/app_scaffold.dart';
import 'package:yekermo/ui/price_row.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ScreenState<OrderDraft> state = ref.watch(checkoutControllerProvider);
    final double bottomPadding =
        AppSpacing.tapTarget +
        MediaQuery.paddingOf(context).bottom +
        AppSpacing.lg * 2;

    return AppScaffold(
      appBar: const AppBarWithBack(title: 'Checkout'),
      body: switch (state) {
        InitialState<OrderDraft>() => const AppLoading(),
        LoadingState<OrderDraft>() => const AppLoading(),
        StaleLoadingState<OrderDraft>() => const AppLoading(),
        EmptyState<OrderDraft>() => _CheckoutEmpty(
          bottomPadding: bottomPadding,
        ),
        ErrorState<OrderDraft>(:final failure) => _CheckoutError(
          message: failure.message,
          bottomPadding: bottomPadding,
        ),
        SuccessState<OrderDraft>(:final data) => _CheckoutContent(
          draft: data,
          bottomPadding: bottomPadding,
          paymentLast4: _paymentLast4(ref),
          onPlaceOrder: () => _placeOrder(context, ref),
        ),
      },
    );
  }

  static String _paymentLast4(WidgetRef ref) {
    final paymentState = ref.read(paymentControllerProvider);
    return switch (paymentState) {
      SuccessState(:final data) => data.method?.last4 ?? '4242',
      _ => '4242',
    };
  }

  static Future<void> _placeOrder(BuildContext context, WidgetRef ref) async {
    final paymentState = ref.read(paymentControllerProvider);
    final PaymentMethod method = switch (paymentState) {
      SuccessState<PaymentVm>(:final data) =>
        data.method ?? const PaymentMethod(brand: 'Card', last4: '4242'),
      _ => const PaymentMethod(brand: 'Card', last4: '4242'),
    };
    final String txId = 'stub-${DateTime.now().millisecondsSinceEpoch}';
    final Order? order = await ref
        .read(checkoutControllerProvider.notifier)
        .payAndPlaceOrder(paymentMethod: method, paymentTransactionId: txId);
    if (context.mounted && order != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Order placed.')));
    }
  }
}

class _CheckoutEmpty extends StatelessWidget {
  const _CheckoutEmpty({required this.bottomPadding});

  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppSpacing.pagePadding.copyWith(bottom: bottomPadding),
      children: [
        Center(
          child: Padding(
            padding: AppSpacing.pagePadding,
            child: Text(
              'Add items to review your order.',
              style: context.text.bodyMedium?.copyWith(
                color: context.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        AppSpacing.vXl,
      ],
    );
  }
}

class _CheckoutError extends StatelessWidget {
  const _CheckoutError({required this.message, required this.bottomPadding});

  final String message;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppSpacing.pagePadding.copyWith(bottom: bottomPadding),
      children: [
        Center(
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
        ),
        AppSpacing.vXl,
      ],
    );
  }
}

class _CheckoutContent extends StatelessWidget {
  const _CheckoutContent({
    required this.draft,
    required this.bottomPadding,
    required this.paymentLast4,
    required this.onPlaceOrder,
  });

  final OrderDraft draft;
  final double bottomPadding;
  final String paymentLast4;
  final VoidCallback onPlaceOrder;

  static String _addressLabel(Address a) {
    final name = a.label.name;
    return name.isEmpty
        ? 'Address'
        : '${name[0].toUpperCase()}${name.substring(1)}';
  }

  static String _addressLine(Address a) => '${a.line1}, ${a.city}';

  @override
  Widget build(BuildContext context) {
    final Address? address = draft.address;
    final String addressLabel = address != null
        ? _addressLabel(address)
        : 'Address';
    final String addressLine = address != null ? _addressLine(address) : '—';
    final double deliveryAndFees =
        draft.fees.deliveryFee + draft.fees.serviceFee;

    return Stack(
      children: [
        ListView(
          padding: AppSpacing.pagePadding.copyWith(bottom: bottomPadding),
          children: [
            _AddressCard(label: addressLabel, address: addressLine),
            AppSpacing.vMd,
            _PaymentCard(last4: paymentLast4),
            AppSpacing.vMd,
            _OrderSummaryCard(
              lines: draft.items
                  .map(
                    (line) => _OrderLineDto(
                      name: line.item.name,
                      quantity: line.quantity,
                      lineTotal: line.total,
                    ),
                  )
                  .toList(),
              subtotal: draft.fees.subtotal,
              deliveryAndFees: deliveryAndFees,
              tax: draft.fees.tax,
              total: draft.fees.total,
            ),
            AppSpacing.vSm,
            Text(
              'Totals may adjust at confirmation.',
              style: context.text.bodySmall?.copyWith(color: context.muted),
            ),
            AppSpacing.vLg,
            Text(
              'Your order will be prepared with care and delivered to your door.',
              style: context.text.bodySmall?.copyWith(color: context.muted),
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
              child: AppButton(label: 'Place order', onPressed: onPlaceOrder),
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderLineDto {
  const _OrderLineDto({
    required this.name,
    required this.quantity,
    required this.lineTotal,
  });

  final String name;
  final int quantity;
  final double lineTotal;
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.label, required this.address});

  final String label;
  final String address;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = context.text;
    return AppCard(
      onTap: () {},
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery address',
                  style: text.labelMedium?.copyWith(
                    color: context.textMuted,
                  ),
                ),
                AppSpacing.vXs,
                Text(label, style: text.titleSmall),
                AppSpacing.vXs,
                Text(
                  address,
                  style: text.bodyMedium?.copyWith(
                    color: context.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: context.textTertiary,
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.last4});

  final String last4;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return AppCard(
      onTap: () {},
      child: Row(
        children: [
          Container(
            width: 40,
            height: 28,
            decoration: BoxDecoration(
              color: ColorTokens.surfaceVariant,
              borderRadius: AppRadii.br12,
            ),
          ),
          AppSpacing.hMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment method',
                  style: text.labelMedium?.copyWith(
                    color: context.textMuted,
                  ),
                ),
                AppSpacing.vXs,
                Text('•••• $last4', style: text.titleSmall),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: context.textTertiary,
          ),
        ],
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({
    required this.lines,
    required this.subtotal,
    required this.deliveryAndFees,
    required this.tax,
    required this.total,
  });

  final List<_OrderLineDto> lines;
  final double subtotal;
  final double deliveryAndFees;
  final double tax;
  final double total;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = context.text;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order summary',
            style: text.titleSmall?.copyWith(fontWeight: FontWeight.w500),
          ),
          AppSpacing.vSm,
          ...lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${line.name} × ${line.quantity}',
                    style: text.bodyMedium?.copyWith(
                      color: context.textMuted,
                    ),
                  ),
                  Text(
                    PriceRow.format(line.lineTotal),
                    style: text.bodyMedium?.copyWith(
                      color: context.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppSpacing.vSm,
          const Divider(height: 1),
          AppSpacing.vSm,
          PriceRow(label: 'Subtotal', value: subtotal),
          PriceRow(label: 'Delivery & fees', value: deliveryAndFees),
          PriceRow(label: 'Estimated taxes', value: tax),
          AppSpacing.vXs,
          PriceRow(label: 'Total', value: total, emphasize: true),
        ],
      ),
    );
  }
}

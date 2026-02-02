import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yekermo/app/di.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/data/payments/payment_result.dart';
import 'package:yekermo/domain/cart.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/order_draft.dart';
import 'package:yekermo/domain/payment_method.dart';
import 'package:yekermo/features/payments/payment_controller.dart';
import 'package:yekermo/core/copy/trust_copy.dart';
import 'package:yekermo/observability/analytics.dart';
import 'package:yekermo/shared/extensions/context_extensions.dart';
import 'package:yekermo/shared/state/screen_state.dart';
import 'package:yekermo/shared/tokens/app_spacing.dart';
import 'package:yekermo/shared/widgets/app_button.dart';
import 'package:yekermo/shared/widgets/app_card.dart';
import 'package:yekermo/shared/widgets/app_scaffold.dart';
import 'package:yekermo/shared/widgets/app_section_header.dart';
import 'package:yekermo/shared/widgets/app_text_field.dart';
import 'package:yekermo/shared/widgets/async_state_view.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final TextEditingController _cardNumber = TextEditingController();
  final TextEditingController _expiry = TextEditingController();
  final TextEditingController _cvc = TextEditingController();
  bool _hasCardNumber = false;

  @override
  void initState() {
    super.initState();
    _cardNumber.addListener(_syncCardState);
  }

  @override
  void dispose() {
    _cardNumber.removeListener(_syncCardState);
    _cardNumber.dispose();
    _expiry.dispose();
    _cvc.dispose();
    super.dispose();
  }

  void _syncCardState() {
    final String digits = _cardNumber.text.replaceAll(RegExp(r'\D'), '');
    final bool nextHasCardNumber = digits.length >= 4;
    if (nextHasCardNumber != _hasCardNumber) {
      setState(() => _hasCardNumber = nextHasCardNumber);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ScreenState<OrderDraft> state = ref.watch(checkoutControllerProvider);
    final ScreenState<PaymentVm> paymentState = ref.watch(
      paymentControllerProvider,
    );
    final bool hasPaymentError = paymentState is ErrorState<PaymentVm>;
    final bool needsAddress = switch (state) {
      EmptyState<OrderDraft>(:final message) =>
        (message ?? '').toLowerCase().contains('address'),
      _ => false,
    };
    return AppScaffold(
      title: 'Review order',
      body: AsyncStateView<OrderDraft>(
        state: state,
        emptyBuilder: (_) => _CheckoutEmpty(
          message: _emptyMessage(state),
          showAddressAction: needsAddress,
          onAddAddress: () => context.push(Routes.addressManager),
        ),
        dataBuilder: (context, data) => _CheckoutBody(
          draft: data,
          paymentState: paymentState,
          hasPaymentError: hasPaymentError,
          cardNumber: _cardNumber,
          expiry: _expiry,
          cvc: _cvc,
          hasCardNumber: _hasCardNumber,
          onFulfillmentChange: (mode) => ref
              .read(checkoutControllerProvider.notifier)
              .setFulfillment(mode),
          onAddAddress: () => context.push(Routes.addressManager),
          onNotesChanged: (value) =>
              ref.read(checkoutControllerProvider.notifier).setNotes(value),
          onPayAndPlaceOrder: () async {
            final PaymentMethod? method = _buildPaymentMethod(_cardNumber.text);
            if (method == null) return;
            ref.read(paymentControllerProvider.notifier).setMethod(method);
            final PaymentResult result = await ref
                .read(paymentControllerProvider.notifier)
                .processPayment(amount: data.fees.total, method: method);
            if (!result.isSuccess) return;
            final order = await ref
                .read(checkoutControllerProvider.notifier)
                .payAndPlaceOrder(
                  paymentMethod: method,
                  paymentTransactionId: result.transactionId,
                );
            if (order == null) return;
            if (!context.mounted) return;
            context.go(Routes.orderConfirmation(order.id));
          },
          onRetryPayment: () {
            ref
                .read(analyticsProvider)
                .track(AnalyticsEvents.paymentRetryTriggered);
          },
        ),
      ),
    );
  }

  String _emptyMessage(ScreenState<OrderDraft> state) {
    return switch (state) {
      EmptyState<OrderDraft>(:final message) =>
        message ?? 'Review details will show here.',
      _ => 'Review details will show here.',
    };
  }
}

class _CheckoutEmpty extends StatelessWidget {
  const _CheckoutEmpty({
    required this.message,
    required this.showAddressAction,
    required this.onAddAddress,
  });

  final String message;
  final bool showAddressAction;
  final VoidCallback onAddAddress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          if (showAddressAction) ...[
            AppSpacing.vSm,
            AppButton(
              label: 'Add address',
              onPressed: onAddAddress,
              style: AppButtonStyle.secondary,
            ),
          ],
        ],
      ),
    );
  }
}

class _CheckoutBody extends StatelessWidget {
  const _CheckoutBody({
    required this.draft,
    required this.paymentState,
    required this.hasPaymentError,
    required this.cardNumber,
    required this.expiry,
    required this.cvc,
    required this.hasCardNumber,
    required this.onFulfillmentChange,
    required this.onAddAddress,
    required this.onNotesChanged,
    required this.onPayAndPlaceOrder,
    required this.onRetryPayment,
  });

  final OrderDraft draft;
  final ScreenState<PaymentVm> paymentState;
  final bool hasPaymentError;
  final TextEditingController cardNumber;
  final TextEditingController expiry;
  final TextEditingController cvc;
  final bool hasCardNumber;
  final ValueChanged<FulfillmentMode> onFulfillmentChange;
  final VoidCallback onAddAddress;
  final ValueChanged<String> onNotesChanged;
  final Future<void> Function() onPayAndPlaceOrder;
  final VoidCallback onRetryPayment;

  @override
  Widget build(BuildContext context) {
    final bool canPlace =
        draft.items.isNotEmpty &&
        (draft.fulfillmentMode == FulfillmentMode.pickup ||
            draft.address != null);
    final bool isProcessing = paymentState is LoadingState<PaymentVm>;
    final String? placeHint = canPlace
        ? null
        : 'Add a delivery address to place this order.';
    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        const AppSectionHeader(title: 'Fulfillment'),
        AppSpacing.vSm,
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            FilterChip(
              label: const Text('Delivery'),
              selected: draft.fulfillmentMode == FulfillmentMode.delivery,
              onSelected: (_) => onFulfillmentChange(FulfillmentMode.delivery),
            ),
            FilterChip(
              label: const Text('Pickup'),
              selected: draft.fulfillmentMode == FulfillmentMode.pickup,
              onSelected: (_) => onFulfillmentChange(FulfillmentMode.pickup),
            ),
          ],
        ),
        AppSpacing.vMd,
        if (draft.fulfillmentMode == FulfillmentMode.pickup) ...[
          Text(
            'Pickup can be faster right now.',
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          AppSpacing.vMd,
        ],
        if (draft.fulfillmentMode == FulfillmentMode.delivery) ...[
          Text(
            'Delivery fits tonight.',
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          AppSpacing.vMd,
        ],
        if (draft.fulfillmentMode == FulfillmentMode.delivery) ...[
          _AddressSection(address: draft.address, onAddAddress: onAddAddress),
          AppSpacing.vMd,
        ],
        const AppSectionHeader(title: 'Items'),
        AppSpacing.vSm,
        ...draft.items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AppCard(
              padding: AppSpacing.cardPadding,
              child: _OrderItemRow(lineItem: item),
            ),
          ),
        ),
        AppSpacing.vMd,
        const AppSectionHeader(title: 'Fees'),
        AppSpacing.vSm,
        _FeeRow(label: 'Subtotal', value: draft.fees.subtotal),
        _FeeRow(label: 'Service fee', value: draft.fees.serviceFee),
        if (draft.fulfillmentMode == FulfillmentMode.delivery)
          _FeeRow(label: 'Delivery fee', value: draft.fees.deliveryFee),
        _FeeRow(label: 'Tax', value: draft.fees.tax),
        AppSpacing.vSm,
        _FeeRow(label: 'Total', value: draft.fees.total, emphasize: true),
        AppSpacing.vMd,
        const AppSectionHeader(title: 'Notes'),
        AppSpacing.vSm,
        AppTextField(
          hintText: 'Add a note (optional)',
          onSubmitted: onNotesChanged,
        ),
        AppSpacing.vMd,
        const AppSectionHeader(title: 'Payment'),
        AppSpacing.vSm,
        AppCard(
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: cardNumber,
                hintText: 'Card number',
                enabled: !isProcessing,
              ),
              AppSpacing.vSm,
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: expiry,
                      hintText: 'MM/YY',
                      enabled: !isProcessing,
                    ),
                  ),
                  AppSpacing.hSm,
                  Expanded(
                    child: AppTextField(
                      controller: cvc,
                      hintText: 'CVC',
                      enabled: !isProcessing,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        AppSpacing.vSm,
        if (hasPaymentError) ...[
          // TODO(phase8): categorize retry copy by error (network/timeout/unknown).
          Text(
            TrustCopy.paymentNotCharged,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          Text(
            TrustCopy.paymentTryAgain,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          AppSpacing.vSm,
        ],
        if (isProcessing) ...[
          Text(
            'Processing payment...',
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          AppSpacing.vSm,
        ],
        if (placeHint != null && !hasPaymentError) ...[
          Text(
            placeHint,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          AppSpacing.vSm,
        ],
        if (!hasCardNumber && !hasPaymentError) ...[
          Text(
            'Add a payment method to continue.',
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          AppSpacing.vSm,
        ],
        AppButton(
          label: hasPaymentError ? 'Retry payment' : 'Pay and place order',
          onPressed: canPlace && hasCardNumber && !isProcessing
              ? () async {
                  if (hasPaymentError) {
                    onRetryPayment();
                  }
                  await onPayAndPlaceOrder();
                }
              : null,
        ),
        if (!hasPaymentError) ...[
          AppSpacing.vSm,
          Text(
            "You'll see a confirmation next.",
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ],
    );
  }
}

PaymentMethod? _buildPaymentMethod(String rawNumber) {
  final String digits = rawNumber.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 4) return null;
  return PaymentMethod(
    brand: 'Card',
    last4: digits.substring(digits.length - 4),
  );
}

class _AddressSection extends StatelessWidget {
  const _AddressSection({required this.address, required this.onAddAddress});

  final Address? address;
  final VoidCallback onAddAddress;

  @override
  Widget build(BuildContext context) {
    if (address == null) {
      return AppCard(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Delivery address', style: context.text.titleSmall),
            AppSpacing.vXs,
            Text(
              'Add a delivery address to continue.',
              style: context.text.bodySmall?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
            AppSpacing.vSm,
            AppButton(
              label: 'Add address',
              onPressed: onAddAddress,
              style: AppButtonStyle.secondary,
            ),
          ],
        ),
      );
    }

    final Address addressData = address!;
    return AppCard(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Delivery to', style: context.text.titleSmall),
          AppSpacing.vXs,
          Text(
            '${_label(addressData.label)} • ${addressData.line1}',
            style: context.text.bodySmall,
          ),
          Text(
            addressData.city,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          if ((addressData.notes ?? '').isNotEmpty) ...[
            AppSpacing.vXs,
            Text(
              addressData.notes!,
              style: context.text.bodySmall?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
          AppSpacing.vSm,
          AppButton(
            label: 'Manage address',
            onPressed: onAddAddress,
            style: AppButtonStyle.secondary,
          ),
        ],
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow({required this.lineItem});

  final CartLineItem lineItem;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lineItem.item.name, style: context.text.titleMedium),
              AppSpacing.vXs,
              Text(
                'Qty ${lineItem.quantity}',
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        Text(
          '\$${lineItem.total.toStringAsFixed(2)}',
          style: context.text.titleSmall,
        ),
      ],
    );
  }
}

class _FeeRow extends StatelessWidget {
  const _FeeRow({
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
        : context.text.bodyMedium;
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

String _label(AddressLabel label) {
  switch (label) {
    case AddressLabel.home:
      return 'Home';
    case AddressLabel.work:
      return 'Work';
  }
}

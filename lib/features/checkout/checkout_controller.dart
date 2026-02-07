import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yekermo/app/di.dart';
import 'package:yekermo/observability/app_log.dart';
import 'package:yekermo/domain/cart.dart';
import 'package:yekermo/domain/failure.dart';
import 'package:yekermo/domain/order_failures.dart';
import 'package:yekermo/domain/fees.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/order_draft.dart';
import 'package:yekermo/domain/payment_method.dart';
import 'package:yekermo/shared/state/screen_state.dart';

class CheckoutController extends Notifier<ScreenState<OrderDraft>> {
  FulfillmentMode _mode = FulfillmentMode.delivery;
  String? _notes;
  final Set<String> _processedPayments = {};

  @override
  ScreenState<OrderDraft> build() {
    ref.watch(cartControllerProvider);
    ref.watch(addressScreenStateProvider);
    return _buildState();
  }

  void setFulfillment(FulfillmentMode mode) {
    _mode = mode;
    state = _buildState();
  }

  void setNotes(String notes) {
    _notes = notes;
    state = _buildState();
  }

  Future<Order?> payAndPlaceOrder({
    required PaymentMethod paymentMethod,
    required String paymentTransactionId,
  }) async {
    final ScreenState<OrderDraft> current = state;
    if (current is! SuccessState<OrderDraft>) return null;
    final OrderDraft draft = current.data;
    if (!_canPlace(draft)) return null;
    if (_processedPayments.contains(paymentTransactionId)) {
      return null;
    }
    try {
      final Order order = await ref
          .read(ordersRepositoryProvider)
          .placeOrder(draft, paymentMethod: paymentMethod);
      _processedPayments.add(paymentTransactionId);
      ref.read(cartRepositoryProvider).clear();
      ref.read(cartControllerProvider.notifier).refresh();
      ref.invalidate(homeControllerProvider);
      ref.invalidate(ordersControllerProvider);
      return order;
    } catch (error, stackTrace) {
      final Failure failure = error is PlaceOrderException
          ? _failureForPlaceOrderCode(error.failure.code)
          : const Failure('Unable to place order right now.');
      AppLog.error('Place order failed: ${failure.message}', error, stackTrace);
      state = ScreenState.error(failure);
      return null;
    }
  }

  ScreenState<OrderDraft> _buildState() {
    final List<CartLineItem> items = ref
        .read(cartRepositoryProvider)
        .getItems();
    final ScreenState<Address?> addressState = ref.read(addressScreenStateProvider);
    final Address? address = addressState is SuccessState<Address?> ? addressState.data : null;
    final double subtotal = items.fold(0, (sum, item) => sum + item.total);
    final FeeBreakdown baseFees = FeeBreakdown.fromSubtotal(subtotal);
    final double deliveryFee = _mode == FulfillmentMode.delivery
        ? baseFees.deliveryFee
        : 0;
    final FeeBreakdown fees = FeeBreakdown(
      subtotal: subtotal,
      serviceFee: baseFees.serviceFee,
      deliveryFee: deliveryFee,
      tax: baseFees.tax,
    );

    final OrderDraft draft = OrderDraft(
      items: items,
      fulfillmentMode: _mode,
      address: address,
      notes: _notes,
      fees: fees,
    );

    if (items.isEmpty) {
      return ScreenState.empty('Add items to review your order.');
    }
    return ScreenState.success(draft);
  }

  Failure _failureForPlaceOrderCode(PlaceOrderFailureCode code) {
    debugPrint('PlaceOrderFailure: $code');
    switch (code) {
      case PlaceOrderFailureCode.restaurantClosed:
        return const Failure('Restaurant is closed.');
      case PlaceOrderFailureCode.serviceModeUnavailable:
      case PlaceOrderFailureCode.unknownRestaurant:
      case PlaceOrderFailureCode.unknown:
        return const Failure('Unable to place order right now.');
    }
  }

  bool _canPlace(OrderDraft draft) {
    if (draft.items.isEmpty) return false;
    if (draft.fulfillmentMode == FulfillmentMode.delivery &&
        draft.address == null) {
      return false;
    }
    return true;
  }
}

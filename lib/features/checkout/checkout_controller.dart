import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yekermo/app/di.dart';
import 'package:yekermo/domain/cart.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/order_draft.dart';
import 'package:yekermo/shared/state/screen_state.dart';

class CheckoutController extends Notifier<ScreenState<OrderDraft>> {
  static const double _serviceFee = 2.25;
  static const double _deliveryFee = 3.75;
  static const double _taxRate = 0.05;

  FulfillmentMode _mode = FulfillmentMode.delivery;
  String? _notes;

  @override
  ScreenState<OrderDraft> build() {
    ref.watch(cartControllerProvider);
    ref.watch(addressControllerProvider);
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

  ScreenState<OrderDraft> _buildState() {
    final List<CartLineItem> items =
        ref.read(cartRepositoryProvider).getItems();
    final ScreenState<Address?> addressState =
        ref.read(addressControllerProvider);
    final Address? address = switch (addressState) {
      SuccessState<Address?>(:final data) => data,
      _ => null,
    };
    final double subtotal =
        items.fold(0, (sum, item) => sum + item.total);
    final double deliveryFee =
        _mode == FulfillmentMode.delivery ? _deliveryFee : 0;
    final double tax = subtotal * _taxRate;

    final FeeBreakdown fees = FeeBreakdown(
      subtotal: subtotal,
      serviceFee: _serviceFee,
      deliveryFee: deliveryFee,
      tax: tax,
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
}

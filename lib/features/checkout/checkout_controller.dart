import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yekermo/app/di.dart';
import 'package:yekermo/domain/cart.dart';
import 'package:yekermo/domain/failure.dart';
import 'package:yekermo/domain/fees.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/order_draft.dart';
import 'package:yekermo/domain/payment_method.dart';
import 'package:yekermo/shared/state/screen_state.dart';

class CheckoutController extends Notifier<ScreenState<OrderDraft>> {
  static const double _serviceFee = 2.25;
  static const double _deliveryFee = 3.75;
  static const double _taxRate = 0.05;

  FulfillmentMode _mode = FulfillmentMode.delivery;
  String? _notes;
  final Set<String> _processedPayments = {};

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
    } catch (error) {
      state = ScreenState.error(
        const Failure('Unable to place order right now.'),
      );
      return null;
    }
  }

  ScreenState<OrderDraft> _buildState() {
    final List<CartLineItem> items = ref
        .read(cartRepositoryProvider)
        .getItems();
    final Address? address = ref.read(addressRepositoryProvider).getDefault();
    final double subtotal = items.fold(0, (sum, item) => sum + item.total);
    final double deliveryFee = _mode == FulfillmentMode.delivery
        ? _deliveryFee
        : 0;
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

  bool _canPlace(OrderDraft draft) {
    if (draft.items.isEmpty) return false;
    if (draft.fulfillmentMode == FulfillmentMode.delivery &&
        draft.address == null) {
      return false;
    }
    return true;
  }
}

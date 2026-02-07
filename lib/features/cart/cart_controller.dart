import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yekermo/app/providers.dart';
import 'package:yekermo/domain/cart.dart';
import 'package:yekermo/domain/fees.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/shared/state/screen_state.dart';

/// Cart state and mutations. Currently allows any items; when wiring checkout,
/// decide policy: one-restaurant-at-a-time (typical for delivery) with a calm
/// "Replace cart?" flow when adding from a different restaurant, or allow mixed.
class CartController extends Notifier<ScreenState<CartVm>> {
  @override
  ScreenState<CartVm> build() {
    return _loadState();
  }

  List<CartLineItem> getItems() => ref.read(cartRepositoryProvider).getItems();

  /// Returns true if the cart was cleared and replaced (different restaurant).
  bool addItem(MenuItem item, int quantity) {
    final repo = ref.read(cartRepositoryProvider);
    final items = repo.getItems();
    final bool didReplace =
        items.isNotEmpty && items.first.item.restaurantId != item.restaurantId;
    if (didReplace) {
      repo.clear();
    }
    repo.addItem(item, quantity);
    state = _loadState();
    return didReplace;
  }

  void updateQuantity(String itemId, int quantity) {
    ref.read(cartRepositoryProvider).updateQuantity(itemId, quantity);
    state = _loadState();
  }

  void removeItem(String itemId) {
    ref.read(cartRepositoryProvider).removeItem(itemId);
    state = _loadState();
  }

  void clear() {
    ref.read(cartRepositoryProvider).clear();
    state = _loadState();
  }

  void refresh() {
    state = _loadState();
  }

  ScreenState<CartVm> _loadState() {
    final items = ref.read(cartRepositoryProvider).getItems();
    if (items.isEmpty) {
      return ScreenState.empty('Your cart is quiet for now.');
    }
    final double subtotal = ref.read(cartRepositoryProvider).subtotal;
    final FeeBreakdown fees = FeeBreakdown.fromSubtotal(subtotal);
    final String restaurantName = _restaurantDisplayName(items);
    final String restaurantMeta = _restaurantDisplayMeta(items);
    return ScreenState.success(
      CartVm(
        items: items,
        subtotal: subtotal,
        totalCount: ref.read(cartRepositoryProvider).totalCount,
        fees: fees,
        restaurantName: restaurantName,
        restaurantMeta: restaurantMeta,
      ),
    );
  }

  static String _restaurantDisplayName(List<CartLineItem> items) {
    if (items.isEmpty) return 'Your order';
    return 'Your order';
  }

  static String _restaurantDisplayMeta(List<CartLineItem> items) {
    return '';
  }
}

class CartVm {
  const CartVm({
    required this.items,
    required this.subtotal,
    required this.totalCount,
    required this.fees,
    this.restaurantName = 'Your order',
    this.restaurantMeta = '',
  });

  final List<CartLineItem> items;
  final double subtotal;
  final int totalCount;
  final FeeBreakdown fees;
  final String restaurantName;
  final String restaurantMeta;
}

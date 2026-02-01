import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yekermo/app/providers.dart';
import 'package:yekermo/domain/cart.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/shared/state/screen_state.dart';

class CartController extends Notifier<ScreenState<CartVm>> {
  @override
  ScreenState<CartVm> build() {
    return _loadState();
  }

  List<CartLineItem> getItems() => ref.read(cartRepositoryProvider).getItems();

  void addItem(MenuItem item, int quantity) {
    ref.read(cartRepositoryProvider).addItem(item, quantity);
    state = _loadState();
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
    return ScreenState.success(
      CartVm(
        items: items,
        subtotal: ref.read(cartRepositoryProvider).subtotal,
        totalCount: ref.read(cartRepositoryProvider).totalCount,
      ),
    );
  }
}

class CartVm {
  const CartVm({
    required this.items,
    required this.subtotal,
    required this.totalCount,
  });

  final List<CartLineItem> items;
  final double subtotal;
  final int totalCount;
}

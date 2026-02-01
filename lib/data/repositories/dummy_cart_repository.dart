import 'package:yekermo/data/repositories/cart_repository.dart';
import 'package:yekermo/domain/cart.dart';
import 'package:yekermo/domain/models.dart';

class DummyCartRepository implements CartRepository {
  final Map<String, CartLineItem> _items = {};

  @override
  List<CartLineItem> getItems() => _items.values.toList(growable: false);

  @override
  int get totalCount =>
      _items.values.fold(0, (count, item) => count + item.quantity);

  @override
  double get subtotal => _items.values.fold(0, (sum, item) => sum + item.total);

  @override
  void addItem(MenuItem item, int quantity) {
    final CartLineItem? existing = _items[item.id];
    if (existing == null) {
      _items[item.id] = CartLineItem(item: item, quantity: quantity);
    } else {
      _items[item.id] = CartLineItem(
        item: existing.item,
        quantity: existing.quantity + quantity,
      );
    }
  }

  @override
  void updateQuantity(String itemId, int quantity) {
    final CartLineItem? existing = _items[itemId];
    if (existing == null) return;
    if (quantity <= 0) {
      _items.remove(itemId);
      return;
    }
    _items[itemId] = CartLineItem(item: existing.item, quantity: quantity);
  }

  @override
  void removeItem(String itemId) {
    _items.remove(itemId);
  }

  @override
  void clear() {
    _items.clear();
  }
}

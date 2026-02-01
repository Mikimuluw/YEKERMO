import 'package:yekermo/domain/cart.dart';
import 'package:yekermo/domain/models.dart';

abstract class CartRepository {
  List<CartLineItem> getItems();
  int get totalCount;
  double get subtotal;

  void addItem(MenuItem item, int quantity);
  void updateQuantity(String itemId, int quantity);
  void removeItem(String itemId);
  void clear();
}

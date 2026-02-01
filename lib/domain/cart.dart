import 'package:yekermo/domain/models.dart';

class CartLineItem {
  const CartLineItem({required this.item, required this.quantity});

  final MenuItem item;
  final int quantity;

  double get total => item.price * quantity;
}

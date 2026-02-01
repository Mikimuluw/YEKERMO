import 'package:yekermo/domain/models.dart';

class OrderItemDto {
  const OrderItemDto({required this.menuItemId, required this.quantity});

  final String menuItemId;
  final int quantity;

  OrderItem toModel() => OrderItem(menuItemId: menuItemId, quantity: quantity);
}

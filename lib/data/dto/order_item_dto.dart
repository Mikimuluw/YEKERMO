import 'package:yekermo/domain/models.dart';

class OrderItemDto {
  const OrderItemDto({required this.menuItemId, required this.quantity});

  final String menuItemId;
  final int quantity;

  static OrderItemDto fromJson(Map<String, dynamic> json) => OrderItemDto(
        menuItemId: json['menuItemId'] as String,
        quantity: json['quantity'] as int,
      );

  OrderItem toModel() => OrderItem(menuItemId: menuItemId, quantity: quantity);
}

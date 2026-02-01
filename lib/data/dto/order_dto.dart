import 'package:yekermo/data/dto/order_item_dto.dart';
import 'package:yekermo/domain/models.dart';

class OrderDto {
  const OrderDto({
    required this.id,
    required this.restaurantId,
    required this.items,
    required this.total,
    this.scheduledTime,
  });

  final String id;
  final String restaurantId;
  final List<OrderItemDto> items;
  final double total;
  final DateTime? scheduledTime;

  Order toModel() => Order(
        id: id,
        restaurantId: restaurantId,
        items: items.map((item) => item.toModel()).toList(),
        total: total,
        scheduledTime: scheduledTime,
      );
}

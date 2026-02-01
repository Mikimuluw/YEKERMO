import 'package:yekermo/data/dto/address_dto.dart';
import 'package:yekermo/data/dto/order_item_dto.dart';
import 'package:yekermo/domain/models.dart';

class OrderDto {
  const OrderDto({
    required this.id,
    required this.restaurantId,
    required this.items,
    required this.total,
    this.status,
    this.fulfillmentMode,
    this.address,
    this.placedAt,
    this.scheduledTime,
  });

  final String id;
  final String restaurantId;
  final List<OrderItemDto> items;
  final double total;
  final OrderStatus? status;
  final FulfillmentMode? fulfillmentMode;
  final AddressDto? address;
  final DateTime? placedAt;
  final DateTime? scheduledTime;

  Order toModel() => Order(
        id: id,
        restaurantId: restaurantId,
        items: items.map((item) => item.toModel()).toList(),
        total: total,
        status: status ?? OrderStatus.completed,
        fulfillmentMode: fulfillmentMode ?? FulfillmentMode.delivery,
        address: address?.toModel(),
        placedAt: placedAt,
        scheduledTime: scheduledTime,
      );
}

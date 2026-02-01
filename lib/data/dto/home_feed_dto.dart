import 'package:yekermo/data/dto/address_dto.dart';
import 'package:yekermo/data/dto/customer_dto.dart';
import 'package:yekermo/data/dto/order_dto.dart';
import 'package:yekermo/data/dto/restaurant_dto.dart';

class HomeFeedDto {
  const HomeFeedDto({
    required this.customer,
    required this.addresses,
    required this.pastOrders,
    required this.trustedRestaurants,
    required this.allRestaurants,
  });

  final CustomerDto customer;
  final List<AddressDto> addresses;
  final List<OrderDto> pastOrders;
  final List<RestaurantDto> trustedRestaurants;
  final List<RestaurantDto> allRestaurants;
}

import 'package:yekermo/domain/models.dart';

class HomeFeed {
  const HomeFeed({
    required this.customer,
    required this.primaryAddress,
    required this.pastOrders,
    required this.trustedRestaurants,
    required this.allRestaurants,
  });

  final Customer customer;
  final Address primaryAddress;
  final List<Order> pastOrders;
  final List<Restaurant> trustedRestaurants;
  final List<Restaurant> allRestaurants;

  bool get hasOrders => pastOrders.isNotEmpty;
}

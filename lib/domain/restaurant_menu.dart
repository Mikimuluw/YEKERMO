import 'package:yekermo/domain/models.dart';

class RestaurantMenu {
  const RestaurantMenu({
    required this.restaurant,
    required this.categories,
    required this.items,
  });

  final Restaurant restaurant;
  final List<MenuCategory> categories;
  final List<MenuItem> items;
}

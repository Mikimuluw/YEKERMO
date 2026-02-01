import 'package:yekermo/data/dto/menu_category_dto.dart';
import 'package:yekermo/data/dto/menu_item_dto.dart';
import 'package:yekermo/data/dto/restaurant_dto.dart';
import 'package:yekermo/domain/restaurant_menu.dart';

class RestaurantMenuDto {
  const RestaurantMenuDto({
    required this.restaurant,
    required this.categories,
    required this.items,
  });

  final RestaurantDto restaurant;
  final List<MenuCategoryDto> categories;
  final List<MenuItemDto> items;

  RestaurantMenu toModel() => RestaurantMenu(
        restaurant: restaurant.toModel(),
        categories: categories.map((item) => item.toModel()).toList(),
        items: items.map((item) => item.toModel()).toList(),
      );
}

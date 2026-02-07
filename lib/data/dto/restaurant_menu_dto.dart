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

  static RestaurantMenuDto fromJson(Map<String, dynamic> json) {
    final categoriesList = json['categories'] as List<dynamic>? ?? [];
    final categories = categoriesList.map((e) => MenuCategoryDto.fromJson(e as Map<String, dynamic>)).toList();
    final items = categoriesList.expand((c) {
      final itemsList = (c as Map<String, dynamic>)['items'] as List<dynamic>? ?? [];
      return itemsList.map((e) => MenuItemDto.fromJson(e as Map<String, dynamic>));
    }).toList();
    return RestaurantMenuDto(
      restaurant: RestaurantDto.fromJson(json),
      categories: categories,
      items: items,
    );
  }

  RestaurantMenu toModel() => RestaurantMenu(
    restaurant: restaurant.toModel(),
    categories: categories.map((item) => item.toModel()).toList(),
    items: items.map((item) => item.toModel()).toList(),
  );
}

import 'package:yekermo/domain/models.dart';

class MenuItemDto {
  const MenuItemDto({
    required this.id,
    required this.restaurantId,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.tags,
    this.available = true,
  });

  final String id;
  final String restaurantId;
  final String categoryId;
  final String name;
  final String description;
  final double price;
  final List<MenuItemTag> tags;
  final bool available;

  static List<MenuItemTag> _tags(List<dynamic>? list) {
    if (list == null) return [];
    final out = <MenuItemTag>[];
    for (final e in list) {
      final s = e.toString();
      if (s == 'quickFilling') out.add(MenuItemTag.quickFilling);
      if (s == 'familySize') out.add(MenuItemTag.familySize);
      if (s == 'fastingFriendly') out.add(MenuItemTag.fastingFriendly);
    }
    return out;
  }

  static MenuItemDto fromJson(Map<String, dynamic> json) {
    double price = 0;
    if (json['price'] != null) {
      price = (json['price'] is int) ? (json['price'] as int).toDouble() : json['price'] as double;
    }
    return MenuItemDto(
      id: json['id'] as String,
      restaurantId: json['restaurantId'] as String,
      categoryId: json['categoryId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: price,
      tags: _tags(json['tags'] as List<dynamic>?),
      available: json['available'] as bool? ?? true,
    );
  }

  MenuItem toModel() => MenuItem(
    id: id,
    restaurantId: restaurantId,
    categoryId: categoryId,
    name: name,
    description: description,
    price: price,
    tags: tags,
  );
}

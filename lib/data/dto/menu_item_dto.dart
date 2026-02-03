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

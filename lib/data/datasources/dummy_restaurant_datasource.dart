import 'package:yekermo/data/dto/menu_category_dto.dart';
import 'package:yekermo/data/dto/menu_item_dto.dart';
import 'package:yekermo/data/dto/restaurant_dto.dart';
import 'package:yekermo/data/dto/restaurant_menu_dto.dart';
import 'package:yekermo/data/seed/yyc_restaurants.dart';
import 'package:yekermo/domain/models.dart';

class DummyRestaurantDataSource {
  const DummyRestaurantDataSource();

  RestaurantMenuDto fetchRestaurantMenu(String restaurantId) {
    return _menus[restaurantId] ?? _menus.values.first;
  }

  RestaurantDto fetchRestaurant(String restaurantId) {
    final RestaurantMenuDto menu = _menus[restaurantId] ?? _menus.values.first;
    return menu.restaurant;
  }

  static final Map<String, RestaurantMenuDto> _menus = {
    for (final YYCRestaurantSeed seed in yycRestaurants)
      seed.id: _menuForSeed(seed),
  };

  static RestaurantMenuDto _menuForSeed(YYCRestaurantSeed seed) {
    final String categoryId = '${seed.id}-cat-1';
    final String itemId = '${seed.id}-item-1';
    final String unavailableItemId = '${seed.id}-item-2';
    final List<MenuItemDto> items = [
      MenuItemDto(
        id: itemId,
        restaurantId: seed.id,
        categoryId: categoryId,
        name: 'Injera platter',
        description: 'Assorted house favorites served with injera.',
        price: 18.00,
        tags: const [MenuItemTag.familySize],
      ),
      MenuItemDto(
        id: unavailableItemId,
        restaurantId: seed.id,
        categoryId: categoryId,
        name: 'Kitfo special',
        description: 'Temporarily unavailable.',
        price: 19.50,
        tags: const [MenuItemTag.quickFilling],
        available: false,
      ),
    ];

    final List<MenuItemDto> availableItems = items
        .where((item) => item.available)
        .toList();

    return RestaurantMenuDto(
      restaurant: RestaurantDto(
        id: seed.id,
        name: seed.name,
        tagline: 'Calgary Ethiopian kitchen',
        prepTimeBand: PrepTimeBand.standard,
        serviceModes: seed.serviceModes,
        tags: seed.tags,
        trustCopy: 'Local favorite',
        dishNames: const ['Injera platter'],
        address: seed.address,
      ),
      categories: [
        MenuCategoryDto(id: categoryId, title: 'House favorites'),
      ],
      items: availableItems,
    );
  }
}

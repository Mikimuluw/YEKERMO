import 'package:yekermo/data/dto/menu_category_dto.dart';
import 'package:yekermo/data/dto/menu_item_dto.dart';
import 'package:yekermo/data/dto/restaurant_dto.dart';
import 'package:yekermo/data/dto/restaurant_menu_dto.dart';
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

  static const Map<String, RestaurantMenuDto> _menus = {
    'rest-1': RestaurantMenuDto(
      restaurant: RestaurantDto(
        id: 'rest-1',
        name: 'Teff & Timber',
        address: '120 King St W, Toronto, ON',
        tagline: 'Warm bowls, quick pickup',
        prepTimeBand: PrepTimeBand.fast,
        serviceModes: [ServiceMode.pickup, ServiceMode.delivery],
        tags: [RestaurantTag.quickFilling, RestaurantTag.pickupFriendly],
        trustCopy: 'Popular with returning guests',
        dishNames: ['Misir Comfort Bowl', 'Alicha Bowl'],
      ),
      categories: [
        MenuCategoryDto(id: 'cat-1', title: 'Comfort bowls'),
        MenuCategoryDto(id: 'cat-2', title: 'Plates'),
      ],
      items: [
        MenuItemDto(
          id: 'item-1',
          restaurantId: 'rest-1',
          categoryId: 'cat-1',
          name: 'Misir Comfort Bowl',
          description: 'Red lentils, warm spices, citrus finish.',
          price: 14.25,
          tags: [MenuItemTag.quickFilling, MenuItemTag.fastingFriendly],
        ),
        MenuItemDto(
          id: 'item-2',
          restaurantId: 'rest-1',
          categoryId: 'cat-1',
          name: 'Alicha Bowl',
          description: 'Mild turmeric stew with seasonal veg.',
          price: 13.75,
          tags: [MenuItemTag.fastingFriendly],
        ),
        MenuItemDto(
          id: 'item-3',
          restaurantId: 'rest-1',
          categoryId: 'cat-2',
          name: 'Doro Plate',
          description: 'Slow-simmered chicken, house berbere.',
          price: 17.50,
          tags: [MenuItemTag.familySize],
        ),
      ],
    ),
    'rest-2': RestaurantMenuDto(
      restaurant: RestaurantDto(
        id: 'rest-2',
        name: 'Meskela Kitchen',
        address: '88 Queen St E, Toronto, ON',
        tagline: 'Slow-simmered classics',
        prepTimeBand: PrepTimeBand.standard,
        serviceModes: [ServiceMode.delivery],
        tags: [RestaurantTag.familySize],
        trustCopy: 'Family-size favorites',
        dishNames: ['Family Feast Platter', 'Doro Wat'],
      ),
      categories: [
        MenuCategoryDto(id: 'cat-3', title: 'Family platters'),
        MenuCategoryDto(id: 'cat-4', title: 'Sides'),
      ],
      items: [
        MenuItemDto(
          id: 'item-4',
          restaurantId: 'rest-2',
          categoryId: 'cat-3',
          name: 'Family Feast Platter',
          description: 'Shared injera, slow-cooked classics.',
          price: 32.00,
          tags: [MenuItemTag.familySize],
        ),
        MenuItemDto(
          id: 'item-5',
          restaurantId: 'rest-2',
          categoryId: 'cat-3',
          name: 'Doro Wat',
          description: 'Braised chicken, deep spice.',
          price: 18.25,
          tags: [MenuItemTag.quickFilling],
        ),
        MenuItemDto(
          id: 'item-6',
          restaurantId: 'rest-2',
          categoryId: 'cat-4',
          name: 'Gomen Side',
          description: 'Sauteed greens, garlic, lemon.',
          price: 6.50,
          tags: [MenuItemTag.fastingFriendly],
        ),
      ],
    ),
    'rest-3': RestaurantMenuDto(
      restaurant: RestaurantDto(
        id: 'rest-3',
        name: 'Blue River Platters',
        address: '350 Bloor St W, Toronto, ON',
        tagline: 'Comfort meals for cold nights',
        prepTimeBand: PrepTimeBand.standard,
        serviceModes: [ServiceMode.delivery, ServiceMode.pickup],
        tags: [RestaurantTag.quickFilling, RestaurantTag.familySize],
        trustCopy: 'Warm and filling picks',
        dishNames: ['Injera Combo', 'Lentil Stew'],
      ),
      categories: [MenuCategoryDto(id: 'cat-5', title: 'Warm classics')],
      items: [
        MenuItemDto(
          id: 'item-7',
          restaurantId: 'rest-3',
          categoryId: 'cat-5',
          name: 'Injera Combo',
          description: 'Mixed lentils, greens, and mild stew.',
          price: 16.00,
          tags: [MenuItemTag.quickFilling],
        ),
        MenuItemDto(
          id: 'item-8',
          restaurantId: 'rest-3',
          categoryId: 'cat-5',
          name: 'Lentil Stew',
          description: 'Slow-cooked lentils, gentle spice.',
          price: 13.50,
          tags: [MenuItemTag.fastingFriendly],
        ),
      ],
    ),
    'rest-4': RestaurantMenuDto(
      restaurant: RestaurantDto(
        id: 'rest-4',
        name: 'Cedar Street Deli',
        address: '45 Front St E, Toronto, ON',
        tagline: 'Family size portions',
        prepTimeBand: PrepTimeBand.fast,
        serviceModes: [ServiceMode.pickup],
        tags: [RestaurantTag.familySize, RestaurantTag.pickupFriendly],
        trustCopy: 'Pickup stays fast here',
        dishNames: ['Family Kitfo Tray', 'Veggie Platter'],
      ),
      categories: [MenuCategoryDto(id: 'cat-6', title: 'Shared trays')],
      items: [
        MenuItemDto(
          id: 'item-9',
          restaurantId: 'rest-4',
          categoryId: 'cat-6',
          name: 'Family Kitfo Tray',
          description: 'Family-style kitfo with fresh sides.',
          price: 29.00,
          tags: [MenuItemTag.familySize],
        ),
        MenuItemDto(
          id: 'item-10',
          restaurantId: 'rest-4',
          categoryId: 'cat-6',
          name: 'Veggie Platter',
          description: 'Mixed vegetables, bright and mild.',
          price: 18.00,
          tags: [MenuItemTag.fastingFriendly],
        ),
      ],
    ),
    'rest-5': RestaurantMenuDto(
      restaurant: RestaurantDto(
        id: 'rest-5',
        name: 'Bahir Spice House',
        address: '200 Danforth Ave, Toronto, ON',
        tagline: 'Slow heat, deep flavor',
        prepTimeBand: PrepTimeBand.slow,
        serviceModes: [ServiceMode.delivery],
        tags: [RestaurantTag.fastingFriendly],
        trustCopy: 'Fasting-friendly comfort',
        dishNames: ['Shiro Bowl', 'Gomen'],
      ),
      categories: [MenuCategoryDto(id: 'cat-7', title: 'Fasting-friendly')],
      items: [
        MenuItemDto(
          id: 'item-11',
          restaurantId: 'rest-5',
          categoryId: 'cat-7',
          name: 'Shiro Bowl',
          description: 'Creamy chickpea stew, warm and mild.',
          price: 14.00,
          tags: [MenuItemTag.fastingFriendly],
        ),
        MenuItemDto(
          id: 'item-12',
          restaurantId: 'rest-5',
          categoryId: 'cat-7',
          name: 'Gomen',
          description: 'Slow-sauteed greens, garlic finish.',
          price: 12.00,
          tags: [MenuItemTag.fastingFriendly],
        ),
      ],
    ),
  };
}

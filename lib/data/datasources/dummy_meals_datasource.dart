import 'package:yekermo/data/dto/address_dto.dart';
import 'package:yekermo/data/dto/customer_dto.dart';
import 'package:yekermo/data/dto/home_feed_dto.dart';
import 'package:yekermo/data/dto/order_dto.dart';
import 'package:yekermo/data/dto/order_item_dto.dart';
import 'package:yekermo/data/dto/preference_dto.dart';
import 'package:yekermo/data/dto/restaurant_dto.dart';
import 'package:yekermo/domain/models.dart';

/// Stub hours for discovery open/closed when no seed hours (e.g. rest-1..rest-5).
const Map<int, String> _stubHours = {
  1: '11:00-21:00',
  2: '11:00-21:00',
  3: '11:00-21:00',
  4: '11:00-21:00',
  5: '11:00-21:00',
  6: '11:00-21:00',
  7: '11:00-21:00',
};

class DummyMealsDataSource {
  const DummyMealsDataSource();

  HomeFeedDto fetchHomeFeed() {
    const CustomerDto customer = CustomerDto(
      id: 'cust-1',
      name: 'Mina',
      primaryAddressId: 'addr-1',
      preference: PreferenceDto(
        favoriteCuisines: ['Ethiopian', 'East African'],
        dietaryTags: ['Low spice', 'Family-friendly'],
      ),
    );

    const List<AddressDto> addresses = [
      AddressDto(
        id: 'addr-1',
        label: AddressLabel.home,
        line1: '215 Riverstone Ave',
        city: 'YYC',
        neighborhood: 'Crescent Heights',
        notes: 'Buzz 312, side door after 6pm',
      ),
      AddressDto(
        id: 'addr-2',
        label: AddressLabel.work,
        line1: '502 8th St',
        city: 'YYC',
        neighborhood: 'Downtown',
        notes: 'Front desk drop-off',
      ),
    ];

    const List<RestaurantDto> trustedRestaurants = [
      RestaurantDto(
        id: 'rest-1',
        name: 'Teff & Timber',
        address: '120 King St W, Toronto, ON',
        tagline: 'Warm bowls, quick pickup',
        prepTimeBand: PrepTimeBand.fast,
        serviceModes: [ServiceMode.pickup, ServiceMode.delivery],
        tags: [RestaurantTag.quickFilling, RestaurantTag.pickupFriendly],
        trustCopy: 'Popular with returning guests',
        dishNames: ['Misir Comfort Bowl', 'Alicha Bowl'],
        hoursByWeekday: _stubHours,
      ),
      RestaurantDto(
        id: 'rest-2',
        name: 'Meskela Kitchen',
        address: '88 Queen St E, Toronto, ON',
        tagline: 'Slow-simmered classics',
        prepTimeBand: PrepTimeBand.standard,
        serviceModes: [ServiceMode.delivery],
        tags: [RestaurantTag.familySize],
        trustCopy: 'Family-size favorites',
        dishNames: ['Family Feast Platter', 'Doro Wat'],
        hoursByWeekday: _stubHours,
      ),
    ];

    const List<RestaurantDto> allRestaurants = [
      RestaurantDto(
        id: 'rest-3',
        name: 'Blue River Platters',
        address: '350 Bloor St W, Toronto, ON',
        tagline: 'Comfort meals for cold nights',
        prepTimeBand: PrepTimeBand.standard,
        serviceModes: [ServiceMode.delivery, ServiceMode.pickup],
        tags: [RestaurantTag.quickFilling, RestaurantTag.familySize],
        trustCopy: 'Warm and filling picks',
        dishNames: ['Injera Combo', 'Lentil Stew'],
        hoursByWeekday: _stubHours,
      ),
      RestaurantDto(
        id: 'rest-4',
        name: 'Cedar Street Deli',
        address: '45 Front St E, Toronto, ON',
        tagline: 'Family size portions',
        prepTimeBand: PrepTimeBand.fast,
        serviceModes: [ServiceMode.pickup],
        tags: [RestaurantTag.familySize, RestaurantTag.pickupFriendly],
        trustCopy: 'Pickup stays fast here',
        dishNames: ['Family Kitfo Tray', 'Veggie Platter'],
        hoursByWeekday: _stubHours,
      ),
      RestaurantDto(
        id: 'rest-5',
        name: 'Bahir Spice House',
        address: '200 Danforth Ave, Toronto, ON',
        tagline: 'Slow heat, deep flavor',
        prepTimeBand: PrepTimeBand.slow,
        serviceModes: [ServiceMode.delivery],
        tags: [RestaurantTag.fastingFriendly],
        trustCopy: 'Fasting-friendly comfort',
        dishNames: ['Shiro Bowl', 'Gomen'],
        hoursByWeekday: _stubHours,
      ),
    ];

    const List<OrderDto> pastOrders = [
      OrderDto(
        id: 'order-1',
        restaurantId: 'rest-1',
        items: [OrderItemDto(menuItemId: 'item-1', quantity: 1)],
        total: 21.75,
        scheduledTime: null,
      ),
    ];

    return const HomeFeedDto(
      customer: customer,
      addresses: addresses,
      pastOrders: pastOrders,
      trustedRestaurants: trustedRestaurants,
      allRestaurants: allRestaurants,
    );
  }
}

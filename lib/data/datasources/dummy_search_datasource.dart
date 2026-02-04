import 'package:yekermo/data/dto/restaurant_dto.dart';
import 'package:yekermo/domain/models.dart';

class DummySearchDataSource {
  const DummySearchDataSource();

  List<RestaurantDto> search(String? query) {
    const List<RestaurantDto> restaurants = [
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
      ),
    ];

    final String normalized = (query ?? '').trim().toLowerCase();
    if (normalized.isEmpty) return restaurants;
    return restaurants
        .where(
          (item) =>
              item.name.toLowerCase().contains(normalized) ||
              item.tagline.toLowerCase().contains(normalized) ||
              item.dishNames.any(
                (dish) => dish.toLowerCase().contains(normalized),
              ),
        )
        .toList();
  }
}

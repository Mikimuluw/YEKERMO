import 'package:yekermo/data/dto/restaurant_dto.dart';
import 'package:yekermo/domain/models.dart';

class DummySearchDataSource {
  const DummySearchDataSource();

  static const List<RestaurantDto> _restaurants = [
    RestaurantDto(
      id: 'search-1',
      name: 'Lalibela Kitchen',
      address: '',
      tagline: 'Ethiopian • 25–35 min',
      prepTimeBand: PrepTimeBand.standard,
      serviceModes: [ServiceMode.delivery],
      tags: [],
      trustCopy: '',
      dishNames: [],
      rating: 4.8,
      maxMinutes: 35,
    ),
    RestaurantDto(
      id: 'search-2',
      name: 'Abyssinia Restaurant',
      address: '',
      tagline: 'Ethiopian • 30–40 min',
      prepTimeBand: PrepTimeBand.standard,
      serviceModes: [ServiceMode.delivery],
      tags: [],
      trustCopy: '',
      dishNames: [],
      rating: 4.6,
      maxMinutes: 40,
    ),
    RestaurantDto(
      id: 'search-3',
      name: 'Queen of Sheba',
      address: '',
      tagline: 'Ethiopian • 20–28 min',
      prepTimeBand: PrepTimeBand.fast,
      serviceModes: [ServiceMode.delivery],
      tags: [],
      trustCopy: '',
      dishNames: [],
      rating: 4.9,
      maxMinutes: 28,
    ),
    RestaurantDto(
      id: 'search-4',
      name: 'Addis Cafe',
      address: '',
      tagline: 'Ethiopian • 25–30 min',
      prepTimeBand: PrepTimeBand.fast,
      serviceModes: [ServiceMode.delivery],
      tags: [],
      trustCopy: '',
      dishNames: [],
      rating: 4.5,
      maxMinutes: 30,
    ),
  ];

  List<RestaurantDto> search(String? query) {
    final String normalized = (query ?? '').trim().toLowerCase();
    if (normalized.isEmpty) return List.from(_restaurants);
    return _restaurants
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

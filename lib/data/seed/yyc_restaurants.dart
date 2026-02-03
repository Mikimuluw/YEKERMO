import 'package:yekermo/domain/models.dart';

class YYCRestaurantSeed {
  const YYCRestaurantSeed({
    required this.id,
    required this.name,
    required this.address,
    required this.serviceModes,
    required this.hoursByWeekday,
    this.tags = const [],
  });

  final String id;
  final String name;
  final String address;
  final List<ServiceMode> serviceModes;
  final Map<int, String> hoursByWeekday; // 1=Mon … 7=Sun
  final List<RestaurantTag> tags;
}

const yycRestaurants = <YYCRestaurantSeed>[
  YYCRestaurantSeed(
    id: 'yyc_abyssinia',
    name: 'Abyssinia Restaurant',
    address: '910 12 Ave SW, Calgary, AB',
    serviceModes: [ServiceMode.pickup],
    hoursByWeekday: {
      1: '11:00-21:30',
      2: '11:00-21:30',
      3: '11:00-21:30',
      4: '11:00-21:30',
      5: '11:00-21:30',
      6: '11:00-21:30',
      7: '11:00-21:30',
    },
  ),

  // Add the rest incrementally (Piassa, Habesha, Solomon, Mesob, Geez, Arada, Ensira, Yegna, Horeb)
];

YYCRestaurantSeed? yycRestaurantById(String id) {
  for (final YYCRestaurantSeed restaurant in yycRestaurants) {
    if (restaurant.id == id) return restaurant;
  }
  return null;
}

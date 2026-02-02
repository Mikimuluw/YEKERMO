import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/data/seed/yyc_restaurants.dart';

void main() {
  test('YYC restaurant registry is valid', () {
    final Set<String> ids = <String>{};

    for (final YYCRestaurantSeed restaurant in yycRestaurants) {
      expect(restaurant.name.trim(), isNotEmpty);
      expect(restaurant.address.trim(), isNotEmpty);
      expect(
        ids.add(restaurant.id),
        isTrue,
        reason: 'Duplicate id: ${restaurant.id}',
      );
      expect(restaurant.hoursByWeekday.length, 7);
    }
  });
}

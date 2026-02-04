import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/data/datasources/dummy_restaurant_datasource.dart';

void main() {
  test('unavailable menu items are not returned', () {
    const DummyRestaurantDataSource dataSource = DummyRestaurantDataSource();
    final menu = dataSource.fetchRestaurantMenu('yyc_abyssinia');
    final bool hasUnavailable = menu.items.any(
      (item) => item.id == 'yyc_abyssinia-item-2',
    );
    expect(hasUnavailable, isFalse);
  });
}

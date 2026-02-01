import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/data/datasources/dummy_restaurant_datasource.dart';
import 'package:yekermo/data/repositories/dummy_restaurant_repository.dart';
import 'package:yekermo/data/repositories/restaurant_repository.dart';
import 'package:yekermo/data/result.dart';
import 'package:yekermo/domain/restaurant_menu.dart';

void main() {
  test('restaurant menu maps dto to domain', () async {
    const RestaurantRepository repo = DummyRestaurantRepository(
      DummyRestaurantDataSource(),
    );
    final Result<RestaurantMenu> result = await repo.fetchRestaurantMenu(
      'rest-1',
    );

    expect(result, isA<Success<RestaurantMenu>>());
    final RestaurantMenu menu = (result as Success<RestaurantMenu>).data;
    expect(menu.restaurant.id, 'rest-1');
    expect(menu.categories, isNotEmpty);
    expect(menu.items, isNotEmpty);
    expect(menu.items.first.tags, isNotEmpty);
  });
}

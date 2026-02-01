import 'package:yekermo/data/datasources/dummy_restaurant_datasource.dart';
import 'package:yekermo/data/dto/restaurant_menu_dto.dart';
import 'package:yekermo/data/repositories/restaurant_repository.dart';
import 'package:yekermo/data/result.dart';
import 'package:yekermo/domain/failure.dart';
import 'package:yekermo/domain/restaurant_menu.dart';

class DummyRestaurantRepository implements RestaurantRepository {
  const DummyRestaurantRepository(this.dataSource);

  final DummyRestaurantDataSource dataSource;

  @override
  Future<Result<RestaurantMenu>> fetchRestaurantMenu(String restaurantId) async {
    await Future<void>.delayed(const Duration(milliseconds: 280));
    try {
      final RestaurantMenuDto dto = dataSource.fetchRestaurantMenu(restaurantId);
      return Result.success(dto.toModel());
    } catch (error) {
      return Result.failure(
        const Failure('Unable to load this menu right now.'),
      );
    }
  }
}

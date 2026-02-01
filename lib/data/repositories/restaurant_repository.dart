import 'package:yekermo/data/result.dart';
import 'package:yekermo/domain/restaurant_menu.dart';

abstract class RestaurantRepository {
  Future<Result<RestaurantMenu>> fetchRestaurantMenu(String restaurantId);
}

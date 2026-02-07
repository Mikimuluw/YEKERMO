import 'package:yekermo/core/transport/transport_client.dart';
import 'package:yekermo/data/dto/restaurant_menu_dto.dart';
import 'package:yekermo/data/repositories/restaurant_repository.dart';
import 'package:yekermo/data/result.dart';
import 'package:yekermo/domain/failure.dart';
import 'package:yekermo/domain/restaurant_menu.dart';

class ApiRestaurantRepository implements RestaurantRepository {
  ApiRestaurantRepository(this.transportClient);

  final TransportClient transportClient;

  @override
  Future<Result<RestaurantMenu>> fetchRestaurantMenu(String restaurantId) async {
    try {
      final response = await transportClient.request<Map<String, dynamic>>(
        TransportRequest(
          method: 'GET',
          url: Uri(path: '/restaurants/$restaurantId/menu'),
          timeout: const Duration(seconds: 12),
        ),
      );
      final data = response.data;
      final menu = RestaurantMenuDto.fromJson(data).toModel();
      return Result.success(menu);
    } on TransportError catch (e) {
      if (e.kind == TransportErrorKind.network || e.kind == TransportErrorKind.timeout) {
        return Result.failure(const Failure(
          'Check your connection and try again. If the problem continues, the server may be unavailable.',
        ));
      }
      return Result.failure(Failure(e.message));
    } on Exception catch (e) {
      return Result.failure(Failure('Unable to load this menu: $e'));
    }
  }
}

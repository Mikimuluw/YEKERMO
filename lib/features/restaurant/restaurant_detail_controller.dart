import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yekermo/app/providers.dart';
import 'package:yekermo/data/result.dart';
import 'package:yekermo/domain/restaurant_menu.dart';
import 'package:yekermo/features/restaurant/restaurant_detail_input.dart';
import 'package:yekermo/shared/state/screen_state.dart';

/// Query for the detail screen. Overridden by route with path param.
final restaurantDetailQueryProvider = Provider<RestaurantDetailQuery>(
  (_) => throw UnimplementedError(
    'RestaurantDetailQuery must be overridden (e.g. by route).',
  ),
);

final restaurantDetailControllerProvider =
    NotifierProvider<
      RestaurantDetailController,
      ScreenState<RestaurantDetailInput>
    >(RestaurantDetailController.new);

/// Loads restaurant + menu by id and builds [RestaurantDetailInput].
/// Reuses [restaurantRepositoryProvider]; no parallel repo.
class RestaurantDetailController
    extends Notifier<ScreenState<RestaurantDetailInput>> {
  @override
  ScreenState<RestaurantDetailInput> build() {
    state = ScreenState.loading();
    _load();
    return state;
  }

  Future<void> _load() async {
    final String restaurantId = ref
        .read(restaurantDetailQueryProvider)
        .restaurantId;
    if (restaurantId.isEmpty) {
      state = ScreenState.empty('Restaurant not found.');
      return;
    }
    final Result<RestaurantMenu> result = await ref
        .read(restaurantRepositoryProvider)
        .fetchRestaurantMenu(restaurantId);
    switch (result) {
      case Success<RestaurantMenu>(:final data):
        final input = _toDetailInput(data);
        state = ScreenState.success(input);
      case FailureResult<RestaurantMenu>(:final failure):
        state = ScreenState.error(failure);
    }
  }

  static RestaurantDetailInput _toDetailInput(RestaurantMenu menu) {
    final r = menu.restaurant;
    final String ratingLabel = r.rating != null ? '${r.rating}' : '—';
    final dishes = menu.items
        .map(
          (m) => DishDetailInput(
            id: m.id,
            name: m.name,
            description: m.description,
            price: m.price,
          ),
        )
        .toList();
    return RestaurantDetailInput(
      name: r.name,
      meta: r.tagline,
      ratingLabel: ratingLabel,
      restaurantId: r.id,
      dishes: dishes,
    );
  }
}

class RestaurantDetailQuery {
  const RestaurantDetailQuery({required this.restaurantId});
  final String restaurantId;
}

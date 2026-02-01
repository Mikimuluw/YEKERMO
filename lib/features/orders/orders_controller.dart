import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yekermo/app/providers.dart';
import 'package:yekermo/data/result.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/restaurant_menu.dart';
import 'package:yekermo/shared/state/screen_state.dart';

class OrdersController extends Notifier<ScreenState<OrdersVm>> {
  int _requestId = 0;

  @override
  ScreenState<OrdersVm> build() {
    state = ScreenState.loading();
    Future<void>.microtask(_loadLatest);
    return state;
  }

  Future<void> refresh() => _loadLatest();

  Future<void> _loadLatest() async {
    final int requestId = ++_requestId;
    final List<Order> orders = await ref
        .read(ordersRepositoryProvider)
        .getOrders();
    if (requestId != _requestId) return;

    if (orders.isEmpty) {
      state = ScreenState.empty('Your past orders will show up here.');
      return;
    }

    final List<OrderSummary> summaries = await Future.wait(
      orders.map(_buildSummary),
    );
    if (requestId != _requestId) return;
    state = ScreenState.success(OrdersVm(summaries: summaries));
  }

  Future<OrderSummary> _buildSummary(Order order) async {
    final Result<RestaurantMenu> menuResult = await ref
        .read(restaurantRepositoryProvider)
        .fetchRestaurantMenu(order.restaurantId);
    final Restaurant? restaurant = switch (menuResult) {
      Success<RestaurantMenu>(:final data) => data.restaurant,
      FailureResult<RestaurantMenu>() => null,
    };
    return OrderSummary(order: order, restaurant: restaurant);
  }

  Future<ReorderResult> reorder(Order order) async {
    final Result<RestaurantMenu> menuResult = await ref
        .read(restaurantRepositoryProvider)
        .fetchRestaurantMenu(order.restaurantId);
    final List<MenuItem> menuItems = switch (menuResult) {
      Success<RestaurantMenu>(:final data) => data.items,
      FailureResult<RestaurantMenu>() => const [],
    };
    final Map<String, MenuItem> itemMap = {
      for (final item in menuItems) item.id: item,
    };

    ref.read(cartRepositoryProvider).clear();
    int missingCount = 0;
    int addedCount = 0;
    for (final item in order.items) {
      final MenuItem? menuItem = itemMap[item.menuItemId];
      if (menuItem == null) {
        missingCount += 1;
        continue;
      }
      ref.read(cartRepositoryProvider).addItem(menuItem, item.quantity);
      addedCount += 1;
    }
    return ReorderResult(missingCount: missingCount, addedCount: addedCount);
  }
}

class OrdersVm {
  const OrdersVm({required this.summaries});

  final List<OrderSummary> summaries;
}

class OrderSummary {
  const OrderSummary({required this.order, required this.restaurant});

  final Order order;
  final Restaurant? restaurant;
}

class ReorderResult {
  const ReorderResult({required this.missingCount, required this.addedCount});

  final int missingCount;
  final int addedCount;
  bool get hasMissing => missingCount > 0;
  bool get hasItems => addedCount > 0;
}

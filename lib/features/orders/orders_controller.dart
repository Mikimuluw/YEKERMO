import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yekermo/app/clock_provider.dart';
import 'package:yekermo/app/providers.dart';
import 'package:yekermo/app/reorder_signal_provider.dart';
import 'package:yekermo/core/config/app_config.dart';
import 'package:yekermo/core/time/restaurant_hours.dart';
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
    final AppConfig config = ref.read(appConfigProvider);
    if (!config.enableReorder) {
      return OrderSummary(
        order: order,
        restaurant: null,
        isEligibleForReorder: false,
        ineligibleReason: 'Reorder is not available.',
      );
    }

    final Result<RestaurantMenu> menuResult = await ref
        .read(restaurantRepositoryProvider)
        .fetchRestaurantMenu(order.restaurantId);
    final Restaurant? restaurant = switch (menuResult) {
      Success<RestaurantMenu>(:final data) => data.restaurant,
      FailureResult<RestaurantMenu>() => null,
    };
    final List<MenuItem> menuItems = switch (menuResult) {
      Success<RestaurantMenu>(:final data) => data.items,
      FailureResult<RestaurantMenu>() => const [],
    };

    final bool eligible;
    final String? ineligibleReason;
    if (restaurant == null) {
      eligible = false;
      ineligibleReason = 'Restaurant is no longer available.';
    } else {
      final DateTime now = ref.read(clockProvider).now();
      final bool open = restaurant.hoursByWeekday != null &&
          isOpenNow(restaurant.hoursByWeekday!, now);
      if (!open) {
        eligible = false;
        ineligibleReason = 'Restaurant is closed right now.';
      } else if (!restaurant.serviceModes.contains(order.fulfillmentMode)) {
        eligible = false;
        ineligibleReason =
            'Pickup or delivery is no longer available for this restaurant.';
      } else {
        final bool allOffered = order.items.every(
          (line) => menuItems.any((m) => m.id == line.menuItemId),
        );
        if (!allOffered) {
          eligible = false;
          ineligibleReason = 'Some items are no longer available.';
        } else {
          eligible = true;
          ineligibleReason = null;
        }
      }
    }

    return OrderSummary(
      order: order,
      restaurant: restaurant,
      isEligibleForReorder: eligible,
      ineligibleReason: ineligibleReason,
    );
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
    if (addedCount > 0) {
      ref
          .read(reorderSignalProvider.notifier)
          .incrementForRestaurant(order.restaurantId);
    }
    return ReorderResult(missingCount: missingCount, addedCount: addedCount);
  }
}

class OrdersVm {
  const OrdersVm({required this.summaries});

  final List<OrderSummary> summaries;
}

class OrderSummary {
  const OrderSummary({
    required this.order,
    required this.restaurant,
    this.isEligibleForReorder = true,
    this.ineligibleReason,
  });

  final Order order;
  final Restaurant? restaurant;
  /// When false, Reorder CTA should be disabled and [ineligibleReason] shown (Phase 11.2 / PRD §4.3).
  final bool isEligibleForReorder;
  final String? ineligibleReason;
}

class ReorderResult {
  const ReorderResult({required this.missingCount, required this.addedCount});

  final int missingCount;
  final int addedCount;
  bool get hasMissing => missingCount > 0;
  bool get hasItems => addedCount > 0;
}

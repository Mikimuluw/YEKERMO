import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yekermo/app/providers.dart';
import 'package:yekermo/data/result.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/restaurant_menu.dart';
import 'package:yekermo/shared/state/screen_state.dart';

final orderDetailsQueryProvider = Provider<OrderDetailsQuery>(
  (_) => throw UnimplementedError('OrderDetailsQuery must be overridden.'),
);

final orderDetailControllerProvider =
    NotifierProvider<OrderDetailController, ScreenState<OrderDetailVm>>(
      OrderDetailController.new,
    );

class OrderDetailController extends Notifier<ScreenState<OrderDetailVm>> {
  int _requestId = 0;

  @override
  ScreenState<OrderDetailVm> build() {
    state = ScreenState.loading();
    Future<void>.microtask(_loadLatest);
    return state;
  }

  Future<void> refresh() => _loadLatest();

  Future<void> _loadLatest() async {
    final int requestId = ++_requestId;
    final OrderDetailsQuery query = ref.read(orderDetailsQueryProvider);
    final Order? order = await ref
        .read(ordersRepositoryProvider)
        .getOrder(query.orderId);
    if (requestId != _requestId) return;

    if (order == null) {
      state = ScreenState.empty('Order details will appear here.');
      return;
    }

    final Result<RestaurantMenu> menuResult = await ref
        .read(restaurantRepositoryProvider)
        .fetchRestaurantMenu(order.restaurantId);
    final Restaurant? restaurant = switch (menuResult) {
      Success<RestaurantMenu>(:final data) => data.restaurant,
      FailureResult<RestaurantMenu>() => null,
    };
    final Map<String, MenuItem> itemMap = switch (menuResult) {
      Success<RestaurantMenu>(:final data) => {
        for (final item in data.items) item.id: item,
      },
      FailureResult<RestaurantMenu>() => const {},
    };
    final List<OrderLineView> lines = order.items
        .map(
          (line) => OrderLineView(
            itemName: itemMap[line.menuItemId]?.name ?? 'Item unavailable',
            quantity: line.quantity,
          ),
        )
        .toList();
    if (requestId != _requestId) return;
    state = ScreenState.success(
      OrderDetailVm(order: order, restaurant: restaurant, lines: lines),
    );
  }
}

class OrderDetailsQuery {
  const OrderDetailsQuery({required this.orderId});

  final String orderId;
}

class OrderDetailVm {
  const OrderDetailVm({
    required this.order,
    required this.restaurant,
    required this.lines,
  });

  final Order order;
  final Restaurant? restaurant;
  final List<OrderLineView> lines;
}

class OrderLineView {
  const OrderLineView({required this.itemName, required this.quantity});

  final String itemName;
  final int quantity;
}

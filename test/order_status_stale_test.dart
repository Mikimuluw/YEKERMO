import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/app/providers.dart';
import 'package:yekermo/data/repositories/orders_repository.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/order_draft.dart';
import 'package:yekermo/domain/payment_method.dart';
import 'package:yekermo/features/orders/order_detail_controller.dart';
import 'package:yekermo/shared/state/screen_state.dart';

/// Orders repo that never completes getOrder — used to simulate slow/stale load.
class _NeverCompletingOrdersRepository implements OrdersRepository {
  final Completer<Order?> _getOrderCompleter = Completer<Order?>();

  @override
  Future<List<Order>> getOrders() async => [];

  @override
  Future<Order?> getOrder(String id) => _getOrderCompleter.future;

  @override
  Future<Order?> getLatestOrder() async => null;

  @override
  Future<Order> placeOrder(
    OrderDraft draft, {
    required PaymentMethod paymentMethod,
  }) async {
    throw UnimplementedError();
  }
}

void main() {
  test('order detail controller exposes stale state after threshold', () async {
    final _NeverCompletingOrdersRepository ordersRepo =
        _NeverCompletingOrdersRepository();

    final container = ProviderContainer(
      overrides: [
        ordersRepositoryProvider.overrideWithValue(ordersRepo),
        orderDetailsQueryProvider.overrideWithValue(
          const OrderDetailsQuery(orderId: 'order-1'),
        ),
        staleThresholdProvider.overrideWithValue(Duration.zero),
      ],
    );
    addTearDown(container.dispose);

    container.read(orderDetailControllerProvider);

    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    final ScreenState<OrderDetailVm> state =
        container.read(orderDetailControllerProvider);

    expect(state, isA<StaleLoadingState<OrderDetailVm>>());
  });
}

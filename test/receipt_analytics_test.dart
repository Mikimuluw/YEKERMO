import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/app/providers.dart';
import 'package:yekermo/domain/fees.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/payment_method.dart';
import 'package:yekermo/features/orders/order_detail_controller.dart';
import 'package:yekermo/features/orders/receipt_screen.dart';
import 'package:yekermo/observability/analytics_events.dart';
import 'package:yekermo/shared/state/screen_state.dart';

import 'helpers/spy_analytics.dart';

class _FakeOrderDetailController extends OrderDetailController {
  _FakeOrderDetailController(this.viewModel);

  final OrderDetailVm viewModel;

  @override
  ScreenState<OrderDetailVm> build() => ScreenState.success(viewModel);
}

void main() {
  testWidgets('Receipt view analytics fires once per entry', (tester) async {
    final Order order = Order(
      id: 'order-1',
      restaurantId: 'rest-1',
      items: const [OrderItem(menuItemId: 'item-1', quantity: 1)],
      total: 15.00,
      status: OrderStatus.received,
      fulfillmentMode: FulfillmentMode.delivery,
      paymentStatus: PaymentStatus.paid,
      paymentMethod: const PaymentMethod(brand: 'Card', last4: '4242'),
      feeBreakdown: const FeeBreakdown(
        subtotal: 12,
        serviceFee: 1,
        deliveryFee: 1,
        tax: 1,
      ),
    );
    final OrderDetailVm viewModel = OrderDetailVm(
      order: order,
      restaurant: const Restaurant(
        id: 'rest-1',
        name: 'Teff & Timber',
        address: '120 King St W, Toronto, ON',
        tagline: 'Warm bowls, quick pickup',
        prepTimeBand: PrepTimeBand.fast,
        serviceModes: [ServiceMode.pickup, ServiceMode.delivery],
        tags: [RestaurantTag.quickFilling],
        trustCopy: 'Popular with returning guests',
        dishNames: ['Misir Comfort Bowl'],
      ),
      lines: const [
        OrderLineView(itemName: 'Misir Comfort Bowl', quantity: 1, price: 12),
      ],
    );
    final SpyAnalytics analytics = SpyAnalytics();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analyticsProvider.overrideWithValue(analytics),
          orderDetailControllerProvider.overrideWith(
            () => _FakeOrderDetailController(viewModel),
          ),
        ],
        child: const MaterialApp(home: ReceiptScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(analytics.countFor(AnalyticsEvents.receiptViewed), 1);

    await tester.pump();
    expect(analytics.countFor(AnalyticsEvents.receiptViewed), 1);
  });
}

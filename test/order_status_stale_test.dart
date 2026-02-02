import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/core/copy/trust_copy.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/features/orders/order_detail_controller.dart';
import 'package:yekermo/features/orders/order_detail_view.dart';

void main() {
  testWidgets('Stale order status shows reassurance copy', (tester) async {
    final DateTime placedAt = DateTime.now().subtract(
      TrustCopy.orderStatusStaleThreshold + const Duration(minutes: 1),
    );
    final Order order = Order(
      id: 'order-1',
      restaurantId: 'rest-1',
      items: const [OrderItem(menuItemId: 'item-1', quantity: 1)],
      total: 12.00,
      status: OrderStatus.received,
      fulfillmentMode: FulfillmentMode.delivery,
      placedAt: placedAt,
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

    await tester.pumpWidget(
      MaterialApp(home: OrderDetailContent(viewModel: viewModel)),
    );

    expect(find.text(TrustCopy.orderStatusChecking), findsOneWidget);
    expect(find.text(TrustCopy.orderStatusNoAction), findsOneWidget);
  });
}

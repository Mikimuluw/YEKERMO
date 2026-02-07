import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/app/providers.dart';
import 'package:yekermo/app/router.dart';
import 'package:yekermo/app/routes.dart';
import 'helpers/fake_welcome_storage.dart';
import 'package:yekermo/data/repositories/dummy_address_repository.dart';
import 'package:yekermo/features/orders/order_detail_controller.dart';
import 'package:yekermo/data/repositories/dummy_cart_repository.dart';
import 'package:yekermo/data/repositories/dummy_orders_repository.dart';
import 'package:yekermo/data/repositories/dummy_payments_repository.dart';
import 'package:yekermo/domain/models.dart';

/// Phase 12: One full end-to-end "money path" test per service mode.
/// Exercises: cart → checkout → pay → place order → order confirmation.

void main() {
  testWidgets(
    'Money path (delivery): cart → checkout → pay → place → confirmation',
    (tester) async {
      final DummyCartRepository cartRepo = DummyCartRepository();
      cartRepo.addItem(
        const MenuItem(
          id: 'item-1',
          restaurantId: 'rest-1',
          categoryId: 'cat-1',
          name: 'Misir Comfort Bowl',
          description: 'Red lentils, warm spices.',
          price: 10.00,
          tags: [MenuItemTag.quickFilling],
        ),
        1,
      );
      final DummyAddressRepository addressRepo = DummyAddressRepository()
        ..save(
          const Address(
            id: 'addr-1',
            label: AddressLabel.home,
            line1: '215 Riverstone Ave',
            city: 'YYC',
          ),
        );
      final DummyOrdersRepository ordersRepo = DummyOrdersRepository();
      final DummyPaymentsRepository paymentsRepo = DummyPaymentsRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            welcomeStorageProvider.overrideWithValue(FakeWelcomeStorage()),
            cartRepositoryProvider.overrideWithValue(cartRepo),
            addressRepositoryProvider.overrideWithValue(addressRepo),
            ordersRepositoryProvider.overrideWithValue(ordersRepo),
            paymentsRepositoryProvider.overrideWithValue(paymentsRepo),
            orderDetailsQueryProvider.overrideWithValue(
              const OrderDetailsQuery(orderId: 'order-1'),
            ),
          ],
          child: MaterialApp.router(routerConfig: appRouter),
        ),
      );
      await tester.pumpAndSettle();

      appRouter.go(Routes.checkout);
      await tester.pumpAndSettle();

      expect(find.text('Review order'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.widgetWithText(FilledButton, 'Pay and place order'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(1), '4242');
      await tester.enterText(textFields.at(2), '12/28');
      await tester.enterText(textFields.at(3), '123');
      await tester.pumpAndSettle();

      await tester.tap(
        find.widgetWithText(FilledButton, 'Pay and place order'),
      );
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(await ordersRepo.getOrders(), isNotEmpty);
      expect(find.text('Restaurant is closed.'), findsNothing);
      expect(find.text('Unable to place order right now.'), findsNothing);
    },
  );

  testWidgets(
    'Money path (pickup): cart → checkout → pay → place → confirmation',
    (tester) async {
      final DummyCartRepository cartRepo = DummyCartRepository();
      cartRepo.addItem(
        const MenuItem(
          id: 'item-1',
          restaurantId: 'rest-1',
          categoryId: 'cat-1',
          name: 'Misir Comfort Bowl',
          description: 'Red lentils, warm spices.',
          price: 10.00,
          tags: [MenuItemTag.quickFilling],
        ),
        1,
      );
      final DummyAddressRepository addressRepo = DummyAddressRepository();
      final DummyOrdersRepository ordersRepo = DummyOrdersRepository();
      final DummyPaymentsRepository paymentsRepo = DummyPaymentsRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            welcomeStorageProvider.overrideWithValue(FakeWelcomeStorage()),
            cartRepositoryProvider.overrideWithValue(cartRepo),
            addressRepositoryProvider.overrideWithValue(addressRepo),
            ordersRepositoryProvider.overrideWithValue(ordersRepo),
            paymentsRepositoryProvider.overrideWithValue(paymentsRepo),
            orderDetailsQueryProvider.overrideWithValue(
              const OrderDetailsQuery(orderId: 'order-1'),
            ),
          ],
          child: MaterialApp.router(routerConfig: appRouter),
        ),
      );
      await tester.pumpAndSettle();

      appRouter.go(Routes.checkout);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pickup'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.widgetWithText(FilledButton, 'Pay and place order'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(1), '4242');
      await tester.enterText(textFields.at(2), '12/28');
      await tester.enterText(textFields.at(3), '123');
      await tester.pumpAndSettle();

      await tester.tap(
        find.widgetWithText(FilledButton, 'Pay and place order'),
      );
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(await ordersRepo.getOrders(), isNotEmpty);
      expect(find.text('Restaurant is closed.'), findsNothing);
      expect(find.text('Unable to place order right now.'), findsNothing);
    },
  );
}

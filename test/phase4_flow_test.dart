import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/app/providers.dart';
import 'package:yekermo/app/router.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/data/repositories/dummy_address_repository.dart';
import 'package:yekermo/data/repositories/dummy_cart_repository.dart';
import 'package:yekermo/domain/models.dart';

void main() {
  testWidgets('Cart to review flow with delivery and address', (tester) async {
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cartRepositoryProvider.overrideWithValue(cartRepo),
          addressRepositoryProvider.overrideWithValue(addressRepo),
        ],
        child: MaterialApp.router(
          routerConfig: appRouter,
        ),
      ),
    );

    appRouter.go(Routes.cart);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Review order'));
    await tester.pumpAndSettle();

    expect(find.text('Fulfillment'), findsOneWidget);
    expect(find.textContaining('Add a delivery address'), findsOneWidget);

    await tester.tap(find.text('Delivery'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add address'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '215 Riverstone Ave');
    await tester.enterText(find.byType(TextField).at(1), 'YYC');
    await tester.tap(find.text('Save address'));
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Delivery fee'), 300);
    expect(find.text('Delivery fee'), findsOneWidget);
    expect(find.text('\$16.50'), findsOneWidget);

    final FilledButton button = tester.widget(
      find.widgetWithText(FilledButton, 'Ready to place order'),
    );
    expect(button.onPressed, isNull);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/app/di.dart';
import 'package:yekermo/app/reorder_signal_provider.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/reorder_signal.dart';
import 'package:yekermo/domain/restaurant_menu.dart';
import 'package:yekermo/features/restaurant/restaurant_controller.dart';
import 'package:yekermo/features/restaurant/restaurant_screen.dart';
import 'package:yekermo/shared/state/screen_state.dart';
import 'helpers/fake_reorder_signal_store.dart';

const String _restaurantId = 'rest-1';

const Restaurant _stubRestaurant = Restaurant(
  id: _restaurantId,
  name: 'Stub',
  tagline: 'Tag',
  prepTimeBand: PrepTimeBand.fast,
  serviceModes: [ServiceMode.delivery],
  tags: [],
  trustCopy: 'Trust',
  dishNames: [],
);

void main() {
  testWidgets('reorder reason label visible when count >= 2', (tester) async {
    final fakeStore = FakeReorderSignalStore(
      initial: ReorderSignal({_restaurantId: 2}),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          reorderSignalStoreProvider.overrideWithValue(fakeStore),
          restaurantControllerProvider.overrideWith(
            () => _StubRestaurantController(),
          ),
          restaurantQueryProvider.overrideWithValue(
            RestaurantQuery(restaurantId: _restaurantId),
          ),
        ],
        child: MaterialApp(
          home: RestaurantScreen(restaurantId: _restaurantId),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Because you reorder'), findsOneWidget);
  });

  testWidgets('reorder reason label hidden when count < 2', (tester) async {
    final fakeStore = FakeReorderSignalStore(
      initial: ReorderSignal.empty,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          reorderSignalStoreProvider.overrideWithValue(fakeStore),
          restaurantControllerProvider.overrideWith(
            () => _StubRestaurantController(),
          ),
          restaurantQueryProvider.overrideWithValue(
            RestaurantQuery(restaurantId: _restaurantId),
          ),
        ],
        child: MaterialApp(
          home: RestaurantScreen(restaurantId: _restaurantId),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Because you reorder'), findsNothing);
  });
}

class _StubRestaurantController extends RestaurantController {
  @override
  ScreenState<RestaurantVm> build() {
    return ScreenState.success(
      const RestaurantVm(
        restaurant: _stubRestaurant,
        categories: [],
        items: [],
        forYouItems: [],
        headerTitle: 'Menu',
        headerSubtitle: 'Subtitle',
        pastOrderQuantities: {},
        intent: null,
      ),
    );
  }
}

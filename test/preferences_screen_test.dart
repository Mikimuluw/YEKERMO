import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/app/user_preferences_provider.dart';
import 'package:yekermo/domain/user_preferences.dart';
import 'package:yekermo/features/settings/preferences_screen.dart';
import 'helpers/fake_preferences_store.dart';

void main() {
  testWidgets('toggle switch updates provider state and calls save', (
    tester,
  ) async {
    final fakeStore = FakePreferencesStore(
      initial: const UserPreferences(
        pickupPreferred: false,
        fastingFriendly: false,
        vegetarianBias: false,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [preferencesStoreProvider.overrideWithValue(fakeStore)],
        child: const MaterialApp(home: PreferencesScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(fakeStore.saveCalls, isEmpty);

    final pickupSwitch = find.byWidgetPredicate(
      (w) =>
          w is SwitchListTile &&
          w.title is Text &&
          (w.title as Text).data == 'Prefer pickup',
    );
    expect(pickupSwitch, findsOneWidget);

    await tester.tap(pickupSwitch);
    await tester.pumpAndSettle();

    expect(fakeStore.saveCalls, hasLength(1));
    expect(fakeStore.saveCalls.first.pickupPreferred, isTrue);
    expect(fakeStore.saveCalls.first.fastingFriendly, isFalse);
    expect(fakeStore.saveCalls.first.vegetarianBias, isFalse);
  });
}

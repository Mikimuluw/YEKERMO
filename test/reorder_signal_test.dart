import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/app/reorder_signal_provider.dart';
import 'package:yekermo/domain/reorder_signal.dart';
import 'helpers/fake_reorder_signal_store.dart';

void main() {
  group('ReorderSignal', () {
    test('defaults empty', () {
      const signal = ReorderSignal();
      expect(signal.counts, isEmpty);
      expect(signal.countForRestaurant('r1'), 0);
    });

    test('increment works', () {
      const signal = ReorderSignal();
      final one = signal.increment('r1');
      expect(one.countForRestaurant('r1'), 1);
      expect(one.countForRestaurant('r2'), 0);

      final two = one.increment('r1');
      expect(two.countForRestaurant('r1'), 2);

      final twoAndOne = two.increment('r2');
      expect(twoAndOne.countForRestaurant('r1'), 2);
      expect(twoAndOne.countForRestaurant('r2'), 1);
    });

    test('empty constant is empty', () {
      expect(ReorderSignal.empty.counts, isEmpty);
    });
  });

  group('ReorderSignal persistence', () {
    test('round-trip via map preserves counts', () {
      const signal = ReorderSignal({'r1': 2, 'r2': 1});
      expect(signal.countForRestaurant('r1'), 2);
      expect(signal.countForRestaurant('r2'), 1);
      final ReorderSignal loaded = ReorderSignal(signal.counts);
      expect(loaded.countForRestaurant('r1'), 2);
      expect(loaded.countForRestaurant('r2'), 1);
    });
  });

  group('ReorderSignalProvider', () {
    test('incrementForRestaurant updates state and persists', () async {
      final fakeStore = FakeReorderSignalStore();

      final container = ProviderContainer(
        overrides: [
          reorderSignalStoreProvider.overrideWithValue(fakeStore),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(reorderSignalProvider).countForRestaurant('r1'), 0);

      await container
          .read(reorderSignalProvider.notifier)
          .incrementForRestaurant('r1');

      expect(container.read(reorderSignalProvider).countForRestaurant('r1'), 1);
      expect(fakeStore.saveCalls, isNotEmpty);
      expect(fakeStore.saveCalls.last.countForRestaurant('r1'), 1);
    });
  });
}


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/app/providers.dart';
import 'package:yekermo/app/referral_provider.dart';
import 'package:yekermo/core/config/app_config.dart';
import 'package:yekermo/domain/referral.dart';
import 'helpers/fake_referral_store.dart';

/// Allow async _load to complete so state is populated.
Future<void> _waitForLoad(ProviderContainer container) async {
  for (var i = 0; i < 20; i++) {
    if (container.read(referralProvider).code.isNotEmpty) return;
    await Future.delayed(const Duration(milliseconds: 5));
  }
}

void main() {
  group('Referral model', () {
    test('copyWith updates only given fields', () {
      const r = Referral(code: 'abc', sentCount: 1, redeemedCount: 0);
      expect(r.copyWith(sentCount: 2).sentCount, 2);
      expect(r.copyWith(sentCount: 2).redeemedCount, 0);
      expect(r.copyWith(redeemedCount: 1).code, 'abc');
    });
  });

  group('Referral code stability', () {
    test('code generated once and stable across load/save round-trip', () async {
      final fakeStore = FakeReferralStore();
      final container = ProviderContainer(
        overrides: [referralStoreProvider.overrideWithValue(fakeStore)],
      );
      addTearDown(container.dispose);

      await _waitForLoad(container);

      final code1 = container.read(referralProvider).code;
      expect(code1, isNotEmpty);

      await container.read(referralProvider.notifier).incrementSent();
      final code2 = container.read(referralProvider).code;
      expect(code2, code1);

      expect(fakeStore.saveCalls, isNotEmpty);
      expect(fakeStore.saveCalls.last.code, code1);
    });
  });

  group('ReferralProvider', () {
    test('sent count increments and persists', () async {
      final fakeStore = FakeReferralStore(
        initial: const Referral(code: 'xyz', sentCount: 0, redeemedCount: 0),
      );
      final container = ProviderContainer(
        overrides: [referralStoreProvider.overrideWithValue(fakeStore)],
      );
      addTearDown(container.dispose);

      await _waitForLoad(container);
      expect(container.read(referralProvider).sentCount, 0);

      await container.read(referralProvider.notifier).incrementSent();
      expect(container.read(referralProvider).sentCount, 1);
      expect(fakeStore.saveCalls.last.sentCount, 1);

      await container.read(referralProvider.notifier).incrementSent();
      expect(container.read(referralProvider).sentCount, 2);
      expect(fakeStore.saveCalls.last.sentCount, 2);
    });

    test('kill switch disables mutation', () async {
      final fakeStore = FakeReferralStore(
        initial: const Referral(code: 'kk', sentCount: 0, redeemedCount: 0),
      );
      final container = ProviderContainer(
        overrides: [
          referralStoreProvider.overrideWithValue(fakeStore),
          appConfigProvider.overrideWith(
            (ref) => const AppConfig(enableReferral: false),
          ),
        ],
      );
      addTearDown(container.dispose);

      await _waitForLoad(container);
      await container.read(referralProvider.notifier).incrementSent();
      expect(container.read(referralProvider).sentCount, 0);
      expect(fakeStore.saveCalls, isEmpty);

      await container.read(referralProvider.notifier).incrementRedeemed();
      expect(container.read(referralProvider).redeemedCount, 0);
      expect(fakeStore.saveCalls, isEmpty);
    });
  });

  group('Referral persistence', () {
    test('round-trip via store preserves code and counts', () async {
      final fakeStore = FakeReferralStore(
        initial: const Referral(code: 'round', sentCount: 3, redeemedCount: 1),
      );
      final container = ProviderContainer(
        overrides: [referralStoreProvider.overrideWithValue(fakeStore)],
      );
      addTearDown(container.dispose);

      await _waitForLoad(container);
      final ref = container.read(referralProvider);
      expect(ref.code, 'round');
      expect(ref.sentCount, 3);
      expect(ref.redeemedCount, 1);
    });
  });
}

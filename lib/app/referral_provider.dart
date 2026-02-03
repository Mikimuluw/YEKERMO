import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yekermo/core/storage/local_referral_store.dart';
import 'package:yekermo/core/storage/referral_store.dart';
import 'package:yekermo/domain/referral.dart';

final referralStoreProvider = Provider<ReferralStore>((ref) {
  return LocalReferralStore();
});

final referralProvider =
    NotifierProvider<ReferralNotifier, Referral>(ReferralNotifier.new);

class ReferralNotifier extends Notifier<Referral> {
  @override
  Referral build() {
    state = Referral(code: '');
    Future<void>.microtask(_load);
    return state;
  }

  Future<void> _load() async {
    final store = ref.read(referralStoreProvider);
    final loaded = await store.load();
    if (!ref.mounted) return;
    state = loaded;
  }

  Future<void> incrementSent() async {
    final newState = state.copyWith(sentCount: state.sentCount + 1);
    state = newState;
    await ref.read(referralStoreProvider).save(newState);
  }

  /// Stubbed for now; no server/redemption flow yet.
  Future<void> incrementRedeemed() async {
    final newState = state.copyWith(redeemedCount: state.redeemedCount + 1);
    state = newState;
    await ref.read(referralStoreProvider).save(newState);
  }
}

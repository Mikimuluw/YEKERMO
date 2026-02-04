import 'package:yekermo/core/storage/referral_store.dart';
import 'package:yekermo/domain/referral.dart';

/// In-memory store that records save() calls for tests.
class FakeReferralStore extends ReferralStore {
  FakeReferralStore({Referral? initial})
    : _referral = initial ?? const Referral(code: 'test-code');

  Referral _referral;

  final List<Referral> saveCalls = [];

  @override
  Future<Referral> load() async => _referral;

  @override
  Future<void> save(Referral referral) async {
    _referral = referral;
    saveCalls.add(referral);
  }
}

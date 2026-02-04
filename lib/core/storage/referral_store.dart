import 'package:yekermo/domain/referral.dart';

abstract class ReferralStore {
  Future<Referral> load();
  Future<void> save(Referral referral);
}

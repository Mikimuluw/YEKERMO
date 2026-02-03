import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:yekermo/core/storage/referral_store.dart';
import 'package:yekermo/domain/referral.dart';

class LocalReferralStore extends ReferralStore {
  static const _key = 'referral';

  static String _generateCode() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final r = Random();
    return List.generate(8, (_) => chars[r.nextInt(chars.length)]).join();
  }

  @override
  Future<Referral> load() async {
    final sp = await SharedPreferences.getInstance();
    final String? raw = sp.getString(_key);
    if (raw == null) {
      final referral = Referral(code: _generateCode());
      await save(referral);
      return referral;
    }
    try {
      final Map<String, dynamic> map = jsonDecode(raw) as Map<String, dynamic>;
      return Referral(
        code: map['code'] as String,
        sentCount: (map['sentCount'] as num?)?.toInt() ?? 0,
        redeemedCount: (map['redeemedCount'] as num?)?.toInt() ?? 0,
      );
    } catch (_) {
      final referral = Referral(code: _generateCode());
      await save(referral);
      return referral;
    }
  }

  @override
  Future<void> save(Referral referral) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(
      _key,
      jsonEncode({
        'code': referral.code,
        'sentCount': referral.sentCount,
        'redeemedCount': referral.redeemedCount,
      }),
    );
  }
}

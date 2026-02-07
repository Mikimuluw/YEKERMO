import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight gate: has the user seen the one-time welcome screen?
/// Implementations are injectable for tests.
abstract class WelcomeStorage {
  Future<bool> hasSeen();
  Future<void> markSeen();
}

class LocalWelcomeStorage implements WelcomeStorage {
  LocalWelcomeStorage();

  static const _key = 'welcome_seen';

  @override
  Future<bool> hasSeen() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_key) ?? false;
  }

  @override
  Future<void> markSeen() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_key, true);
  }
}

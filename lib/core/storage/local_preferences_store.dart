import 'package:shared_preferences/shared_preferences.dart';
import 'package:yekermo/core/storage/preferences_store.dart';
import 'package:yekermo/domain/user_preferences.dart';

class LocalPreferencesStore extends PreferencesStore {
  static const _pickupKey = 'pref_pickup';
  static const _fastingKey = 'pref_fasting';
  static const _vegKey = 'pref_veg';

  @override
  Future<UserPreferences> load() async {
    final sp = await SharedPreferences.getInstance();
    return UserPreferences(
      pickupPreferred: sp.getBool(_pickupKey) ?? false,
      fastingFriendly: sp.getBool(_fastingKey) ?? false,
      vegetarianBias: sp.getBool(_vegKey) ?? false,
    );
  }

  @override
  Future<void> save(UserPreferences prefs) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_pickupKey, prefs.pickupPreferred);
    await sp.setBool(_fastingKey, prefs.fastingFriendly);
    await sp.setBool(_vegKey, prefs.vegetarianBias);
  }
}

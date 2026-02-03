import 'package:yekermo/domain/user_preferences.dart';

abstract class PreferencesStore {
  Future<UserPreferences> load();
  Future<void> save(UserPreferences prefs);
}

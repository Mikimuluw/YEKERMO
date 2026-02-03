import 'package:yekermo/core/storage/preferences_store.dart';
import 'package:yekermo/domain/user_preferences.dart';

/// In-memory store that records save() calls for tests.
class FakePreferencesStore extends PreferencesStore {
  FakePreferencesStore({UserPreferences? initial}) : _prefs = initial ?? UserPreferences.defaults;

  UserPreferences _prefs;

  final List<UserPreferences> saveCalls = [];

  @override
  Future<UserPreferences> load() async => _prefs;

  @override
  Future<void> save(UserPreferences prefs) async {
    _prefs = prefs;
    saveCalls.add(prefs);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yekermo/core/storage/local_preferences_store.dart';
import 'package:yekermo/core/storage/preferences_store.dart';
import 'package:yekermo/domain/user_preferences.dart';

final preferencesStoreProvider = Provider<PreferencesStore>((ref) {
  return LocalPreferencesStore();
});

final userPreferencesProvider =
    NotifierProvider<UserPreferencesNotifier, UserPreferences>(
      UserPreferencesNotifier.new,
    );

class UserPreferencesNotifier extends Notifier<UserPreferences> {
  @override
  UserPreferences build() {
    state = UserPreferences.defaults;
    Future<void>.microtask(_load);
    return state;
  }

  Future<void> _load() async {
    final store = ref.read(preferencesStoreProvider);
    state = await store.load();
  }

  Future<void> update(UserPreferences prefs) async {
    state = prefs;
    await ref.read(preferencesStoreProvider).save(prefs);
  }
}

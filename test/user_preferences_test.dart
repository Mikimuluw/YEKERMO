import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/domain/user_preferences.dart';

void main() {
  test('defaults are all false', () {
    const prefs = UserPreferences();
    expect(prefs.pickupPreferred, false);
    expect(prefs.fastingFriendly, false);
    expect(prefs.vegetarianBias, false);
  });

  test('copyWith updates only specified fields', () {
    const prefs = UserPreferences();
    final updated = prefs.copyWith(pickupPreferred: true);

    expect(updated.pickupPreferred, true);
    expect(updated.fastingFriendly, false);
    expect(updated.vegetarianBias, false);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/core/ranking/preference_scoring.dart';
import 'package:yekermo/domain/user_preferences.dart';

void main() {
  group('preferenceScore', () {
    test('all prefs off returns 0 for any flags', () {
      const prefs = UserPreferences();
      expect(
        preferenceScore(
          prefs: prefs,
          supportsPickup: true,
          isFastingFriendly: true,
          isVegetarian: true,
        ),
        0,
      );
      expect(
        preferenceScore(
          prefs: prefs,
          supportsPickup: false,
          isFastingFriendly: false,
          isVegetarian: false,
        ),
        0,
      );
    });

    test('pickupPreferred on gives +2 when supportsPickup', () {
      const prefs = UserPreferences(pickupPreferred: true);
      expect(
        preferenceScore(
          prefs: prefs,
          supportsPickup: true,
          isFastingFriendly: false,
          isVegetarian: false,
        ),
        2,
      );
      expect(
        preferenceScore(
          prefs: prefs,
          supportsPickup: false,
          isFastingFriendly: false,
          isVegetarian: false,
        ),
        0,
      );
    });

    test('fastingFriendly on gives +1 when isFastingFriendly', () {
      const prefs = UserPreferences(fastingFriendly: true);
      expect(
        preferenceScore(
          prefs: prefs,
          supportsPickup: false,
          isFastingFriendly: true,
          isVegetarian: false,
        ),
        1,
      );
      expect(
        preferenceScore(
          prefs: prefs,
          supportsPickup: false,
          isFastingFriendly: false,
          isVegetarian: false,
        ),
        0,
      );
    });

    test('vegetarianBias on gives +1 when isVegetarian', () {
      const prefs = UserPreferences(vegetarianBias: true);
      expect(
        preferenceScore(
          prefs: prefs,
          supportsPickup: false,
          isFastingFriendly: false,
          isVegetarian: true,
        ),
        1,
      );
      expect(
        preferenceScore(
          prefs: prefs,
          supportsPickup: false,
          isFastingFriendly: false,
          isVegetarian: false,
        ),
        0,
      );
    });

    test('multiple prefs on sum correctly', () {
      const prefs = UserPreferences(
        pickupPreferred: true,
        fastingFriendly: true,
        vegetarianBias: true,
      );
      expect(
        preferenceScore(
          prefs: prefs,
          supportsPickup: true,
          isFastingFriendly: true,
          isVegetarian: true,
        ),
        4,
      );
    });

    test('turning prefs off restores zero score', () {
      const prefsOn = UserPreferences(pickupPreferred: true);
      const prefsOff = UserPreferences();
      expect(
        preferenceScore(
          prefs: prefsOn,
          supportsPickup: true,
          isFastingFriendly: false,
          isVegetarian: false,
        ),
        2,
      );
      expect(
        preferenceScore(
          prefs: prefsOff,
          supportsPickup: true,
          isFastingFriendly: false,
          isVegetarian: false,
        ),
        0,
      );
    });
  });

  group('ordering bias', () {
    test('all prefs off preserves original order when scores tie', () {
      const prefs = UserPreferences();
      final items = [
        (supportsPickup: true, isFasting: false, isVeg: false),
        (supportsPickup: false, isFasting: false, isVeg: false),
        (supportsPickup: true, isFasting: true, isVeg: false),
      ];
      final withScores = items.map((item) {
        final score = preferenceScore(
          prefs: prefs,
          supportsPickup: item.supportsPickup,
          isFastingFriendly: item.isFasting,
          isVegetarian: item.isVeg,
        );
        return (item, score);
      }).toList();
      withScores.sort((a, b) => b.$2.compareTo(a.$2));
      final order = withScores.map((e) => e.$1).toList();
      expect(order[0].supportsPickup, items[0].supportsPickup);
      expect(order[1].supportsPickup, items[1].supportsPickup);
      expect(order[2].supportsPickup, items[2].supportsPickup);
    });

    test('pickupPreferred on pushes pickup-supporting items up', () {
      const prefs = UserPreferences(pickupPreferred: true);
      final items = [
        (supportsPickup: false, isFasting: false, isVeg: false),
        (supportsPickup: true, isFasting: false, isVeg: false),
        (supportsPickup: false, isFasting: false, isVeg: false),
      ];
      final withScores = items.map((item) {
        final score = preferenceScore(
          prefs: prefs,
          supportsPickup: item.supportsPickup,
          isFastingFriendly: item.isFasting,
          isVegetarian: item.isVeg,
        );
        return (item, score);
      }).toList();
      withScores.sort((a, b) => b.$2.compareTo(a.$2));
      final order = withScores.map((e) => e.$1).toList();
      expect(order.first.supportsPickup, isTrue);
      expect(order.last.supportsPickup, isFalse);
    });
  });
}

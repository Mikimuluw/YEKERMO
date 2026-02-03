import 'package:yekermo/domain/user_preferences.dart';

/// Scores a restaurant/item for preference-based ordering.
/// Only nudges order; base relevance still dominates.
/// Pickup preferred +2, fasting +1, vegetarian bias +1.
int preferenceScore({
  required UserPreferences prefs,
  required bool supportsPickup,
  required bool isFastingFriendly,
  required bool isVegetarian,
}) {
  var score = 0;
  if (prefs.pickupPreferred && supportsPickup) score += 2;
  if (prefs.fastingFriendly && isFastingFriendly) score += 1;
  if (prefs.vegetarianBias && isVegetarian) score += 1;
  return score;
}

class UserPreferences {
  const UserPreferences({
    this.pickupPreferred = false,
    this.fastingFriendly = false,
    this.vegetarianBias = false,
  });

  final bool pickupPreferred;
  final bool fastingFriendly;
  final bool vegetarianBias;

  UserPreferences copyWith({
    bool? pickupPreferred,
    bool? fastingFriendly,
    bool? vegetarianBias,
  }) {
    return UserPreferences(
      pickupPreferred: pickupPreferred ?? this.pickupPreferred,
      fastingFriendly: fastingFriendly ?? this.fastingFriendly,
      vegetarianBias: vegetarianBias ?? this.vegetarianBias,
    );
  }

  static const defaults = UserPreferences();
}

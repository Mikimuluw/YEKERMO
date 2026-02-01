class DiscoveryFilters {
  const DiscoveryFilters({
    this.intent,
    this.pickupFriendly = false,
    this.familySize = false,
    this.fastingFriendly = false,
  });

  final String? intent;
  final bool pickupFriendly;
  final bool familySize;
  final bool fastingFriendly;

  bool get hasAny =>
      (intent != null && intent!.isNotEmpty) ||
      pickupFriendly ||
      familySize ||
      fastingFriendly;
}

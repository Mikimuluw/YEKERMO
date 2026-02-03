/// Immutable map of restaurantId -> reorder count. Defaults empty.
class ReorderSignal {
  const ReorderSignal([this.counts = const {}]);

  final Map<String, int> counts;

  int countForRestaurant(String restaurantId) => counts[restaurantId] ?? 0;

  ReorderSignal increment(String restaurantId) {
    final next = (counts[restaurantId] ?? 0) + 1;
    return ReorderSignal({...counts, restaurantId: next});
  }

  static const empty = ReorderSignal();
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yekermo/core/storage/local_reorder_signal_store.dart';
import 'package:yekermo/core/storage/reorder_signal_store.dart';
import 'package:yekermo/domain/reorder_signal.dart';

final reorderSignalStoreProvider = Provider<ReorderSignalStore>((ref) {
  return LocalReorderSignalStore();
});

final reorderSignalProvider =
    NotifierProvider<ReorderSignalNotifier, ReorderSignal>(
      ReorderSignalNotifier.new,
    );

class ReorderSignalNotifier extends Notifier<ReorderSignal> {
  @override
  ReorderSignal build() {
    state = ReorderSignal.empty;
    Future<void>.microtask(_load);
    return state;
  }

  Future<void> _load() async {
    final store = ref.read(reorderSignalStoreProvider);
    final loaded = await store.load();
    if (!ref.mounted) return;
    state = loaded;
  }

  Future<void> incrementForRestaurant(String restaurantId) async {
    final newState = state.increment(restaurantId);
    state = newState;
    await ref.read(reorderSignalStoreProvider).save(newState);
  }

  int countForRestaurant(String restaurantId) =>
      state.countForRestaurant(restaurantId);
}

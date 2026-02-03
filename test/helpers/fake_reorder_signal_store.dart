import 'package:yekermo/core/storage/reorder_signal_store.dart';
import 'package:yekermo/domain/reorder_signal.dart';

/// In-memory store that records save() calls for tests.
class FakeReorderSignalStore extends ReorderSignalStore {
  FakeReorderSignalStore({ReorderSignal? initial})
      : _signal = initial ?? ReorderSignal.empty;

  ReorderSignal _signal;

  final List<ReorderSignal> saveCalls = [];

  @override
  Future<ReorderSignal> load() async => _signal;

  @override
  Future<void> save(ReorderSignal signal) async {
    _signal = signal;
    saveCalls.add(signal);
  }
}

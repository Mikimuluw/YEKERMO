import 'package:yekermo/domain/reorder_signal.dart';

abstract class ReorderSignalStore {
  Future<ReorderSignal> load();
  Future<void> save(ReorderSignal signal);
}

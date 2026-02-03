import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:yekermo/core/storage/reorder_signal_store.dart';
import 'package:yekermo/domain/reorder_signal.dart';

class LocalReorderSignalStore extends ReorderSignalStore {
  static const _key = 'reorder_signal';

  @override
  Future<ReorderSignal> load() async {
    final sp = await SharedPreferences.getInstance();
    final String? raw = sp.getString(_key);
    if (raw == null) return ReorderSignal.empty;
    try {
      final Map<String, dynamic> decoded =
          jsonDecode(raw) as Map<String, dynamic>;
      final Map<String, int> counts = decoded.map(
        (k, v) => MapEntry(k, v as int),
      );
      return ReorderSignal(counts);
    } catch (_) {
      return ReorderSignal.empty;
    }
  }

  @override
  Future<void> save(ReorderSignal signal) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_key, jsonEncode(signal.counts));
  }
}

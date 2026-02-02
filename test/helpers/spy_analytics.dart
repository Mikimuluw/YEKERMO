import 'package:yekermo/observability/analytics.dart';

class SpyAnalytics implements Analytics {
  final Map<String, int> counts = {};

  @override
  void track(String event, {Map<String, Object?>? properties}) {
    counts.update(event, (value) => value + 1, ifAbsent: () => 1);
  }

  int countFor(String event) => counts[event] ?? 0;
}

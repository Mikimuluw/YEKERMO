abstract class Analytics {
  void track(String event, {Map<String, Object?>? properties});
}

class DummyAnalytics implements Analytics {
  const DummyAnalytics();

  @override
  void track(String event, {Map<String, Object?>? properties}) {}
}

abstract class Analytics {
  void track(String event, {Map<String, Object?>? properties});
}

class DummyAnalytics implements Analytics {
  const DummyAnalytics();

  @override
  void track(String event, {Map<String, Object?>? properties}) {}
}

class AnalyticsEvents {
  static const String discoveryViewed = 'discovery_viewed';
  static const String discoveryFilterApplied = 'discovery_filter_applied';
  static const String searchSubmitted = 'search_submitted';
  static const String restaurantCardTapped = 'restaurant_card_tapped';
}

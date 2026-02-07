import 'package:yekermo/core/city/city.dart';

class AppConfig {
  const AppConfig({
    this.useRealBackend = false,
    this.defaultCity = const CityContext(CityId.calgary),
    this.enablePersonalization = true,
    this.enableReorderPersonalization = true,
    this.enableReorder = true,
    this.enableReferral = true,
  });

  final bool useRealBackend;
  final CityContext defaultCity;
  final bool enablePersonalization;
  final bool enableReorderPersonalization;
  /// When false, all Reorder CTAs are disabled (global kill-switch). Default true. See Phase 11.2 / PRD §4.3.
  final bool enableReorder;
  final bool enableReferral;
}

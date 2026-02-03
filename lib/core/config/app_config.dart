import 'package:yekermo/core/city/city.dart';

class AppConfig {
  const AppConfig({
    this.useRealBackend = false,
    this.defaultCity = const CityContext(CityId.calgary),
    this.enablePersonalization = true,
    this.enableReorderPersonalization = true,
    this.enableReferral = true,
  });

  final bool useRealBackend;
  final CityContext defaultCity;
  final bool enablePersonalization;
  final bool enableReorderPersonalization;
  final bool enableReferral;
}

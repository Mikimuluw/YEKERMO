import 'package:yekermo/core/city/city.dart';

class AppConfig {
  const AppConfig({
    this.useRealBackend = false,
    this.defaultCity = const CityContext(CityId.calgary),
  });

  final bool useRealBackend;
  final CityContext defaultCity;
}

enum CityId { calgary }

extension CityIdX on CityId {
  String get slug => 'calgary';
}

class CityContext {
  const CityContext(this.cityId);

  final CityId cityId;
}

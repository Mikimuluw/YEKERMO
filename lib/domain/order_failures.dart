enum PlaceOrderFailureCode {
  restaurantClosed,
  serviceModeUnavailable,
  unknownRestaurant,
  unknown,
}

class PlaceOrderFailure {
  final PlaceOrderFailureCode code;

  const PlaceOrderFailure(this.code);

  @override
  String toString() => 'PlaceOrderFailure($code)';
}

class PlaceOrderException implements Exception {
  final PlaceOrderFailure failure;
  const PlaceOrderException(this.failure);
}

/// Simple restaurant input for the detail screen. Pass from router or use default stub.
///
/// [restaurantId] is used when adding dishes to cart (required for cart state).
/// When routing from list cards (Home, Search, Discovery), pass the real [restaurantId]
/// from the tapped restaurant so cart identity is correct. Default `'detail'` is for
/// standalone/stub usage only.
///
/// Cart policy (one-restaurant-at-a-time vs mixed, and "Replace cart?" flow) is
/// enforced at cart/checkout layer; this screen only needs a valid id for add-item.
class RestaurantDetailInput {
  const RestaurantDetailInput({
    required this.name,
    required this.meta,
    required this.ratingLabel,
    required this.dishes,
    this.restaurantId = 'detail',
  });

  final String name;
  final String meta;
  final String ratingLabel;
  final List<DishDetailInput> dishes;
  final String restaurantId;
}

class DishDetailInput {
  const DishDetailInput({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
  });

  final String id;
  final String name;
  final String description;
  final double price;
}

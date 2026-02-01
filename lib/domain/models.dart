enum AddressLabel { home, work }

enum PrepTimeBand { fast, standard, slow }

extension PrepTimeBandLabel on PrepTimeBand {
  String get label {
    switch (this) {
      case PrepTimeBand.fast:
        return '20–30 min';
      case PrepTimeBand.standard:
        return '30–40 min';
      case PrepTimeBand.slow:
        return '40–55 min';
    }
  }
}

enum ServiceMode { delivery, pickup }

enum RestaurantTag {
  quickFilling,
  familySize,
  fastingFriendly,
  pickupFriendly,
}

enum MenuItemTag {
  quickFilling,
  familySize,
  fastingFriendly,
}

class Address {
  const Address({
    required this.id,
    required this.label,
    required this.line1,
    required this.city,
    this.neighborhood,
    this.notes,
  });

  final String id;
  final AddressLabel label;
  final String line1;
  final String city;
  final String? neighborhood;
  final String? notes;
}

class Preference {
  const Preference({
    required this.favoriteCuisines,
    required this.dietaryTags,
  });

  final List<String> favoriteCuisines;
  final List<String> dietaryTags;
}

class Customer {
  const Customer({
    required this.id,
    required this.name,
    required this.primaryAddressId,
    required this.preference,
  });

  final String id;
  final String name;
  final String primaryAddressId;
  final Preference preference;
}

class Restaurant {
  const Restaurant({
    required this.id,
    required this.name,
    required this.tagline,
    required this.prepTimeBand,
    required this.serviceModes,
    required this.tags,
    required this.trustCopy,
    required this.dishNames,
  });

  final String id;
  final String name;
  final String tagline;
  final PrepTimeBand prepTimeBand;
  final List<ServiceMode> serviceModes;
  final List<RestaurantTag> tags;
  final String trustCopy;
  final List<String> dishNames;
}

class MenuCategory {
  const MenuCategory({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;
}

class MenuItem {
  const MenuItem({
    required this.id,
    required this.restaurantId,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.tags,
  });

  final String id;
  final String restaurantId;
  final String categoryId;
  final String name;
  final String description;
  final double price;
  final List<MenuItemTag> tags;
}

class OrderItem {
  const OrderItem({
    required this.menuItemId,
    required this.quantity,
  });

  final String menuItemId;
  final int quantity;
}

class Order {
  const Order({
    required this.id,
    required this.restaurantId,
    required this.items,
    required this.total,
    this.scheduledTime,
  });

  final String id;
  final String restaurantId;
  final List<OrderItem> items;
  final double total;
  final DateTime? scheduledTime;
}

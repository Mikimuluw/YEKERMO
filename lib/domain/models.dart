import 'package:yekermo/domain/fees.dart';
import 'package:yekermo/domain/payment_method.dart';

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

enum FulfillmentMode { delivery, pickup }

enum OrderStatus {
  received,
  preparing,
  ready,
  completed,
  cancelled,
  failed,
  refunded,
}

enum PaymentStatus { unpaid, paid }

extension OrderStatusLabel on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.received:
        return 'Received';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.failed:
        return 'Failed';
      case OrderStatus.refunded:
        return 'Refunded';
    }
  }

  /// In-progress: received, preparing, ready. Shown in Active tab.
  bool get isInProgress =>
      this == OrderStatus.received ||
      this == OrderStatus.preparing ||
      this == OrderStatus.ready;

  /// Terminal: completed, cancelled, failed, refunded. Shown in Past tab; no polling.
  bool get isTerminal =>
      this == OrderStatus.completed ||
      this == OrderStatus.cancelled ||
      this == OrderStatus.failed ||
      this == OrderStatus.refunded;

  /// Display label for UI. For [OrderStatus.ready], varies by fulfillment:
  /// delivery → "On the way", pickup → "Ready". Other statuses use [label].
  String displayLabel(FulfillmentMode? fulfillmentMode) {
    if (this == OrderStatus.ready && fulfillmentMode != null) {
      return fulfillmentMode == FulfillmentMode.delivery
          ? 'On the way'
          : 'Ready';
    }
    return label;
  }

  /// Receipt screen header title. Trust-first wording.
  String get receiptHeaderTitle {
    switch (this) {
      case OrderStatus.completed:
        return 'Order delivered';
      case OrderStatus.cancelled:
        return 'Order cancelled';
      case OrderStatus.failed:
        return 'Order not completed';
      case OrderStatus.refunded:
        return 'Order refunded';
      case OrderStatus.received:
      case OrderStatus.preparing:
      case OrderStatus.ready:
        return 'Order details';
    }
  }
}

enum RestaurantTag { quickFilling, familySize, fastingFriendly, pickupFriendly }

enum MenuItemTag { quickFilling, familySize, fastingFriendly }

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
  const Preference({required this.favoriteCuisines, required this.dietaryTags});

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
    required this.address,
    required this.tagline,
    required this.prepTimeBand,
    required this.serviceModes,
    required this.tags,
    required this.trustCopy,
    required this.dishNames,
    this.hoursByWeekday,
    this.rating,
    this.maxMinutes,
  });

  final String id;
  final String name;
  final String address;
  final String tagline;
  final PrepTimeBand prepTimeBand;
  final List<ServiceMode> serviceModes;
  final List<RestaurantTag> tags;
  final String trustCopy;
  final List<String> dishNames;

  /// 1 = Monday … 7 = Sunday; value e.g. "11:00-21:30". Used for open/closed and availability copy.
  final Map<int, String>? hoursByWeekday;

  /// Optional for search/browse (e.g. "Top rated" filter).
  final double? rating;

  /// Optional for search/browse (e.g. "Under 30 min" filter).
  final int? maxMinutes;
}

class MenuCategory {
  const MenuCategory({required this.id, required this.title});

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
  const OrderItem({required this.menuItemId, required this.quantity});

  final String menuItemId;
  final int quantity;
}

class Order {
  const Order({
    required this.id,
    required this.restaurantId,
    required this.items,
    required this.total,
    required this.status,
    required this.fulfillmentMode,
    this.paymentStatus = PaymentStatus.unpaid,
    this.paymentMethod,
    this.feeBreakdown,
    this.paidAt,
    this.address,
    this.placedAt,
    this.scheduledTime,
  });

  final String id;
  final String restaurantId;
  final List<OrderItem> items;
  final double total;
  final OrderStatus status;
  final FulfillmentMode fulfillmentMode;
  final PaymentStatus paymentStatus;
  final PaymentMethod? paymentMethod;
  final FeeBreakdown? feeBreakdown;
  final DateTime? paidAt;
  final Address? address;
  final DateTime? placedAt;
  final DateTime? scheduledTime;
}

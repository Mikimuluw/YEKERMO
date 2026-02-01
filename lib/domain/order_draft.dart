import 'package:yekermo/domain/cart.dart';
import 'package:yekermo/domain/models.dart';

enum FulfillmentMode { delivery, pickup }

class FeeBreakdown {
  const FeeBreakdown({
    required this.subtotal,
    required this.serviceFee,
    required this.deliveryFee,
    required this.tax,
  });

  final double subtotal;
  final double serviceFee;
  final double deliveryFee;
  final double tax;

  double get total => subtotal + serviceFee + deliveryFee + tax;
}

class OrderDraft {
  const OrderDraft({
    required this.items,
    required this.fulfillmentMode,
    required this.fees,
    this.address,
    this.notes,
  });

  final List<CartLineItem> items;
  final FulfillmentMode fulfillmentMode;
  final Address? address;
  final String? notes;
  final FeeBreakdown fees;
}

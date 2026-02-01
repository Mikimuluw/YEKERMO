import 'package:yekermo/domain/cart.dart';
import 'package:yekermo/domain/fees.dart';
import 'package:yekermo/domain/models.dart';

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

import 'package:yekermo/data/dto/address_dto.dart';
import 'package:yekermo/data/dto/order_item_dto.dart';
import 'package:yekermo/domain/fees.dart';
import 'package:yekermo/domain/models.dart';
import 'package:yekermo/domain/payment_method.dart';

class OrderDto {
  const OrderDto({
    required this.id,
    required this.restaurantId,
    required this.items,
    required this.total,
    this.status,
    this.fulfillmentMode,
    this.paymentStatus,
    this.paymentMethod,
    this.feeBreakdown,
    this.paidAt,
    this.address,
    this.placedAt,
    this.scheduledTime,
  });

  final String id;
  final String restaurantId;
  final List<OrderItemDto> items;
  final double total;
  final OrderStatus? status;
  final FulfillmentMode? fulfillmentMode;
  final PaymentStatus? paymentStatus;
  final PaymentMethod? paymentMethod;
  final FeeBreakdown? feeBreakdown;
  final DateTime? paidAt;
  final AddressDto? address;
  final DateTime? placedAt;
  final DateTime? scheduledTime;

  static OrderStatus _statusFromString(String s) {
    final upper = s.toUpperCase();
    switch (upper) {
      case 'RECEIVED':
      case 'NEW':
      case 'PENDING_PAYMENT':
      case 'ACCEPTED':
        return OrderStatus.received;
      case 'PREPARING':
        return OrderStatus.preparing;
      case 'READY':
      case 'READY_FOR_PICKUP':
      case 'OUT_FOR_DELIVERY':
        return OrderStatus.ready;
      case 'COMPLETED':
      case 'DELIVERED':
        return OrderStatus.completed;
      case 'CANCELLED':
        return OrderStatus.cancelled;
      case 'FAILED':
      case 'REJECTED':
        return OrderStatus.failed;
      case 'REFUNDED':
        return OrderStatus.refunded;
      default:
        return OrderStatus.received;
    }
  }

  static FulfillmentMode _fulfillmentFromString(String s) {
    return s == 'pickup' ? FulfillmentMode.pickup : FulfillmentMode.delivery;
  }

  static PaymentStatus _paymentStatusFromString(String s) {
    return s.toUpperCase() == 'PAID' ? PaymentStatus.paid : PaymentStatus.unpaid;
  }

  static OrderDto fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    final addressMap = json['address'] as Map<String, dynamic>?;
    final paymentMap = json['paymentMethod'] as Map<String, dynamic>?;
    double total = 0;
    if (json['total'] != null) {
      total = (json['total'] is int) ? (json['total'] as int).toDouble() : json['total'] as double;
    }
    final subtotal = (json['subtotal'] is int) ? (json['subtotal'] as int).toDouble() : (json['subtotal'] as double?) ?? 0;
    final serviceFee = (json['serviceFee'] is int) ? (json['serviceFee'] as int).toDouble() : (json['serviceFee'] as double?) ?? 0;
    final deliveryFee = (json['deliveryFee'] is int) ? (json['deliveryFee'] as int).toDouble() : (json['deliveryFee'] as double?) ?? 0;
    final tax = (json['tax'] is int) ? (json['tax'] as int).toDouble() : (json['tax'] as double?) ?? 0;
    return OrderDto(
      id: json['id'] as String,
      restaurantId: json['restaurantId'] as String,
      items: itemsList.map((e) => OrderItemDto.fromJson(e as Map<String, dynamic>)).toList(),
      total: total,
      status: json['status'] != null ? _statusFromString(json['status'] as String) : null,
      fulfillmentMode: json['fulfillmentMode'] != null ? _fulfillmentFromString(json['fulfillmentMode'] as String) : null,
      paymentStatus: json['paymentStatus'] != null ? _paymentStatusFromString(json['paymentStatus'] as String) : null,
      paymentMethod: paymentMap != null ? PaymentMethod(brand: paymentMap['brand'] as String, last4: paymentMap['last4'] as String) : null,
      feeBreakdown: FeeBreakdown(subtotal: subtotal, serviceFee: serviceFee, deliveryFee: deliveryFee, tax: tax),
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt'] as String) : null,
      address: addressMap != null ? AddressDto.fromJson(addressMap) : null,
      placedAt: json['placedAt'] != null ? DateTime.parse(json['placedAt'] as String) : null,
      scheduledTime: json['scheduledTime'] != null ? DateTime.parse(json['scheduledTime'] as String) : null,
    );
  }

  Order toModel() => Order(
    id: id,
    restaurantId: restaurantId,
    items: items.map((item) => item.toModel()).toList(),
    total: total,
    status: status ?? OrderStatus.received,
    fulfillmentMode: fulfillmentMode ?? FulfillmentMode.delivery,
    paymentStatus: paymentStatus ?? PaymentStatus.paid,
    paymentMethod: paymentMethod,
    feeBreakdown: feeBreakdown,
    paidAt: paidAt,
    address: address?.toModel(),
    placedAt: placedAt,
    scheduledTime: scheduledTime,
  );
}

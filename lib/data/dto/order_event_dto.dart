/// One entry in the order audit/timeline from GET /orders/:id/events.
class OrderEventDto {
  const OrderEventDto({
    required this.id,
    required this.orderId,
    required this.type,
    required this.actorType,
    required this.createdAt,
    this.fromStatus,
    this.toStatus,
    this.actorId,
    this.metadata = const {},
  });

  final String id;
  final String orderId;
  final String type;
  final String? fromStatus;
  final String? toStatus;
  final String actorType;
  final String? actorId;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  static OrderEventDto fromJson(Map<String, dynamic> json) {
    return OrderEventDto(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      type: json['type'] as String,
      fromStatus: json['fromStatus'] as String?,
      toStatus: json['toStatus'] as String?,
      actorType: json['actorType'] as String,
      actorId: json['actorId'] as String?,
      metadata: json['metadata'] is Map<String, dynamic>
          ? json['metadata'] as Map<String, dynamic>
          : const {},
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Short label for timeline (e.g. "Order placed", "Payment confirmed").
  String get displayLabel {
    switch (type) {
      case 'ORDER_CREATED':
        return 'Order placed';
      case 'PAYMENT_SUCCEEDED':
        return 'Payment confirmed';
      case 'PAYMENT_FAILED':
        return 'Payment failed';
      case 'STATUS_CHANGED':
        return toStatus != null ? _statusLabel(toStatus!) : 'Status updated';
      case 'CANCELLED_BY_CUSTOMER':
        return 'Cancelled by you';
      case 'CANCELLED_BY_RESTAURANT':
        return 'Cancelled by restaurant';
      default:
        return type.replaceAll('_', ' ').toLowerCase();
    }
  }

  static String _statusLabel(String s) {
    return s.replaceAll('_', ' ').toLowerCase();
  }
}

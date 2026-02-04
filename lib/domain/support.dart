enum SupportCategory {
  missingItem,
  wrongItem,
  lateDelivery,
  cancelRequest,
  other,
}

class SupportRequestDraft {
  const SupportRequestDraft({
    required this.orderId,
    required this.userEmail,
    required this.category,
    required this.createdAt,
    this.message,
  });

  final String orderId;
  final String userEmail;
  final SupportCategory category;
  final String? message;
  final DateTime createdAt;

  Map<String, Object?> toPayload() => {
    'orderId': orderId,
    'userEmail': userEmail,
    'category': category.name,
    'message': message,
    'timestamp': createdAt.toIso8601String(),
  };
}

class SupportEntryPoint {
  const SupportEntryPoint({required this.orderId, required this.userEmail});

  final String orderId;
  final String userEmail;

  SupportRequestDraft createDraft({
    required SupportCategory category,
    String? message,
    DateTime? timestamp,
  }) {
    return SupportRequestDraft(
      orderId: orderId,
      userEmail: userEmail,
      category: category,
      message: message,
      createdAt: timestamp ?? DateTime.now(),
    );
  }
}

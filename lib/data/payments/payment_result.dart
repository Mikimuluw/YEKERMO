enum PaymentResultStatus { success, failure }

class PaymentResult {
  const PaymentResult({
    required this.status,
    required this.transactionId,
    this.message,
  });

  final PaymentResultStatus status;
  final String transactionId;
  final String? message;

  bool get isSuccess => status == PaymentResultStatus.success;
}

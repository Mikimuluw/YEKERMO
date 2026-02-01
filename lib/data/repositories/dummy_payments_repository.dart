import 'dart:math';

import 'package:yekermo/data/payments/payment_intent.dart';
import 'package:yekermo/data/payments/payment_result.dart';
import 'package:yekermo/data/repositories/payments_repository.dart';
import 'package:yekermo/domain/payment_method.dart';

class DummyPaymentsRepository implements PaymentsRepository {
  @override
  Future<PaymentResult> processPayment(
    PaymentIntent intent,
    PaymentMethod method,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (method.last4 == '0000') {
      return const PaymentResult(
        status: PaymentResultStatus.failure,
        transactionId: 'txn-failed',
        message: "Payment didn't go through. Nothing was charged.",
      );
    }
    final int suffix = Random().nextInt(9999);
    return PaymentResult(
      status: PaymentResultStatus.success,
      transactionId: 'txn-$suffix',
    );
  }
}

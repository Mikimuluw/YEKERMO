import 'package:yekermo/data/payments/payment_intent.dart';
import 'package:yekermo/data/payments/payment_result.dart';
import 'package:yekermo/domain/payment_method.dart';

abstract class PaymentsRepository {
  Future<PaymentResult> processPayment(
    PaymentIntent intent,
    PaymentMethod method,
  );
}

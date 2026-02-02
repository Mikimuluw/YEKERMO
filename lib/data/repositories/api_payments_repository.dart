import 'package:yekermo/core/transport/transport_client.dart';
import 'package:yekermo/data/payments/payment_intent.dart';
import 'package:yekermo/data/payments/payment_result.dart';
import 'package:yekermo/data/repositories/payments_repository.dart';
import 'package:yekermo/domain/payment_method.dart';

class ApiPaymentsRepository implements PaymentsRepository {
  ApiPaymentsRepository(this.transportClient);

  final TransportClient transportClient;

  @override
  Future<PaymentResult> processPayment(
    PaymentIntent intent,
    PaymentMethod method,
  ) async {
    try {
      final TransportResponse<PaymentResult> response =
          await transportClient.request<PaymentResult>(
        TransportRequest(
          method: 'POST',
          url: Uri(path: '/payments/charge'),
          body: <String, Object?>{
            'amount': intent.amount,
            'currency': intent.currency,
            'description': intent.description,
            'paymentMethod': <String, Object?>{
              'brand': method.brand,
              'last4': method.last4,
            },
          },
          timeout: const Duration(seconds: 12),
        ),
      );
      return response.data;
    } on TransportError catch (error) {
      return _failureFromTransport(error);
    } catch (_) {
      return _fallbackFailure();
    }
  }

  PaymentResult _failureFromTransport(TransportError error) {
    return _fallbackFailure();
  }

  PaymentResult _fallbackFailure() {
    return const PaymentResult(
      status: PaymentResultStatus.failure,
      transactionId: 'txn-failed',
      message: "Payment didn't go through. Nothing was charged.",
    );
  }
}

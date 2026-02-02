import 'package:flutter_test/flutter_test.dart';
import 'package:yekermo/core/transport/fake_transport_client.dart';
import 'package:yekermo/core/transport/transport_client.dart';
import 'package:yekermo/data/payments/payment_intent.dart';
import 'package:yekermo/data/payments/payment_result.dart';
import 'package:yekermo/data/repositories/api_payments_repository.dart';
import 'package:yekermo/data/repositories/dummy_payments_repository.dart';
import 'package:yekermo/data/repositories/payments_repository.dart';
import 'package:yekermo/domain/payment_method.dart';

const PaymentIntent _intent = PaymentIntent(
  amount: 12.50,
  currency: 'CAD',
  description: 'Test payment',
);

const PaymentMethod _successMethod = PaymentMethod(
  brand: 'Card',
  last4: '4242',
);

const PaymentMethod _failureMethod = PaymentMethod(
  brand: 'Card',
  last4: '0000',
);

const String _failureMessage = "Payment didn't go through. Nothing was charged.";

void main() {
  group('PaymentsRepository contract', () {
    test('dummy repository returns success result', () async {
      final PaymentsRepository repo = DummyPaymentsRepository();
      final PaymentResult result = await repo.processPayment(
        _intent,
        _successMethod,
      );
      expect(result.status, PaymentResultStatus.success);
      expect(result.transactionId.isNotEmpty, isTrue);
    });

    test('dummy repository returns failure result with message', () async {
      final PaymentsRepository repo = DummyPaymentsRepository();
      final PaymentResult result = await repo.processPayment(
        _intent,
        _failureMethod,
      );
      expect(result.status, PaymentResultStatus.failure);
      expect(result.transactionId, 'txn-failed');
      expect(result.message, _failureMessage);
    });

    test('api repository returns success result', () async {
      final FakeTransportClient transport = FakeTransportClient(
        response: const TransportResponse<PaymentResult>(
          data: PaymentResult(
            status: PaymentResultStatus.success,
            transactionId: 'txn-1234',
          ),
          statusCode: 200,
        ),
      );
      final PaymentsRepository repo = ApiPaymentsRepository(transport);
      final PaymentResult result = await repo.processPayment(
        _intent,
        _successMethod,
      );
      expect(result.status, PaymentResultStatus.success);
      expect(result.transactionId, 'txn-1234');
    });

    test('api repository maps transport errors to failure', () async {
      final FakeTransportClient transport = FakeTransportClient(
        scenario: FakeTransportScenario.timeout,
      );
      final PaymentsRepository repo = ApiPaymentsRepository(transport);
      final PaymentResult result = await repo.processPayment(
        _intent,
        _successMethod,
      );
      expect(result.status, PaymentResultStatus.failure);
      expect(result.transactionId, 'txn-failed');
      expect(result.message, _failureMessage);
    });
  });
}

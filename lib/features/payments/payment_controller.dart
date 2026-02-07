import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yekermo/app/providers.dart';
import 'package:yekermo/data/payments/payment_intent.dart';
import 'package:yekermo/observability/app_log.dart';
import 'package:yekermo/data/payments/payment_result.dart';
import 'package:yekermo/domain/failure.dart';
import 'package:yekermo/domain/payment_method.dart';
import 'package:yekermo/shared/state/screen_state.dart';

class PaymentController extends Notifier<ScreenState<PaymentVm>> {
  @override
  ScreenState<PaymentVm> build() {
    return ScreenState.success(const PaymentVm());
  }

  void setMethod(PaymentMethod method) {
    state = ScreenState.success(PaymentVm(method: method));
  }

  Future<PaymentResult> processPayment({
    required double amount,
    required PaymentMethod method,
  }) async {
    state = ScreenState.loading();
    final PaymentResult result = await ref
        .read(paymentsRepositoryProvider)
        .processPayment(
          PaymentIntent(
            amount: amount,
            currency: 'USD',
            description: 'Yekermo order',
          ),
          method,
        );
    if (result.isSuccess) {
      state = ScreenState.success(PaymentVm(method: method));
    } else {
      final String message =
          result.message ?? "Payment didn't go through. Nothing was charged.";
      AppLog.error('Payment failed: $message');
      state = ScreenState.error(Failure(message));
    }
    return result;
  }
}

class PaymentVm {
  const PaymentVm({this.method});

  final PaymentMethod? method;
}

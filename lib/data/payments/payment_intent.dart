class PaymentIntent {
  const PaymentIntent({
    required this.amount,
    required this.currency,
    required this.description,
  });

  final double amount;
  final String currency;
  final String description;
}

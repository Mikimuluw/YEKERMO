class PaymentMethod {
  const PaymentMethod({required this.brand, required this.last4});

  final String brand;
  final String last4;

  String get label => '$brand •••• $last4';
}

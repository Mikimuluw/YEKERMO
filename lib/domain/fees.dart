class FeeBreakdown {
  const FeeBreakdown({
    required this.subtotal,
    required this.serviceFee,
    required this.deliveryFee,
    required this.tax,
  });

  final double subtotal;
  final double serviceFee;
  final double deliveryFee;
  final double tax;

  double get total => subtotal + serviceFee + deliveryFee + tax;
}

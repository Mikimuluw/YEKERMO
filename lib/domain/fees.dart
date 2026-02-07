/// Single source of truth for cart/checkout fee and total math.
/// Use [FeeBreakdown.fromSubtotal] so Cart and Checkout show the same numbers.
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

  static const double defaultDeliveryFee = 3.75;
  static const double defaultServiceFee = 2.25;
  static const double defaultTaxRate = 0.05;

  /// Rounds to 2 decimals to avoid floating-point display issues.
  static double _round2(double v) => (v * 100).round() / 100;

  /// Computes delivery fee, service fee, and tax from subtotal (delivery mode).
  /// Cart and Checkout use this so totals never diverge.
  /// Values are rounded to 2 decimals; consider moving to int cents for production.
  factory FeeBreakdown.fromSubtotal(double subtotal) {
    final sub = _round2(subtotal);
    final tax = _round2(sub * defaultTaxRate);
    return FeeBreakdown(
      subtotal: sub,
      serviceFee: defaultServiceFee,
      deliveryFee: defaultDeliveryFee,
      tax: tax,
    );
  }
}

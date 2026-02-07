import 'package:flutter/material.dart';
import 'package:yekermo/theme/spacing.dart';

/// One row for fees breakdown: label on the left, price on the right. Uses theme text styles.
///
/// [value] is the numeric amount; displayed as currency. Use [emphasize] for total row.
/// No hardcoded colors or styles.
class PriceRow extends StatelessWidget {
  const PriceRow({
    super.key,
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final double value;
  final bool emphasize;

  static String format(double value) => '\$${value.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle? style = emphasize ? textTheme.titleSmall : textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(format(value), style: style),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:yekermo/shared/extensions/context_extensions.dart';
import 'package:yekermo/theme/spacing.dart';

/// Link-style action for "View receipt", "Get help", "Change address", etc.
///
/// Uses theme primary color and text style; no border or fill. Meets minimum
/// tap target height. Only tokens and theme; no custom styling.
class LinkButton extends StatelessWidget {
  const LinkButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = context.colors;
    final TextStyle? textStyle = context.text.bodyMedium?.copyWith(
      color: colors.primary,
    );

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: colors.primary,
        minimumSize: const Size(48, AppSpacing.tapTarget),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      child: Text(label, style: textStyle),
    );
  }
}

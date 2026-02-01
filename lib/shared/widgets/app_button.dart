import 'package:flutter/material.dart';
import 'package:yekermo/shared/tokens/app_spacing.dart';

enum AppButtonStyle { primary, secondary }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = AppButtonStyle.primary,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonStyle style;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final ButtonStyle buttonStyle = ButtonStyle(
      minimumSize: WidgetStateProperty.all(
        const Size(0, AppSpacing.tapTarget),
      ),
    );

    final Widget child = icon == null
        ? Text(label)
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: AppSpacing.xs),
              Text(label),
            ],
          );

    switch (style) {
      case AppButtonStyle.primary:
        return FilledButton(
          onPressed: onPressed,
          style: buttonStyle,
          child: child,
        );
      case AppButtonStyle.secondary:
        return OutlinedButton(
          onPressed: onPressed,
          style: buttonStyle,
          child: child,
        );
    }
  }
}

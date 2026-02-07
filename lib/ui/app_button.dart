import 'package:flutter/material.dart';
import 'package:yekermo/theme/spacing.dart';

/// Primary or secondary CTA. Full-width by default; uses theme and [AppSpacing.tapTarget].
///
/// No hardcoded colors or text styles. [label] and optional [icon] are content.
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
    final bool enabled = onPressed != null;
    final ButtonStyle buttonStyle = ButtonStyle(
      minimumSize: WidgetStateProperty.all(
        const Size(double.infinity, AppSpacing.tapTarget),
      ),
      elevation: WidgetStateProperty.all(enabled ? null : 0),
      shadowColor: WidgetStateProperty.all(enabled ? null : Colors.transparent),
    );

    final Widget child = icon == null
        ? Text(label)
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: AppSpacing.xs),
              Text(label),
            ],
          );

    Widget button;
    switch (style) {
      case AppButtonStyle.primary:
        button = FilledButton(
          onPressed: onPressed,
          style: buttonStyle,
          child: child,
        );
        break;
      case AppButtonStyle.secondary:
        button = OutlinedButton(
          onPressed: onPressed,
          style: buttonStyle,
          child: child,
        );
        break;
    }
    if (!enabled) {
      button = Opacity(opacity: 0.5, child: button);
    }
    return button;
  }
}

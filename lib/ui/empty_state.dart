import 'package:flutter/material.dart';
import 'package:yekermo/shared/extensions/context_extensions.dart';
import 'package:yekermo/shared/tokens/app_spacing.dart';

/// Standard empty state for Orders, Favorites, Search, etc.
///
/// Centered layout: optional icon, title, optional message, optional action.
/// Uses only theme (context.text, context.colors) and [AppSpacing]. No custom styling.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.action,
  });

  final String title;
  final String? message;
  final IconData? icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = context.text;
    final ColorScheme colors = context.colors;

    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 48,
                color: context.textTertiary,
              ),
              AppSpacing.vMd,
            ],
            Text(title, style: text.titleMedium, textAlign: TextAlign.center),
            if (message != null) ...[
              AppSpacing.vXs,
              Text(
                message!,
                style: text.bodyMedium?.copyWith(color: context.muted),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[AppSpacing.vMd, action!],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:yekermo/shared/extensions/context_extensions.dart';
import 'package:yekermo/shared/tokens/app_spacing.dart';

class AppLoading extends StatelessWidget {
  const AppLoading({super.key, this.message, this.textOnly = false});

  final String? message;
  /// When true, shows only calm text (no spinner). Use for order detail etc.
  final bool textOnly;

  @override
  Widget build(BuildContext context) {
    if (textOnly) {
      return Center(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Text(
            message ?? 'Loading…',
            style: context.text.bodyMedium?.copyWith(
              color: context.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              AppSpacing.vSm,
              Text(
                message!,
                style: context.text.bodyMedium?.copyWith(
                  color: context.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

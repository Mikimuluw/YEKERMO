import 'package:flutter/material.dart';
import 'package:yekermo/observability/app_log.dart';
import 'package:yekermo/shared/extensions/context_extensions.dart';
import 'package:yekermo/shared/tokens/app_spacing.dart';
import 'package:yekermo/shared/widgets/app_scaffold.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = context.text;
    final ColorScheme scheme = context.colors;
    AppLog.warn('Route not found: ${message ?? 'unknown'}');

    return AppScaffold(
      title: 'Not found',
      body: Center(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Text(
            message ?? 'We could not find that page.',
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yekermo/app/routes.dart';
import 'package:yekermo/observability/app_log.dart';
import 'package:yekermo/shared/extensions/context_extensions.dart';
import 'package:yekermo/shared/tokens/app_spacing.dart';
import 'package:yekermo/ui/app_button.dart';
import 'package:yekermo/ui/app_scaffold.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = context.text;
    AppLog.warn('Route not found: ${message ?? 'unknown'}');

    return AppScaffold(
      title: 'Not found',
      body: Center(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message ?? 'We could not find that page.',
                style: textTheme.bodyMedium?.copyWith(
                  color: context.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.vLg,
              AppButton(
                label: 'Back to Home',
                onPressed: () => context.go(Routes.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

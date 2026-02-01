import 'package:flutter/material.dart';
import 'package:yekermo/shared/extensions/context_extensions.dart';
import 'package:yekermo/shared/tokens/app_spacing.dart';
import 'package:yekermo/shared/widgets/app_scaffold.dart';

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = context.text;
    final ColorScheme scheme = context.colors;

    return AppScaffold(
      title: title,
      body: Center(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Text(
            subtitle ?? 'Coming soon.',
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

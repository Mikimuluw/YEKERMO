import 'package:flutter/material.dart';
import 'package:yekermo/theme/spacing.dart';

/// List row: leading, title, optional subtitle, trailing. Uses theme text styles and spacing.
///
/// Takes content (strings, widgets); no hardcoded colors or styles.
class AppListTile extends StatelessWidget {
  const AppListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return ListTile(
      contentPadding: AppSpacing.s16,
      leading: leading,
      title: Text(title, style: textTheme.titleMedium),
      subtitle: subtitle != null ? Text(subtitle!, style: textTheme.bodyMedium) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}

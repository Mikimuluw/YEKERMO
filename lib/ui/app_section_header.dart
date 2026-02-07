import 'package:flutter/material.dart';
import 'package:yekermo/theme/spacing.dart';

/// Section title row (e.g. "Your usual", "Popular dishes", "Fees"). Uses theme title style.
///
/// Takes [title] and optional [trailing]. No hardcoded colors or text styles.
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sectionTitleGap),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: textTheme.titleMedium),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

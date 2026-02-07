import 'package:flutter/material.dart';
import 'package:yekermo/theme/color_tokens.dart';

/// App bar: primary background, title left-aligned, no bottom divider.
/// Actions (e.g. notification bell) sit inside a soft circular container.
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppBar({
    super.key,
    required this.title,
    this.actions,
  });

  final String title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color containerColor = isDark
        ? ColorTokens.onPrimary.withValues(alpha: 0.2)
        : ColorTokens.onPrimary.withValues(alpha: 0.15);

    return AppBar(
      title: Align(alignment: Alignment.centerLeft, child: Text(title)),
      titleSpacing: 16,
      actions: actions == null
          ? null
          : [
              for (final w in actions!)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: containerColor,
                        shape: BoxShape.circle,
                      ),
                      child: w,
                    ),
                  ),
                ),
            ],
    );
  }
}

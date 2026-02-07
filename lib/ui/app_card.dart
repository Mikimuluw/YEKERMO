import 'package:flutter/material.dart';
import 'package:yekermo/theme/color_tokens.dart';
import 'package:yekermo/theme/radii.dart';
import 'package:yekermo/theme/spacing.dart';

/// Card with theme-driven surface and token shadow. Use this for all card surfaces (no raw [Card]).
///
/// Default padding is [AppSpacing.cardPadding]. Uses [AppRadii.brCard] and [ColorTokens.cardShadow].
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding, this.onTap});

  final Widget child;

  /// If null, uses [AppSpacing.cardPadding].
  final EdgeInsets? padding;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets resolvedPadding = padding ?? AppSpacing.cardPadding;
    final Color surfaceColor =
        Theme.of(context).cardTheme.color ??
        Theme.of(context).colorScheme.surface;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: AppRadii.brCard,
        boxShadow: ColorTokens.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.brCard,
          child: Padding(padding: resolvedPadding, child: child),
        ),
      ),
    );
  }
}

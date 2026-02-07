import 'package:flutter/material.dart';
import 'package:yekermo/theme/color_tokens.dart';

extension AppContextExtensions on BuildContext {
  TextTheme get text => Theme.of(this).textTheme;
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// Semantic muted/secondary text. Use instead of ad-hoc onSurface.withValues(alpha: …).
  Color get muted => Theme.of(this).brightness == Brightness.dark
      ? ColorTokens.nightMuted
      : ColorTokens.muted;

  /// Muted text color (secondary hierarchy). Use for supporting text, metadata, labels.
  /// Alias for `muted` for clarity in usage.
  Color get textMuted => muted;

  /// Tertiary text (low emphasis). Use for timestamps, helper text, very low emphasis content.
  Color get textTertiary => colors.onSurface.withValues(alpha: 0.5);
}

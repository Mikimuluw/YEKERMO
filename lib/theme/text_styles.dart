import 'package:flutter/material.dart';

/// Single source of truth for typography tokens.
///
/// Prefer using Theme.textTheme (via `context.text`) in UI; use these names
/// when building or overriding text styles so typography stays consistent.
class TextStyles {
  TextStyles._();

  /// Headline (e.g. screen title). Semibold.
  static const String headline = 'headlineSmall';

  /// Section or card title. Semibold.
  static const String titleLarge = 'titleLarge';
  static const String titleMedium = 'titleMedium';

  /// Body copy.
  static const String bodyLarge = 'bodyLarge';
  static const String bodyMedium = 'bodyMedium';
  static const String bodySmall = 'bodySmall';

  /// Labels, buttons, captions. Semibold for labels.
  static const String labelLarge = 'labelLarge';
  static const String labelMedium = 'labelMedium';
  static const String labelSmall = 'labelSmall';

  /// Build a text style with optional color override (e.g. muted).
  static TextStyle withColor(TextStyle base, Color color) =>
      base.copyWith(color: color);
}

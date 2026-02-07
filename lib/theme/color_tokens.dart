import 'package:flutter/material.dart';
import 'package:yekermo/theme/tokens.dart';

/// Yekermo UI guardrails: color tokens. Canonical values in [AppTokens].
/// See docs/ui_guardrails.md.
class ColorTokens {
  ColorTokens._();

  // --- From AppTokens (lock) ---
  static const Color background = AppTokens.brandCanvas;
  static const Color surface = AppTokens.surfaceCard;
  static const Color primary = AppTokens.brandPrimary;
  static const Color onSurface = AppTokens.textPrimary;
  static const Color muted = AppTokens.textSecondary;

  /// Secondary surface (chips, inputs). Soft neutral.
  static const Color surfaceVariant = Color(0xFFF5F0E6);

  /// Darker primary (pressed, dark mode app bar).
  static const Color primaryDark = Color(0xFF3D0910);

  /// Content on primary (button label, app bar text).
  static const Color onPrimary = Color(0xFFFFFFFF);

  // --- Accent (supporting only) ---
  static const Color accent = Color(0xFFC8A66A);
  static const Color onAccent = Color(0xFF2C2520);

  /// Dividers avoided; separation by space. Use only when necessary.
  static const Color divider = Color(0xFFE6DCC8);

  // --- Dark mode ---
  static const Color nightBackground = Color(0xFF15100C);
  static const Color nightSurface = Color(0xFF20160F);
  static const Color nightOnSurface = Color(0xFFF3E9DD);
  static const Color nightMuted = Color(0xFFCABBAA);

  // --- Semantic ---
  static const Color error = Color(0xFFB3261E);
  static const Color onError = Color(0xFFFFFFFF);

  // --- Card elevation (soft, no borders) ---
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> cardShadowElevated = [
    BoxShadow(
      color: Color(0x18000000),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];
}

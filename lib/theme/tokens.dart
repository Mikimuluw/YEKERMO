import 'package:flutter/material.dart';

/// Authoritative design tokens for Yekermo. Lock once; do not debate.
/// See docs/ui_guardrails.md. All theme files should use these constants.
class AppTokens {
  AppTokens._();

  // --- Color tokens ---
  static const Color brandPrimary = Color(0xFF5B0E14);
  static const Color brandCanvas = Color(0xFFF1E194);

  static const Color surfaceCard = Color(0xFFFFFBF5);
  static const Color textPrimary = Color(0xFF2A1C18);
  static const Color textSecondary = Color(0xFF6E5A54);

  // --- Radius tokens ---
  /// Small (chips, small buttons).
  static const double radiusSm = 10.0;

  /// Default for cards. All cards use this unless explicitly justified.
  static const double radiusMd = 14.0;

  /// Large (modals, hero areas).
  static const double radiusLg = 18.0;

  // --- Spacing tokens ---
  static const double spaceXs = 6.0;
  static const double spaceSm = 10.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 32.0;

  /// Section title → content (12–16px).
  static const double sectionTitleGap = 14.0;

  /// Before next section (24–32px).
  static const double sectionGap = 28.0;

  // --- Typography scale (reference) ---
  // titleLarge: 22, SemiBold
  // sectionHeader: 16, Medium
  // body: 15
  // meta: 13
  // Metadata opacity: 0.65
}

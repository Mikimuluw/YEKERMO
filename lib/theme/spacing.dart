import 'package:flutter/material.dart';
import 'package:yekermo/theme/tokens.dart';

/// Spacing tokens. Canonical values in [AppTokens]. Section rhythm: space only, no dividers.
class AppSpacing {
  AppSpacing._();

  static const double xs = AppTokens.spaceXs;
  static const double sm = AppTokens.spaceSm;
  static const double md = AppTokens.spaceMd;
  static const double lg = AppTokens.spaceLg;
  static const double xl = AppTokens.spaceXl;

  static const double sectionTitleGap = AppTokens.sectionTitleGap;
  static const double sectionGap = AppTokens.sectionGap;

  /// Minimum touch target height (e.g. primary CTA).
  static const double tapTarget = 48;

  static const EdgeInsets s8 = EdgeInsets.all(xs);
  static const EdgeInsets s12 = EdgeInsets.all(sm);
  static const EdgeInsets s16 = EdgeInsets.all(md);
  static const EdgeInsets s24 = EdgeInsets.all(lg);

  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: lg,
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(md);

  static const SizedBox vXs = SizedBox(height: xs);
  static const SizedBox vSm = SizedBox(height: sm);
  static const SizedBox vMd = SizedBox(height: md);
  static const SizedBox vLg = SizedBox(height: lg);
  static const SizedBox vXl = SizedBox(height: xl);

  static const SizedBox hXs = SizedBox(width: xs);
  static const SizedBox hSm = SizedBox(width: sm);
  static const SizedBox hMd = SizedBox(width: md);
  static const SizedBox hLg = SizedBox(width: lg);
  static const SizedBox hXl = SizedBox(width: xl);

  /// After a section title (12–16px).
  static const SizedBox vSectionTitle = SizedBox(height: sectionTitleGap);

  /// Before the next section (24–32px).
  static const SizedBox vSection = SizedBox(height: sectionGap);
}

import 'package:flutter/material.dart';
import 'package:yekermo/theme/tokens.dart';

/// Border radii. Canonical values in [AppTokens]. All cards use [radiusMd].
class AppRadii {
  AppRadii._();

  static const double r12 = AppTokens.radiusSm;
  static const double r16 = AppTokens.radiusMd;
  static const double r24 = AppTokens.radiusLg;

  static const double card = AppTokens.radiusMd;
  static const double input = AppTokens.radiusMd;
  static const double button = AppTokens.radiusMd;

  static BorderRadius get br12 => BorderRadius.circular(r12);
  static BorderRadius get br16 => BorderRadius.circular(r16);
  static BorderRadius get br24 => BorderRadius.circular(r24);

  static BorderRadius get brCard => BorderRadius.circular(card);
  static BorderRadius get brInput => BorderRadius.circular(input);
  static BorderRadius get brButton => BorderRadius.circular(button);
}

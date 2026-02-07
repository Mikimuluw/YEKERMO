import 'package:flutter/material.dart';
import 'package:yekermo/theme/color_tokens.dart';

/// Shadow tokens. Prefer [ColorTokens.cardShadow] / [ColorTokens.cardShadowElevated].
/// These aliases exist for backward compatibility.
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> s1 = ColorTokens.cardShadow;
  static const List<BoxShadow> s2 = ColorTokens.cardShadowElevated;
}

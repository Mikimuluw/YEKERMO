import 'package:flutter/material.dart';
import 'package:yekermo/theme/color_tokens.dart';
import 'package:yekermo/theme/radii.dart';
import 'package:yekermo/theme/spacing.dart';

class AppTheme {
  static ThemeData get light => _buildLight();
  static ThemeData get dark => _buildDark();

  static ThemeData _buildLight() {
    const ColorScheme scheme = ColorScheme(
      brightness: Brightness.light,
      primary: ColorTokens.primary,
      onPrimary: ColorTokens.onPrimary,
      secondary: ColorTokens.accent,
      onSecondary: ColorTokens.onSurface,
      error: ColorTokens.error,
      onError: ColorTokens.onError,
      surface: ColorTokens.surface,
      onSurface: ColorTokens.onSurface,
      primaryContainer: ColorTokens.primaryDark,
      onPrimaryContainer: ColorTokens.onPrimary,
      secondaryContainer: ColorTokens.surfaceVariant,
      onSecondaryContainer: ColorTokens.onSurface,
      surfaceContainerHighest: ColorTokens.surfaceVariant,
      outline: ColorTokens.divider,
      shadow: Color(0x33000000),
      inverseSurface: ColorTokens.onSurface,
      onInverseSurface: ColorTokens.surface,
      inversePrimary: ColorTokens.accent,
      surfaceTint: ColorTokens.primary,
    );

    return _baseTheme(scheme).copyWith(
      scaffoldBackgroundColor: ColorTokens.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: ColorTokens.primary,
        foregroundColor: ColorTokens.onPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  static ThemeData _buildDark() {
    const ColorScheme scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: ColorTokens.accent,
      onPrimary: ColorTokens.nightBackground,
      secondary: ColorTokens.primary,
      onSecondary: ColorTokens.onPrimary,
      error: Color(0xFFF2B8B5),
      onError: ColorTokens.nightBackground,
      surface: ColorTokens.nightSurface,
      onSurface: ColorTokens.nightOnSurface,
      primaryContainer: ColorTokens.primaryDark,
      onPrimaryContainer: ColorTokens.nightOnSurface,
      secondaryContainer: ColorTokens.nightBackground,
      onSecondaryContainer: ColorTokens.nightOnSurface,
      surfaceContainerHighest: ColorTokens.nightBackground,
      outline: ColorTokens.nightMuted,
      shadow: Color(0x66000000),
      inverseSurface: ColorTokens.nightOnSurface,
      onInverseSurface: ColorTokens.nightBackground,
      inversePrimary: ColorTokens.accent,
      surfaceTint: ColorTokens.accent,
    );

    return _baseTheme(scheme).copyWith(
      scaffoldBackgroundColor: ColorTokens.nightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: ColorTokens.primaryDark,
        foregroundColor: ColorTokens.nightOnSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  static ThemeData _baseTheme(ColorScheme scheme) {
    final TextTheme baseText = scheme.brightness == Brightness.dark
        ? Typography.material2021().white
        : Typography.material2021().black;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: baseText.copyWith(
        headlineSmall: baseText.headlineSmall?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: baseText.headlineMedium?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: baseText.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: baseText.titleMedium?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: baseText.bodyLarge?.copyWith(color: scheme.onSurface),
        bodyMedium: baseText.bodyMedium?.copyWith(color: scheme.onSurface),
        labelLarge: baseText.labelLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w400,
        ),
      ),
      dividerTheme: DividerThemeData(color: scheme.outline, thickness: 1),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        selectedColor: scheme.primary,
        labelStyle: TextStyle(color: scheme.onSurface),
        secondaryLabelStyle: TextStyle(color: scheme.onPrimary),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xs / 2,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.br16),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surface,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurface.withValues(alpha: 0.5),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: AppRadii.br16,
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.br16,
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.br16,
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
      ),
    );
  }
}

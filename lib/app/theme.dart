import 'package:flutter/material.dart';
import 'package:yekermo/shared/tokens/app_radii.dart';
import 'package:yekermo/shared/tokens/app_spacing.dart';

class AppColors {
  static const Color warmBrown = Color(0xFF4A2F1B);
  static const Color warmBrownDark = Color(0xFF2E1C10);
  static const Color creamCanvas = Color(0xFFF7F1E7);
  static const Color creamSurface = Color(0xFFFFFBF4);
  static const Color goldenAccent = Color(0xFFC8A66A);
  static const Color charcoal = Color(0xFF2C2520);
  static const Color muted = Color(0xFF7C6F63);
  static const Color divider = Color(0xFFE6D8C8);

  static const Color night = Color(0xFF15100C);
  static const Color nightSurface = Color(0xFF20160F);
  static const Color nightOnSurface = Color(0xFFF3E9DD);
  static const Color nightMuted = Color(0xFFCABBAA);
}

class AppTheme {
  static ThemeData get light => _buildLight();
  static ThemeData get dark => _buildDark();

  static ThemeData _buildLight() {
    const ColorScheme scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.warmBrown,
      onPrimary: Colors.white,
      secondary: AppColors.goldenAccent,
      onSecondary: AppColors.charcoal,
      error: Color(0xFFB3261E),
      onError: Colors.white,
      surface: AppColors.creamSurface,
      onSurface: AppColors.charcoal,
      primaryContainer: AppColors.warmBrownDark,
      onPrimaryContainer: Colors.white,
      secondaryContainer: AppColors.creamCanvas,
      onSecondaryContainer: AppColors.charcoal,
      surfaceContainerHighest: AppColors.creamCanvas,
      outline: AppColors.divider,
      shadow: Color(0x33000000),
      inverseSurface: AppColors.charcoal,
      onInverseSurface: AppColors.creamSurface,
      inversePrimary: AppColors.goldenAccent,
      surfaceTint: AppColors.warmBrown,
    );

    return _baseTheme(scheme).copyWith(
      scaffoldBackgroundColor: AppColors.creamCanvas,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.warmBrown,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }

  static ThemeData _buildDark() {
    const ColorScheme scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.goldenAccent,
      onPrimary: AppColors.night,
      secondary: AppColors.warmBrown,
      onSecondary: Colors.white,
      error: Color(0xFFF2B8B5),
      onError: AppColors.night,
      surface: AppColors.nightSurface,
      onSurface: AppColors.nightOnSurface,
      primaryContainer: AppColors.warmBrownDark,
      onPrimaryContainer: AppColors.nightOnSurface,
      secondaryContainer: AppColors.night,
      onSecondaryContainer: AppColors.nightOnSurface,
      surfaceContainerHighest: AppColors.night,
      outline: AppColors.nightMuted,
      shadow: Color(0x66000000),
      inverseSurface: AppColors.nightOnSurface,
      onInverseSurface: AppColors.night,
      inversePrimary: AppColors.goldenAccent,
      surfaceTint: AppColors.goldenAccent,
    );

    return _baseTheme(scheme).copyWith(
      scaffoldBackgroundColor: AppColors.night,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.warmBrownDark,
        foregroundColor: AppColors.nightOnSurface,
        elevation: 0,
        centerTitle: false,
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
        titleLarge: baseText.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: baseText.titleMedium?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: baseText.bodyLarge?.copyWith(
          color: scheme.onSurface,
        ),
        bodyMedium: baseText.bodyMedium?.copyWith(
          color: scheme.onSurface,
        ),
        labelLarge: baseText.labelLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outline,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        selectedColor: scheme.primary.withValues(alpha: 0.12),
        labelStyle: TextStyle(color: scheme.onSurface),
        secondaryLabelStyle: TextStyle(color: scheme.onSurface),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xs / 2,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: scheme.surfaceTint,
        elevation: 0.4,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.br16),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surface,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurface.withValues(alpha: 0.6),
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

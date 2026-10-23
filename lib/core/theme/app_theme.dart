import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.brand,
      brightness: Brightness.light,
    );
    return _base(colorScheme);
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.brandDark,
      brightness: Brightness.dark,
    );
    return _base(colorScheme);
  }

  static ThemeData ocean() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF007C91),
      brightness: Brightness.light,
    );
    return _base(colorScheme);
  }

  static ThemeData glass() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF4D8DFF),
      brightness: Brightness.light,
      surface: const Color(0xFFEAF3FF),
    );
    return _base(
      colorScheme,
      cardColor: Colors.white.withValues(alpha: 0.58),
      cardRadius: 24,
      cardBorder: BorderSide(
        color: Colors.white.withValues(alpha: 0.78),
        width: 1.2,
      ),
    );
  }

  static ThemeData _base(
    ColorScheme colorScheme, {
    Color? cardColor,
    double cardRadius = 8,
    BorderSide cardBorder = BorderSide.none,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardColor ?? colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: cardBorder,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: colorScheme.secondaryContainer,
      ),
    );
  }
}

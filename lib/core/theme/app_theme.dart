import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors matching Kobson Cash logo
  static const Color primaryBlue = Color(0xFF0055FF);
  static const Color darkBlue = Color(0xFF0B192C);
  static const Color accentGold = Color(0xFFFF9900);
  static const Color accentOrange = Color(0xFFFF6F00);
  static const Color successGreen = Color(0xFF10B981);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: accentGold,
        surface: surfaceLight,
        error: errorRed,
      ),
      scaffoldBackgroundColor: surfaceLight,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: errorRed),
        ),
        labelStyle: const TextStyle(color: textMuted),
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
      ),
      cardTheme: CardThemeData(
        color: cardWhite,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.04),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}

class AppColors {
  static const Color primaryBlue = AppTheme.primaryBlue;
  static const Color navyBlue = AppTheme.darkBlue;
  static const Color darkBlue = AppTheme.darkBlue;
  static const Color accentGold = AppTheme.accentGold;
  static const Color accentOrange = AppTheme.accentOrange;
  static const Color successGreen = AppTheme.successGreen;
  static const Color errorRed = AppTheme.errorRed;
  static const Color backgroundLight = AppTheme.surfaceLight;
  static const Color surfaceLight = AppTheme.surfaceLight;
  static const Color cardWhite = AppTheme.cardWhite;
  static const Color textPrimary = AppTheme.textDark;
  static const Color textSecondary = AppTheme.textMuted;
  static const Color textDark = AppTheme.textDark;
  static const Color textMuted = AppTheme.textMuted;
}

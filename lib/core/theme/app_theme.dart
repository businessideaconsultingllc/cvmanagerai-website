import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors - Premium & Vibrant
  static const Color primaryColor = Color(0xFF4F46E5); // Indigo (New Primary)
  static const Color secondaryColor = Color(0xFF4338CA); // Indigo 700
  static const Color accentColor = Color(0xFF6366F1); // Indigo 500

  // Neutral Colors (Light)
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF1E293B); // Slate 800
  static const Color textSecondaryLight = Color(0xFF64748B); // Slate 500
  static const Color borderLight = Color(0xFFE2E8F0); // Slate 200

  // Neutral Colors (Dark)
  static const Color backgroundDark = Color(0xFF0F172A); // Slate 900
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400
  static const Color borderDark = Color(0xFF334155); // Slate 700

  static TextTheme _buildTextTheme(
      TextTheme base, Color primaryTextColor, Color secondaryTextColor) {
    return base.copyWith(
      displayLarge: GoogleFonts.inter(
        color: primaryTextColor,
        fontWeight: FontWeight.bold,
        fontSize: 32,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.inter(
        color: primaryTextColor,
        fontWeight: FontWeight.bold,
        fontSize: 28,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.inter(
        color: primaryTextColor,
        fontWeight: FontWeight.w600,
        fontSize: 24,
      ),
      headlineMedium: GoogleFonts.inter(
        color: primaryTextColor,
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
      titleLarge: GoogleFonts.inter(
        color: primaryTextColor,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      titleMedium: GoogleFonts.inter(
        color: primaryTextColor,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      bodyLarge: GoogleFonts.inter(
        color: primaryTextColor,
        fontSize: 16,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        color: secondaryTextColor,
        fontSize: 14,
        height: 1.5,
      ),
      labelLarge: GoogleFonts.inter(
        color: primaryTextColor,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: backgroundLight,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceLight,
      error: const Color(0xFFEF4444),
      brightness: Brightness.light,
    ),
    textTheme: _buildTextTheme(
        GoogleFonts.interTextTheme(), textPrimaryLight, textSecondaryLight),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: backgroundLight,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: textPrimaryLight,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Inter',
      ),
      iconTheme: IconThemeData(color: textPrimaryLight),
    ),
    cardTheme: CardTheme(
      color: surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: borderLight),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shadowColor: Colors.black.withValues(alpha: 0.05),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      labelStyle: const TextStyle(
          color: textSecondaryLight, fontWeight: FontWeight.w500),
      hintStyle: TextStyle(color: textSecondaryLight.withValues(alpha: 0.6)),
      floatingLabelStyle:
          const TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
      prefixIconColor: textSecondaryLight,
      suffixIconColor: textSecondaryLight,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        side: const BorderSide(color: primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: borderLight,
      thickness: 1,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundDark,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: accentColor, // Lighter blue for dark mode
      secondary: secondaryColor,
      surface: surfaceDark,

      error: const Color(0xFFEF4444),
      brightness: Brightness.dark,
    ),
    textTheme: _buildTextTheme(
        GoogleFonts.interTextTheme(), textPrimaryDark, textSecondaryDark),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: backgroundDark,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: textPrimaryDark,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Inter',
      ),
      iconTheme: IconThemeData(color: textPrimaryDark),
    ),
    cardTheme: CardTheme(
      color: surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: borderDark),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accentColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      labelStyle: const TextStyle(
          color: textSecondaryDark, fontWeight: FontWeight.w500),
      hintStyle: TextStyle(color: textSecondaryDark.withValues(alpha: 0.5)),
      floatingLabelStyle:
          const TextStyle(color: accentColor, fontWeight: FontWeight.w600),
      prefixIconColor: textSecondaryDark,
      suffixIconColor: textSecondaryDark,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: backgroundDark,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: accentColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        side: const BorderSide(color: accentColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: borderDark,
      thickness: 1,
    ),
  );
}

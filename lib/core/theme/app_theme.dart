import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class AppTheme {
  // ========================================
  // 🎨 PREMIUM COLOR PALETTE
  // ========================================

  // Primary Brand Colors - Vibrant & Professional
  static const Color primaryIndigo = Color(0xFF6366F1); // Indigo 500
  static const Color primaryViolet = Color(0xFF8B5CF6); // Violet 500
  static const Color primaryPink = Color(0xFFEC4899); // Pink 500

  // Accent Colors
  static const Color accentCyan = Color(0xFF06B6D4); // Cyan 500
  static const Color accentEmerald = Color(0xFF10B981); // Emerald 500
  static const Color accentAmber = Color(0xFFF59E0B); // Amber 500

  // Semantic Colors
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color infoBlue = Color(0xFF3B82F6);

  // Backward Compatibility - Old Color Names
  static const Color primaryColor = primaryIndigo;
  static const Color secondaryColor = primaryViolet;
  static const Color accentColor = accentCyan;

  // Neutral Colors (Light Mode)
  static const Color backgroundLight = Color(0xFFFAFAFC); // Ultra light
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceElevatedLight = Color(0xFFF8FAFC);
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0xFF64748B); // Slate 500
  static const Color borderLight = Color(0xFFE2E8F0); // Slate 200
  static const Color borderSubtleLight = Color(0xFFF1F5F9); // Slate 100

  // Neutral Colors (Dark Mode)
  static const Color backgroundDark = Color(0xFF0F172A); // Slate 900
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800
  static const Color surfaceElevatedDark = Color(0xFF334155); // Slate 700
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400
  static const Color borderDark = Color(0xFF334155); // Slate 700
  static const Color borderSubtleDark = Color(0xFF1E293B); // Slate 800

  // ========================================
  // 🌈 BEAUTIFUL GRADIENTS
  // ========================================

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryIndigo, primaryViolet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [primaryIndigo, primaryViolet, primaryPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [accentEmerald, accentCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradientLight = LinearGradient(
    colors: [Color(0xFFFAFAFC), Color(0xFFF1F5F9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient backgroundGradientDark = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Glass effect colors
  static Color glassLight = Colors.white.withOpacity(0.7);
  static Color glassDark = const Color(0xFF1E293B).withOpacity(0.7);
  static Color glassBorderLight = Colors.white.withOpacity(0.2);
  static Color glassBorderDark = Colors.white.withOpacity(0.1);

  // ========================================
  // 📝 TYPOGRAPHY
  // ========================================

  static TextTheme _buildTextTheme(
      TextTheme base, Color primaryTextColor, Color secondaryTextColor) {
    return base.copyWith(
      // Display styles - For hero sections
      displayLarge: GoogleFonts.inter(
        color: primaryTextColor,
        fontWeight: FontWeight.bold,
        fontSize: 40,
        letterSpacing: -1.0,
        height: 1.1,
      ),
      displayMedium: GoogleFonts.inter(
        color: primaryTextColor,
        fontWeight: FontWeight.bold,
        fontSize: 32,
        letterSpacing: -0.5,
        height: 1.2,
      ),
      displaySmall: GoogleFonts.inter(
        color: primaryTextColor,
        fontWeight: FontWeight.bold,
        fontSize: 28,
        letterSpacing: -0.5,
        height: 1.2,
      ),

      // Headlines
      headlineLarge: GoogleFonts.inter(
        color: primaryTextColor,
        fontWeight: FontWeight.bold,
        fontSize: 24,
        height: 1.3,
      ),
      headlineMedium: GoogleFonts.inter(
        color: primaryTextColor,
        fontWeight: FontWeight.w600,
        fontSize: 20,
        height: 1.3,
      ),
      headlineSmall: GoogleFonts.inter(
        color: primaryTextColor,
        fontWeight: FontWeight.w600,
        fontSize: 18,
        height: 1.4,
      ),

      // Titles
      titleLarge: GoogleFonts.inter(
        color: primaryTextColor,
        fontWeight: FontWeight.w600,
        fontSize: 18,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.inter(
        color: primaryTextColor,
        fontWeight: FontWeight.w600,
        fontSize: 16,
        height: 1.4,
      ),
      titleSmall: GoogleFonts.inter(
        color: primaryTextColor,
        fontWeight: FontWeight.w500,
        fontSize: 14,
        height: 1.4,
      ),

      // Body text
      bodyLarge: GoogleFonts.inter(
        color: primaryTextColor,
        fontSize: 16,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.inter(
        color: secondaryTextColor,
        fontSize: 14,
        height: 1.6,
      ),
      bodySmall: GoogleFonts.inter(
        color: secondaryTextColor,
        fontSize: 12,
        height: 1.5,
      ),

      // Labels
      labelLarge: GoogleFonts.inter(
        color: primaryTextColor,
        fontWeight: FontWeight.w600,
        fontSize: 14,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.inter(
        color: primaryTextColor,
        fontWeight: FontWeight.w500,
        fontSize: 12,
        letterSpacing: 0.2,
      ),
      labelSmall: GoogleFonts.inter(
        color: secondaryTextColor,
        fontWeight: FontWeight.w500,
        fontSize: 11,
        letterSpacing: 0.5,
      ),
    );
  }

  // ========================================
  // ☀️ LIGHT THEME
  // ========================================

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: backgroundLight,
    primaryColor: primaryIndigo,

    colorScheme: ColorScheme.light(
      primary: primaryIndigo,
      secondary: primaryViolet,
      tertiary: primaryPink,
      surface: surfaceLight,
      surfaceContainerHighest: surfaceElevatedLight,
      error: errorRed,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimaryLight,
      onSurfaceVariant: textSecondaryLight,
      outline: borderLight,
      outlineVariant: borderSubtleLight,
    ),

    textTheme: _buildTextTheme(
      GoogleFonts.interTextTheme(),
      textPrimaryLight,
      textSecondaryLight,
    ),

    // AppBar - Clean and minimal
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: backgroundLight,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.inter(
        color: textPrimaryLight,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: textPrimaryLight),
    ),

    // Cards - Premium with subtle shadows
    cardTheme: CardTheme(
      color: surfaceLight,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: borderSubtleLight, width: 1),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),

    // Input Fields - Modern and clean
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),

      // Borders
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: borderLight, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: borderLight, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryIndigo, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: errorRed, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: errorRed, width: 2),
      ),

      // Text styles
      labelStyle: GoogleFonts.inter(
        color: textSecondaryLight,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      hintStyle: GoogleFonts.inter(
        color: textSecondaryLight.withOpacity(0.5),
        fontSize: 14,
      ),
      floatingLabelStyle: GoogleFonts.inter(
        color: primaryIndigo,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),

      // Icons
      prefixIconColor: textSecondaryLight,
      suffixIconColor: textSecondaryLight,
    ),

    // Elevated Buttons - Bold and beautiful
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryIndigo,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        shadowColor: primaryIndigo.withOpacity(0.3),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: 0.2,
        ),
      ),
    ),

    // Outlined Buttons
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryIndigo,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        side: const BorderSide(color: primaryIndigo, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: 0.2,
        ),
      ),
    ),

    // Text Buttons
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryIndigo,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    ),

    // Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryIndigo,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: borderLight,
      thickness: 1,
      space: 1,
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: surfaceElevatedLight,
      selectedColor: primaryIndigo,
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  // ========================================
  // 🌙 DARK THEME
  // ========================================

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundDark,
    primaryColor: primaryIndigo,

    colorScheme: ColorScheme.dark(
      primary: primaryViolet,
      secondary: primaryPink,
      tertiary: accentCyan,
      surface: surfaceDark,
      surfaceContainerHighest: surfaceElevatedDark,
      error: errorRed,
      onPrimary: backgroundDark,
      onSecondary: Colors.white,
      onSurface: textPrimaryDark,
      onSurfaceVariant: textSecondaryDark,
      outline: borderDark,
      outlineVariant: borderSubtleDark,
    ),

    textTheme: _buildTextTheme(
      GoogleFonts.interTextTheme(),
      textPrimaryDark,
      textSecondaryDark,
    ),

    // AppBar
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: backgroundDark,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.inter(
        color: textPrimaryDark,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: textPrimaryDark),
    ),

    // Cards
    cardTheme: CardTheme(
      color: surfaceDark,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: borderDark.withOpacity(0.5), width: 1),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),

    // Input Fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: borderDark, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: borderDark, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryViolet, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: errorRed, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: errorRed, width: 2),
      ),
      labelStyle: GoogleFonts.inter(
        color: textSecondaryDark,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      hintStyle: GoogleFonts.inter(
        color: textSecondaryDark.withOpacity(0.5),
        fontSize: 14,
      ),
      floatingLabelStyle: GoogleFonts.inter(
        color: primaryViolet,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      prefixIconColor: textSecondaryDark,
      suffixIconColor: textSecondaryDark,
    ),

    // Elevated Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryViolet,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        shadowColor: primaryViolet.withOpacity(0.3),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: 0.2,
        ),
      ),
    ),

    // Outlined Buttons
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryViolet,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        side: const BorderSide(color: primaryViolet, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: 0.2,
        ),
      ),
    ),

    // Text Buttons
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryViolet,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    ),

    // Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryViolet,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),

    // Divider
    dividerTheme: DividerThemeData(
      color: borderDark,
      thickness: 1,
      space: 1,
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: surfaceElevatedDark,
      selectedColor: primaryViolet,
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

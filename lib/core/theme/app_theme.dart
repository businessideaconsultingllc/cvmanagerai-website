import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class AppTheme {
  // ========================================
  // 🎨 PREMIUM COLOR PALETTE
  // ========================================

  // Primary Brand Colors - Vibrant & Professional
  static const Color primaryIndigo =
      Color(0xFF4F46E5); // Indigo 600 - Deeper, more professional
  static const Color primaryViolet = Color(0xFF7C3AED); // Violet 600
  static const Color primaryPink = Color(0xFFDB2777); // Pink 600

  // Accent Colors - Neo-Pop touches
  static const Color accentCyan = Color(0xFF0891B2); // Cyan 600
  static const Color accentEmerald = Color(0xFF059669); // Emerald 600
  static const Color accentAmber = Color(0xFFD97706); // Amber 600
  static const Color accentRose = Color(0xFFE11D48); // Rose 600

  // Semantic Colors
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color infoBlue = Color(0xFF3B82F6);

  // Backward Compatibility
  static const Color primaryColor = primaryIndigo;
  static const Color secondaryColor = primaryViolet;
  static const Color accentColor = accentCyan;

  // Neutral Colors (Light Mode)
  static const Color backgroundLight = Color(0xFFF3F4F6); // Cool Grey 100
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceElevatedLight = Color(0xFFF9FAFB);
  static const Color textPrimaryLight = Color(0xFF111827); // Gray 900
  static const Color textSecondaryLight = Color(0xFF4B5563); // Gray 600
  static const Color borderLight = Color(0xFFE5E7EB); // Gray 200
  static const Color borderSubtleLight = Color(0xFFF3F4F6); // Gray 100

  // Neutral Colors (Dark Mode) - "Midnight" Theme
  static const Color backgroundDark = Color(0xFF0B0F19); // Deep dark blue-black
  static const Color surfaceDark = Color(0xFF111827); // slightly lighter
  static const Color surfaceElevatedDark = Color(0xFF1F2937);
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color borderDark = Color(0xFF374151);
  static const Color borderSubtleDark = Color(0xFF1F2937);

  // ========================================
  // 🌈 PREMIUM GRADIENTS
  // ========================================

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryIndigo, primaryViolet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 1.0],
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF4338CA), Color(0xFF7C3AED), Color(0xFFBE185D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient glassGradientLight = LinearGradient(
    colors: [Colors.white70, Colors.white30],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradientDark = LinearGradient(
    colors: [Color(0xCC1F2937), Color(0x771F2937)], // Darker glass
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glass Colors
  static const Color glassLight = Color(0x99FFFFFF);
  static const Color glassDark = Color(0x99111827);
  static const Color glassBorderLight = Color(0x33FFFFFF);
  static const Color glassBorderDark = Color(0x33FFFFFF);

  // ========================================
  // ✨ SHADOWS & GLOWS
  // ========================================

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.06), // Very subtle
      blurRadius: 20,
      offset: const Offset(0, 10),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> mediumShadow = [
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.1),
      blurRadius: 30,
      offset: const Offset(0, 12),
      spreadRadius: -4,
    ),
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.03),
      blurRadius: 10,
      offset: const Offset(0, 4),
      spreadRadius: -2,
    ),
  ];

  static List<BoxShadow> glowShadow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 16,
          offset: const Offset(0, 8),
          spreadRadius: -4,
        ),
      ];

  // ========================================
  // 📝 TYPOGRAPHY (Outfit - Modern & Geometric)
  // ========================================

  static TextTheme _buildTextTheme(
      TextTheme base, Color primaryTextColor, Color secondaryTextColor) {
    // We use 'Outfit' if available via GoogleFonts, otherwise fallback to Inter
    // For now, let's stick to Inter but with tighter tracking for a premium feel
    return base.copyWith(
      // Display styles - For hero sections
      displayLarge: GoogleFonts.outfit(
        color: primaryTextColor,
        fontWeight: FontWeight.w700,
        fontSize:
            36, // Reduced slightly for mobile safety, responsive scaling needed elsewhere
        letterSpacing: -1.0,
        height: 1.1,
      ),
      displayMedium: GoogleFonts.outfit(
        color: primaryTextColor,
        fontWeight: FontWeight.w700,
        fontSize: 30,
        letterSpacing: -0.8,
        height: 1.2,
      ),
      displaySmall: GoogleFonts.outfit(
        color: primaryTextColor,
        fontWeight: FontWeight.w600,
        fontSize: 24,
        letterSpacing: -0.5,
        height: 1.2,
      ),

      // Headlines
      headlineLarge: GoogleFonts.outfit(
        color: primaryTextColor,
        fontWeight: FontWeight.w600,
        fontSize: 22,
        height: 1.3,
      ),
      headlineMedium: GoogleFonts.outfit(
        color: primaryTextColor,
        fontWeight: FontWeight.w600,
        fontSize: 20,
        height: 1.3,
        letterSpacing: -0.5,
      ),
      headlineSmall: GoogleFonts.outfit(
        color: primaryTextColor,
        fontWeight: FontWeight.w600,
        fontSize: 18,
        height: 1.4,
      ),

      // Titles
      titleLarge: GoogleFonts.plusJakartaSans(
        color: primaryTextColor,
        fontWeight: FontWeight.w600,
        fontSize: 18,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        color: primaryTextColor,
        fontWeight: FontWeight.w600,
        fontSize: 16,
        height: 1.4,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        color: primaryTextColor,
        fontWeight: FontWeight.w600,
        fontSize: 14,
        height: 1.4,
      ),

      // Body text - High legibility
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
      labelLarge: GoogleFonts.plusJakartaSans(
        color: primaryTextColor,
        fontWeight: FontWeight.w600,
        fontSize: 14,
        letterSpacing: 0.2,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        color: primaryTextColor,
        fontWeight: FontWeight.w600,
        fontSize: 12,
        letterSpacing: 0.3,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        color: secondaryTextColor,
        fontWeight: FontWeight.w600,
        fontSize: 10,
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
      tertiary: accentCyan,
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

    // AppBar
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: backgroundLight.withOpacity(0.8), // Glass effect support
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.outfit(
        color: textPrimaryLight,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: textPrimaryLight),
    ),

    // Cards - Soft & Floating
    cardTheme: CardTheme(
      color: surfaceLight,
      elevation: 0, // We use custom shadows usually, but default 0 is good
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side:
            const BorderSide(color: Colors.transparent), // No border by default
      ),
    ),

    // Input Fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryIndigo, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: errorRed),
      ),
      hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
    ),

    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryIndigo,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    ),

    // Chips for "Tags"
    chipTheme: ChipThemeData(
      backgroundColor: surfaceElevatedLight,
      labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      side: const BorderSide(color: borderLight),
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
      primary: primaryViolet, // Violet pops better in dark mode
      secondary: primaryPink,
      tertiary: accentCyan,
      surface: surfaceDark,
      surfaceContainerHighest: surfaceElevatedDark,
      error: errorRed,
      onPrimary: Colors.white,
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
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: backgroundDark.withOpacity(0.8),
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.outfit(
        color: textPrimaryDark,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: textPrimaryDark),
    ),
    cardTheme: CardTheme(
      color: surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: borderSubtleDark, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceElevatedDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryViolet, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryViolet,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    ),
  );
}

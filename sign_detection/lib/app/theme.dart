import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light theme colors - Sophisticated & Professional
  static const Color _lightPrimary = Color(0xFF5B67CA);
  static const Color _lightPrimaryDark = Color(0xFF3B4B9E);
  static const Color _lightBackground = Color(0xFFFCFDFE);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightError = Color(0xFFDC2626);
  static const Color _lightSecondary = Color(0xFFFFA500);
  static const Color _lightTertiary = Color(0xFF00D9FF);

  // Dark theme colors
  static const Color _darkPrimary = Color(0xFF5B67CA);
  static const Color _darkBackground = Color(0xFF0F0F0F);
  static const Color _darkSurface = Color(0xFF1A1A1A);
  static const Color _darkError = Color(0xFFDC2626);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: _lightPrimary,
      scaffoldBackgroundColor: _lightBackground,
      colorScheme: const ColorScheme.light(
        primary: _lightPrimary,
        secondary: _lightSecondary,
        tertiary: _lightTertiary,
        error: _lightError,
        background: _lightBackground,
        surface: _lightSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: _lightPrimaryDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.roboto(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: _lightPrimaryDark,
        ),
      ),
      cardTheme: CardThemeData(
        color: _lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        shadowColor: _lightPrimary.withValues(alpha: 0.08),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 4,
          shadowColor: _lightPrimary.withValues(alpha: 0.3),
          textStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _lightPrimary,
          side: const BorderSide(color: _lightPrimary, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textTheme: GoogleFonts.robotoTextTheme(
        ThemeData.light().textTheme.copyWith(
              displayLarge: GoogleFonts.roboto(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: _lightPrimaryDark,
              ),
              displayMedium: GoogleFonts.roboto(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: _lightPrimaryDark,
              ),
              displaySmall: GoogleFonts.roboto(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: _lightPrimaryDark,
              ),
              headlineMedium: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: _lightPrimaryDark,
              ),
              headlineSmall: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _lightPrimaryDark,
              ),
              titleLarge: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _lightPrimaryDark,
              ),
              titleMedium: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _lightPrimaryDark,
              ),
              titleSmall: GoogleFonts.roboto(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _lightPrimaryDark,
              ),
              bodyLarge: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF333333),
              ),
              bodyMedium: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF666666),
              ),
              bodySmall: GoogleFonts.roboto(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF999999),
              ),
            ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF0F2F7),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _lightPrimary, width: 2),
        ),
        hintStyle: GoogleFonts.roboto(color: const Color(0xFFAAADB5)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _lightSurface,
        selectedItemColor: _lightPrimary,
        unselectedItemColor: Color(0xFFC4C7CF),
        type: BottomNavigationBarType.fixed,
        elevation: 12,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: _darkPrimary,
      scaffoldBackgroundColor: _darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: _darkPrimary,
        secondary: _lightSecondary,
        error: _darkError,
        background: _darkBackground,
        surface: _darkSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.roboto(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: _darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _darkPrimary,
          side: const BorderSide(color: _darkPrimary, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textTheme: GoogleFonts.robotoTextTheme(
        ThemeData.dark().textTheme.copyWith(
              displayLarge: GoogleFonts.roboto(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              displayMedium: GoogleFonts.roboto(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              displaySmall: GoogleFonts.roboto(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              headlineMedium: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              headlineSmall: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              titleLarge: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              titleMedium: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              titleSmall: GoogleFonts.roboto(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              bodyLarge: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFE0E0E0),
              ),
              bodyMedium: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFB0B0B0),
              ),
              bodySmall: GoogleFonts.roboto(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF808080),
              ),
            ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: GoogleFonts.roboto(color: const Color(0xFF808080)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _darkSurface,
        selectedItemColor: _darkPrimary,
        unselectedItemColor: Color(0xFF808080),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}

// theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Gaming color palette
  static const Color primaryGaming = Color(0xFF6C63FF);
  static const Color secondaryGaming = Color(0xFF3F3D56);
  static const Color accentNeon = Color(0xFF00F5FF);
  static const Color successGreen = Color(0xFF00E676);
  static const Color dangerRed = Color(0xFFFF6B6B);
  static const Color warningAmber = Color(0xFFFFB74D);
  static const Color darkBg = Color(0xFF1A1A2E);
  static const Color darkCard = Color(0xFF16213E);
  static const Color lightBg = Color(0xFFF8F9FF);
  static const Color lightCard = Color(0xFFFFFFFF);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryGaming,
      scaffoldBackgroundColor: lightBg,
      fontFamily: 'Orbitron',
      colorScheme: const ColorScheme.light(
        primary: primaryGaming,
        secondary: accentNeon,
        surface: lightCard,
        error: dangerRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF2C2C54),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Orbitron',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: primaryGaming,
        ),
        iconTheme: IconThemeData(color: primaryGaming),
      ),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 8,
        shadowColor: primaryGaming.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGaming,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: primaryGaming.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentNeon,
        foregroundColor: Colors.white,
        elevation: 12,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryGaming,
      scaffoldBackgroundColor: darkBg,
      fontFamily: 'Orbitron',
      colorScheme: const ColorScheme.dark(
        primary: primaryGaming,
        secondary: accentNeon,
        surface: darkCard,
        error: dangerRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Orbitron',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: accentNeon,
        ),
        iconTheme: IconThemeData(color: accentNeon),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 8,
        shadowColor: accentNeon.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: primaryGaming.withOpacity(0.3), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGaming,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: primaryGaming.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentNeon,
        foregroundColor: darkBg,
        elevation: 12,
      ),
    );
  }
}

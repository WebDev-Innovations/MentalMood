import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Colors ---
  static const Color primarySage = Color(0xFF6DA48D);
  static const Color primaryLight = Color(0xFFE8F1ED);
  static const Color secondarySoft = Color(0xFF98C1B1);
  static const Color accentCoral = Color(0xFFF4A261);
  static const Color bgLight = Color(0xFFF8FAF9);
  static const Color bgDark = Color(0xFF0E1411);
  static const Color surfaceDark = Color(0xFF1B2621);

  // --- Gradients ---
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primarySage, Color(0xFF8EBAA7)],
  );

  static const BoxDecoration pageDecoration = BoxDecoration(
    color: bgLight,
  );

  static const BoxDecoration pageDecorationDark = BoxDecoration(
    color: bgDark,
  );

  // --- Theme Definitions ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySage,
        primary: primarySage,
        secondary: secondarySoft,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: bgLight,
      textTheme: GoogleFonts.quicksandTextTheme().copyWith(
        displayLarge: GoogleFonts.quicksand(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        titleLarge: GoogleFonts.quicksand(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: primarySage,
        iconTheme: IconThemeData(color: primarySage),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 4,
          shadowColor: primarySage.withAlpha((0.4 * 255).round()),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          side: const BorderSide(color: primarySage, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          foregroundColor: primarySage,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.black12, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.black12, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: primarySage, width: 1.5),
        ),
        labelStyle: const TextStyle(color: Colors.black54),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySage,
        brightness: Brightness.dark,
        primary: primarySage,
        secondary: secondarySoft,
        surface: surfaceDark,
      ),
      scaffoldBackgroundColor: bgDark,
      textTheme: GoogleFonts.quicksandTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.quicksand(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titleLarge: GoogleFonts.quicksand(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: primarySage,
          foregroundColor: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.white10, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.white10, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: primarySage, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}

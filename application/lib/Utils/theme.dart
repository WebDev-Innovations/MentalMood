import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Organic Harmony Palette ---
  static const Color primary = Color(0xFF6DA48D);
  static const Color sagePrimary = Color(0xFF6DA48D);
  static const Color accent = Color(0xFFE07A5F);
  static const Color terracottaError = Color(0xFFE07A5F);
  static const Color background = Color(0xFFFDFCF0);
  static const Color creamBg = Color(0xFFFDFCF0);
  static const Color text = Color(0xFF2C3E50);
  static const Color charcoalText = Color(0xFF2C3E50);
  
  static const Color indigoPrimary = Color(0xFF5C6BC0);
  static const Color mintAccent = Color(0xFF80CBC4);
  static const Color amberWarm = Color(0xFFFFB74D);
  static const Color sandAccent = Color(0xFFECE3CE);
  static const Color oliveSecondary = Color(0xFFA1A483);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: sagePrimary,
        primary: sagePrimary,
        secondary: oliveSecondary,
        background: creamBg,
        surface: Colors.white,
        error: terracottaError,
      ),
      scaffoldBackgroundColor: creamBg,
      textTheme: GoogleFonts.poppinsTextTheme().apply(bodyColor: charcoalText, displayColor: charcoalText),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        color: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: charcoalText, fontFamily: 'Poppins'),
        iconTheme: IconThemeData(color: sagePrimary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: sagePrimary.withOpacity(0.1),
        labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: sagePrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 64),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1, fontFamily: 'Poppins'),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: sagePrimary,
        brightness: Brightness.dark,
        primary: sagePrimary,
        onPrimary: Colors.white,
        background: const Color(0xFF121614),
        surface: const Color(0xFF1E2321),
      ),
      scaffoldBackgroundColor: const Color(0xFF121614),
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        color: const Color(0xFF1E2321),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: sagePrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 64),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1, fontFamily: 'Poppins'),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
        },
      ),
    );
  }
}

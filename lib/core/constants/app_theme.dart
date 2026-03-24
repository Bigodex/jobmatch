// =======================================================
// APP THEME
// -------------------------------------------------------
// Tema global do app (Dark)
// =======================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {

  // ===================================================
  // CORES
  // ===================================================

  static const Color background = Color(0xFF000000);
  static const Color card = Color(0xFF17181C);
  static const Color primary = Color(0xFF68E3FF);

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white54;

  // 🔥 NOVA COR
  static const Color cardTertiary = Color(0xFF1D1F24);

  // ===================================================
  // THEME
  // ===================================================

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,

    scaffoldBackgroundColor: background,
    cardColor: card,

    // 🔥 REMOVE RIPPLE GLOBAL
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
    splashFactory: NoSplash.splashFactory,

    // -------------------------------------------------
    // COLOR SCHEME
    // -------------------------------------------------
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: primary,
      surface: card,
      onSurface: textPrimary,
    ),

    // -------------------------------------------------
    // EXTENSIONS (CORES CUSTOM)
    // -------------------------------------------------
    extensions: const [
      AppColorsExtension(
        header: Color(0xFF1D1F27),
        cardSecondary: Color(0xFF201F24),
        cardTertiary: Color(0xFF1D1F24), // 🔥 NOVA COR
      ),
    ],

    // -------------------------------------------------
    // APP BAR
    // -------------------------------------------------
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    // -------------------------------------------------
    // BOTTOM NAV
    // -------------------------------------------------
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: card,
      selectedItemColor: primary,
      unselectedItemColor: textSecondary,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),

    // -------------------------------------------------
    // TEXT
    // -------------------------------------------------
    textTheme: GoogleFonts.interTextTheme().apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    ),

    // -------------------------------------------------
    // BUTTON
    // -------------------------------------------------
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 20,
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // -------------------------------------------------
    // INPUT
    // -------------------------------------------------
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: textSecondary),
    ),

    // -------------------------------------------------
    // DIVIDER
    // -------------------------------------------------
    dividerColor: Colors.white12,
  );
}

// =======================================================
// THEME EXTENSION
// -------------------------------------------------------
// Cores customizadas do app
// =======================================================

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color header;
  final Color cardSecondary;
  final Color cardTertiary; // 🔥 NOVO

  const AppColorsExtension({
    required this.header,
    required this.cardSecondary,
    required this.cardTertiary,
  });

  @override
  AppColorsExtension copyWith({
    Color? header,
    Color? cardSecondary,
    Color? cardTertiary,
  }) {
    return AppColorsExtension(
      header: header ?? this.header,
      cardSecondary: cardSecondary ?? this.cardSecondary,
      cardTertiary: cardTertiary ?? this.cardTertiary,
    );
  }

  @override
  AppColorsExtension lerp(
    ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) return this;

    return AppColorsExtension(
      header: Color.lerp(header, other.header, t)!,
      cardSecondary: Color.lerp(cardSecondary, other.cardSecondary, t)!,
      cardTertiary: Color.lerp(cardTertiary, other.cardTertiary, t)!,
    );
  }
}
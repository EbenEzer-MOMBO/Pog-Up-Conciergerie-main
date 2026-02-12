// lib/config/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Couleurs de la charte graphique
  static const Color primaryRed =
      Color(0xFFC61329); // Rouge vif - couleur principale
  static const Color alternativeRed = Color(0xFFBC0202); // Alternative rouge
  static const Color anthraciteGray =
      Color(0xFF3A3838); // Gris anthracite / noir doux
  static const Color goldYellow = Color(0xFFFABF09); // Jaune / Or

  // Couleurs secondaires
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color mediumGray = Color(0xFF6C757D);
  static const Color darkGray = Color(0xFF495057);
  static const Color white = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFDC3545);
  static const Color successColor = Color(0xFF28A745);

  // Theme principal
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: MaterialColor(primaryRed.toARGB32(), {
        50: Color(0xFFFFEBEE),
        100: Color(0xFFC61329).withValues(alpha: 0.2),
        200: Color(0xFFC61329).withValues(alpha: 0.4),
        300: Color(0xFFC61329).withValues(alpha: 0.6),
        400: Color(0xFFC61329).withValues(alpha: 0.8),
        500: primaryRed,
        600: Color(0xFFB51226),
        700: Color(0xFFA31023),
        800: Color(0xFF910D20),
        900: Color(0xFF7F0A1D),
      }),
      primaryColor: primaryRed,
      colorScheme: const ColorScheme.light(
        primary: primaryRed,
        secondary: goldYellow,
        surface: white,
        error: errorColor,
        onPrimary: white,
        onSecondary: anthraciteGray,
        onSurface: anthraciteGray,
      ),
      scaffoldBackgroundColor: lightGray,
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        foregroundColor: anthraciteGray,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: anthraciteGray,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Montserrat',
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: anthraciteGray,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Montserrat',
        ),
        headlineMedium: TextStyle(
          color: anthraciteGray,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Montserrat',
        ),
        bodyLarge: TextStyle(
          color: anthraciteGray,
          fontSize: 14,
          fontFamily: 'Montserrat',
        ),
        bodyMedium: TextStyle(
          color: anthraciteGray,
          fontSize: 13,
          fontFamily: 'Montserrat',
        ),
        labelLarge: TextStyle(
          color: white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Montserrat',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          foregroundColor: white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryRed, width: 2),
        ),
        labelStyle: const TextStyle(color: mediumGray),
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIconColor: primaryRed,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.all(primaryRed),
        checkColor: WidgetStateProperty.all(white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  // Styles de texte personnalisés
  static const TextStyle pogStyle = TextStyle(
    color: primaryRed,
    fontWeight: FontWeight.bold,
    fontFamily: 'Montserrat',
  );

  static const TextStyle upStyle = TextStyle(
    color: anthraciteGray,
    fontWeight: FontWeight.bold,
    fontFamily: 'Montserrat',
  );

  static const TextStyle conciergerieStyle = TextStyle(
    color: goldYellow,
    fontWeight: FontWeight.bold,
    fontFamily: 'Montserrat',
  );

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryRed, alternativeRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldYellow, Color(0xFFE6A800)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

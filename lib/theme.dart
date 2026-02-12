// theme.dart
import 'package:flutter/material.dart';
import 'config/app_theme.dart';

final ThemeData appTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppTheme.primaryRed, // Teal professionnel
    secondary: AppTheme.goldYellow,
    surface: Colors.white,
    background: AppTheme.lightGray,
  ),
  useMaterial3: true,
  fontFamily: 'Montserrat',

  // AppBar Theme
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: AppTheme.anthraciteGray,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: AppTheme.anthraciteGray,
    ),
  ),

  // Card Theme
  cardTheme: CardThemeData(
    elevation: 0,
    shadowColor: Colors.black.withValues(alpha: 0.05),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: Colors.white,
  ),

  // Input Decoration Theme
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
      borderSide: const BorderSide(color: AppTheme.primaryRed, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Colors.orange, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    labelStyle: const TextStyle(
      fontFamily: 'Montserrat',
      color: AppTheme.anthraciteGray,
      fontWeight: FontWeight.w500,
    ),
  ),

  // Elevated Button Theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppTheme.primaryRed,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  // Text Button Theme
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppTheme.primaryRed,
      textStyle: const TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  // Text Theme
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: AppTheme.anthraciteGray,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: AppTheme.anthraciteGray,
    ),
    titleLarge: TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppTheme.anthraciteGray,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppTheme.anthraciteGray,
    ),
    bodyLarge: TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 14,
      color: AppTheme.anthraciteGray,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 12,
      color: AppTheme.anthraciteGray,
    ),
    bodySmall: TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 10,
      color: Colors.grey,
    ),
  ),

  // Scaffold Background Color
  scaffoldBackgroundColor: AppTheme.lightGray,
);

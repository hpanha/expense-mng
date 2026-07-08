import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppTheme {
  static const Color primaryTeal = Color(0xFF0F858C);
  static Color get darkTeal => Get.isDarkMode ? Colors.grey[300]! : Colors.black;
  static Color get backgroundTeal => Get.isDarkMode ? Colors.black : Colors.white;
  static const Color lightTeal = Color(0xFFE2F0F0);
  static const Color primaryNavy = primaryTeal; // Fallback helper to avoid breaking existing code immediately

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    primaryColor: primaryTeal,
    colorScheme: const ColorScheme.light(
      primary: primaryTeal,
      secondary: Color(0xFF0C4A4F),
      background: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF0C4A4F),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Color(0xFF0C4A4F),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Color(0xFF0C4A4F)),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black),
      titleLarge: TextStyle(color: Colors.black),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    primaryColor: primaryTeal,
    colorScheme: const ColorScheme.dark(
      primary: primaryTeal,
      secondary: lightTeal,
      background: Colors.black,
      surface: Color(0xFF1E2222),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.grey[300]),
      bodyMedium: TextStyle(color: Colors.grey[300]),
      titleLarge: TextStyle(color: Colors.grey[300]),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E2222),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}


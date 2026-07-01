import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryNavy = Color(0xFF0F172A);

  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    primaryColor: primaryNavy,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: primaryNavy,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: primaryNavy,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: primaryNavy),
    ),
  );
}

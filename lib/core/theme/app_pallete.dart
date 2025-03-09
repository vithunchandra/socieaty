import 'package:flutter/material.dart';

class AppPallete {
  AppPallete._();

  // Brand Color
  static const MaterialColor primaryColor = MaterialColor(
    0xFFEB7317, // The main color
    <int, Color>{
      50: Color(0xFFFAF3ED), // The lightest shade
      100: Color(0xFFFFCCA6),
      200: Color(0xFFFFBE8C),
      300: Color(0xFFF7954A),
      400: Color(0xFFEB7317), // The main shade
      500: Color(0xFFA84E08),
      600: Color(0xFF753300),
      700: Color(0xFF5C2800),
      800: Color(0xFF381800), // Darkest shade
    },
  );

  // Neutral Color
  static const MaterialColor neutralColor = MaterialColor(
    0xFFADB5BD, // Main color (AD B5 BD)
    <int, Color>{
      50: Color(0xFFF8F9FA), // Lightest shade
      100: Color(0xFFE9ECEF),
      200: Color(0xFFDEE2E6),
      300: Color(0xFFCED4DA),
      400: Color(0xFFADB5BD), // Main shade
      500: Color(0xFF6C757D),
      600: Color(0xFF495057),
      700: Color(0xFF343A40),
      800: Color(0xFF212529), // Darkest shade
    },
  );

  //Supporting Color
  static const secondaryColor = Color(0xFF16CDA2);
  static const successColor = Color(0xFF2EE017);
  static const errorColor = Color(0xFFE0370D);
  static const warningColor = Color(0xFFF19809);
  static const infoColor = Color(0xFF0F8BFF);

  // Foreground Color
  static const lightColorOnSurface = Colors.black;
  static const darkColorOnSurface = Colors.white;
}

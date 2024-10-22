import 'package:flutter/material.dart';

import '../app_pallete.dart';

class CustomTextTheme {
  CustomTextTheme._();

  static const TextTheme lightTextTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 57, color: AppPallete.lightColorOnSurface, fontWeight: FontWeight.bold, letterSpacing: 0.25),
    displayMedium: TextStyle(fontSize: 45, color: AppPallete.lightColorOnSurface, fontWeight: FontWeight.normal, letterSpacing: 0),
    displaySmall: TextStyle(fontSize: 36, color: AppPallete.lightColorOnSurface, fontWeight: FontWeight.normal, letterSpacing: 0),
    headlineLarge: TextStyle(fontSize: 32, color: AppPallete.lightColorOnSurface, fontWeight: FontWeight.bold, letterSpacing: 0),
    headlineMedium: TextStyle(fontSize: 28, color: AppPallete.lightColorOnSurface, fontWeight: FontWeight.normal, letterSpacing: 0),
    headlineSmall: TextStyle(fontSize: 24, color: AppPallete.lightColorOnSurface, fontWeight: FontWeight.normal, letterSpacing: 0),
    titleLarge: TextStyle(fontSize: 20, color: AppPallete.lightColorOnSurface, fontWeight: FontWeight.w500, letterSpacing: 0),
    titleMedium: TextStyle(fontSize: 18, color: AppPallete.lightColorOnSurface, fontWeight: FontWeight.w500, letterSpacing: 0.15),
    titleSmall: TextStyle(fontSize: 16, color: AppPallete.lightColorOnSurface, fontWeight: FontWeight.w500, letterSpacing: 0.1),
    bodyLarge: TextStyle(fontSize: 16, color: AppPallete.lightColorOnSurface, fontWeight: FontWeight.normal, letterSpacing: 0.5),
    bodyMedium: TextStyle(fontSize: 14, color: AppPallete.lightColorOnSurface, fontWeight: FontWeight.normal, letterSpacing: 0.25),
    bodySmall: TextStyle(fontSize: 12, color: AppPallete.lightColorOnSurface, fontWeight: FontWeight.normal, letterSpacing: 0.4),
    labelLarge: TextStyle(fontSize: 14, color: AppPallete.lightColorOnSurface, fontWeight: FontWeight.w500, letterSpacing: 0.1),
    labelMedium: TextStyle(fontSize: 12, color: AppPallete.lightColorOnSurface, fontWeight: FontWeight.w500, letterSpacing: 0.5),
    labelSmall: TextStyle(fontSize: 11, color: AppPallete.lightColorOnSurface, fontWeight: FontWeight.w500, letterSpacing: 0.5),
  );
  static const TextTheme darkTextTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 57, color: AppPallete.darkColorOnSurface, fontWeight: FontWeight.normal, letterSpacing: 0.25),
    displayMedium: TextStyle(fontSize: 45, color: AppPallete.darkColorOnSurface, fontWeight: FontWeight.normal, letterSpacing: 0),
    displaySmall: TextStyle(fontSize: 36, color: AppPallete.darkColorOnSurface, fontWeight: FontWeight.normal, letterSpacing: 0),
    headlineLarge: TextStyle(fontSize: 32, color: AppPallete.darkColorOnSurface, fontWeight: FontWeight.normal, letterSpacing: 0),
    headlineMedium: TextStyle(fontSize: 28, color: AppPallete.darkColorOnSurface, fontWeight: FontWeight.normal, letterSpacing: 0),
    headlineSmall: TextStyle(fontSize: 24, color: AppPallete.darkColorOnSurface, fontWeight: FontWeight.normal, letterSpacing: 0),
    titleLarge: TextStyle(fontSize: 22, color: AppPallete.darkColorOnSurface, fontWeight: FontWeight.normal, letterSpacing: 0),
    titleMedium: TextStyle(fontSize: 16, color: AppPallete.darkColorOnSurface, fontWeight: FontWeight.w500, letterSpacing: 0.15),
    titleSmall: TextStyle(fontSize: 14, color: AppPallete.darkColorOnSurface, fontWeight: FontWeight.w500, letterSpacing: 0.1),
    bodyLarge: TextStyle(fontSize: 16, color: AppPallete.darkColorOnSurface, fontWeight: FontWeight.normal, letterSpacing: 0.5),
    bodyMedium: TextStyle(fontSize: 14, color: AppPallete.darkColorOnSurface, fontWeight: FontWeight.normal, letterSpacing: 0.25),
    bodySmall: TextStyle(fontSize: 12, color: AppPallete.darkColorOnSurface, fontWeight: FontWeight.normal, letterSpacing: 0.4),
    labelLarge: TextStyle(fontSize: 14, color: AppPallete.darkColorOnSurface, fontWeight: FontWeight.w500, letterSpacing: 0.1),
    labelMedium: TextStyle(fontSize: 12, color: AppPallete.darkColorOnSurface, fontWeight: FontWeight.w500, letterSpacing: 0.5),
    labelSmall: TextStyle(fontSize: 11, color: AppPallete.darkColorOnSurface, fontWeight: FontWeight.w500, letterSpacing: 0.5),
  );
}

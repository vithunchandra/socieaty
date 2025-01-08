import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';

class CustomNavigationBarTheme {
  static final lightNavigationBarTheme = NavigationBarThemeData(
    backgroundColor: AppPallete.neutralColor.shade50,
    indicatorColor: AppPallete.primaryColor,
  );

  static final darkNavigationBarTheme = NavigationBarThemeData(
    backgroundColor: Colors.black,
    indicatorColor: AppPallete.primaryColor,
  );
}

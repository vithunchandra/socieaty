import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';

class AppColorScheme {
  static final ColorScheme lightColorScheme = ColorScheme(
    primary: AppPallete.primaryColor,
    onPrimary: AppPallete.neutralColor.shade50,
    secondary: AppPallete.primaryColor.shade600,
    onSecondary: AppPallete.neutralColor.shade50,
    error: AppPallete.errorColor,
    onError: AppPallete.neutralColor.shade50,
    surface: AppPallete.primaryColor.shade300,
    onSurface: AppPallete.primaryColor.shade800,
    brightness: Brightness.light,
  );
}

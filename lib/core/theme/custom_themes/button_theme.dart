import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/theme/custom_themes/text_theme.dart';

class CustomButtonStyle {
  CustomButtonStyle._();

  static final elevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppPallete.primaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    textStyle: CustomTextTheme.lightTextTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
  );

  static final filledButtonStyle = FilledButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    textStyle: CustomTextTheme.lightTextTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
    shadowColor: AppPallete.primaryColor,
    elevation: 1.0,
  );

  static final outlinedButtonStyle = OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    side: BorderSide(color: AppPallete.primaryColor),
    textStyle: CustomTextTheme.lightTextTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
    foregroundColor: AppPallete.primaryColor,
    backgroundColor: Colors.transparent,
  );
}

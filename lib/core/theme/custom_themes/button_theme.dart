import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/theme/custom_themes/text_theme.dart';

class CustomButtonStyle {
  CustomButtonStyle._();

  static final elevatedButtonStyle = ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    textStyle: CustomTextTheme.lightTextTheme.titleMedium,
  );

  static final filledButtonStyle = FilledButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    textStyle: CustomTextTheme.lightTextTheme.titleMedium,
    shadowColor: AppPallete.primaryColor,
    elevation: 3.0,
  );

  static final outlinedButtonStyle = OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    textStyle: CustomTextTheme.lightTextTheme.titleMedium,
  );
}

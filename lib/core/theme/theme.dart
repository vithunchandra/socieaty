import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/theme/custom_themes/button_theme.dart';
import 'package:socieaty/core/theme/custom_themes/color_scheme.dart';
import 'package:socieaty/core/theme/custom_themes/input_decoration_theme.dart';
import 'package:socieaty/core/theme/custom_themes/text_theme.dart';

class SocieatyAppTheme {
  SocieatyAppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: AppColorScheme.lightColorScheme,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppPallete.neutralColor[50],
    textTheme: CustomTextTheme.lightTextTheme,
    inputDecorationTheme: CustomInputDecorationTheme.inputDecorationTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(style: CustomButtonStyle.elevatedButtonStyle),
    filledButtonTheme: FilledButtonThemeData(style: CustomButtonStyle.filledButtonStyle),
    outlinedButtonTheme: OutlinedButtonThemeData(style: CustomButtonStyle.outlinedButtonStyle),
  );
}

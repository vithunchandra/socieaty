import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/theme/theme.dart';

part 'app_theme_provider.g.dart';

@riverpod
class AppTheme extends _$AppTheme {
  @override
  ThemeData build() {
    return SocieatyAppTheme.lightTheme;
  }

  void setTheme(ThemeData theme) {
    state = theme;
  }

  void toggleTheme() {
    if (state == SocieatyAppTheme.lightTheme) {
      state = SocieatyAppTheme.darkTheme;
    } else {
      state = SocieatyAppTheme.lightTheme;
    }
  }
}

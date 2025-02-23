import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/app_theme_provider.dart';

class ScaffoldWithCustomTheme extends ConsumerStatefulWidget {
  final ThemeData previousTheme;
  final Widget body;
  const ScaffoldWithCustomTheme({super.key, required this.previousTheme, required this.body});

  @override
  ConsumerState<ScaffoldWithCustomTheme> createState() => _ScaffoldWithCustomThemeState();
}

class _ScaffoldWithCustomThemeState extends ConsumerState<ScaffoldWithCustomTheme> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ref.read(appThemeProvider.notifier).setTheme(widget.previousTheme);
        }
      },
      child: Scaffold(
        body: widget.body,
      ),
    );
  }
}

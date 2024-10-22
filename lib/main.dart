import 'package:flutter/material.dart';
import 'package:socieaty/core/routes/routes.dart';
import 'package:socieaty/core/theme/theme.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: SocieatyAppTheme.lightTheme,
      routerConfig: router,
    );
  }
}

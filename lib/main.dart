import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/core/routes/routes.dart';
import 'package:socieaty/core/theme/theme.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  await container.read(authLocalRepositoryProvider).init();
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const App(),
    ),
  );
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

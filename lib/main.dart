import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/app_theme_provider.dart';
import 'package:socieaty/core/notifications/local_notification_service.dart';
import 'package:socieaty/core/routes/routes.dart';
import 'package:socieaty/core/theme/theme.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  await container.read(authLocalRepositoryProvider).init();

  // Initialize notification service at startup
  await container.read(localNotificationServiceProvider).init();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const App(),
    ),
  );
}

GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey();

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  void _updateSystemChrome(ThemeData themeData) {
    // Set SystemChrome settings
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            themeData == SocieatyAppTheme.lightTheme ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: themeData.scaffoldBackgroundColor,
        systemNavigationBarIconBrightness:
            themeData == SocieatyAppTheme.lightTheme ? Brightness.dark : Brightness.light,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: SocieatyAppTheme.lightTheme.scaffoldBackgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(appThemeProvider, (_, next) {
      _updateSystemChrome(next);
    });

    return MaterialApp.router(
      key: rootNavigatorKey,
      theme: ref.watch(appThemeProvider),
      themeAnimationDuration: const Duration(milliseconds: 0),
      routerConfig: ref.watch(routerProvider),
    );
  }
}

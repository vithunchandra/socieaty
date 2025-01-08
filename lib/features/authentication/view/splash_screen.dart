import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/app_theme.dart';
import 'package:socieaty/core/enums/user_role.enum.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/theme/theme.dart';
import 'package:socieaty/features/authentication/provider/session_provider.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _InitPageState();
}

class _InitPageState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(getSessionDataProvider, (_, next) {
      next.when(
        data: (user) {
          ref.watch(getSessionDataProvider).whenData((data) async {
            await ref.watch(authLocalRepositoryProvider).setUserData(data);
          });

          if (user.role == UserRole.customer) {
            Future.delayed(Duration(seconds: 3), () {
              if (context.mounted) {
                ref.read(appThemeProvider.notifier).setTheme(SocieatyAppTheme.darkTheme);
                context.pushReplacement("/customer/home");
              }
            });
          } else {
            Future.delayed(Duration(seconds: 3), () {
              if (context.mounted) {
                context.pushReplacement("/restaurant");
              }
            });
          }
        },
        error: (message, stackTrace) {
          Future.delayed(Duration(seconds: 3), () {
            if (context.mounted) {
              context.pushReplacement("/landing");
            }
          });
        },
        loading: () {},
      );
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppPallete.primaryColor.shade200, AppPallete.primaryColor.shade600], begin: Alignment.topLeft, end: Alignment.topRight),
        ),
        child: Center(
          child: Text(
            "Socieaty",
            style: Theme.of(context).textTheme.displayMedium,
          ),
        ),
      ),
    );
  }
}

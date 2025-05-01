import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/app_theme_provider.dart';
import 'package:socieaty/core/enums/user_role.enum.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/theme/theme.dart';
import 'package:socieaty/features/authentication/provider/session_provider.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/restaurant/enum/restaurant_verification_status_enum.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';

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
        data: (user) async {
          await ref.watch(authLocalRepositoryProvider).setUserData(user);

          if (user.role == UserRole.customer) {
            Future.delayed(Duration(seconds: 3), () {
              if (context.mounted) {
                ref.read(appThemeProvider.notifier).setTheme(SocieatyAppTheme.darkTheme);
                context.pushReplacement("/customer/home");
              }
            });
          } else if (user.role == UserRole.restaurant) {
            Future.delayed(Duration(seconds: 3), () {
              if (context.mounted) {
                if (user.restaurantData!.verificationStatus == RestaurantVerificationStatus.verified) {
                  context.pushReplacement("/restaurant/dashboard");
                } else if (user.restaurantData!.verificationStatus ==
                    RestaurantVerificationStatus.unverified) {
                  context.pushReplacement("/restaurant/unverified");
                } else {
                  context.pushReplacement("/restaurant/rejected");
                }
              }
            });
          } else if (user.role == UserRole.admin) {
            debugPrint("Admin");
            Future.delayed(Duration(seconds: 3), () {
              if (context.mounted) {
                context.pushReplacement("/admin");
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
        skipError: false,
      );
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [AppPallete.primaryColor.shade200, AppPallete.primaryColor.shade600],
              begin: Alignment.topLeft,
              end: Alignment.topRight),
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

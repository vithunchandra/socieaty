import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/shared/widgets/banner_image.dart';

import '../../../core/theme/app_pallete.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenHeight,
          width: screenWidth,
          child: Column(
            children: [
              const Expanded(child: BannerImage(image: "assets/images/login_background_alternative.png")),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Join to food society",
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Sign up now to explore the world of food",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppPallete.neutralColor),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: FilledButton(
                          onPressed: () {
                            context.push('/signup/customer');
                          },
                          child: const Text("Sign up as customer"),
                        ),
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Divider(color: AppPallete.neutralColor),
                            ),
                          ),
                          Text("or"),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Divider(color: AppPallete.neutralColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: FilledButton(
                          onPressed: () {
                            context.push('/signup/restaurant/first');
                          },
                          child: const Text("Sign up as restaurant"),
                        ),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "have an account? ",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          GestureDetector(
                            onTap: () {
                              context.go('/signin');
                            },
                            child: Text(
                              "Sign in",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppPallete.primaryColor),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

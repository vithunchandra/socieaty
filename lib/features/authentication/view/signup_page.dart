import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/shared/widgets/banner_image_widget.dart';

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
              const Expanded(child: BannerImageWidget(image: "assets/images/login_background_alternative.png")),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 32.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Daftar \nFood Socieaty",
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: FilledButton(
                          onPressed: () {
                            context.push('/signup/customer');
                          },
                          child: const Text("Daftar sebagai customer"),
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
                          Text("Atau"),
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
                          child: const Text("Daftar sebagai restaurant"),
                        ),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Sudah punya akun? ",
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

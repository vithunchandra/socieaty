import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/authentication/provider/session_provider.dart';
import 'package:socieaty/shared/widgets/loading_indicator.dart';

class LandingPage extends ConsumerWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppPallete.primaryColor.shade100,
      body: ref.watch(getSessionDataProvider).isLoading
          ? LoadingIndicator()
          : SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: screenHeight,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(child: Image.asset("assets/images/landing_page_image_3.png")),
                      const SizedBox(
                        height: 24.0,
                      ),
                      Text(
                        "Explore the beautiful world of food with Socieaty",
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(
                        height: 32.0,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: FilledButton(
                              onPressed: () {
                                context.push('/signin');
                              },
                              child: const Text("Sign In"),
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
                            child: OutlinedButton(
                              onPressed: () {
                                context.push('/signup');
                              },
                              style: OutlinedButton.styleFrom(foregroundColor: AppPallete.primaryColor.shade500),
                              child: const Text("Sign Up"),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

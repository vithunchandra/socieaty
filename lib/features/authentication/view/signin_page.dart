import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/app_theme_provider.dart';
import 'package:socieaty/core/enums/user_role.enum.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/theme/theme.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/authentication/viewmodel/signin_viewmodel.dart';
import 'package:socieaty/features/authentication/viewstate/signin_form_state.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/shared/widgets/banner_image_widget.dart';
import 'package:socieaty/shared/widgets/custom_text_field.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';
import 'package:socieaty/shared/widgets/obscure_text_field.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  SigninFormState _formData = SigninFormState();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isLoading = false;

    ref.listen(signinViewmodelProvider, (_, nextState) {
      switch (nextState.signinState) {
        case SuccessState(data: final user):
          if (user.role == UserRole.customer) {
            ref.read(appThemeProvider.notifier).setTheme(SocieatyAppTheme.darkTheme);
            context.replace('/customer/home');
          } else {
            context.replace('/restaurant/dashboard');
          }
          isLoading = false;
        case ErrorState(message: final message):
          showSnackbar(context, message, state: SnackbarState.error);
          isLoading = false;
        case LoadingState():
          isLoading = true;
        case IdleState():
          isLoading = false;
      }
    });

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenHeight,
          width: screenWidth,
          child: Column(
            children: [
              const Expanded(
                  child:
                      BannerImageWidget(image: "assets/images/login_background_alternative.png")),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Hai, \nSelamat Datang",
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Email",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          hintText: "Masukan email anda",
                          prefixIcon: const Icon(Icons.email_outlined),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Email tidak boleh kosong";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _formData = _formData.copyWith(email: value);
                          },
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Password",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ObscureTextField(
                          hintText: "Masukan password anda",
                          prefixIcon: const Icon(Icons.key_outlined),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Password tidak boleh kosong";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _formData = _formData.copyWith(password: value);
                          },
                        ),
                        const SizedBox(height: 36),
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: FilledButton(
                            onPressed: () {
                              if (_formKey.currentState != null &&
                                  _formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                ref.read(signinViewmodelProvider.notifier).signin(_formData);
                              }
                            },
                            child: isLoading
                                ? const LoadingIndicatorWidget(size: 16, color: Colors.white,)
                                : const Text("Sign in"),
                          ),
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Tidak punya akun? ",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            GestureDetector(
                              onTap: () {
                                context.go('/signup');
                              },
                              child: Text(
                                "Sign up",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: AppPallete.primaryColor),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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

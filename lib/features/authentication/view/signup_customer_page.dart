import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/authentication/viewmodel/signup_customer_viewmodel.dart';
import 'package:socieaty/features/authentication/viewstate/signup_customer_form_state.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/shared/widgets/custom_underline_text_field.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';
import 'package:socieaty/shared/widgets/obscure_underline_text_field.dart';

import '../../../core/theme/app_pallete.dart';

class SignupCustomerPage extends ConsumerStatefulWidget {
  const SignupCustomerPage({super.key});

  @override
  ConsumerState<SignupCustomerPage> createState() => _SignupCustomerPageState();
}

class _SignupCustomerPageState extends ConsumerState<SignupCustomerPage> {
  final _formKey = GlobalKey<FormState>();
  SignupCustomerFormState _formData = SignupCustomerFormState();
  final _passwordController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    ref.listen(signupCustomerViewmodelProvider, (_, next) {
      switch (next.signupState) {
        case LoadingState():
          isLoading = true;
          setState(() {});
        case SuccessState<SocieatyUser>():
          context.replace('/signin');
        case ErrorState(message: final message):
          showSnackbar(context, message, state: SnackbarState.error);
        case IdleState():
          {}
      }
    });

    return Scaffold(
      backgroundColor: AppPallete.neutralColor.shade50,
      appBar: AppBar(
        backgroundColor: AppPallete.primaryColor,
        foregroundColor: AppPallete.darkColorOnSurface,
      ),
      body: SafeArea(
        child: Container(
          color: AppPallete.primaryColor,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: screenWidth,
                        padding:
                            const EdgeInsets.only(bottom: 48.0, left: 16.0, right: 16.0, top: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: AppPallete.neutralColor.shade50,
                                  size: 30,
                                ),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: Text(
                                    "Registrasi Customer",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(color: AppPallete.darkColorOnSurface),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16.0),
                            Text(
                              "Silahkan masukan data yang diperlukan untuk menyelesaikan proses registrasi",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: AppPallete.darkColorOnSurface),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppPallete.neutralColor.shade50,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Nama user",
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              CustomUnderlineTextField(
                                maxLength: 24,
                                hintText: "Masukan nama user",
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Nama user tidak boleh kosong";
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _formData = _formData.copyWith(name: value);
                                },
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                "Nama akan ditampilkan sebagai nama pengenal user",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(
                                height: 32.0,
                              ),
                              Text(
                                "Email user",
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              CustomUnderlineTextField(
                                maxLength: 48,
                                hintText: "cth: usersocieaty@gmail.com",
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Email tidak boleh kosong";
                                  }
                                  if (!EmailValidator.validate(value)) {
                                    return "Email yang dimasukan tidak valid";
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _formData = _formData.copyWith(email: value);
                                },
                              ),
                              const SizedBox(height: 32.0),
                              Text(
                                "Password",
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              ObscureUnderlineTextField(
                                controller: _passwordController,
                                hintText: "Masukan password",
                                maxLength: 32,
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
                              const SizedBox(height: 32.0),
                              Text(
                                "Konfirmasi password",
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              ObscureUnderlineTextField(
                                hintText: "Masukan konfirmasi password",
                                maxLength: 32,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Konfirmasi password tidak boleh kosong";
                                  }
                                  if (_passwordController.text != value) {
                                    return "Konfirmasi password tidak sesuai dengan password";
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _formData = _formData.copyWith(confirmPassword: value);
                                },
                              ),
                              const SizedBox(height: 32.0),
                              Text(
                                "Nomor handphone",
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              CustomUnderlineTextField(
                                hintText: "cth: 08524390xxxx",
                                maxLength: 12,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Nomor handphone tidak boleh kosong";
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _formData = _formData.copyWith(phoneNumber: value);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: AppPallete.neutralColor.shade50,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: FilledButton(
                    onPressed: () {
                      if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        ref
                            .read(signupCustomerViewmodelProvider.notifier)
                            .signupCustomer(_formData);
                      }
                    },
                    child: isLoading
                        ? const LoadingIndicatorWidget(size: 16, color: Colors.white)
                        : const Text("Sign Up"),
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

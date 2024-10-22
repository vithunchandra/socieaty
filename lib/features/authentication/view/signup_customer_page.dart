import 'package:flutter/material.dart';
import 'package:socieaty/shared/widgets/custom_underline_text_field.dart';
import 'package:socieaty/shared/widgets/obscure_underline_text_field.dart';

import '../../../core/theme/app_pallete.dart';

class SignupCustomerPage extends StatelessWidget {
  SignupCustomerPage({super.key});
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppPallete.primaryColor,
      appBar: AppBar(
        backgroundColor: AppPallete.primaryColor,
        foregroundColor: AppPallete.darkColorOnSurface,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: screenWidth,
              padding: const EdgeInsets.only(bottom: 48.0, left: 16.0, right: 16.0, top: 24.0),
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
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppPallete.darkColorOnSurface),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    "Silahkan masukan data yang diperlukan untuk menyelesaikan proses registrasi",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppPallete.darkColorOnSurface),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppPallete.neutralColor.shade50,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
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
                                controller: _nameController,
                                maxLength: 24,
                                hintText: "Masukan nama user",
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
                                controller: _emailController,
                                maxLength: 48,
                                hintText: "cth: usersocieaty@gmail.com",
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
                              ),
                              const SizedBox(height: 32.0),
                              Text(
                                "Konfirmasi password",
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              ObscureUnderlineTextField(
                                controller: _confirmPasswordController,
                                hintText: "Masukan konfirmasi password",
                                maxLength: 32,
                              ),
                              const SizedBox(height: 32.0),
                              Text(
                                "Nomor handphone",
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              CustomUnderlineTextField(
                                controller: _phoneNumberController,
                                hintText: "cth: 08524390xxxx",
                                maxLength: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0,),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(onPressed: () {}, child: const Text("Sign Up")),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

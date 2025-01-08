import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/features/authentication/viewstate/signup_restaurant_form_state.dart';

import '../../../core/theme/app_pallete.dart';
import '../../../shared/widgets/custom_underline_text_field.dart';
import '../../../shared/widgets/obscure_underline_text_field.dart';

class SignupRestaurantFirstPage extends StatefulWidget {
  const SignupRestaurantFirstPage({super.key});

  @override
  State<SignupRestaurantFirstPage> createState() => _SignupRestaurantFirstPageState();
}

class _SignupRestaurantFirstPageState extends State<SignupRestaurantFirstPage> {
  final _formKey = GlobalKey<FormState>();
  SignupRestaurantFormState _formData = SignupRestaurantFormState();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _passwordController.text = "vithun11";
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppPallete.neutralColor.shade50,
      appBar: AppBar(
        title: const Text("Registrasi customer"),
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
                                    "Isi data diri",
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppPallete.darkColorOnSurface),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16.0),
                            Text(
                              "Silahkan masukan data-data diperlukan untuk lanjut ke proses selanjutnya",
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppPallete.darkColorOnSurface),
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
                        child: SafeArea(
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
                                  initialValue: "Vithun",
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "Nama tidak boleh kosong";
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
                                  initialValue: "vithunchandra@gmail.com",
                                  validator: (value) {
                                    if (value == null || !EmailValidator.validate(value)) {
                                      return "Email tidak valid";
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
                                    debugPrint("${_passwordController.text} Hallo");
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
                                  initialValue: "vithun11",
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "Konfirmasi password tidak boleh kosong";
                                    }
                                    if (value != _passwordController.text) {
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
                                  initialValue: "085243908885",
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
                        _formKey.currentState?.save();
                        context.push('/signup/restaurant/final', extra: _formData);
                      }
                    },
                    child: const Text("Selanjutnya"),
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

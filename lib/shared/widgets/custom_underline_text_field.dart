import 'package:flutter/material.dart';

import '../../core/theme/app_pallete.dart';

class CustomUnderlineTextField extends StatelessWidget {
  final TextEditingController controller;
  final Icon? prefixIcon;
  final String? hintText;
  final int? maxLength;
  final String? Function(String?)? validator;

  const CustomUnderlineTextField({super.key, required this.controller, this.prefixIcon, this.hintText, this.validator, this.maxLength});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      maxLength: maxLength,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0),
        hintText: hintText,
        hintStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppPallete.neutralColor, fontSize: 22),
        prefixIcon: prefixIcon,
        prefixIconConstraints: const BoxConstraints(minWidth: 60),
        counterText: "",
        border: const UnderlineInputBorder(
          borderSide: BorderSide(width: 2.0),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppPallete.neutralColor, width: 2.0),
        ),
      ),
    );
  }
}

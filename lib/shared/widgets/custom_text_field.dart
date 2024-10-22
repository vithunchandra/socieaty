import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final Icon? prefixIcon;
  final String? hintText;
  final String? Function(String?)? validator;

  const CustomTextField({super.key, required this.controller, this.prefixIcon, this.hintText, this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: Theme.of(context).textTheme.bodyMedium,
        prefixIcon: prefixIcon,
        prefixIconConstraints: const BoxConstraints(minWidth: 60),
      ),
    );
  }
}

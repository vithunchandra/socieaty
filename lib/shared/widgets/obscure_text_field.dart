import 'package:flutter/material.dart';

class ObscureTextField extends StatefulWidget {
  final TextEditingController? controller;
  final Icon? prefixIcon;
  final String? hintText;
  final String? initialValue;
  final int? maxLength;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;

  const ObscureTextField({super.key, this.controller, this.prefixIcon, this.hintText, this.validator, this.initialValue, this.maxLength, this.onSaved});

  @override
  State<ObscureTextField> createState() => _ObscureTextFieldState();
}

class _ObscureTextFieldState extends State<ObscureTextField> {
  bool isObscure = true;
  Icon suffixIcon = const Icon(Icons.visibility_outlined);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      maxLength: widget.maxLength,
      initialValue: widget.initialValue,
      obscureText: isObscure,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: Theme.of(context).textTheme.bodyMedium,
        prefixIcon: widget.prefixIcon,
        counterText: "",
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              isObscure = !isObscure;
              suffixIcon = isObscure ? const Icon(Icons.visibility_off_outlined) : const Icon(Icons.visibility_outlined);
            });
          },
          child: suffixIcon,
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 60),
        suffixIconConstraints: const BoxConstraints(minWidth: 60),
      ),
      onSaved: widget.onSaved,
    );
  }
}

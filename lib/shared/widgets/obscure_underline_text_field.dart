import 'package:flutter/material.dart';

import '../../core/theme/app_pallete.dart';

class ObscureUnderlineTextField extends StatefulWidget {
  final TextEditingController? controller;
  final Icon? prefixIcon;
  final String? hintText;
  final String? initialValue;
  final int? maxLength;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;

  const ObscureUnderlineTextField({super.key, this.controller, this.prefixIcon, this.hintText, this.validator, this.maxLength, this.onSaved, this.initialValue});

  @override
  State<ObscureUnderlineTextField> createState() => _ObscureUnderlineTextFieldState();
}

class _ObscureUnderlineTextFieldState extends State<ObscureUnderlineTextField> {
  bool isObscure = true;
  Icon suffixIcon = const Icon(Icons.visibility_outlined);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      maxLength: widget.maxLength,
      initialValue: widget.initialValue,
      style: Theme.of(context).textTheme.titleLarge,
      obscureText: isObscure,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0),
        hintText: widget.hintText,
        hintStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppPallete.neutralColor),
        prefixIcon: widget.prefixIcon,
        counterText: "",
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppPallete.darkColorOnSurface),
        ),
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

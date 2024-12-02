import 'package:flutter/material.dart';

import '../../core/theme/app_pallete.dart';

class CustomUnderlineTextField extends StatefulWidget {
  final TextEditingController? controller;
  final Icon? prefixIcon;
  final Icon? suffixIcon;
  final String? hintText;
  final String? initialValue;
  final int? maxLength;
  final void Function()? suffixIconAction;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;

  const CustomUnderlineTextField({
    super.key,
    this.controller, // Make this required
    this.prefixIcon,
    this.hintText,
    this.validator,
    this.maxLength,
    this.suffixIcon,
    this.suffixIconAction,
    this.onSaved,
    this.initialValue,
  });

  @override
  State<CustomUnderlineTextField> createState() => _CustomUnderlineTextFieldState();
}

class _CustomUnderlineTextFieldState extends State<CustomUnderlineTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      maxLength: widget.maxLength,
      initialValue: widget.initialValue,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0),
        hintText: widget.hintText,
        hintStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppPallete.neutralColor, fontSize: 22),
        prefixIcon: widget.prefixIcon,
        prefixIconConstraints: const BoxConstraints(minWidth: 60),
        suffixIconConstraints: const BoxConstraints(minWidth: 60),
        suffixIcon: widget.suffixIcon == null
            ? null
            : GestureDetector(
                onTap: widget.suffixIconAction,
                child: widget.suffixIcon,
              ),
        counterText: "",
        border: const UnderlineInputBorder(
          borderSide: BorderSide(width: 2.0),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppPallete.neutralColor, width: 2.0),
        ),
      ),
      onSaved: widget.onSaved,
    );
  }
}

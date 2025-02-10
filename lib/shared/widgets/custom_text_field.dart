import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final Icon? prefixIcon;
  final Icon? suffixIcon;
  final String? hintText;
  final String? initialValue;
  final int? maxLength;
  final int? minLines;
  final int? maxLines;
  final TextInputType? keyboardType;
  final void Function()? suffixIconAction;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;

  const CustomTextField({
    super.key,
    this.controller,
    this.prefixIcon,
    this.hintText,
    this.validator,
    this.suffixIcon,
    this.initialValue,
    this.maxLength,
    this.suffixIconAction,
    this.onSaved,
    this.maxLines,
    this.keyboardType,
    this.minLines,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      maxLength: widget.maxLength,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      initialValue: widget.initialValue,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppPallete.neutralColor),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon == null
            ? null
            : GestureDetector(
                onTap: widget.suffixIconAction,
                child: widget.suffixIcon,
              ),
        counterText: "",
      ),
      onSaved: widget.onSaved,
    );
  }
}

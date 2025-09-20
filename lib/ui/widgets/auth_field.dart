import 'package:flutter/material.dart';

class AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool? isObscureText;
  final String? Function(String?)? validator;
  final TextStyle? textStyle;
  final TextStyle? hintStyle; // yeni parametre

  const AuthField({
    super.key,
    required this.controller,
    required this.hintText,
    this.isObscureText,
    this.validator,
    this.textStyle,
    this.hintStyle,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isObscureText ?? false,
      validator: validator,
      style: textStyle ?? TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: hintStyle ?? TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.7),
      ),
    );
  }
}

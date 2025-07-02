import 'package:book_journal/core/theme.dart/appPalette.dart';
import 'package:flutter/material.dart';

class AuthField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isObscureText;

  const AuthField({
    super.key,
    required this.hintText,
    required this.controller,
    this.isObscureText = false,
    required String? Function(dynamic value) validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
         hintStyle: TextStyle(color: AppPallete.gradient2),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppPallete.gradient1,
            width: 3,
          ), // Normal durumda çerçeve rengi
          borderRadius: BorderRadius.circular(8), // İstersen köşe yuvarlama
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppPallete.gradient3,
            width: 3,
          ), // Focus olduğunda çerçeve rengi
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 3,
          ), // Hata varsa çerçeve
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent, width: 3),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return "$hintText is missing!";
        }
        return null;
      },
      obscureText: isObscureText,
    );
  }
}

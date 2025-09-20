import 'package:book_journal/core/theme.dart/appPalette.dart';
import 'package:flutter/material.dart';

class AuthGradientButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final Color? gradientStart; // yeni parametre
  final Color? gradientEnd;   // yeni parametre

  const AuthGradientButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    this.gradientStart,
    this.gradientEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppPalette.appGradient,
        borderRadius: BorderRadius.circular(7),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(395, 55),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Text(
          buttonText,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppPalette.background,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:book_journal/core/theme.dart/appPalette.dart';

class SaveButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const SaveButton({required this.text, required this.onPressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Tema durumuna göre gradient seç
    final gradient = isDark
        ? AppDarkPalette.appGradient
        : AppPalette.appGradient;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Material(
        borderRadius: BorderRadius.circular(20),
        elevation: 4,
        shadowColor: Colors.black45,
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onPressed,
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppDarkPalette.textPrimary : AppPalette.surface, 
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

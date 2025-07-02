import 'package:book_journal/core/theme.dart/appPalette.dart';
import 'package:flutter/material.dart';

Widget modernTextField(
  TextEditingController controller,
  String label, {
  int maxLines = 1,
  VoidCallback? onClear,
  bool showClearButton = false,
  IconData? prefixIcon,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: AppPallete.gradient3),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppPallete.gradient3.withOpacity(0.9)),
        filled: true,
        fillColor: AppPallete.gradient2,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppPallete.gradient3)
            : null,
        suffixIcon: showClearButton
            ? IconButton(
                icon: Icon(Icons.clear, color: AppPallete.gradient1),
                onPressed: onClear,
              )
            : null,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppPallete.gradient2, width: 2),
        ),
      ),
    ),
  );
}

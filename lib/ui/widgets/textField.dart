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
      style: TextStyle(color: AppPalette.primary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppPalette.primary.withOpacity(0.9)),
        filled: true,
        fillColor: AppPalette.card,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppPalette.primary)
            : null,
        suffixIcon: showClearButton
            ? IconButton(
                icon: Icon(Icons.clear, color: AppPalette.primary),
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
          borderSide: BorderSide(color: AppPalette.background, width: 2),
        ),
      ),
    ),
  );
}

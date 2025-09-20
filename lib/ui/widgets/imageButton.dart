import 'package:book_journal/core/theme.dart/appPalette.dart';
import 'package:flutter/material.dart';

Widget modernImageButton({
  required IconData icon,
  required String label,
  required VoidCallback onPressed,
}) {
  return ElevatedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, color: AppPalette.primary, size: 18),
    label: Text(
      label,
      style: TextStyle(
        color: AppPalette.primary,
        fontSize: 12,
      ),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white.withOpacity(0.9), // Açık arka plan
      shadowColor: AppPalette.primary.withOpacity(0.3),
      elevation: 2,
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 13),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppPalette.primary, width: 1),
      ),
      minimumSize: Size(90, 40),
    ),
  );
}

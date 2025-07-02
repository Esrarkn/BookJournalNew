import 'dart:ui';

import 'package:book_journal/core/theme.dart/appPalette.dart';
import 'package:flutter/material.dart';

Widget modernSaveButton(String text, VoidCallback onPressed) {
  return Center(
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(30),
      splashColor: Colors.white24,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppPallete.gradient2, AppPallete.backgroundColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppPallete.gradient3.withOpacity(0.6),
              offset: Offset(0, 6),
              blurRadius: 10,
            ),
          ],
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 64),
        child: Text(
          text,
          style: TextStyle(
            color: AppPallete.whiteColor,
            fontWeight: FontWeight.w500,
            fontSize: 18,
            letterSpacing: 1.2,
          ),
        ),
      ),
    ),
  );
}

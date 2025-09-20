import 'package:flutter/material.dart';
import 'package:book_journal/core/theme.dart/appPalette.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppDarkPalette.background, AppDarkPalette.surface]
                : [Colors.indigo.shade50, AppPalette.background, Colors.purple.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(child: child),
      ),
    );
  }
}

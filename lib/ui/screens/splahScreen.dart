import 'dart:async';
import 'package:book_journal/core/theme.dart/appPalette.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    _fadeController.forward();

    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.backgroundColor/*const Color(0xFFFAF3E0)*/, // Soft beige
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          Lottie.asset(
  'assets/animations/book4.json',
  height: 250,
  fit: BoxFit.cover,
  alignment: Alignment.bottomCenter,
),
Transform.translate(
  offset: const Offset(0, -20), // yukarı 20px kaydır
  child: const Text(
    'Book Journal',
    style: TextStyle(
      fontSize: 50,
      fontWeight: FontWeight.bold,
      color: AppPallete.gradient2,
      fontFamily: "Playfair",
    ),
  ),
),

              const SizedBox(height: 12),
              const Text(
                'Keep your reading memories alive.',
                style: TextStyle(
                  fontSize: 20,
                  color: AppPallete.gradient1,
                  fontFamily: "Playfair"
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

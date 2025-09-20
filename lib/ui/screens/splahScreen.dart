import 'package:book_journal/ui/widgets/appBackground.dart';
import 'package:flutter/material.dart';
import 'package:book_journal/core/theme.dart/appPalette.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _lottieController;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOutCubic,
    );

    _fadeController.forward();

    _lottieController = AnimationController(vsync: this);

    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AppBackground(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/animations/book3.json',
                  height: 250,
                  fit: BoxFit.cover,
                  controller: _lottieController,
                  onLoaded: (composition) {
                    // animasyonu biraz yavaşlat
                    _lottieController.duration = composition.duration * 1.2;
                    _lottieController.forward();
                  },
                ),
                Transform.translate(
                  offset: const Offset(0, -20),
                  child: Text(
                    'Soul Book',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: AppPalette.border,
                      fontFamily: "Playfair",
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Okudukların ruhunda iz bıraksın.',
                  style: TextStyle(
                    fontSize: 20,
                    color: isDarkMode ? Colors.white70 : AppPalette.primary,
                    fontFamily: "Playfair",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
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
                controller: _lottieController,
                onLoaded: (composition) {
                  // animasyonu daha yavaş oynat
                  _lottieController.duration = composition.duration * 1.2; 
                  _lottieController.forward();
                },
              ),
              Transform.translate(
                offset: const Offset(0, -20),
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
                  fontFamily: "Playfair",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

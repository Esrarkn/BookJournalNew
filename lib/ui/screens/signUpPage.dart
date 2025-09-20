import 'package:book_journal/core/theme.dart/appPalette.dart';
import 'package:book_journal/data/bloc/auth_bloc/auth_bloc.dart';
import 'package:book_journal/data/bloc/auth_bloc/auth_event.dart';
import 'package:book_journal/ui/screens/logInPage.dart';
import 'package:book_journal/ui/widgets/appBackground.dart';
import 'package:book_journal/ui/widgets/auth_field.dart';
import 'package:book_journal/ui/widgets/auth_gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Cihazın ışık/karanlık modunu alıyoruz
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AppBackground(
        child: Center(
          child: SingleChildScrollView(
             padding: const EdgeInsets.all(15.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Başlık
                  Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..shader = AppPalette.appGradient.createShader(
                          const Rect.fromLTWH(100, 100, 200, 70),
                        ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Name alanı
                  AuthField(
                    controller: nameController,
                    hintText: "Name",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "İsim boş olamaz!";
                      }
                      return null;
                    },
                                        textStyle: TextStyle(  color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade800,),
                    hintStyle: TextStyle(  color: isDarkMode ? AppPalette.textPrimary : AppPalette.textTertiary,),
                  ),
                  const SizedBox(height: 16),

                  // Email alanı
                  AuthField(
                    controller: emailController,
                    hintText: "Email",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "E-posta adresi boş olamaz!";
                      }
                      String pattern =
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                      RegExp regex = RegExp(pattern);
                      if (!regex.hasMatch(value)) {
                        return "Geçerli bir e-posta adresi giriniz!";
                      }
                      return null;
                    },
                    textStyle: TextStyle(  color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade800,),
                    hintStyle: TextStyle(  color: isDarkMode ? AppPalette.textPrimary : AppPalette.textTertiary,),
                  ),
                  const SizedBox(height: 16),

                  // Password alanı
                  AuthField(
                    controller: passwordController,
                    hintText: "Password",
                    isObscureText: true,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return "Şifre en az 6 karakter olmalıdır!";
                      }
                      return null;
                    },
                                        textStyle: TextStyle(  color: isDarkMode ? Colors.grey.shade800  : Colors.grey.shade800,),
                    hintStyle: TextStyle(  color: isDarkMode ? AppPalette.textPrimary : AppPalette.textTertiary,),
                  ),
                  const SizedBox(height: 24),

                  // Sign Up Button
                  AuthGradientButton(
                    buttonText: "Sign Up",
                     gradientStart: Color(0xFF667EEA),
                        gradientEnd: Color(0xFFED64A6),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        context.read<AuthBloc>().add(
                              SignUpEvent(
                                name: nameController.text.trim(),
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                              ),
                            );
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // Log In Text
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LogInPage()),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 16,
                        ),
                        children: [
                          TextSpan(
                            text: "Log In",
                            style: TextStyle(
                              color: AppPalette.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

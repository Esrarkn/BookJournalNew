import 'package:book_journal/core/theme.dart/appPalette.dart';
import 'package:book_journal/data/bloc/auth_bloc/auth_bloc.dart';
import 'package:book_journal/data/bloc/auth_bloc/auth_event.dart';
import 'package:book_journal/data/bloc/auth_bloc/auth_state.dart';
import 'package:book_journal/ui/screens/homePage.dart';
import 'package:book_journal/ui/screens/signUpPage.dart';
import 'package:book_journal/ui/widgets/appBackground.dart';
import 'package:book_journal/ui/widgets/auth_field.dart';
import 'package:book_journal/ui/widgets/auth_gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
@override
Widget build(BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Scaffold(
    resizeToAvoidBottomInset: true,
    body: AppBackground(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top,
          ),
          child: IntrinsicHeight(
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) async {
                if (state is AuthSuccess) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => HomePage(user: state.user)),
                  );
                } else if (state is AuthFailure) {
                  showSnackbar(context, state.message);
                }
              },
              builder: (context, state) {
                if (state is AuthLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
      
                return Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      Text(
                        "Log In.",
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..shader = AppPalette.appGradient.createShader(
                                const Rect.fromLTWH(100, 100, 200, 70)),
                        ),
                      ),
                      const SizedBox(height: 30),
                      AuthField(
                        controller: emailController,
                        hintText: "Email",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Email is required";
                          }
                          if (!value.contains("@")) {
                            return "Enter a valid email";
                          }
                          return null;
                        },
                        textStyle: TextStyle(
                          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade800,
                        ),
                        hintStyle: TextStyle(
                          color: isDarkMode ? AppPalette.textPrimary : AppPalette.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AuthField(
                        controller: passwordController,
                        hintText: "Password",
                        isObscureText: true,
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                        textStyle: TextStyle(
                          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade800,
                        ),
                        hintStyle: TextStyle(
                          color: isDarkMode ? AppPalette.textPrimary : AppPalette.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      AuthGradientButton(
                        buttonText: "Log In",
                        gradientStart: Color(0xFF667EEA),
                        gradientEnd: Color(0xFFED64A6),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(
                                  SignInEvent(
                                    email: emailController.text.trim(),
                                    password: passwordController.text.trim(),
                                  ),
                                );
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignUpPage()),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade700,
                              fontSize: 16,
                            ),
                            children: [
                              TextSpan(
                                text: "Sign Up",
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
                      const SizedBox(height: 100),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
}
}
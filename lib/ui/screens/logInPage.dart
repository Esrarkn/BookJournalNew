import 'package:book_journal/core/theme.dart/appPalette.dart';
import 'package:book_journal/data/bloc/auth_bloc/auth_bloc.dart';
import 'package:book_journal/data/bloc/auth_bloc/auth_event.dart';
import 'package:book_journal/data/bloc/auth_bloc/auth_state.dart';
import 'package:book_journal/ui/models/user.dart';
import 'package:book_journal/ui/screens/homePage.dart';
import 'package:book_journal/ui/screens/signUpPage.dart';
import 'package:book_journal/ui/widgets/auth_field.dart';
import 'package:book_journal/ui/widgets/auth_gradient_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: BlocConsumer<AuthBloc, AuthState>(
listener: (context, state) async {
  if (state is AuthFailure) {
    showSnackbar(context, state.message);
  } else if (state is AuthSuccess) {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    // Güvenli kontrol
    if (firebaseUser == null) {
      showSnackbar(context, "Giriş yapılamadı. Lütfen tekrar deneyin.");
      return;
    }

    final appUser = AppUser(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage(user: appUser)),
    );
  }
},



          builder: (context, state) {
            if (state is AuthLoading) {
             return  Center(
  child: CircularProgressIndicator(),
);
            }

            return Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Log In.",
                    style:
                        TextStyle(fontSize: 50, fontWeight: FontWeight.bold,color: AppPallete.gradient2),
                  ),
                  SizedBox(height: 30),
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
                  ),
                  SizedBox(height: 15),
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
                  ),
                  SizedBox(height: 20),
                  AuthGradientButton(
                    buttonText: "Log In",
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        // Event gönder: Firebase login
                        context.read<AuthBloc>().add(SignInEvent(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                            ));
                      }
                    },
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpPage()));
                    },
                    child: RichText(
                        text: TextSpan(
                            text: "Don't have an account? ",
                            style: Theme.of(context).textTheme.titleMedium ?.copyWith(color:AppPallete.gradient2),
                            children: [
                          TextSpan(
                            text: "Sign Up",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppPallete.gradient3,
                                  fontWeight: FontWeight.bold,
                                ),
                          )
                        ])),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
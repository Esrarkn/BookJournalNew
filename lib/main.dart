import 'package:book_journal/data/bloc/auth_bloc/auth_bloc.dart';
import 'package:book_journal/data/bloc/book_bloc/book_bloc.dart';
import 'package:book_journal/data/bloc/goal_bloc/goal_bloc.dart';
import 'package:book_journal/data/bloc/goal_bloc/goal_event.dart';
import 'package:book_journal/data/repository/firebaseBookRepository.dart';
import 'package:book_journal/ui/models/user.dart';
import 'package:book_journal/ui/screens/bookFormPage.dart';
import 'package:book_journal/ui/screens/homePage.dart';
import 'package:book_journal/ui/screens/logInPage.dart';
import 'package:book_journal/ui/screens/profilePage.dart';
import 'package:book_journal/ui/screens/splahScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:book_journal/core/theme.dart/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; 
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    AppUser? appUser;
    if (firebaseUser != null) {
      appUser = AppUser(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName,
      );
    }

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => BookBloc(
                bookRepository: FirebaseBookRepository(),
              ),
            ),
            BlocProvider(
              create: (context) => AuthBloc(FirebaseAuth.instance),
            ),
            BlocProvider(
              create: (context) => GoalBloc(
                firestore: FirebaseFirestore.instance,
              )..add(const LoadGoal()),
            ),
          ],
          child: MaterialApp(
            title: 'Book Journal',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightThemeMode,
            home: firebaseUser != null && appUser != null
                ? HomePage(user: appUser)
                : const SplashScreen(),
            locale: const Locale('tr'),
            supportedLocales: const [
              Locale('tr'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routes: {
              '/login': (context) => const LogInPage(),
              '/addBook': (context) => BookFormPage(),
              '/profile': (context) =>
                  appUser != null ? ProfilePage(user: appUser) : const LogInPage(),
            },
            builder: (context, widget) {
              ScreenUtil.init(context);
              return widget!;
            },
          ),
        );
      },
    );
  }
}

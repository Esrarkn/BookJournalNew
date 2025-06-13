import 'package:book_journal/core/theme.dart/theme_provider.dart';
import 'package:book_journal/data/bloc/book_bloc/book_bloc.dart';
import 'package:book_journal/data/bloc/goal_bloc/goal_bloc.dart';
import 'package:book_journal/data/repository/firebaseBookRepository.dart';
import 'package:book_journal/data/repository/goalRepository.dart';
import 'package:book_journal/ui/screens/bookFormPage.dart';
import 'package:book_journal/ui/screens/bookPage.dart';
import 'package:book_journal/ui/screens/homePage.dart';
import 'package:book_journal/ui/screens/onBoardingPage.dart';
import 'package:book_journal/ui/screens/splashPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:book_journal/core/theme.dart/theme.dart';
import 'package:provider/provider.dart';

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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => BookBloc(
                bookRepository: FirebaseBookRepository(),
              ),
        ),
         BlocProvider(
          create:
              (context) => GoalBloc(),
        ),
        // Kitap arama ve kayıt yönetimi
      ],
      child: MaterialApp(
        title: 'Book Journal',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkThemeMode, // Light tema varsayılan olarak
        home: HomePage(),
        routes: {'/addBook': (context) => BookFormPage()},
      ),
    );
  }
}

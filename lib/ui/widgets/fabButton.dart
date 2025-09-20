import 'package:book_journal/core/theme.dart/appPalette.dart';
import 'package:book_journal/data/bloc/book_bloc/book_bloc.dart';
import 'package:book_journal/data/bloc/book_bloc/book_event.dart';
import 'package:book_journal/ui/screens/bookFormPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Fabbutton extends StatelessWidget {
  Fabbutton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FloatingActionButton(
      heroTag: null,
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BookFormPage()),
        );

        // Kullanıcı kitap eklediyse anasayfayı yenile
        if (result != null) {
          context.read<BookBloc>().add(FetchBooks());
        }
      },
      backgroundColor: isDark ? AppDarkPalette.primary : AppPalette.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Icon(
        Icons.add,
        size: 30,
        color: isDark ? AppDarkPalette.textPrimary : AppPalette.primary,
      ),
    );
  }
}

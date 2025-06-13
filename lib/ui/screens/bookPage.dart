import 'package:book_journal/ui/screens/readingStatsPage.dart';
import 'package:book_journal/ui/screens/widgets/bookCard.dart';
import 'package:book_journal/ui/widgets/fabButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:book_journal/core/theme.dart/appPalette.dart';
import 'package:book_journal/data/bloc/book_bloc/book_bloc.dart';
import 'package:book_journal/data/bloc/book_bloc/book_event.dart';
import 'package:book_journal/data/bloc/book_bloc/book_state.dart';
import 'package:book_journal/ui/models/book_model.dart';


class BookPage extends StatefulWidget {
  @override
  _BookPageState createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  ReadingStatus _filterStatus = ReadingStatus.tumKitaplar;
  final List<String> _filters = ["Tüm Kitaplar", "Okunuyor", "Okundu"];

  @override
  void initState() {
    super.initState();
    context.read<BookBloc>().add(LoadBooks());
  }

  void _updateFilter(String newStatus) {
    setState(() {
      _filterStatus = _getReadingStatusFromString(newStatus);
    });
    context.read<BookBloc>().add(FilterBooks(status: _filterStatus));
  }

  ReadingStatus _getReadingStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case "okunuyor":
        return ReadingStatus.okunuyor;
      case "okundu":
        return ReadingStatus.okundu;
      case "tüm kitaplar":
      default:
        return ReadingStatus.tumKitaplar;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {},
          icon: Icon(Icons.menu, color: AppPallete.gradient1),
        ),
        title: Text(
          "Bookly Journal",
          style: TextStyle(
            color: AppPallete.gradient2,
            fontSize: 25,
            fontFamily: "Spinnaker",
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
  final state = context.read<BookBloc>().state;
  if (state is BookLoaded) {
    final books = state.books; // Tüm kitaplar
    final Map<String, int> categoryStats = {};

    for (var book in books) {
      final category = book.category ?? 'Belirsiz';
      if (categoryStats.containsKey(category)) {
        categoryStats[category] = categoryStats[category]! + 1;
      } else {
        categoryStats[category] = 1;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryStatisticsPage(categoryStats: categoryStats),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("İstatistikleri görmek için önce kitaplar yüklenmeli.")),
    );
  }
},

            icon: Icon(Icons.search, color: AppPallete.gradient1),
          ),
        ],
      ),
      body: BlocListener<BookBloc, BookState>(
        listener: (context, state) {
          if (state is BookLoaded) {
            context.read<BookBloc>().add(FilterBooks(status: _filterStatus));
          }
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              child: Wrap(
                spacing: 10.0,
                runSpacing: 6.0,
                alignment: WrapAlignment.center,
                children: _filters.map((label) {
                  final isSelected = _getReadingStatusFromString(label) == _filterStatus;
                  return ChoiceChip(
                    label: Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppPallete.gradient2,
                    backgroundColor: Colors.grey.shade200,
                    onSelected: (_) => _updateFilter(label),
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: BlocBuilder<BookBloc, BookState>(
                builder: (context, state) {
                  if (state is BookLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is BookLoaded) {
                    final books = state.filteredBooks;
                    if (books.isEmpty) {
                      return Center(
                        child: Text("Bu kategoride kitap yok.", style: TextStyle(fontSize: 16)),
                      );
                    }
                    return ListView.builder(
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(child: BookCard(book: books[index]));
                      },
                    );
                  } else if (state is BookError) {
                    return Center(
                      child: Text("Hata: ${state.message}", style: TextStyle(color: Colors.red)),
                    );
                  }
                  return Center(child: Text("Henüz hiç kitap eklenmedi."));
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Fabbutton(),
    );
  }
}

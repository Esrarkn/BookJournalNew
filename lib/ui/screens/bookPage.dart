import 'package:book_journal/ui/screens/readingStatsPage.dart';
import 'package:book_journal/ui/widgets/bookCard.dart';
import 'package:book_journal/ui/widgets/fabButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:book_journal/core/theme.dart/appPalette.dart';
import 'package:book_journal/data/bloc/book_bloc/book_bloc.dart';
import 'package:book_journal/data/bloc/book_bloc/book_event.dart';
import 'package:book_journal/data/bloc/book_bloc/book_state.dart';
import 'package:book_journal/ui/models/book.dart';


class BookPage extends StatefulWidget {
  @override
  _BookPageState createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  ReadingStatus _filterStatus = ReadingStatus.tumKitaplar;
  final List<String> _filters = ["Tüm Kitaplar", "Okunuyor", "Okundu"];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<BookBloc>().add(LoadBooks());
  }
  @override
void didChangeDependencies() {
  super.didChangeDependencies();
  context.read<BookBloc>().add(FetchBooks()); // <- Kitapları tekrar getir
}

    @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;
  final isSmallDevice = screenWidth < 360;

  return Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
  appBar: AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  title: _isSearching
      ? Container(
          width: screenWidth * 0.75, 
          height: 45,
          decoration: BoxDecoration(
            color: AppPallete.backgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.045,
            ),
            decoration: InputDecoration(
              hintText: 'Kitap ismi ara...',
              hintStyle: TextStyle(color: AppPallete.gradient1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.grey.shade600, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.grey.shade600, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: AppPallete.gradient1, width: 2),
              ),
              prefixIcon: Icon(Icons.search, color: AppPallete.gradient1),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey.shade600),
                      onPressed: () {
                        _searchController.clear();
                        context.read<BookBloc>().add(FilterBooks(status: _filterStatus));
                        setState(() {});
                      },
                    ),
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
            onChanged: (query) {
              context.read<BookBloc>().add(SearchBooks(query: query));
              setState(() {});
            },
          ),
        )
      : Text(
          "Bookly Journal",
          style: TextStyle(
            color: AppPallete.gradient2,
            fontSize: screenWidth * 0.075,
            fontFamily: "Playfair",
          ),
        ),
  centerTitle: true,
  actions: [
    IconButton(
      onPressed: () {
        setState(() {
          if (_isSearching) {
            _searchController.clear();
            context.read<BookBloc>().add(FilterBooks(status: _filterStatus));
          }
          _isSearching = !_isSearching;
        });
      },
      icon: Icon(
        _isSearching ? Icons.close : Icons.search, 
        color: AppPallete.gradient1,
        size: screenWidth * 0.07,
      ),
    ),
  ],
  ),
  
    body: BlocListener<BookBloc, BookState>(
      listener: (context, state) {
        if (state is BookLoaded && !_isSearching) {
          context.read<BookBloc>().add(FilterBooks(status: _filterStatus));
        }
      },
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: screenWidth * 0.001),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((label) {
                  final isSelected = _getReadingStatusFromString(label) == _filterStatus;
                  return ChoiceChip(
                    label: Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: screenWidth * 0.04,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppPallete.gradient2,
                    backgroundColor: Colors.grey.shade200,
                    onSelected: (_) => _updateFilter(label),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.02,
                      vertical: screenHeight * 0.008,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                }).toList(),
              ),
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
                      child: Text(
                        "Bu kategoride kitap yok.",
                        style: TextStyle(fontSize: screenWidth * 0.045),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        child: BookCard(book: books[index]),
                      );
                    },
                  );
                } else if (state is BookError) {
                  return Center(
                    child: Text(
                      "Hata: ${state.message}",
                      style: TextStyle(color: Colors.red, fontSize: screenWidth * 0.04),
                    ),
                  );
                }
                return Center(
                  child: Text(
                    "Henüz hiç kitap eklenmedi.",
                    style: TextStyle(fontSize: screenWidth * 0.045),
                  ),
                );
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

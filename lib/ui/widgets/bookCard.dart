import 'package:book_journal/core/theme.dart/appPalette.dart';
import 'package:book_journal/ui/models/book_model.dart';
import 'package:book_journal/ui/screens/detailBookPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:book_journal/data/bloc/book_bloc/book_bloc.dart';
import 'package:book_journal/data/bloc/book_bloc/book_event.dart';

class BookCard extends StatelessWidget {
  final Book book;

  const BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(book.id), // Her kitap için benzersiz bir key
      direction: DismissDirection.endToStart, // Yalnızca sola kaydırarak silme
      onDismissed: (direction) {
        // Kitap silme işlemi
        context.read<BookBloc>().add(
          DeleteBook(book),
        ); // Kitap silme event'i gönderiyoruz
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("${book.title} silindi")));
      },
      background: Container(
        color: AppPallete.gradient3, // Silme işlemi arka planı
        alignment: Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.only(right: 20),
          child: Icon(Icons.delete, color: Colors.white),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BookDetailPage(book: book)),
          );
        },
        child: Container(
          height: 150,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppPallete.gradient1,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Kitap Görseli
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    book.imageUrl.isNotEmpty
                        ? Image.network(
                          book.imageUrl,
                          width: 60,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Image.asset(
                                "assets/images/book.png",
                                width: 60,
                                height: 90,
                                fit: BoxFit.cover,
                              ),
                        )
                        : Image.asset(
                          "assets/images/book.png",
                          width: 60,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
              ),
              SizedBox(width: 12),

              // Kitap Bilgileri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      book.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppPallete.gradient3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      book.author.isNotEmpty ? book.author : "Bilinmeyen Yazar",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

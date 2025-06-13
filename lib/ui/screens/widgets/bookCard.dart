import 'package:book_journal/core/theme.dart/appPalette.dart';
import 'package:book_journal/data/bloc/book_bloc/book_bloc.dart';
import 'package:book_journal/data/bloc/book_bloc/book_event.dart';
import 'package:book_journal/ui/models/book_model.dart';
import 'package:book_journal/ui/screens/detailBookPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookCard extends StatelessWidget {
  final Book book;

  const BookCard({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(book.id ?? book.title), // Kitap için benzersiz bir key olmalı (id kullanıyorsan id en iyisi)
      direction: DismissDirection.endToStart, // Sadece sağdan sola kaydırınca
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: AppPallete.gradient3,
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Kitabı Sil'),
            content: const Text('Bu kitabı silmek istediğine emin misin?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Vazgeç'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Sil'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        context.read<BookBloc>().add(DeleteBook(book));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${book.title} silindi.")),
        );
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookDetailPage(book: book),
            ),
          );
        },
        child: Card(
          color: AppPallete.gradient1,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kitap görseli
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: book.imageUrl.isNotEmpty
                      ? Image.network(
                          book.imageUrl,
                          width: 70,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Image.asset(
                            "assets/images/book.png",
                            width: 70,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          "assets/images/book.png",
                          width: 70,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(width: 12),
                // Kitap bilgileri
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kitap adı
                      Text(
                        book.title.isNotEmpty ? book.title : "Başlıksız Kitap",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppPallete.gradient3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Yazar adı
                      Text(
                        book.author.isNotEmpty ? book.author : "Bilinmeyen Yazar",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Açıklama
                      Text(
                        book.description.isNotEmpty
                            ? book.description
                            : "Henüz Tamamlanmadı.",
                        style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:book_journal/core/theme.dart/appPalette.dart';
import 'package:book_journal/data/bloc/book_bloc/book_bloc.dart';
import 'package:book_journal/data/bloc/book_bloc/book_event.dart';
import 'package:book_journal/ui/models/book.dart';
import 'package:book_journal/ui/screens/detailBookPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookCard extends StatelessWidget {
  final Book book;

  const BookCard({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(book.id ?? book.title), 
      direction: DismissDirection.endToStart, 
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade400, Colors.red.shade600],
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Kitabı Sil'),
            content: const Text('Bu kitabı silmek istediğine emin misin?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text('Vazgeç', style: TextStyle(color: Colors.grey.shade600)),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text('Sil', style: TextStyle(color: Colors.red.shade600)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        context.read<BookBloc>().add(DeleteBook(book));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${book.title} silindi."),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
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
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppPalette.card,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kitap Kapağı
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 100,
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: _getBookCoverGradient(),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _getBookCoverGradient().colors.first.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: (book.imageUrl.isNotEmpty)
                      ? Image.network(
                          book.imageUrl,
                          width: 60,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildBookIcon(),
                        )
                      : (book.imagePath.isNotEmpty)
                          ? Image.file(
                              File(book.imagePath),
                              width: 60,
                              height: 80,
                              fit: BoxFit.cover,
                            )
                          : _buildBookIcon(),
                ),
              ),
              const SizedBox(width: 16),
              
              // Kitap Detayları
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Üst kısım - Başlık, Yazar, Rating, Tarih
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book.title.isNotEmpty ? book.title : "Başlıksız Kitap",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                book.author.isNotEmpty ? book.author : "Bilinmeyen Yazar",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              // Rating
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    Icons.star,
                                    size: 16,
                                    color: index < (book.rating ?? 0)
                                        ? Colors.amber.shade400 
                                        : Colors.grey.shade300,
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                        // Tarih
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _formatDate(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Hisler Bölümü
                    if (book.feelings.isNotEmpty || book.feelings?.isNotEmpty == true)
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.purple.shade50, Colors.pink.shade50],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.favorite, 
                                     size: 14, 
                                     color: AppPalette.feelingsIcon),
                                SizedBox(width: 6),
                              Text(
                                  'Hislerim',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppPalette.feelingsText,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Text(
                              _getFeelingsText(),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                height: 1.4,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 8),
                    
                    // Alıntı Bölümü (eğer varsa)
                    if (book.quotes?.isNotEmpty == true)
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.amber.shade50, Colors.orange.shade50],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.format_quote, 
                                     size: 14, 
                                     color: AppPalette.quoteIcon),
                                SizedBox(width: 6),
                                Text(
                                  'Favori Alıntı',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppPalette.quoteTitle,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Text(
                              '"${book.quotes}"',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                fontStyle: FontStyle.italic,
                                height: 1.4,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
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

  Widget _buildBookIcon() {
    return Icon(
      Icons.menu_book,
      color: Colors.white,
      size: 30,
    );
  }

  LinearGradient _getBookCoverGradient() {
    // Kitap türüne veya alfabetik sıraya göre farklı gradyanlar
    final title = book.title.toLowerCase();
    if (title.startsWith(RegExp(r'[a-f]'))) {
      return LinearGradient(colors: [Colors.pink.shade400, Colors.purple.shade400]);
    } else if (title.startsWith(RegExp(r'[g-m]'))) {
      return LinearGradient(colors: [Colors.amber.shade400, Colors.orange.shade400]);
    } else if (title.startsWith(RegExp(r'[n-s]'))) {
      return LinearGradient(colors: [Colors.blue.shade400, Colors.indigo.shade400]);
    } else {
      return LinearGradient(colors: [Colors.teal.shade400, Colors.green.shade400]);
    }
  }

  String _formatDate() {
    if (book.createdAt != null) {
      return '${book.createdAt!.day}/${book.createdAt!.month}';
    }
    return '${DateTime.now().day}/${DateTime.now().month}';
  }

  String _getFeelingsText() {
    if (book.feelings?.isNotEmpty == true) {
      return book.feelings!;
    } else if (book.feelings.isNotEmpty) {
      return book.feelings;
    }
    return "Henüz hisler eklenmedi.";
  }
}

// Placeholder widget for empty image
Widget _emptyImagePlaceholder() {
  return Container(
    width: 60,
    height: 80,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.grey.shade300, Colors.grey.shade400],
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Center(
      child: Icon(
        Icons.add_photo_alternate,
        size: 30,
        color: Colors.grey.shade600,
      ),
    ),
  );
}
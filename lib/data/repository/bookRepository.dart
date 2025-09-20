import 'dart:io';

import 'package:book_journal/ui/models/book.dart';
import 'package:book_journal/ui/models/session.dart';

abstract class BookRepository {
  Future<List<Book>> getBooks();
  Future<void> addBook(Book book);
  Future<List<Book>> searchBooks(String query);
  Future<void> deleteBook(Book book);
  Future<void> updateBook(Book book);
  Future<String> uploadBookImage(File imageFile);
// Belirli bir kitap için seansları dinamik olarak getirir
Stream<List<Session>> watchSessionsForBook(String bookId);

}
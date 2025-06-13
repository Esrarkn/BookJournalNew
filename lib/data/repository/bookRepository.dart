import 'package:book_journal/ui/models/book_model.dart';

abstract class BookRepository {
  Future<List<Book>> getBooks();
  Future<void> addBook(Book book);
  Future<List<Book>> searchBooks(String query);
  Future<void> deleteBook(Book book);
  Future<void> updateBook(Book book);
}

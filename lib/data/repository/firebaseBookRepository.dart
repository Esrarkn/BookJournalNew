import 'dart:io';

import 'package:book_journal/data/repository/bookRepository.dart';
import 'package:book_journal/data/services/firebase_service.dart';
import 'package:book_journal/ui/models/book.dart';
import 'package:book_journal/ui/models/session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseBookRepository implements BookRepository {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Future<List<Book>> getBooks() async {
    return await _firebaseService.getBooks();
  }

  @override
  Future<void> addBook(Book book) async {
    await _firebaseService.addBook(book);
  }

  @override
  Future<List<Book>> searchBooks(String query) async {
    return await _firebaseService.searchBooks(query);
  }

  @override
  Future<void> deleteBook(Book book) async {
    await _firebaseService.deleteBook(book.id);
  }

  @override
  Future<void> updateBook(Book book) async {
    await _firebaseService.updateBook(book.id, book);
  }
    @override
  Future<String> uploadBookImage(File imageFile) async {
    return await _firebaseService.uploadBookImage(imageFile);
  }
  Stream<List<Session>> watchSessionsForBook(String bookId) {
  return _firebaseService.watchSessionsForBook(bookId);
}
Future<void> addSession(String bookId, int minutes) async {
  final docRef = FirebaseFirestore.instance
      .collection('books')
      .doc(bookId)
      .collection('sessions')
      .doc();

  await docRef.set({
    'minutes': minutes,
    'date': FieldValue.serverTimestamp(),
  });
}

}
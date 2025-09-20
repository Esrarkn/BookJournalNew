import 'dart:io';
import 'package:book_journal/data/repository/bookRepository.dart';
import 'package:book_journal/data/services/firebase_service.dart';
import 'package:book_journal/ui/models/book.dart';
import 'package:book_journal/ui/models/session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class BookRepositoryImpl implements BookRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseService firebaseService;

  BookRepositoryImpl({required this.firebaseService});

@override
Future<void> addBook(Book book) async {
  try {
    final docRef = _firestore.collection('books').doc();
    final bookMap = book.copyWith(id: docRef.id).toMap(includeTimestamp: true);
    
    // 👇 Debug için timestamp kontrolü
    debugPrint("Timestamp ekleniyor: ${bookMap['createdAt']}"); 
    
    await docRef.set(bookMap);
  } catch (e) {
    debugPrint("Hata: $e");
    rethrow;
  }
}
 @override
Future<List<Book>> getBooks() async {
  try {
    final query = await _firestore.collection('books')
        .where('userId', isEqualTo: firebaseService.currentUserId) // kullanıcıya göre filtreleme
        .orderBy('createdAt', descending: true) // en yeniden en eskiye sıralama
        .get();

    return query.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Book.fromMap(data);
    }).toList();
  } catch (e) {
    debugPrint("Sorgu hatası: $e");

    // createdAt alanı olmayan kitaplar için fallback sıralama
    final allBooks = await _firestore.collection('books')
        .where('userId', isEqualTo: firebaseService.currentUserId)
        .get();

    final books = allBooks.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Book.fromMap(data);
    }).toList();

    books.sort((a, b) => (b.createdAt ?? DateTime(1970)).compareTo(a.createdAt ?? DateTime(1970)));
    return books;
  }
}

@override
Future<List<Book>> searchBooks(String query) async {
  if (query.isEmpty) return [];

  try {
    final querySnapshot = await _firestore
        .collection('books')
        .where('userId', isEqualTo: firebaseService.currentUserId) // ✔️ kullanıcıya göre filtre
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: query + '\uf8ff')
        .orderBy('title') // önce başlığa göre sırala
        .orderBy('createdAt', descending: true) // sonra tarihe göre
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Book.fromMap(data);
    }).toList();
  } catch (e) {
    // createdAt yoksa fallback
    final querySnapshot = await _firestore
        .collection('books')
        .where('userId', isEqualTo: firebaseService.currentUserId) // ✔️ kullanıcıya göre filtre
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: query + '\uf8ff')
        .orderBy('title') // sadece title ile
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Book.fromMap(data);
    }).toList();
  }
}

  @override
  Future<void> deleteBook(Book book) async {
    await _firestore.collection('books').doc(book.id).delete();
  }
Future<void> updateBook(Book book) async {
  try {
    // Önce mevcut createdAt değerini al
    final currentData = (await _firestore.collection('books').doc(book.id).get()).data();
    final currentCreatedAt = currentData?['createdAt'];

    final bookMap = book.toMap(includeTimestamp: false);
    
    // Orijinal createdAt değerini koru
    if (currentCreatedAt != null) {
      bookMap['createdAt'] = currentCreatedAt;
    }

    await _firestore.collection('books').doc(book.id).update(bookMap);
  } catch (e) {
    debugPrint("Güncelleme hatası: $e");
    rethrow;
  }
}
  @override
  Future<String> uploadBookImage(File imageFile) async {
    return await firebaseService.uploadBookImage(imageFile);
  } 
  Stream<List<Session>> watchSessionsForBook(String bookId) {
  return _firestore
      .collection('books')
      .doc(bookId)
      .collection('sessions')
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return Session(
              minutes: data['minutes'] ?? 0,
              date: (data['date'] as Timestamp).toDate(),
            );
          }).toList());
}

}
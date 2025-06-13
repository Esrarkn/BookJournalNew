import 'package:book_journal/ui/models/book_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Book>> getBooks() async {
    final querySnapshot = await _firestore.collection('books').get();
    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Book.fromMap(data);
    }).toList();
  }

  Future<void> addBook(Book book) async {
    DocumentReference docRef = await _firestore
        .collection('books')
        .add(book.toMap());
    await docRef.update({'id': docRef.id});
  }

  Future<List<Book>> searchBooks(String query) async {
    if (query.isEmpty) {
      return []; // Eğer query boşsa, boş liste döndür
    }

    final querySnapshot =
        await _firestore
            .collection('books')
            .where('title', isGreaterThanOrEqualTo: query)
            .where(
              'title',
              isLessThanOrEqualTo: query + '\uf8ff',
            ) // Yüksek Unicode karakteri ile tam eşleşme sağlama
            .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // Firestore ID ekleniyor
      return Book.fromMap(data);
    }).toList();
  }

  Future<void> deleteBook(String bookId) async {
    try {
      await _firestore
          .collection('books')
          .doc(bookId)
          .delete(); // Firestore'dan kitabı sil
    } catch (e) {
      throw Exception('Kitap silinirken bir hata oluştu: $e');
    }
  }

  Future<void> updateBook(String bookId, Book book) async {
    try {
      await _firestore.collection('books').doc(bookId).update(book.toMap());
    } catch (e) {
      print("Kitap güncellenirken hata oluştu: $e");
      throw Exception("Kitap güncellenirken hata oluştu");
    }
  }
}

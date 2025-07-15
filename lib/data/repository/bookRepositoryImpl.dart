import 'package:book_journal/data/repository/bookRepository.dart';
import 'package:book_journal/ui/models/book.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookRepositoryImpl implements BookRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

@override
Future<void> addBook(Book book) async {
  final docRef = await _firestore.collection('books').add({
    ...book.toMap(),
    'createdAt': FieldValue.serverTimestamp(), // ✅ EKLENDİ
  });
  await docRef.update({'id': docRef.id});
}
@override
Future<List<Book>> getBooks() async {
  final querySnapshot = await _firestore
      .collection('books')
      .orderBy('createdAt', descending: true)
      .get();

  final books = querySnapshot.docs.map((doc) {
    final data = doc.data();
    data['id'] = doc.id;
    return Book.fromMap(data);
  }).toList();

  // 🔍 Burada createdAt değerlerini konsola yazdıralım:
  for (var book in books) {
    print('Kitap: ${book.title} - CreatedAt: ${book.createdAt}');
  }

  return books;
}



  @override
  Future<List<Book>> searchBooks(String query) async {
    if (query.isEmpty) {
      return []; // Eğer sorgu boşsa, boş liste döndür
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

  @override
  Future<void> deleteBook(Book book) async {
    await _firestore.collection('books').doc(book.id).delete();
  }

  @override
  Future<void> updateBook(Book book) async {
    await _firestore.collection('books').doc(book.id).update(book.toMap());
  }
}
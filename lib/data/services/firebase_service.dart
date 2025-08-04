import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:book_journal/ui/models/book.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
    String? get currentUserId {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  Future<String> uploadBookImage(File imageFile) async {
    try {
      String fileId = const Uuid().v4();
      Reference ref = _storage.ref().child("book_images/$fileId.jpg");
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception("Görsel yüklenemedi: $e");
    }
  }

Future<List<Book>> getBooks() async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return [];

  final snapshot = await _firestore
      .collection('books')
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true) // 🔥 sıralama eklendi
      .get();

  return snapshot.docs.map((doc) {
    final data = doc.data();
    data['id'] = doc.id;
    return Book.fromMap(data);
  }).toList();
}


  Future<void> addBook(Book book) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception("Kullanıcı giriş yapmamış");

    await _firestore.collection('books').doc(book.id).set({
      ...book.toMap(),
      'userId': userId,  // Burada userId eklenmeli
    });
  }

Future<List<Book>> searchBooks(String query) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return [];

  if (query.isEmpty) return [];

  final querySnapshot = await _firestore
      .collection('books')
      .where('userId', isEqualTo: userId)
      .where('title', isGreaterThanOrEqualTo: query)
      .where('title', isLessThanOrEqualTo: query + '\uf8ff')
      .get();

  return querySnapshot.docs.map((doc) {
    final data = doc.data();
    data['id'] = doc.id;
    return Book.fromMap(data);
  }).toList();
}


  Future<void> deleteBook(String bookId) async {
    try {
      await _firestore.collection('books').doc(bookId).delete();
    } catch (e) {
      throw Exception('Kitap silinirken bir hata oluştu: $e');
    }
  }

Future<void> updateBook(String bookId, Book book) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) throw Exception("Kullanıcı giriş yapmamış");

  final updatedData = {
    ...book.toMap(),
    'userId': userId,
  };

  try {
    await _firestore.collection('books').doc(bookId).update(updatedData);
  } catch (e) {
    print("Kitap güncellenirken hata oluştu: $e");
    throw Exception("Kitap güncellenirken hata oluştu");
  }
}

}

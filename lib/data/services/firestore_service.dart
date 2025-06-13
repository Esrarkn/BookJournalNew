import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Kitap Ekleme
  Future<void> addBook(String title, String author, String notes) async {
    await _db.collection("books").add({
      "title": title,
      "author": author,
      "notes": notes,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  // Kitapları Listeleme
  Stream<QuerySnapshot> getBooks() {
    return _db.collection("books").orderBy("createdAt", descending: true).snapshots();
  }
}

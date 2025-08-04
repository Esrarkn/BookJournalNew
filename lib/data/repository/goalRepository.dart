import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../ui/models/bookGoal.dart';

class GoalRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> updateGoal(BookGoal goal) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Kullanıcı giriş yapmamış');

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc('currentGoal')
        .set(goal.toMap());
  }

  Future<BookGoal> loadGoal() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Kullanıcı giriş yapmamış');

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc('currentGoal')
        .get();

    if (snapshot.exists) {
      return BookGoal.fromMap(snapshot.data()!);
    } else {
      return BookGoal(
        monthlyGoal: 0,
        yearlyGoal: 0,
        monthlyProgress: 0,
        yearlyProgress: 0,
      );
    }
  }

  Future<void> deleteGoal() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Kullanıcı giriş yapmamış');

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc('currentGoal')
        .delete();
  }
}
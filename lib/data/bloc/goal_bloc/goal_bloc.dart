import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:book_journal/data/bloc/goal_bloc/goal_event.dart';
import 'package:book_journal/data/bloc/goal_bloc/goal_state.dart';
import 'package:book_journal/ui/models/bookGoal.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GoalBloc extends Bloc<GoalEvent, GoalState> {
  final FirebaseFirestore _firestore;
  final String userId;

  GoalBloc({required FirebaseFirestore firestore, required this.userId})
      : _firestore = firestore,
        super(GoalInitial()) {
    on<LoadGoal>(_onLoadGoal);
    on<UpdateGoal>(_onUpdateGoal);
    on<UpdateProgress>(_onUpdateProgress);
    on<UpdateProgressLocal>(_onUpdateProgressLocal); 
  }

  Future<void> _onLoadGoal(LoadGoal event, Emitter<GoalState> emit) async {
    emit(GoalLoading());
    try {
      if (userId.isEmpty) {
        emit(GoalFailure("Kullanıcı oturumu bulunamadı."));
        return;
      }

      final doc = await _firestore.collection('goals').doc(userId).get();

      if (!doc.exists) {
        final defaultGoal = BookGoal(
          monthlyGoal: 0,
          yearlyGoal: 0,
          monthlyProgress: 0,
          yearlyProgress: 0,
        );
        emit(GoalLoadSuccess(defaultGoal));
      } else {
        final data = doc.data()!;
        final bookGoal = BookGoal.fromMap(data);
        emit(GoalLoadSuccess(bookGoal));
      }
    } catch (e) {
      emit(GoalFailure("Hedef verisi yüklenirken hata oluştu: $e"));
    }
  }

  Future<void> _onUpdateGoal(UpdateGoal event, Emitter<GoalState> emit) async {
    emit(GoalLoading());
    try {
      if (userId.isEmpty) {
        emit(GoalFailure("Kullanıcı oturumu bulunamadı."));
        return;
      }

      await _firestore.collection('goals').doc(userId).set(event.bookGoal.toMap());
      emit(GoalLoadSuccess(event.bookGoal));
    } catch (e) {
      emit(GoalFailure("Hedef güncellenirken hata oluştu: $e"));
    }
  }

  /// Sadece ilerleme bilgisini günceller.
  Future<void> _onUpdateProgress(UpdateProgress event, Emitter<GoalState> emit) async {
    if (userId.isEmpty) {
      emit(GoalFailure("Kullanıcı oturumu bulunamadı."));
      return;
    }

    if (state is! GoalLoadSuccess) return;

    final currentGoal = (state as GoalLoadSuccess).bookGoal;

    // İlerlemeyi event'e göre güncelle
    BookGoal updatedGoal;

    if (event.isMonthly) {
      int newMonthlyProgress = event.progress;
      if (newMonthlyProgress > currentGoal.monthlyGoal) {
        newMonthlyProgress = currentGoal.monthlyGoal;
      }
      updatedGoal = currentGoal.copyWith(monthlyProgress: newMonthlyProgress);
    } else {
      int newYearlyProgress = event.progress;
      if (newYearlyProgress > currentGoal.yearlyGoal) {
        newYearlyProgress = currentGoal.yearlyGoal;
      }
      updatedGoal = currentGoal.copyWith(yearlyProgress: newYearlyProgress);
    }

    emit(GoalLoading());

    try {
      await _firestore.collection('goals').doc(userId).update({
        if (event.isMonthly) 'monthlyProgress': updatedGoal.monthlyProgress,
        if (!event.isMonthly) 'yearlyProgress': updatedGoal.yearlyProgress,
        'updatedAt': DateTime.now(),
      });
      emit(GoalLoadSuccess(updatedGoal));
    } catch (e) {
      emit(GoalFailure("İlerleme güncellenirken hata oluştu: $e"));
    }
  }
  Future<void> _onUpdateProgressLocal(UpdateProgressLocal event, Emitter<GoalState> emit) async {
  if (state is GoalLoadSuccess) {
    final currentGoal = (state as GoalLoadSuccess).bookGoal;
    BookGoal updatedGoal;

    if (event.isMonthly) {
      int newMonthlyProgress = event.progress;
      int newYearlyProgress = currentGoal.yearlyProgress < newMonthlyProgress
          ? newMonthlyProgress
          : currentGoal.yearlyProgress;

      updatedGoal = currentGoal.copyWith(
        monthlyProgress: newMonthlyProgress,
        yearlyProgress: newYearlyProgress,
      );
    } else {
      updatedGoal = currentGoal.copyWith(yearlyProgress: event.progress);
    }

    emit(GoalLoadSuccess(updatedGoal));

    // Firestore'a yazmayı arka planda yap
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await _firestore.collection('goals').doc(userId).update(updatedGoal.toMap());
      }
    } catch (e) {
      // Hata yönetimi (isteğe bağlı)
    }
  }
}

}

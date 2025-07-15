import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:book_journal/data/bloc/goal_bloc/goal_event.dart';
import 'package:book_journal/data/bloc/goal_bloc/goal_state.dart';
import 'package:book_journal/ui/models/bookGoal.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GoalBloc extends Bloc<GoalEvent, GoalState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  GoalBloc({required FirebaseFirestore firestore})
      : _firestore = firestore,
        super(GoalInitial()) {
    on<LoadGoal>(_onLoadGoal);
    on<UpdateGoal>(_onUpdateGoal);
    on<UpdateProgress>(_onUpdateProgress);
    on<UpdateProgressLocal>(_onUpdateProgressLocal);
  }

  String get _userId => _auth.currentUser?.uid ?? '';

  Future<void> _onLoadGoal(LoadGoal event, Emitter<GoalState> emit) async {
    emit(GoalLoading());
    try {
      if (_userId.isEmpty) {
        emit(GoalFailure("Kullanıcı oturumu bulunamadı."));
        return;
      }

      final doc = await _firestore
          .collection('goals')
          .doc(_userId)
          .get();

      if (!doc.exists) {
        final defaultGoal = BookGoal(
          monthlyGoal: 0,
          yearlyGoal: 0,
          monthlyProgress: 0,
          yearlyProgress: 0,
        );
        emit(GoalLoadSuccess(defaultGoal));
      } else {
        final bookGoal = BookGoal.fromMap(doc.data()!);
        emit(GoalLoadSuccess(bookGoal));
      }
    } catch (e) {
      emit(GoalFailure("Hedef verisi yüklenirken hata oluştu: $e"));
    }
  }

  Future<void> _onUpdateGoal(UpdateGoal event, Emitter<GoalState> emit) async {
    emit(GoalLoading());
    try {
      if (_userId.isEmpty) {
        emit(GoalFailure("Kullanıcı oturumu bulunamadı."));
        return;
      }

      await _firestore
          .collection('goals')
          .doc(_userId)
          .set(event.bookGoal.toMap());

      emit(GoalLoadSuccess(event.bookGoal));
    } catch (e) {
      emit(GoalFailure("Hedef güncellenirken hata oluştu: $e"));
    }
  }

  Future<void> _onUpdateProgress(UpdateProgress event, Emitter<GoalState> emit) async {
    if (_userId.isEmpty) {
      emit(GoalFailure("Kullanıcı oturumu bulunamadı."));
      return;
    }

    if (state is! GoalLoadSuccess) return;

    final currentGoal = (state as GoalLoadSuccess).bookGoal;

    BookGoal updatedGoal;

    if (event.isMonthly) {
      int newMonthlyProgress = event.progress.clamp(0, currentGoal.monthlyGoal);
      updatedGoal = currentGoal.copyWith(monthlyProgress: newMonthlyProgress);
    } else {
      int newYearlyProgress = event.progress.clamp(0, currentGoal.yearlyGoal);
      updatedGoal = currentGoal.copyWith(yearlyProgress: newYearlyProgress);
    }

    emit(GoalLoading());

    try {
      await _firestore.collection('goals').doc(_userId).update({
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

      try {
        if (_userId.isNotEmpty) {
          await _firestore.collection('goals').doc(_userId).update(updatedGoal.toMap());
        }
      } catch (_) {
        // Hata yönetimi opsiyonel
      }
    }
  }
}

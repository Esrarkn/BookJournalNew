import 'package:equatable/equatable.dart';
import 'package:book_journal/ui/models/bookGoal.dart';

abstract class GoalState extends Equatable {
  const GoalState();

  @override
  List<Object?> get props => [];
}

// Başlangıç durumu
class GoalInitial extends GoalState {}

// Yükleniyor durumu
class GoalLoading extends GoalState {}

// Yükleme başarılı, veri geldi
class GoalLoadSuccess extends GoalState {
  final BookGoal bookGoal;

  const GoalLoadSuccess(this.bookGoal);

  @override
  List<Object?> get props => [bookGoal];
}

// Hata durumu
class GoalFailure extends GoalState {
  final String message;
  GoalFailure(this.message);
}


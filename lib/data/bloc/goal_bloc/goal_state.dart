import 'package:equatable/equatable.dart';

// Goal Durumları (States)
abstract class GoalState extends Equatable {
  const GoalState();

  @override
  List<Object> get props => [];
}

class GoalInitial extends GoalState {}

class GoalLoading extends GoalState {}

class GoalLoaded extends GoalState {
  final int targetBooks; // Hedeflenen kitap sayısı
  final int completedBooks; // Tamamlanan kitap sayısı

  const GoalLoaded({
    required this.targetBooks,
    required this.completedBooks,
  });

  @override
  List<Object> get props => [targetBooks, completedBooks];
}

class GoalProgressUpdated extends GoalState {
  final int completedBooks;

  const GoalProgressUpdated({required this.completedBooks});

  @override
  List<Object> get props => [completedBooks];
}

class GoalError extends GoalState {
  final String message;

  const GoalError(this.message);

  @override
  List<Object> get props => [message];
}

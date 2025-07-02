import 'package:equatable/equatable.dart';
import 'package:book_journal/ui/models/bookGoal.dart';

abstract class GoalEvent extends Equatable {
  const GoalEvent();

  @override
  List<Object?> get props => [];
}

// Hedefi yüklemek için
class LoadGoal extends GoalEvent {
  const LoadGoal();
}

// Hedefi güncellemek için
class UpdateGoal extends GoalEvent {
  final BookGoal bookGoal;

  const UpdateGoal(this.bookGoal);

  @override
  List<Object?> get props => [bookGoal];
}
class UpdateProgress extends GoalEvent {
  final bool isMonthly;
  final int progress;
  UpdateProgress({required this.isMonthly, required this.progress});
}
class UpdateProgressLocal extends GoalEvent {
  final bool isMonthly;
  final int progress;

  UpdateProgressLocal({required this.isMonthly, required this.progress});
}

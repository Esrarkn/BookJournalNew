abstract class GoalEvent {}

class AddGoal extends GoalEvent {
  final int targetBooks;
  final DateTime targetDate;

  AddGoal({required this.targetBooks, required this.targetDate});
}

class IncrementGoalProgress extends GoalEvent {
  final bool isMonthly;

  IncrementGoalProgress({required this.isMonthly});
}

class ToggleGoalProgress extends GoalEvent {
  final bool isMonthly;

  ToggleGoalProgress({required this.isMonthly});
}

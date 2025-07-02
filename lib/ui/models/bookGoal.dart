class BookGoal {
  final int monthlyGoal;
  final int yearlyGoal;
  final int monthlyProgress;
  final int yearlyProgress;

  BookGoal({
    required this.monthlyGoal,
    required this.yearlyGoal,
    required this.monthlyProgress,
    required this.yearlyProgress,
  });

  BookGoal copyWith({
    int? monthlyGoal,
    int? yearlyGoal,
    int? monthlyProgress,
    int? yearlyProgress,
  }) {
    return BookGoal(
      monthlyGoal: monthlyGoal ?? this.monthlyGoal,
      yearlyGoal: yearlyGoal ?? this.yearlyGoal,
      monthlyProgress: monthlyProgress ?? this.monthlyProgress,
      yearlyProgress: yearlyProgress ?? this.yearlyProgress,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'monthlyGoal': monthlyGoal,
      'yearlyGoal': yearlyGoal,
      'monthlyProgress': monthlyProgress,
      'yearlyProgress': yearlyProgress,
    };
  }

  factory BookGoal.fromMap(Map<String, dynamic> map) {
    return BookGoal(
      monthlyGoal: (map['monthlyGoal'] ?? 0) as int,
      yearlyGoal: (map['yearlyGoal'] ?? 0) as int,
      monthlyProgress: (map['monthlyProgress'] ?? 0) as int,
      yearlyProgress: (map['yearlyProgress'] ?? 0) as int,
    );
  }
}

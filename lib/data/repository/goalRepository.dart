class GoalRepository {
  // Bu örnekte yerel veri depolama kullanılıyor
  Future<void> addGoal(int targetBooks, DateTime targetDate) async {
    // Veritabanına ekleme işlemi
  }

  Future<void> updateGoal(int targetBooks, DateTime targetDate) async {
    // Veritabanında güncelleme işlemi
  }

  Future<void> deleteGoal() async {
    // Hedef verisini silme işlemi
  }

  Future<Goal> loadGoal() async {
    // Hedefi veritabanından çekme
    return Goal(targetBooks: 10, targetDate: DateTime.now().add(Duration(days: 30)), completedBooks: 5);
  }
}

class Goal {
  final int targetBooks;
  final DateTime targetDate;
  final int completedBooks;

  Goal({
    required this.targetBooks,
    required this.targetDate,
    required this.completedBooks,
  });
}

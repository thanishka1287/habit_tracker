class Habit {
  String id;
  String name;
  List<String> completedDates; // stored as 'yyyy-MM-dd'

  Habit({
    required this.id,
    required this.name,
    List<String>? completedDates,
  }) : completedDates = completedDates ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'completedDates': completedDates,
      };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        id: json['id'],
        name: json['name'],
        completedDates: List<String>.from(json['completedDates'] ?? []),
      );

  bool isDoneToday() => completedDates.contains(_todayString());

  void toggleToday() {
    final today = _todayString();
    if (completedDates.contains(today)) {
      completedDates.remove(today);
    } else {
      completedDates.add(today);
    }
  }

  /// Counts consecutive days completed, walking backward from today.
  int get currentStreak {
    int streak = 0;
    DateTime day = DateTime.now();
    while (completedDates.contains(_dateString(day))) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Days completed in the last 7 days (including today).
  int get completedThisWeek {
    int count = 0;
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: i));
      if (completedDates.contains(_dateString(day))) count++;
    }
    return count;
  }

  static String _todayString() => _dateString(DateTime.now());

  static String _dateString(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
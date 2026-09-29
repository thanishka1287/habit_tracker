class Habit {
  String id;
  String name;
  int colorValue; // stored as an ARGB int, e.g. 0xFF009688
  List<String> completedDates; // stored as 'yyyy-MM-dd'

  Habit({
    required this.id,
    required this.name,
    this.colorValue = 0xFF009688,
    List<String>? completedDates,
  }) : completedDates = completedDates ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'colorValue': colorValue,
        'completedDates': completedDates,
      };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        id: json['id'],
        name: json['name'],
        colorValue: json['colorValue'] ?? 0xFF009688,
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

  /// Longest run of consecutive completed days across all history.
  int get bestStreak {
    if (completedDates.isEmpty) return 0;

    final sortedDates = completedDates.toList()..sort();
    final parsed = sortedDates.map(_parseDate).toList();

    int best = 1;
    int current = 1;
    for (int i = 1; i < parsed.length; i++) {
      final diff = parsed[i].difference(parsed[i - 1]).inDays;
      if (diff == 1) {
        current++;
        if (current > best) best = current;
      } else if (diff > 1) {
        current = 1;
      }
    }
    return best;
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

  static DateTime _parseDate(String s) {
    final parts = s.split('-');
    return DateTime(
        int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }
}
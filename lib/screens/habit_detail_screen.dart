import 'package:flutter/material.dart';
import '../models/habit.dart';

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  static const _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  String _dateString(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  void _changeMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;
    final color = Color(habit.colorValue);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isCurrentMonth = _month.year == now.year && _month.month == now.month;

    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final leadingBlanks = DateTime(_month.year, _month.month, 1).weekday - 1;

    int doneThisMonth = 0;
    final cells = <Widget>[];

    for (int i = 0; i < leadingBlanks; i++) {
      cells.add(const SizedBox());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_month.year, _month.month, day);
      final done = habit.completedDates.contains(_dateString(date));
      final isToday = date == today;
      if (done) {
        doneThisMonth++;
      }
      cells.add(
        Container(
          margin: const EdgeInsets.all(3),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: done ? color : Colors.transparent,
            shape: BoxShape.circle,
            border: isToday ? Border.all(color: color, width: 2) : null,
          ),
          child: Text(
            '$day',
            style: TextStyle(
              color: done ? Colors.white : null,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(habit.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _changeMonth(-1),
                ),
                Text(
                  '${_monthNames[_month.month - 1]} ${_month.year}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w600),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: isCurrentMonth ? null : () => _changeMonth(1),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: _weekdays
                  .map((d) => Expanded(
                        child: Center(
                          child: Text(d,
                              style: const TextStyle(color: Colors.grey)),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 4),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: cells,
            ),
            const SizedBox(height: 16),
            Text(
              '$doneThisMonth of $daysInMonth days completed this month',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatChip(
                  icon: '🔥',
                  label: 'Current streak',
                  value: '${habit.currentStreak}',
                  color: color,
                ),
                const SizedBox(width: 12),
                _StatChip(
                  icon: '🏆',
                  label: 'Best streak',
                  value: '${habit.bestStreak}',
                  color: color,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text('$icon $value',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
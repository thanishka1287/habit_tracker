import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../screens/habit_detail_screen.dart';

class HabitTile extends StatelessWidget {
  final Habit habit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final Future<bool> Function() confirmDismiss;

  const HabitTile({
    super.key,
    required this.habit,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
    required this.confirmDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final done = habit.isDoneToday();
    final week = habit.completedThisWeek;
    final color = Color(habit.colorValue);

    return Dismissible(
      key: ValueKey(habit.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => confirmDismiss(),
      onDismissed: (_) => onDelete(),
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: ListTile(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HabitDetailScreen(habit: habit),
            ),
          ),
          leading: GestureDetector(
            onTap: onToggle,
            child: Icon(
              done ? Icons.check_circle : Icons.radio_button_unchecked,
              color: done ? color : Colors.grey,
              size: 32,
            ),
          ),
          title: Text(habit.name, style: const TextStyle(fontSize: 18)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🔥 ${habit.currentStreak} day streak'),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: week / 7,
                minHeight: 6,
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 2),
              Text('$week/7 this week',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: onEdit,
          ),
        ),
      ),
    );
  }
}
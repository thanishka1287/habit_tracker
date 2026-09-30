import 'package:flutter/material.dart';
import '../models/habit.dart';

class StatsScreen extends StatelessWidget {
  final List<Habit> habits;

  const StatsScreen({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    final totalHabits = habits.length;
    final totalCheckIns =
        habits.fold<int>(0, (sum, h) => sum + h.completedDates.length);
    final bestStreakOverall = habits.isEmpty
        ? 0
        : habits.map((h) => h.bestStreak).reduce((a, b) => a > b ? a : b);
    final longestStreakHabit = habits.isEmpty
        ? null
        : habits.reduce((a, b) => a.bestStreak >= b.bestStreak ? a : b);

    return Scaffold(
      appBar: AppBar(title: const Text('Your Stats')),
      body: habits.isEmpty
          ? const Center(
              child: Text(
                'Add some habits first to see stats here.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _StatCard(
                  icon: Icons.list_alt,
                  label: 'Total habits',
                  value: '$totalHabits',
                ),
                _StatCard(
                  icon: Icons.check_circle_outline,
                  label: 'Total check-ins',
                  value: '$totalCheckIns',
                ),
                _StatCard(
                  icon: Icons.emoji_events_outlined,
                  label: 'Best streak ever',
                  value: bestStreakOverall == 0
                      ? '0 days'
                      : '$bestStreakOverall days'
                          '${longestStreakHabit != null ? ' (${longestStreakHabit.name})' : ''}',
                ),
                const SizedBox(height: 12),
                const Text('Per-habit breakdown',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...habits.map((h) => Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(h.colorValue),
                        ),
                        title: Text(h.name),
                        subtitle: Text(
                            '${h.completedDates.length} check-ins • best streak ${h.bestStreak}'),
                      ),
                    )),
              ],
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        subtitle: Text(label),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import '../services/habit_storage.dart';
import '../widgets/habit_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<int> _colors = [
    0xFF009688, // teal
    0xFF2196F3, // blue
    0xFF9C27B0, // purple
    0xFFE91E63, // pink
    0xFFFF9800, // orange
    0xFF4CAF50, // green
  ];

  List<Habit> _habits = [];
  bool _loading = true;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final habits = await HabitStorage.loadHabits();
    setState(() {
      _habits = habits;
      _loading = false;
    });
  }

  Future<void> _saveHabits() => HabitStorage.saveHabits(_habits);

  void _toggleHabit(Habit habit) {
    setState(() => habit.toggleToday());
    _saveHabits();
  }

  void _deleteHabit(Habit habit) {
    setState(() => _habits.removeWhere((h) => h.id == habit.id));
    _saveHabits();
  }

  Future<void> _addHabitDialog() async {
    final controller = TextEditingController();
    int selectedColor = _colors.first;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('New Habit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'e.g. Drink water'),
              ),
              const SizedBox(height: 16),
              const Text('Pick a color'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: _colors.map((c) {
                  return GestureDetector(
                    onTap: () => setDialogState(() => selectedColor = c),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(c),
                      child: selectedColor == c
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 18)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, {
                'name': controller.text.trim(),
                'color': selectedColor,
              }),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    if (result != null && (result['name'] as String).isNotEmpty) {
      setState(() => _habits.add(Habit(
            id: _uuid.v4(),
            name: result['name'] as String,
            colorValue: result['color'] as int,
          )));
      _saveHabits();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Habit Tracker'), centerTitle: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _habits.isEmpty
              ? const Center(
                  child: Text(
                    'No habits yet.\nTap + to add your first one!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: _habits.length,
                  itemBuilder: (context, index) {
                    final habit = _habits[index];
                    return HabitTile(
                      habit: habit,
                      onToggle: () => _toggleHabit(habit),
                      onDelete: () => _deleteHabit(habit),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addHabitDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
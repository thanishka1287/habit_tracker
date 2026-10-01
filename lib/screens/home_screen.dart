import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import '../services/habit_storage.dart';
import '../widgets/habit_tile.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool darkMode;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.darkMode,
    required this.onToggleTheme,
  });

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

  static const List<IconData> _icons = [
    Icons.star,
    Icons.fitness_center,
    Icons.menu_book,
    Icons.bedtime,
    Icons.self_improvement,
    Icons.local_drink,
    Icons.directions_run,
    Icons.restaurant,
    Icons.eco,
    Icons.alarm,
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

  Future<bool> _confirmDelete(Habit habit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete habit?'),
        content: Text('"${habit.name}" and its history will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  bool _isDuplicateName(String name, {Habit? excluding}) {
    final lower = name.toLowerCase();
    return _habits.any((h) =>
        h.name.toLowerCase() == lower && h.id != excluding?.id);
  }

  Future<void> _habitFormDialog({Habit? existing}) async {
    final controller = TextEditingController(text: existing?.name ?? '');
    int selectedColor = existing?.colorValue ?? _colors.first;
    int selectedIcon = existing?.iconCodePoint ?? _icons.first.codePoint;
    final isEditing = existing != null;
    String? errorText;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Habit' : 'New Habit'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller,
                  autofocus: true,
                  maxLength: 40,
                  decoration: InputDecoration(
                    hintText: 'e.g. Drink water',
                    errorText: errorText,
                  ),
                  onChanged: (_) => setDialogState(() => errorText = null),
                ),
                const SizedBox(height: 8),
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
                const SizedBox(height: 16),
                const Text('Pick an icon'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _icons.map((iconData) {
                    final isSelected = selectedIcon == iconData.codePoint;
                    return GestureDetector(
                      onTap: () => setDialogState(
                          () => selectedIcon = iconData.codePoint),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: isSelected
                            ? Color(selectedColor)
                            : Colors.grey.shade300,
                        child: Icon(
                          iconData,
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                          size: 20,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isEmpty) {
                  setDialogState(() => errorText = 'Enter a habit name');
                  return;
                }
                if (_isDuplicateName(name, excluding: existing)) {
                  setDialogState(
                      () => errorText = 'You already have this habit');
                  return;
                }
                Navigator.pop(context, {
                  'name': name,
                  'color': selectedColor,
                  'icon': selectedIcon,
                });
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() {
        if (isEditing) {
          existing.name = result['name'] as String;
          existing.colorValue = result['color'] as int;
          existing.iconCodePoint = result['icon'] as int;
        } else {
          _habits.add(Habit(
            id: _uuid.v4(),
            name: result['name'] as String,
            colorValue: result['color'] as int,
            iconCodePoint: result['icon'] as int,
          ));
        }
      });
      _saveHabits();
    }
  }

  Widget _buildSummary() {
    final total = _habits.length;
    final done = _habits.where((h) => h.isDoneToday()).length;
    final allDone = total > 0 && done == total;

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              allDone ? 'All done for today! 🎉' : "Today's progress",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: total == 0 ? 0 : done / total,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              '$done of $total habits completed',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StatsScreen(habits: _habits),
              ),
            ),
          ),
          IconButton(
            icon: Icon(widget.darkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _habits.isEmpty
              ? const Center(
                  child: Text(
                    'No habits yet.\nTap + to add your first one!\n(Swipe left on a habit to delete it)',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: _habits.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) return _buildSummary();
                    final habit = _habits[index - 1];
                    return HabitTile(
                      habit: habit,
                      onToggle: () => _toggleHabit(habit),
                      onDelete: () => _deleteHabit(habit),
                      onEdit: () => _habitFormDialog(existing: habit),
                      confirmDismiss: () => _confirmDelete(habit),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _habitFormDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
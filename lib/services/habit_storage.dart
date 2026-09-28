import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';

/// Handles saving/loading the habit list to on-device storage
/// so data survives app restarts.
class HabitStorage {
  static const _key = 'habits';

  static Future<List<Habit>> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];
    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.map((e) => Habit.fromJson(e)).toList();
  }

  static Future<void> saveHabits(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(habits.map((h) => h.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }
}

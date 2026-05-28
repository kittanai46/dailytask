import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/note.dart';
import '../models/shopping_item.dart';
import '../models/budget.dart';

class StorageService {
  static const _tasksKey = 'tasks';
  static const _notesKey = 'notes';
  static const _shoppingKey = 'shopping_items';
  static const _budgetsKey = 'budgets';

  // Tasks
  static Future<List<Task>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_tasksKey);
    if (str == null) return [];
    return (jsonDecode(str) as List)
        .map((e) => Task.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _tasksKey,
      jsonEncode(tasks.map((e) => e.toJson()).toList()),
    );
  }

  // Notes
  static Future<List<Note>> getNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_notesKey);
    if (str == null) return [];
    return (jsonDecode(str) as List)
        .map((e) => Note.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _notesKey,
      jsonEncode(notes.map((e) => e.toJson()).toList()),
    );
  }

  // Shopping
  static Future<List<ShoppingItem>> getShoppingItems() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_shoppingKey);
    if (str == null) return [];
    return (jsonDecode(str) as List)
        .map((e) => ShoppingItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveShoppingItems(List<ShoppingItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _shoppingKey,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  // Budgets
  static Future<List<Budget>> getBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_budgetsKey);
    if (str == null) return [];
    return (jsonDecode(str) as List)
        .map((e) => Budget.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveBudgets(List<Budget> budgets) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _budgetsKey,
      jsonEncode(budgets.map((e) => e.toJson()).toList()),
    );
  }
}

import 'package:uuid/uuid.dart';

class SubTask {
  final String id;
  String title;
  bool isCompleted;

  SubTask({
    String? id,
    required this.title,
    this.isCompleted = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
      };

  factory SubTask.fromJson(Map<String, dynamic> json) => SubTask(
        id: json['id'] as String,
        title: json['title'] as String,
        isCompleted: json['isCompleted'] as bool? ?? false,
      );
}

class Task {
  final String id;
  String title;
  String description;
  DateTime date;
  bool isCompleted;
  int? iconCode;
  int iconColor;
  String? imagePath;
  List<SubTask> subtasks;

  Task({
    String? id,
    required this.title,
    this.description = '',
    required this.date,
    this.isCompleted = false,
    this.iconCode,
    this.iconColor = 0xFF1565C0,
    this.imagePath,
    List<SubTask>? subtasks,
  })  : id = id ?? const Uuid().v4(),
        subtasks = subtasks ?? [];

  double get progress {
    if (subtasks.isEmpty) return isCompleted ? 1.0 : 0.0;
    return subtasks.where((s) => s.isCompleted).length / subtasks.length;
  }

  int get completedSubtasks => subtasks.where((s) => s.isCompleted).length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'date': date.toIso8601String(),
        'isCompleted': isCompleted,
        'iconCode': iconCode,
        'iconColor': iconColor,
        'imagePath': imagePath,
        'subtasks': subtasks.map((s) => s.toJson()).toList(),
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        date: DateTime.parse(json['date'] as String),
        isCompleted: json['isCompleted'] as bool? ?? false,
        iconCode: json['iconCode'] as int?,
        iconColor: json['iconColor'] as int? ?? 0xFF1565C0,
        imagePath: json['imagePath'] as String?,
        subtasks: (json['subtasks'] as List<dynamic>?)
                ?.map((e) => SubTask.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

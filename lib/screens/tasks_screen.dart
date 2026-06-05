// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../models/task.dart';
import '../services/storage_service.dart';

// ─── Presets ──────────────────────────────────────────────────────────────────

const _kTaskIcons = <IconData?>[
  null,
  Icons.task_alt,
  Icons.star_rounded,
  Icons.favorite_rounded,
  Icons.work_rounded,
  Icons.home_rounded,
  Icons.school_rounded,
  Icons.shopping_cart_rounded,
  Icons.fitness_center_rounded,
  Icons.code_rounded,
  Icons.brush_rounded,
  Icons.music_note_rounded,
  Icons.directions_run,
  Icons.restaurant_rounded,
  Icons.local_hospital_rounded,
  Icons.flight_rounded,
  Icons.phone_rounded,
  Icons.email_rounded,
  Icons.event_rounded,
  Icons.alarm_rounded,
  Icons.flag_rounded,
  Icons.bookmark_rounded,
  Icons.lightbulb_rounded,
  Icons.psychology_rounded,
  Icons.sports_esports_rounded,
];

const _kIconColors = <Color>[
  Color(0xFF1565C0),
  Color(0xFF0D47A1),
  Color(0xFF7B1FA2),
  Color(0xFFC62828),
  Color(0xFFE65100),
  Color(0xFF2E7D32),
  Color(0xFF00695C),
  Color(0xFF37474F),
  Color(0xFFFF8F00),
  Color(0xFF6D4C41),
  Color(0xFFAD1457),
  Color(0xFF283593),
];

// ─── Helpers ──────────────────────────────────────────────────────────────────

String _dayLabel(DateTime date) {
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  final d = DateTime(date.year, date.month, date.day);
  final diff = d.difference(todayDate).inDays;
  if (diff == 0) return 'วันนี้';
  if (diff == -1) return 'เมื่อวาน';
  if (diff == 1) return 'พรุ่งนี้';
  const thDays = [
    'จันทร์', 'อังคาร', 'พุธ', 'พฤหัสบดี', 'ศุกร์', 'เสาร์', 'อาทิตย์'
  ];
  const thMonths = [
    'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
    'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
  ];
  final beYear = date.year + 543;
  return 'วัน${thDays[date.weekday - 1]}ที่ ${date.day} ${thMonths[date.month - 1]} $beYear';
}

String _shortDateLabel(DateTime date) {
  const thMonths = [
    'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
    'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
  ];
  final beYear = date.year + 543;
  return '${date.day} ${thMonths[date.month - 1]} $beYear';
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

IconData _taskIconFromCode(int? code) {
  if (code == null) return Icons.task_alt;
  return _kTaskIcons
      .whereType<IconData>()
      .firstWhere((i) => i.codePoint == code, orElse: () => Icons.task_alt);
}

// ─── TasksScreen ──────────────────────────────────────────────────────────────

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  List<Task> _tasks = [];
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final tasks = await StorageService.getTasks();
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  Future<void> _saveTasks() async {
    await StorageService.saveTasks(_tasks);
  }

  void _toggleTask(Task task) {
    HapticFeedback.lightImpact();
    setState(() {
      if (task.subtasks.isNotEmpty) {
        final allDone = task.subtasks.every((s) => s.isCompleted);
        for (final s in task.subtasks) {
          s.isCompleted = !allDone;
        }
        task.isCompleted = !allDone;
      } else {
        task.isCompleted = !task.isCompleted;
      }
    });
    _saveTasks();
  }

  void _toggleSubtask(Task task, SubTask subtask) {
    HapticFeedback.selectionClick();
    setState(() {
      subtask.isCompleted = !subtask.isCompleted;
      if (task.subtasks.isNotEmpty) {
        task.isCompleted = task.subtasks.every((s) => s.isCompleted);
      }
    });
    _saveTasks();
  }

  void _deleteTask(Task task) {
    final removed = task;
    final idx = _tasks.indexOf(task);
    setState(() => _tasks.removeWhere((t) => t.id == task.id));
    _saveTasks();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ลบ "${removed.title}" แล้ว'),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'เลิกทำ',
          onPressed: () {
            setState(() {
              _tasks.insert(idx.clamp(0, _tasks.length), removed);
            });
            _saveTasks();
          },
        ),
      ),
    );
  }

  Future<void> _openEditor({Task? editTask}) async {
    final result = await Navigator.push<Task>(
      context,
      MaterialPageRoute(
        builder: (_) => _TaskEditorSheet(editTask: editTask),
      ),
    );
    if (result == null) return;
    setState(() {
      if (editTask != null) {
        final idx = _tasks.indexWhere((t) => t.id == editTask.id);
        if (idx != -1) _tasks[idx] = result;
      } else {
        _tasks.add(result);
      }
    });
    _saveTasks();
  }

  // ─── Task detail bottom sheet ──────────────────────────────────────────────

  void _showTaskDetail(Task task) {
    final iconColor = Color(task.iconColor);
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) {
          final isDone = task.isCompleted;
          final completedCount = task.subtasks.where((s) => s.isCompleted).length;
          final total = task.subtasks.length;

          return DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.35,
            maxChildSize: 0.90,
            expand: false,
            builder: (ctx2, scrollCtrl) => Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // drag handle
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 4),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // content
                  Expanded(
                    child: ListView(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      children: [
                        // icon + title + checkbox row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: isDone
                                    ? Colors.green.shade50
                                    : iconColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: task.imagePath != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.file(File(task.imagePath!),
                                          fit: BoxFit.cover))
                                  : Icon(
                                      _taskIconFromCode(task.iconCode),
                                      size: 26,
                                      color: isDone
                                          ? Colors.green.shade400
                                          : iconColor,
                                    ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDone
                                          ? Colors.grey.shade400
                                          : cs.onSurface,
                                      decoration: isDone
                                          ? TextDecoration.lineThrough
                                          : null,
                                      decorationColor: Colors.grey.shade400,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(children: [
                                    Icon(Icons.calendar_today_rounded,
                                        size: 13, color: Colors.grey.shade400),
                                    const SizedBox(width: 4),
                                    Text(
                                      _dayLabel(task.date),
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade500),
                                    ),
                                  ]),
                                ],
                              ),
                            ),
                            // ── main task checkbox ──
                            GestureDetector(
                              onTap: () {
                                _toggleTask(task);
                                setLocal(() {});
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDone ? Colors.green : Colors.transparent,
                                  border: Border.all(
                                    color: isDone ? Colors.green : Colors.grey.shade300,
                                    width: 2,
                                  ),
                                  boxShadow: isDone
                                      ? [BoxShadow(
                                          color: Colors.green.withOpacity(0.3),
                                          blurRadius: 6)]
                                      : null,
                                ),
                                child: isDone
                                    ? const Icon(Icons.check_rounded,
                                        size: 17, color: Colors.white)
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        // description
                        if (task.description.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Icon(Icons.notes_rounded,
                                      size: 14, color: Colors.grey.shade400),
                                  const SizedBox(width: 6),
                                  Text('รายละเอียด',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade500)),
                                ]),
                                const SizedBox(height: 8),
                                Text(
                                  task.description,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: cs.onSurface,
                                      height: 1.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                        // subtasks
                        if (task.subtasks.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Row(children: [
                            Icon(Icons.checklist_rounded,
                                size: 14, color: Colors.grey.shade400),
                            const SizedBox(width: 6),
                            Text('งานย่อย',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade500)),
                            const SizedBox(width: 6),
                            Text(
                              '$completedCount/$total',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: completedCount == total
                                      ? Colors.green
                                      : const Color(0xFF4F46E5),
                                  fontWeight: FontWeight.w600),
                            ),
                          ]),
                          const SizedBox(height: 8),
                          ...task.subtasks.map((sub) => InkWell(
                                onTap: () {
                                  _toggleSubtask(task, sub);
                                  setLocal(() {});
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 4),
                                  child: Row(children: [
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: sub.isCompleted
                                            ? Colors.green
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: sub.isCompleted
                                              ? Colors.green
                                              : Colors.grey.shade300,
                                          width: 1.5,
                                        ),
                                        boxShadow: sub.isCompleted
                                            ? [BoxShadow(
                                                color: Colors.green
                                                    .withOpacity(0.25),
                                                blurRadius: 4)]
                                            : null,
                                      ),
                                      child: sub.isCompleted
                                          ? const Icon(Icons.check_rounded,
                                              size: 13, color: Colors.white)
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        sub.title,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: sub.isCompleted
                                              ? Colors.grey.shade400
                                              : cs.onSurface,
                                          decoration: sub.isCompleted
                                              ? TextDecoration.lineThrough
                                              : null,
                                          decorationColor:
                                              Colors.grey.shade400,
                                        ),
                                      ),
                                    ),
                                  ]),
                                ),
                              )),
                        ],
                        const SizedBox(height: 24),
                        // action buttons
                        Row(children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(ctx2);
                                _openEditor(editTask: task);
                              },
                              icon: const Icon(Icons.edit_rounded, size: 16),
                              label: const Text('แก้ไข'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF1565C0),
                                side: const BorderSide(
                                    color: Color(0xFF1565C0)),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => Navigator.pop(ctx2),
                              icon:
                                  const Icon(Icons.close_rounded, size: 16),
                              label: const Text('ปิด'),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF1565C0),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Daily view ────────────────────────────────────────────────────────────

  Widget _buildDailyView() {
    if (_tasks.isEmpty) return _buildEmptyState();
    final groups = <DateTime, List<Task>>{};
    for (final t in _tasks) {
      final key = DateTime(t.date.year, t.date.month, t.date.day);
      groups.putIfAbsent(key, () => []).add(t);
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dates = groups.keys.toList()
      ..sort((a, b) {
        if (a == today) return -1;
        if (b == today) return 1;
        final aFuture = a.isAfter(today);
        final bFuture = b.isAfter(today);
        if (aFuture && bFuture) return a.compareTo(b);
        if (!aFuture && !bFuture) return b.compareTo(a);
        return aFuture ? -1 : 1;
      });

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: dates.length,
      itemBuilder: (ctx, i) {
        final date = dates[i];
        final dayTasks = groups[date]!
          ..sort((a, b) => a.isCompleted == b.isCompleted
              ? 0
              : a.isCompleted
                  ? 1
                  : -1);
        final isToday = date == today;
        final doneCount = dayTasks.where((t) => t.isCompleted).length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 8),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: isToday
                        ? const Color(0xFF1565C0)
                        : Theme.of(ctx).colorScheme.primaryContainer.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _dayLabel(date),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color:
                          isToday ? Colors.white : Theme.of(ctx).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$doneCount/${dayTasks.length} เสร็จ',
                  style:
                      TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ]),
            ),
            ...dayTasks.map((task) => _TaskCard(
                  task: task,
                  onToggle: () => _toggleTask(task),
                  onSubtaskToggle: (s) => _toggleSubtask(task, s),
                  onDetail: () => _showTaskDetail(task),
                  onEdit: () => _openEditor(editTask: task),
                  onDelete: () => _deleteTask(task),
                )),
          ],
        );
      },
    );
  }

  // ─── All view ──────────────────────────────────────────────────────────────

  Widget _buildAllView() {
    if (_tasks.isEmpty) return _buildEmptyState();
    final incomplete = _tasks.where((t) => !t.isCompleted).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final complete = _tasks.where((t) => t.isCompleted).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final sorted = [...incomplete, ...complete];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: sorted.length,
      itemBuilder: (ctx, i) {
        final task = sorted[i];
        return _TaskCard(
          task: task,
          onToggle: () => _toggleTask(task),
          onSubtaskToggle: (s) => _toggleSubtask(task, s),
          onDetail: () => _showTaskDetail(task),
          onEdit: () => _openEditor(editTask: task),
          onDelete: () => _deleteTask(task),
          showDate: true,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.task_alt,
                size: 40, color: Color(0xFF818CF8)),
          ),
          const SizedBox(height: 16),
          const Text('ยังไม่มีงาน',
              style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          const Text('กด + เพิ่มงาน เพื่อสร้างงานใหม่',
              style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayTasks = _tasks.where((t) =>
        t.date.year == now.year &&
        t.date.month == now.month &&
        t.date.day == now.day);
    final todayDone = todayTasks.where((t) => t.isCompleted).length;
    final todayTotal = todayTasks.length;
    final allDone = _tasks.where((t) => t.isCompleted).length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        titleSpacing: 16,
        title: const Text(
          'จดบันทึกงาน',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            labelStyle: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w400),
            tabs: [
              _buildTab('รายวัน', todayDone, todayTotal),
              _buildTab('ทั้งหมด', allDone, _tasks.length),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDailyView(),
                _buildAllView(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'tasks_fab',
        onPressed: () => _openEditor(),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text('เพิ่มงาน',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Tab _buildTab(String label, int done, int total) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (total > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$done/$total',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Task Card ────────────────────────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.onToggle,
    required this.onSubtaskToggle,
    required this.onDetail,
    required this.onEdit,
    required this.onDelete,
    this.showDate = false,
  });

  final Task task;
  final VoidCallback onToggle;
  final void Function(SubTask) onSubtaskToggle;
  final VoidCallback onDetail;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final isDone = task.isCompleted;
    final iconColor = Color(task.iconColor);
    final hasSubtasks = task.subtasks.isNotEmpty;
    final progress = task.progress;
    final completedCount = task.completedSubtasks;

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('ลบงานนี้?'),
            content: Text('"${task.title}"'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('ยกเลิก'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('ลบ'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_rounded, color: Colors.white, size: 24),
            SizedBox(height: 2),
            Text('ลบ',
                style: TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onDetail,
              onLongPress: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          task.title,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          tileColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                          leading: const Icon(Icons.edit_rounded,
                              color: Color(0xFF1565C0)),
                          title: const Text('แก้ไขงาน',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1565C0))),
                          onTap: () {
                            Navigator.pop(ctx);
                            onEdit();
                          },
                        ),
                        const SizedBox(height: 8),
                        ListTile(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          tileColor: Colors.red.shade50,
                          leading: Icon(Icons.delete_rounded,
                              color: Colors.red.shade400),
                          title: Text('ลบงาน',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red.shade400)),
                          onTap: () async {
                            Navigator.pop(ctx);
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (d) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                title: const Text('ลบงานนี้?'),
                                content: Text('"${task.title}"'),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(d, false),
                                      child: const Text('ยกเลิก')),
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(d, true),
                                      style: TextButton.styleFrom(
                                          foregroundColor: Colors.red),
                                      child: const Text('ลบ')),
                                ],
                              ),
                            );
                            if (confirm == true) onDelete();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        14, 12, 4, hasSubtasks ? 8 : 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ─── Decorative icon ────────────────────
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDone
                                ? Colors.green.shade50
                                : iconColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: task.imagePath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(task.imagePath!),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(
                                  _taskIconFromCode(task.iconCode),
                                  size: 22,
                                  color: isDone
                                      ? Colors.green.shade400
                                      : iconColor,
                                ),
                        ),
                        const SizedBox(width: 12),
                        // ─── Content ────────────────────────────
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isDone
                                      ? Colors.grey.shade400
                                      : Theme.of(context).colorScheme.onSurface,
                                  decoration: isDone
                                      ? TextDecoration.lineThrough
                                      : null,
                                  decorationColor: Colors.grey.shade400,
                                ),
                              ),
                              if (task.description.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  task.description,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              if (hasSubtasks) ...[
                                const SizedBox(height: 7),
                                Row(children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        minHeight: 5,
                                        backgroundColor:
                                            Colors.grey.shade200,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          progress >= 1.0
                                              ? Colors.green
                                              : iconColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$completedCount/${task.subtasks.length} (${(progress * 100).round()}%)',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ]),
                              ],
                              if (showDate) ...[
                                const SizedBox(height: 4),
                                Row(children: [
                                  Icon(Icons.calendar_today_outlined,
                                      size: 11,
                                      color: Colors.grey.shade400),
                                  const SizedBox(width: 3),
                                  Text(
                                    _shortDateLabel(task.date),
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade400),
                                  ),
                                ]),
                              ],
                            ],
                          ),
                        ),
                        // ─── Checkbox button (44×44 tap area) ───
                        GestureDetector(
                          onTap: onToggle,
                          behavior: HitTestBehavior.opaque,
                          child: SizedBox(
                            width: 44,
                            height: 44,
                            child: Center(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDone
                                      ? Colors.green
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isDone
                                        ? Colors.green
                                        : Colors.grey.shade300,
                                    width: 2,
                                  ),
                                  boxShadow: isDone
                                      ? [
                                          BoxShadow(
                                              color: Colors.green
                                                  .withOpacity(0.3),
                                              blurRadius: 6)
                                        ]
                                      : null,
                                ),
                                child: isDone
                                    ? const Icon(Icons.check_rounded,
                                        size: 15, color: Colors.white)
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ─── Subtask list ──────────────────────────────
                  if (hasSubtasks) ...[
                    Divider(
                        height: 1,
                        indent: 14,
                        endIndent: 14,
                        color: Colors.grey.shade100),
                    ...task.subtasks.map((sub) {
                      final isLast = sub == task.subtasks.last;
                      return InkWell(
                        onTap: onDetail,
                        borderRadius: isLast
                            ? const BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              )
                            : BorderRadius.zero,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                              14, 11, 14, 11),
                          child: Row(children: [
                            const SizedBox(width: 56),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: sub.isCompleted
                                    ? Colors.green
                                    : Colors.transparent,
                                border: Border.all(
                                  color: sub.isCompleted
                                      ? Colors.green
                                      : Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                              child: sub.isCompleted
                                  ? const Icon(Icons.check_rounded,
                                      size: 11, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                sub.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: sub.isCompleted
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade700,
                                  decoration: sub.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  decorationColor: Colors.grey.shade400,
                                ),
                              ),
                            ),
                          ]),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Task Editor Sheet ────────────────────────────────────────────────────────

class _TaskEditorSheet extends StatefulWidget {
  const _TaskEditorSheet({this.editTask});
  final Task? editTask;

  @override
  State<_TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends State<_TaskEditorSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  int? _iconCode;
  int _iconColorValue = 0xFF1565C0;
  String? _imagePath;
  bool _useImage = false;
  final List<SubTask> _subtasks = [];
  final List<TextEditingController> _subCtrls = [];

  @override
  void initState() {
    super.initState();
    final t = widget.editTask;
    if (t != null) {
      _titleCtrl.text = t.title;
      _descCtrl.text = t.description;
      _date = t.date;
      _iconCode = t.iconCode;
      _iconColorValue = t.iconColor;
      _imagePath = t.imagePath;
      _useImage = t.imagePath != null;
      for (final s in t.subtasks) {
        _subtasks.add(SubTask(id: s.id, title: s.title, isCompleted: s.isCompleted));
        _subCtrls.add(TextEditingController(text: s.title));
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    for (final c in _subCtrls) c.dispose();
    super.dispose();
  }

  void _addSubtask() {
    setState(() {
      _subtasks.add(SubTask(title: ''));
      _subCtrls.add(TextEditingController());
    });
  }

  void _removeSubtask(int i) {
    setState(() {
      _subtasks.removeAt(i);
      _subCtrls[i].dispose();
      _subCtrls.removeAt(i);
    });
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) return;
    setState(() {
      _imagePath = picked.path;
      _useImage = true;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      locale: const Locale('th', 'TH'),
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _showIconPicker() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 32 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'เลือกไอคอน',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (ctx, setLocal) => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _kTaskIcons.map((icon) {
                  final isSelected = icon == null
                      ? _iconCode == null
                      : _iconCode == icon.codePoint;
                  final color = Color(_iconColorValue);
                  return GestureDetector(
                    onTap: () {
                      setState(() => _iconCode = icon?.codePoint);
                      Navigator.pop(ctx);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: isSelected ? color.withOpacity(0.12) : Theme.of(context).colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? color : const Color(0xFFEEF0F4),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: icon == null
                          ? Icon(Icons.do_not_disturb_alt_rounded, size: 22, color: Colors.grey.shade300)
                          : Icon(icon, size: 26, color: isSelected ? color : const Color(0xFFB0B7C3)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('กรุณากรอกชื่องาน'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    final subtasks = _subCtrls
        .asMap()
        .entries
        .map((e) {
          final title = e.value.text.trim();
          if (title.isEmpty) return null;
          final sub = _subtasks[e.key];
          return SubTask(id: sub.id, title: title, isCompleted: sub.isCompleted);
        })
        .whereType<SubTask>()
        .toList();

    final finalIconCode = _useImage ? null : _iconCode;
    final finalImagePath = _useImage ? _imagePath : null;
    final isCompleted = subtasks.isNotEmpty
        ? subtasks.every((s) => s.isCompleted)
        : (widget.editTask?.isCompleted ?? false);

    Navigator.pop(
      context,
      Task(
        id: widget.editTask?.id,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        date: _date,
        isCompleted: isCompleted,
        iconCode: finalIconCode,
        iconColor: _iconColorValue,
        imagePath: finalImagePath,
        subtasks: subtasks,
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final iconColorObj = Color(_iconColorValue);
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final isTodaySelected = _isSameDay(_date, now);
    final isTomorrowSelected = _isSameDay(_date, tomorrow);
    final isCustomSelected = !isTodaySelected && !isTomorrowSelected;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        title: Text(
          widget.editTask == null ? 'เพิ่มงานใหม่' : 'แก้ไขงาน',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1565C0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              icon: const Icon(Icons.check_rounded, size: 16),
              label: const Text('บันทึก', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 20,
          bottom: 40 + MediaQuery.of(context).viewInsets.bottom,
        ),
        children: [
          // ── Card 1: ชื่องาน ───────────────────────────────────────
          _buildCard([
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: _cardLabel(Icons.edit_rounded, 'ชื่องาน'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: TextField(
              controller: _titleCtrl,
              autofocus: true,
              style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'ระบุชื่องาน...',
                hintStyle: const TextStyle(
                    color: Color(0xFFCBCFDA),
                    fontSize: 17,
                    fontWeight: FontWeight.w400),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
                contentPadding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            ),
          ]),
          const SizedBox(height: 10),

          // ── Card 1b: รายละเอียด ────────────────────────────────────
          _buildCard([
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: _cardLabel(Icons.notes_rounded, 'รายละเอียด'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: TextField(
              controller: _descCtrl,
              maxLines: 4,
              style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface, height: 1.5),
              decoration: InputDecoration(
                hintText: 'เพิ่มรายละเอียด หรือ หมายเหตุ...',
                hintStyle: const TextStyle(color: Color(0xFFCBCFDA), fontSize: 14),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
                contentPadding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            ),
          ]),
          const SizedBox(height: 12),

          // ── Card 2: วันที่ ──────────────────────────────────────────
          _buildCard([
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _cardLabel(Icons.calendar_today_rounded, 'วันที่'),
                  const SizedBox(height: 12),
                  Row(children: [
                    _dateChip('วันนี้', isTodaySelected,
                        () => setState(() => _date = now)),
                    const SizedBox(width: 8),
                    _dateChip('พรุ่งนี้', isTomorrowSelected,
                        () => setState(() => _date = tomorrow)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickDate,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isCustomSelected
                                ? const Color(0xFF1565C0)
                                : Theme.of(context).colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_month_rounded,
                                  size: 14,
                                  color: isCustomSelected
                                      ? Colors.white
                                      : const Color(0xFF9CA3AF)),
                              const SizedBox(width: 5),
                              Text(
                                isCustomSelected
                                    ? _shortDateLabel(_date)
                                    : 'เลือกวัน',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: isCustomSelected
                                        ? Colors.white
                                        : const Color(0xFF9CA3AF)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 12),

          // ── Card 3: ไอคอนและสี ─────────────────────────────────────
          _buildCard([
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _cardLabel(Icons.palette_outlined, 'ไอคอนและสี'),
                  const SizedBox(height: 14),
                  Row(children: [
                    // Icon/Image preview (tap to change)
                    GestureDetector(
                      onTap: _useImage ? _pickImage : _showIconPicker,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: iconColorObj.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: iconColorObj.withOpacity(0.25), width: 1.5),
                        ),
                        child: _imagePath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.file(File(_imagePath!), fit: BoxFit.cover))
                            : Icon(
                                _taskIconFromCode(_iconCode),
                                size: 30,
                                color: iconColorObj),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Toggle: ไอคอน / รูปภาพ
                          Row(children: [
                            _typeChip('ไอคอน', !_useImage, () {
                              setState(() {
                                _useImage = false;
                                _imagePath = null;
                              });
                            }),
                            const SizedBox(width: 8),
                            _typeChip('รูปภาพ', _useImage, _pickImage),
                          ]),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: _useImage ? _pickImage : _showIconPicker,
                            child: Text(
                              _useImage
                                  ? (_imagePath != null
                                      ? 'แตะเพื่อเปลี่ยนรูป'
                                      : 'แตะเพื่อเลือกรูป')
                                  : 'แตะเพื่อเปลี่ยนไอคอน',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF1565C0),
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                  if (!_useImage) ...[
                    const SizedBox(height: 14),
                    // Color swatches (horizontal scroll)
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.zero,
                        itemCount: _kIconColors.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, i) {
                          final c = _kIconColors[i];
                          final isSel = c.value == _iconColorValue;
                          return GestureDetector(
                            onTap: () => setState(() => _iconColorValue = c.value),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSel ? Colors.white : Colors.transparent,
                                  width: 2.5,
                                ),
                                boxShadow: isSel
                                    ? [BoxShadow(color: c.withOpacity(0.5), blurRadius: 6, spreadRadius: 1)]
                                    : null,
                              ),
                              child: isSel
                                  ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ]),
          const SizedBox(height: 12),

          // ── Card 4: งานย่อย ───────────────────────────────────────
          _buildCard([
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Row(children: [
                _cardLabel(Icons.checklist_rounded, 'งานย่อย'),
                if (_subtasks.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      '${_subtasks.length}',
                      style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ]),
            ),
            if (_subtasks.isNotEmpty) ...[
              const SizedBox(height: 4),
              ..._subtasks.asMap().entries.map((e) {
                final i = e.key;
                final sub = e.value;
                return Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 12, 0),
                  child: Row(children: [
                    GestureDetector(
                      onTap: () => setState(() => sub.isCompleted = !sub.isCompleted),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: sub.isCompleted ? Colors.green : Colors.transparent,
                          border: Border.all(
                            color: sub.isCompleted ? Colors.green : Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: sub.isCompleted
                            ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _subCtrls[i],
                        style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: 'งานย่อยที่ ${i + 1}',
                          hintStyle: const TextStyle(color: Color(0xFFBEC3CF), fontSize: 14),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _removeSubtask(i),
                      child: Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        child: Icon(Icons.close_rounded, size: 16, color: Colors.grey.shade400),
                      ),
                    ),
                  ]),
                );
              }),
            ],
            // Add subtask button
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: TextButton.icon(
                onPressed: _addSubtask,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('เพิ่มงานย่อย'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF1565C0),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Widget _buildCard(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      );

  Widget _cardLabel(IconData icon, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Theme.of(context).colorScheme.onSurface),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface),
          ),
        ],
      );

  Widget _dateChip(String label, bool selected, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF1565C0) : Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : Theme.of(context).colorScheme.onSurface),
          ),
        ),
      );

  Widget _typeChip(String label, bool selected, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF1565C0).withOpacity(0.1)
                : Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? const Color(0xFF1565C0) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? const Color(0xFF1565C0) : const Color(0xFF9CA3AF),
            ),
          ),
        ),
      );
}

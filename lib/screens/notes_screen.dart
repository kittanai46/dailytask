import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../services/storage_service.dart';
import 'note_detail_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Note> _notes = [];
  bool _isLoading = true;

  static const List<Color> _noteColors = [
    Color(0xFFFFFDE7), // warm yellow cream
    Color(0xFFE8F5E9), // soft mint green
    Color(0xFFE3F2FD), // soft sky blue
    Color(0xFFFCE4EC), // soft blush pink
    Color(0xFFF3E5F5), // soft lavender
    Color(0xFFFFF3E0), // soft peach
  ];

  static const List<Color> _noteAccentColors = [
    Color(0xFFFFCA28), // amber
    Color(0xFF66BB6A), // green
    Color(0xFF42A5F5), // blue
    Color(0xFFEC407A), // pink
    Color(0xFFAB47BC), // purple
    Color(0xFFFF7043), // deep orange
  ];

  static const List<Color> _noteDarkColors = [
    Color(0xFF3D3820),
    Color(0xFF1B2E1F),
    Color(0xFF1A2733),
    Color(0xFF2E1A22),
    Color(0xFF261A2E),
    Color(0xFF2E2416),
  ];

  String _getPreviewText(String content) {
    if (content.isEmpty) return '';
    try {
      if (content.trimLeft().startsWith('[')) {
        final delta = jsonDecode(content) as List;
        final buffer = StringBuffer();
        for (final op in delta) {
          if (op is Map && op['insert'] is String) {
            buffer.write(op['insert'] as String);
          }
        }
        return buffer.toString().trim();
      }
    } catch (_) {}
    return content;
  }

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await StorageService.getNotes();
    setState(() {
      _notes = notes..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      _isLoading = false;
    });
  }

  Future<void> _saveNotes() async {
    await StorageService.saveNotes(_notes);
  }

  void _addNote() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteDetailScreen(
          note: Note(title: ''),
          isNew: true,
        ),
      ),
    );
    _loadNotes();
  }

  void _openNote(Note note) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteDetailScreen(note: note, isNew: false),
      ),
    );
    _loadNotes();
  }

  void _deleteNote(Note note) {
    setState(() => _notes.removeWhere((n) => n.id == note.id));
    _saveNotes();
  }

  void _confirmDelete(Note note) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('ลบโน็ต?'),
        content: Text(
            'ต้องการลบ "${note.title.isEmpty ? 'โน็ตนี้' : note.title}" หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade400),
            onPressed: () {
              _deleteNote(note);
              Navigator.pop(context);
            },
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF7F4ED),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'โน็ตบันทึก',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
            ),
            if (!_isLoading && _notes.isNotEmpty)
              Text(
                '${_notes.length} รายการ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: isDark
                      ? Colors.white54
                      : const Color(0xFF212121).withOpacity(0.55),
                ),
              ),
          ],
        ),
        backgroundColor:
            isDark ? const Color(0xFF1E1E2C) : const Color(0xFFFFCA28),
        foregroundColor: isDark ? Colors.white : const Color(0xFF212121),
        elevation: 0,
        toolbarHeight: 60,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.07),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
              ? _buildEmptyState(isDark)
              : _buildNoteGrid(isDark),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'notes_fab',
        onPressed: _addNote,
        backgroundColor: const Color(0xFFFFCA28),
        foregroundColor: Colors.black87,
        elevation: 4,
        icon: const Icon(Icons.edit_rounded, size: 20),
        label: const Text(
          'เพิ่มโน็ต',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF2A2A2A)
                  : const Color(0xFFFFF9E6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.sticky_note_2_outlined,
              size: 54,
              color: isDark ? Colors.white24 : const Color(0xFFFFCA28),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'ยังไม่มีโน็ต',
            style: TextStyle(
              color: isDark ? Colors.white60 : const Color(0xFF757575),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'กด "เพิ่มโน็ต" เพื่อเริ่มต้น',
            style: TextStyle(
              color: isDark ? Colors.white38 : const Color(0xFFBDBDBD),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteGrid(bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.80,
      ),
      itemCount: _notes.length,
      itemBuilder: (ctx, i) {
        final note = _notes[i];
        final colorIndex = i % _noteColors.length;
        final cardColor =
            isDark ? _noteDarkColors[colorIndex] : _noteColors[colorIndex];
        final accentColor = _noteAccentColors[colorIndex];
        return _NoteCard(
          note: note,
          cardColor: cardColor,
          accentColor: accentColor,
          isDark: isDark,
          preview: _getPreviewText(note.content),
          onTap: () => _openNote(note),
          onDelete: () => _confirmDelete(note),
        );
      },
    );
  }
}

// ── Note Card ─────────────────────────────────────────────────────────────────

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.note,
    required this.cardColor,
    required this.accentColor,
    required this.isDark,
    required this.preview,
    required this.onTap,
    required this.onDelete,
  });

  final Note note;
  final Color cardColor;
  final Color accentColor;
  final bool isDark;
  final String preview;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final titleColor = isDark ? Colors.white : const Color(0xFF212121);
    final bodyColor =
        isDark ? Colors.white70 : const Color(0xFF5D5D5D);
    final dateColor =
        isDark ? Colors.white38 : const Color(0xFF9E9E9E);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(isDark ? 0.15 : 0.20),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Accent stripe
              Container(height: 5, color: accentColor),
              // Card body
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 6, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              note.title.isEmpty
                                  ? 'ไม่มีหัวเรื่อง'
                                  : note.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: titleColor,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              splashRadius: 18,
                              icon: Icon(
                                Icons.more_vert_rounded,
                                size: 16,
                                color: dateColor,
                              ),
                              onPressed: onDelete,
                              tooltip: 'ลบโน็ต',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: Text(
                          preview,
                          style: TextStyle(
                            color: bodyColor,
                            fontSize: 12.5,
                            height: 1.55,
                          ),
                          overflow: TextOverflow.fade,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Date chip
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: accentColor
                                  .withOpacity(isDark ? 0.25 : 0.18),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 9,
                                  color: isDark
                                      ? accentColor.withOpacity(0.75)
                                      : Colors.grey.shade600,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  DateFormat('dd MMM yy')
                                      .format(note.updatedAt),
                                  style: TextStyle(
                                    color: isDark
                                        ? accentColor.withOpacity(0.75)
                                        : Colors.grey.shade600,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

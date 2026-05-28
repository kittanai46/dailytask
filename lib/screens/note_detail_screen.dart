import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/storage_service.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note note;
  final bool isNew;

  const NoteDetailScreen(
      {super.key, required this.note, required this.isNew});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (widget.isNew && title.isEmpty && content.isEmpty) {
      Navigator.pop(context);
      return;
    }

    widget.note.title = title;
    widget.note.content = content;
    widget.note.updatedAt = DateTime.now();

    final notes = await StorageService.getNotes();
    if (widget.isNew) {
      notes.add(widget.note);
    } else {
      final idx = notes.indexWhere((n) => n.id == widget.note.id);
      if (idx >= 0) {
        notes[idx] = widget.note;
      } else {
        notes.add(widget.note);
      }
    }

    await StorageService.saveNotes(notes);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDE7),
      appBar: AppBar(
        title: Text(widget.isNew ? 'โน็ตใหม่' : 'แก้ไขโน็ต'),
        backgroundColor: const Color(0xFFFFFDE7),
        actions: [
          TextButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: const Text('บันทึก'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'หัวเรื่อง',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: 'เขียนบันทึกที่นี่...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(fontSize: 16, height: 1.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

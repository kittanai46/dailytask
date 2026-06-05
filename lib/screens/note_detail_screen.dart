// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:intl/intl.dart';
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
  late QuillController _quillController;
  final FocusNode _editorFocusNode = FocusNode();
  final FocusNode _viewFocusNode = FocusNode(canRequestFocus: false);
  late bool _isEditing;
  String _lastSavedContent = '';

  @override
  void initState() {
    super.initState();
    _isEditing = widget.isNew;
    _titleController = TextEditingController(text: widget.note.title);

    Document doc;
    try {
      final content = widget.note.content;
      if (content.isNotEmpty && content.trimLeft().startsWith('[')) {
        doc = Document.fromJson(jsonDecode(content) as List);
      } else if (content.isNotEmpty) {
        doc = Document()..insert(0, content);
      } else {
        doc = Document();
      }
    } catch (_) {
      doc = Document();
    }

    _quillController = QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );
    _lastSavedContent = widget.note.content;
    _quillController.addListener(_onDocumentChanged);
  }

  @override
  void dispose() {
    _quillController.removeListener(_onDocumentChanged);
    _titleController.dispose();
    _quillController.dispose();
    _editorFocusNode.dispose();
    _viewFocusNode.dispose();
    super.dispose();
  }

  // Auto-save when a checkbox is toggled in view mode
  void _onDocumentChanged() {
    if (_isEditing || widget.isNew) return;
    final current =
        jsonEncode(_quillController.document.toDelta().toJson());
    if (current == _lastSavedContent) return;
    _lastSavedContent = current;
    _autoSaveCheckbox(current);
  }

  Future<void> _autoSaveCheckbox(String newContent) async {
    widget.note.content = newContent;
    widget.note.updatedAt = DateTime.now();
    final notes = await StorageService.getNotes();
    final idx = notes.indexWhere((n) => n.id == widget.note.id);
    if (idx >= 0) {
      notes[idx] = widget.note;
      await StorageService.saveNotes(notes);
    }
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final plainText = _quillController.document.toPlainText().trim();

    if (widget.isNew && title.isEmpty && plainText.isEmpty) {
      Navigator.pop(context);
      return;
    }

    widget.note.title = title;
    widget.note.content =
        jsonEncode(_quillController.document.toDelta().toJson());
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

    if (!mounted) return;
    if (widget.isNew) {
      Navigator.pop(context);
    } else {
      setState(() => _isEditing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isEditing ? _buildEditMode(context) : _buildViewMode(context);
  }

  // ── View Mode ─────────────────────────────────────────────────────────────

  Widget _buildViewMode(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFFFDF7);
    final textColor = isDark ? Colors.white : const Color(0xFF212121);
    final appBarBg =
        isDark ? const Color(0xFF22223A) : const Color(0xFFFFCA28);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'โน็ต',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: appBarBg,
        foregroundColor: textColor,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.07),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_rounded, size: 20, color: textColor),
            onPressed: () => setState(() => _isEditing = true),
            tooltip: 'แก้ไข',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              widget.note.title.isEmpty
                  ? 'ไม่มีหัวเรื่อง'
                  : widget.note.title,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: widget.note.title.isEmpty
                    ? (isDark ? Colors.white38 : Colors.grey.shade400)
                    : textColor,
                height: 1.3,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 10),
            // Date row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2A2A3E)
                        : const Color(0xFFFFF8DC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? Colors.white12
                          : Colors.amber.withOpacity(0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 12,
                        color: isDark
                            ? Colors.amber.shade300.withOpacity(0.7)
                            : Colors.amber.shade700,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'แก้ไขล่าสุด ${DateFormat('d MMM yyyy, HH:mm').format(widget.note.updatedAt)}',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? Colors.amber.shade300.withOpacity(0.7)
                              : Colors.amber.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Divider(
                color: isDark ? Colors.white12 : Colors.grey.shade200),
            const SizedBox(height: 12),
            // Content — checkboxes tappable, text editing blocked
            QuillEditor(
                controller: _quillController,
                focusNode: _viewFocusNode,
                scrollController: ScrollController(),
                config: QuillEditorConfig(
                  expands: false,
                  padding: EdgeInsets.zero,
                  showCursor: false,
                  customStyles: DefaultStyles(
                    paragraph: DefaultTextBlockStyle(
                      TextStyle(
                        fontSize: 16,
                        height: 1.8,
                        color: isDark
                            ? Colors.white.withOpacity(0.85)
                            : const Color(0xFF3D3D3D),
                      ),
                      HorizontalSpacing.zero,
                      VerticalSpacing.zero,
                      VerticalSpacing.zero,
                      null,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'note_edit_fab',
        onPressed: () => setState(() => _isEditing = true),
        backgroundColor: const Color(0xFFFFCA28),
        foregroundColor: Colors.black87,
        elevation: 4,
        icon: const Icon(Icons.edit_rounded, size: 20),
        label: const Text(
          'แก้ไข',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
    );
  }

  // ── Edit Mode ─────────────────────────────────────────────────────────────

  Widget _buildEditMode(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFFFDF7);
    final textColor = isDark ? Colors.white : const Color(0xFF212121);
    final appBarBg =
        isDark ? const Color(0xFF22223A) : const Color(0xFFFFCA28);
    final toolbarBg =
        isDark ? const Color(0xFF2A2A3E) : const Color(0xFFFFF8DC);
    final dividerColor = isDark ? Colors.white12 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: textColor),
          onPressed: _save,
          tooltip: 'บันทึกและกลับ',
        ),
        title: Text(
          widget.isNew ? 'โน็ตใหม่' : 'แก้ไขโน็ต',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: appBarBg,
        foregroundColor: textColor,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.07),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text(
                'บันทึก',
                style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 14),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: isDark
                    ? const Color(0xFF4A4A6A)
                    : Colors.black.withOpacity(0.12),
                foregroundColor: textColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Title field
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            child: Row(
              children: [
                Icon(
                  Icons.title_rounded,
                  size: 20,
                  color: isDark
                      ? Colors.white38
                      : const Color(0xFFFFCA28),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'หัวเรื่อง',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintStyle: TextStyle(
                          color: isDark
                              ? Colors.white30
                              : const Color(0xFFBDBDBD)),
                    ),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
              height: 1,
              color: dividerColor,
              indent: 20,
              endIndent: 20),
          // Toolbar
          Container(
            margin:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: toolbarBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? Colors.white10
                    : Colors.amber.withOpacity(0.25),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _ToolBtn(
                    controller: _quillController,
                    attribute: Attribute.bold,
                    icon: Icons.format_bold_rounded,
                    tooltip: 'ตัวหนา',
                    activeColor: isDark
                        ? Colors.amber.shade300
                        : const Color(0xFFFFCA28),
                    iconColor: isDark
                        ? Colors.white70
                        : const Color(0xFF424242),
                  ),
                  _ToolBtn(
                    controller: _quillController,
                    attribute: Attribute.italic,
                    icon: Icons.format_italic_rounded,
                    tooltip: 'ตัวเอียง',
                    activeColor: isDark
                        ? Colors.amber.shade300
                        : const Color(0xFFFFCA28),
                    iconColor: isDark
                        ? Colors.white70
                        : const Color(0xFF424242),
                  ),
                  _ToolBtn(
                    controller: _quillController,
                    attribute: Attribute.underline,
                    icon: Icons.format_underlined_rounded,
                    tooltip: 'ขีดเส้นใต้',
                    activeColor: isDark
                        ? Colors.amber.shade300
                        : const Color(0xFFFFCA28),
                    iconColor: isDark
                        ? Colors.white70
                        : const Color(0xFF424242),
                  ),
                  _ToolBtn(
                    controller: _quillController,
                    attribute: Attribute.strikeThrough,
                    icon: Icons.strikethrough_s_rounded,
                    tooltip: 'ขีดทับ',
                    activeColor: isDark
                        ? Colors.amber.shade300
                        : const Color(0xFFFFCA28),
                    iconColor: isDark
                        ? Colors.white70
                        : const Color(0xFF424242),
                  ),
                  _Divider(isDark: isDark),
                  _ToolBtn(
                    controller: _quillController,
                    attribute: Attribute.ul,
                    icon: Icons.format_list_bulleted_rounded,
                    tooltip: 'รายการหัวข้อ',
                    activeColor: isDark
                        ? Colors.green.shade300
                        : const Color(0xFFA5D6A7),
                    iconColor: isDark
                        ? Colors.white70
                        : const Color(0xFF424242),
                  ),
                  _ToolBtn(
                    controller: _quillController,
                    attribute: Attribute.ol,
                    icon: Icons.format_list_numbered_rounded,
                    tooltip: 'รายการลำดับที่',
                    activeColor: isDark
                        ? Colors.green.shade300
                        : const Color(0xFFA5D6A7),
                    iconColor: isDark
                        ? Colors.white70
                        : const Color(0xFF424242),
                  ),
                  _ToolBtn(
                    controller: _quillController,
                    attribute: Attribute.blockQuote,
                    icon: Icons.format_quote_rounded,
                    tooltip: 'อ้างอิง',
                    activeColor: isDark
                        ? Colors.green.shade300
                        : const Color(0xFFA5D6A7),
                    iconColor: isDark
                        ? Colors.white70
                        : const Color(0xFF424242),
                  ),
                  _Divider(isDark: isDark),
                  _HeaderBtn(
                    controller: _quillController,
                    level: 1,
                    isDark: isDark,
                  ),
                  _HeaderBtn(
                    controller: _quillController,
                    level: 2,
                    isDark: isDark,
                  ),
                  _Divider(isDark: isDark),
                  IconButton(
                    icon: Icon(
                      Icons.format_clear_rounded,
                      size: 20,
                      color: isDark
                          ? Colors.white54
                          : Colors.grey.shade500,
                    ),
                    tooltip: 'ล้างรูปแบบ',
                    onPressed: () {
                      _quillController.formatSelection(
                          Attribute.clone(Attribute.bold, null));
                      _quillController.formatSelection(
                          Attribute.clone(Attribute.italic, null));
                      _quillController.formatSelection(
                          Attribute.clone(Attribute.underline, null));
                      _quillController.formatSelection(
                          Attribute.clone(Attribute.strikeThrough, null));
                    },
                    splashRadius: 20,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                        minWidth: 36, minHeight: 36),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: dividerColor),
          // Editor
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 4),
              child: QuillEditor(
                controller: _quillController,
                focusNode: _editorFocusNode,
                scrollController: ScrollController(),
                config: QuillEditorConfig(
                  placeholder: 'เขียนบันทึกที่นี่...',
                  expands: false,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  customStyles: DefaultStyles(
                    paragraph: DefaultTextBlockStyle(
                      TextStyle(
                        fontSize: 16,
                        height: 1.75,
                        color: textColor,
                      ),
                      HorizontalSpacing.zero,
                      VerticalSpacing.zero,
                      VerticalSpacing.zero,
                      null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Toolbar helper widgets ────────────────────────────────────────────────────

class _ToolBtn extends StatefulWidget {
  const _ToolBtn({
    required this.controller,
    required this.attribute,
    required this.icon,
    required this.tooltip,
    required this.activeColor,
    required this.iconColor,
  });

  final QuillController controller;
  final Attribute attribute;
  final IconData icon;
  final String tooltip;
  final Color activeColor;
  final Color iconColor;

  @override
  State<_ToolBtn> createState() => _ToolBtnState();
}

class _ToolBtnState extends State<_ToolBtn> {
  bool _active = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    _updateActive();
  }

  void _onControllerChanged() => _updateActive();

  void _updateActive() {
    final style = widget.controller.getSelectionStyle();
    final isActive = style.containsKey(widget.attribute.key);
    if (isActive != _active) setState(() => _active = isActive);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTap: () {
          widget.controller.formatSelection(
            _active
                ? Attribute.clone(widget.attribute, null)
                : widget.attribute,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _active ? widget.activeColor.withValues(alpha: 0.85) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            widget.icon,
            size: 20,
            color: _active ? Colors.black87 : widget.iconColor,
          ),
        ),
      ),
    );
  }
}

class _HeaderBtn extends StatefulWidget {
  const _HeaderBtn({
    required this.controller,
    required this.level,
    required this.isDark,
  });

  final QuillController controller;
  final int level;
  final bool isDark;

  @override
  State<_HeaderBtn> createState() => _HeaderBtnState();
}

class _HeaderBtnState extends State<_HeaderBtn> {
  bool _active = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
    _update();
  }

  void _onChanged() => _update();

  void _update() {
    final style = widget.controller.getSelectionStyle();
    final val = style.attributes[Attribute.header.key]?.value;
    final isActive = val == widget.level;
    if (isActive != _active) setState(() => _active = isActive);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.isDark
        ? Colors.blue.shade200
        : const Color(0xFFBBDEFB);
    final inactiveColor = widget.isDark ? Colors.white70 : const Color(0xFF424242);

    return Tooltip(
      message: 'หัวข้อระดับ ${widget.level}',
      child: GestureDetector(
        onTap: () {
          final attr = widget.level == 1 ? Attribute.h1 : Attribute.h2;
          widget.controller.formatSelection(
            _active ? Attribute.clone(Attribute.header, null) : attr,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: _active ? activeColor.withValues(alpha: 0.85) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'H${widget.level}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _active ? Colors.black87 : inactiveColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      color: isDark ? Colors.white12 : Colors.grey.shade300,
    );
  }
}

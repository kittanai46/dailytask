// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// ─── Presets ──────────────────────────────────────────────────────────────────

const _kTextColors = <Color>[
  Color(0xFFFFFFFF), Color(0xFFF5F5F5), Color(0xFF000000), Color(0xFF212121),
  Color(0xFFFFD54F), Color(0xFFFFB74D), Color(0xFF80DEEA), Color(0xFF4FC3F7),
  Color(0xFFA5D6A7), Color(0xFFEF9A9A), Color(0xFFCE93D8), Color(0xFFFFCC80),
];

const _kBgColors = <Color>[
  Color(0xFF1565C0), Color(0xFF0D47A1), Color(0xFF283593), Color(0xFF1B5E20),
  Color(0xFF2E7D32), Color(0xFF4A148C), Color(0xFF6A1B9A), Color(0xFF880E4F),
  Color(0xFFBF360C), Color(0xFFE65100), Color(0xFF37474F), Color(0xFF263238),
  Color(0xFF311B92), Color(0xFF004D40), Color(0xFF1A237E), Color(0xFF6D4C41),
  Color(0xFFF57F17), Color(0xFF00695C), Color(0xFF4E342E), Color(0xFF424242),
];

const kDecorIcons = <IconData?>[
  null,
  Icons.auto_awesome,
  Icons.star_rounded,
  Icons.favorite_rounded,
  Icons.bolt,
  Icons.local_fire_department,
  Icons.emoji_events,
  Icons.rocket_launch,
  Icons.celebration,
  Icons.self_improvement,
  Icons.flag_rounded,
  Icons.bookmark_rounded,
  Icons.eco_rounded,
  Icons.wb_sunny_rounded,
  Icons.nights_stay_rounded,
  Icons.military_tech,
  Icons.workspace_premium,
  Icons.psychology,
  Icons.diamond,
  Icons.sports_score,
  Icons.spa_rounded,
  Icons.whatshot_rounded,
  Icons.emoji_nature_rounded,
  Icons.emoji_objects,
  Icons.emoji_food_beverage,
];

const _kFontSizes = <(String, double)>[
  ('เล็ก', 14),
  ('กลาง', 18),
  ('ใหญ่', 22),
  ('ใหญ่มาก', 26),
];

// ─── BannerEditorScreen ───────────────────────────────────────────────────────

class BannerEditorScreen extends StatefulWidget {
  const BannerEditorScreen({
    super.key,
    required this.initialTitle,
    required this.initialSubtitle,
    required this.initialTextColor,
    required this.initialIconColor,
    required this.initialTextStrokeColor,
    required this.initialTitleSize,
    required this.initialIsBold,
    required this.initialBgColor,
    required this.initialDecorIconCode,
    required this.initialImagePath,
    required this.initialImageAlignX,
    required this.initialImageAlignY,
    required this.initialImageDim,
  });

  final String initialTitle;
  final String initialSubtitle;
  final int initialTextColor;
  final int initialIconColor;
  final int? initialTextStrokeColor;
  final double initialTitleSize;
  final bool initialIsBold;
  final int initialBgColor;
  final int? initialDecorIconCode;
  final String? initialImagePath;
  final double initialImageAlignX;
  final double initialImageAlignY;
  final double initialImageDim;

  @override
  State<BannerEditorScreen> createState() => _BannerEditorState();
}

// ─── State notifier ───────────────────────────────────────────────────────────

class _BannerEditorNotifier extends ChangeNotifier {
  _BannerEditorNotifier(BannerEditorScreen w)
      : titleCtrl = TextEditingController(text: w.initialTitle),
        subtitleCtrl = TextEditingController(text: w.initialSubtitle),
        textColor = w.initialTextColor,
        iconColor = w.initialIconColor,
        textStrokeColor = w.initialTextStrokeColor,
        titleSize = w.initialTitleSize,
        isBold = w.initialIsBold,
        bgColor = w.initialBgColor,
        decorIconCode = w.initialDecorIconCode,
        imagePath = w.initialImagePath,
        imageAlignX = w.initialImageAlignX,
        imageAlignY = w.initialImageAlignY,
        imageDim = w.initialImageDim;

  final TextEditingController titleCtrl;
  final TextEditingController subtitleCtrl;
  int textColor;
  int iconColor;
  int? textStrokeColor;
  double titleSize;
  bool isBold;
  int bgColor;
  int? decorIconCode;
  String? imagePath;
  Uint8List? imageBytes;
  double imageAlignX;
  double imageAlignY;
  double imageDim;

  Alignment get imageAlignment => Alignment(imageAlignX, imageAlignY);

  void setTextColor(int v) { textColor = v; notifyListeners(); }
  void setIconColor(int v) { iconColor = v; notifyListeners(); }
  void setTextStrokeColor(int? v) { textStrokeColor = v; notifyListeners(); }
  void setTitleSize(double v) { titleSize = v; notifyListeners(); }
  void toggleBold() { isBold = !isBold; notifyListeners(); }
  void setBgColor(int v) { bgColor = v; notifyListeners(); }
  void setDecorIconCode(int? v) { decorIconCode = v; notifyListeners(); }
  void setImage(String path, Alignment align, double dim, {Uint8List? bytes}) {
    imagePath = path;
    imageBytes = bytes;
    imageAlignX = align.x;
    imageAlignY = align.y;
    imageDim = dim;
    notifyListeners();
  }
  void updateImagePosition(Alignment align, double dim) {
    imageAlignX = align.x;
    imageAlignY = align.y;
    imageDim = dim;
    notifyListeners();
  }
  void removeImage() { imagePath = null; imageBytes = null; notifyListeners(); }

  Map<String, dynamic> get result => {
    'title': titleCtrl.text.trim(),
    'subtitle': subtitleCtrl.text.trim(),
    'textColor': textColor,
    'iconColor': iconColor,
    'textStrokeColor': textStrokeColor,
    'titleSize': titleSize,
    'isBold': isBold,
    'bgColor': bgColor,
    'decorIconCode': decorIconCode,
    'imagePath': imagePath,
    'imageAlignX': imageAlignX,
    'imageAlignY': imageAlignY,
    'imageDim': imageDim,
  };

  @override
  void dispose() {
    titleCtrl.dispose();
    subtitleCtrl.dispose();
    super.dispose();
  }
}

// ─── Widget state ─────────────────────────────────────────────────────────────

class _BannerEditorState extends State<BannerEditorScreen> {
  late final _BannerEditorNotifier _n;

  @override
  void initState() {
    super.initState();
    _n = _BannerEditorNotifier(widget);
  }

  @override
  void dispose() {
    _n.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) return;
    final bytes = await picked.readAsBytes();
    final pos = await Navigator.push<(Alignment, double)>(
      context,
      MaterialPageRoute(
        builder: (_) => _ImagePositionPicker(
          imagePath: picked.path,
          imageBytes: bytes,
          initialAlignment: _n.imageAlignment,
          initialDim: _n.imageDim,
          bannerTitle: _n.titleCtrl.text,
          bannerSubtitle: _n.subtitleCtrl.text,
        ),
      ),
    );
    if (pos == null) return;
    _n.setImage(picked.path, pos.$1, pos.$2, bytes: bytes);
  }

  Future<void> _adjustPosition() async {
    if (_n.imagePath == null || !mounted) return;
    final pos = await Navigator.push<(Alignment, double)>(
      context,
      MaterialPageRoute(
        builder: (_) => _ImagePositionPicker(
          imagePath: _n.imagePath!,
          imageBytes: _n.imageBytes,
          initialAlignment: _n.imageAlignment,
          initialDim: _n.imageDim,
          bannerTitle: _n.titleCtrl.text,
          bannerSubtitle: _n.subtitleCtrl.text,
        ),
      ),
    );
    if (pos == null) return;
    _n.updateImagePosition(pos.$1, pos.$2);
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _n,
      builder: (context, _) {
        final textColorObj = Color(_n.textColor);
        final bgColorObj = Color(_n.bgColor);
        final iconColorObj = Color(_n.iconColor);
        final strokeColorObj =
            _n.textStrokeColor != null ? Color(_n.textStrokeColor!) : null;
        final decorIcon = _n.decorIconCode != null
            ? kDecorIcons
                .whereType<IconData>()
                .firstWhere((i) => i.codePoint == _n.decorIconCode,
                    orElse: () => Icons.auto_awesome)
            : null;

        return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── App bar ───────────────────────────────────────────────
          SliverAppBar(
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            titleSpacing: 24,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 8,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      size: 15, color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
            ),
            title: Text('ออกแบบแบนเนอร์',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -0.3)),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 18),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context, _n.result),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5B6AF6), Color(0xFF8B5CF6)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5B6AF6).withOpacity(0.38),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Text('บันทึก',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            letterSpacing: 0.2)),
                  ),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Preview ─────────────────────────────────────────
                  RepaintBoundary(
                    child: ListenableBuilder(
                      listenable:
                          Listenable.merge([_n.titleCtrl, _n.subtitleCtrl]),
                      builder: (context, _) {
                        final title = _n.titleCtrl.text.trim();
                        final subtitle = _n.subtitleCtrl.text.trim();
                        final hasContent = title.isNotEmpty ||
                            subtitle.isNotEmpty ||
                            _n.imagePath != null ||
                            decorIcon != null;
                        return _buildPreview(
                            bgColorObj, textColorObj, iconColorObj,
                            strokeColorObj, decorIcon,
                            title, subtitle, hasContent);
                      },
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── ข้อความ ─────────────────────────────────────────
                  _sectionCard(
                    title: 'ข้อความ',
                    icon: Icons.title_rounded,
                    accentColor: const Color(0xFF5B6AF6),
                    child: Column(children: [
                      _textField(_n.titleCtrl, 'หัวข้อหลัก',
                          Icons.text_fields_rounded),
                      const SizedBox(height: 10),
                      _textField(_n.subtitleCtrl, 'หัวข้อรอง',
                          Icons.short_text_rounded),
                    ]),
                  ),
                  const SizedBox(height: 14),

                  // ── รูปแบบตัวอักษร ──────────────────────────────────
                  _sectionCard(
                    title: 'รูปแบบตัวอักษร',
                    icon: Icons.format_size_rounded,
                    accentColor: const Color(0xFF06B6D4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _subLabel('ขนาดตัวอักษร'),
                        const SizedBox(height: 10),
                        _fontSizeSelector(),
                        const SizedBox(height: 16),
                        _boldToggle(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── สีตัวอักษร ────────────────────────────────────
                  _sectionCard(
                    title: 'สีและไอคอน',
                    icon: Icons.palette_outlined,
                    accentColor: const Color(0xFFF59E0B),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _subLabel('สีตัวหนังสือ'),
                        const SizedBox(height: 10),
                        _colorGrid(
                          _kTextColors, _n.textColor,
                          (c) => _n.setTextColor(c.value),
                          showBorder: true,
                        ),
                        const SizedBox(height: 18),
                        _subLabel('สีขอบตัวหนังสือ'),
                        const SizedBox(height: 6),
                        Text('เพิ่มขอบให้ตัวหนังสือโดดเด่นขึ้น',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade400)),
                        const SizedBox(height: 10),
                        _strokeColorGrid(),
                        const SizedBox(height: 18),
                        _subLabel('สีไอคอนตกแต่ง'),
                        const SizedBox(height: 10),
                        _colorGrid(
                          _kTextColors, _n.iconColor,
                          (c) => _n.setIconColor(c.value),
                          showBorder: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── ไอคอนตกแต่ง ───────────────────────────────────
                  _sectionCard(
                    title: 'ไอคอนตกแต่ง',
                    icon: Icons.auto_awesome_rounded,
                    accentColor: const Color(0xFFEC4899),
                    child: _iconGrid(iconColorObj, bgColorObj),
                  ),
                  const SizedBox(height: 14),

                  // ── สีพื้นหลัง ─────────────────────────────────────
                  _sectionCard(
                    title: 'สีพื้นหลัง',
                    icon: Icons.palette_rounded,
                    accentColor: const Color(0xFF10B981),
                    child: _colorGrid(
                      _kBgColors,
                      _n.bgColor,
                      (c) => _n.setBgColor(c.value),
                    ),
                  ),
                  const SizedBox(height: 14), 

                  // ── ภาพพื้นหลัง ────────────────────────────────────
                  _sectionCard(
                    title: 'ภาพพื้นหลัง',
                    icon: Icons.image_rounded,
                    accentColor: const Color(0xFFEF4444),
                    child: _imageSection(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
      },
    );
  }

  // ─── Preview ──────────────────────────────────────────────────────────────

  Widget _buildPreview(Color bgColor, Color textColor, Color iconColor,
      Color? strokeColor, IconData? decorIcon,
      String title, String subtitle, bool hasContent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(children: [
            Container(
              width: 4,
              height: 14,
              decoration: BoxDecoration(
                  color: const Color(0xFF5B6AF6),
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 8),
            const Text('ตัวอย่าง',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5B6AF6),
                    letterSpacing: 0.3)),
          ]),
        ),
        GestureDetector(
          onTap: _n.imagePath != null ? _adjustPosition : null,
          child: Container(
            height: 172,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: bgColor,
              image: _n.imagePath != null
                  ? DecorationImage(
                      image: _n.imageBytes != null
                          ? MemoryImage(_n.imageBytes!)
                          : FileImage(File(_n.imagePath!)),
                      fit: BoxFit.cover,
                      alignment: _n.imageAlignment,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(_n.imageDim),
                        BlendMode.darken,
                      ),
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: bgColor.withOpacity(0.45),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(fit: StackFit.expand, children: [
                if (decorIcon != null)
                  Positioned(
                    right: -10,
                    bottom: -10,
                    child: Icon(decorIcon,
                        size: 110, color: iconColor.withOpacity(0.07)),
                  ),
                if (hasContent)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 18),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (decorIcon != null) ...[
                          Icon(decorIcon,
                              size: 28, color: iconColor.withOpacity(0.9)),
                          const SizedBox(height: 7),
                        ],
                        if (title.isNotEmpty)
                          _styledText(title, _n.titleSize,
                              _n.isBold ? FontWeight.bold : FontWeight.normal,
                              textColor, strokeColor),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          _styledText(subtitle, _n.titleSize * 0.68,
                              FontWeight.normal,
                              textColor.withOpacity(0.75),
                              strokeColor?.withOpacity(0.6)),
                        ],
                      ],
                    ),
                  )
                else
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.edit_outlined,
                              size: 26,
                              color: Colors.white.withOpacity(0.5)),
                        ),
                        const SizedBox(height: 10),
                        Text('กรอกข้อความหรือเลือกภาพด้านล่าง',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.45),
                                fontSize: 12,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                if (_n.imagePath != null)
                  Positioned(
                    bottom: 10,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.open_with_rounded,
                                color: Colors.white70, size: 13),
                            SizedBox(width: 4),
                            Text('ปรับตำแหน่ง',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 11)),
                          ]),
                    ),
                  ),
              ]),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Styled text with optional stroke ─────────────────────────────────────

  Widget _styledText(String text, double fontSize, FontWeight weight,
      Color fillColor, Color? strokeColor) {
    final ts = TextStyle(
      fontSize: fontSize,
      fontWeight: weight,
      height: 1.25,
    );
    if (strokeColor == null) {
      return Text(text,
          textAlign: TextAlign.center,
          style: ts.copyWith(color: fillColor));
    }
    return Stack(
      children: [
        Text(text,
            textAlign: TextAlign.center,
            style: ts.copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 2.5
                ..strokeJoin = StrokeJoin.round
                ..color = strokeColor,
            )),
        Text(text,
            textAlign: TextAlign.center,
            style: ts.copyWith(color: fillColor)),
      ],
    );
  }

  // ─── Stroke color grid (with "ไม่มี" option) ─────────────────────────────

  Widget _strokeColorGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        // "ไม่มีขอบ" option
        GestureDetector(
          onTap: () => _n.setTextStrokeColor(null),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              shape: BoxShape.circle,
              border: Border.all(
                color: _n.textStrokeColor == null
                    ? const Color(0xFF5B6AF6)
                    : Colors.grey.shade200,
                width: _n.textStrokeColor == null ? 2.5 : 1.5,
              ),
              boxShadow: _n.textStrokeColor == null
                  ? [
                      const BoxShadow(
                          color: Color(0x405B6AF6),
                          blurRadius: 8,
                          spreadRadius: 1)
                    ]
                  : null,
            ),
            child: Icon(Icons.block_rounded,
                size: 18,
                color: _n.textStrokeColor == null
                    ? const Color(0xFF5B6AF6)
                    : Colors.grey.shade300),
          ),
        ),
        // Color swatches
        ..._kTextColors.map((c) {
          final isSelected = _n.textStrokeColor == c.value;
          return GestureDetector(
            onTap: () => _n.setTextStrokeColor(c.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Colors.white
                      : Colors.grey.shade200,
                  width: isSelected ? 2.5 : 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                            color: c.withOpacity(0.55),
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: const Offset(0, 3)),
                      ]
                    : [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 1)),
                      ],
              ),
              child: isSelected
                  ? Icon(Icons.check_rounded,
                      size: 17,
                      color: c.computeLuminance() > 0.45
                          ? Colors.black87
                          : Colors.white)
                  : null,
            ),
          );
        }),
      ],
    );
  }

  // ─── Section card ──────────────────────────────────────────────────────────

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Color accentColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: accentColor),
            ),
            const SizedBox(width: 10),
            Text(title,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -0.1)),
          ]),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _subLabel(String text) => Text(text,
      style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface));

  // ─── Font size selector ────────────────────────────────────────────────────

  Widget _fontSizeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: _kFontSizes.map((item) {
          final selected = _n.titleSize == item.$2;
          return Expanded(
            child: GestureDetector(
              onTap: () => _n.setTitleSize(item.$2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: selected ? Theme.of(context).colorScheme.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2))
                        ]
                      : null,
                ),
                child: Text(item.$1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: selected
                            ? Theme.of(context).colorScheme.onSurface
                            : const Color(0xFF9CA3AF))),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Bold toggle ───────────────────────────────────────────────────────────

  Widget _boldToggle() {
    return GestureDetector(
      onTap: _n.toggleBold,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _n.isBold
              ? const Color(0xFF5B6AF6).withOpacity(0.08)
              : Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _n.isBold
                ? const Color(0xFF5B6AF6).withOpacity(0.4)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(children: [
          Icon(Icons.format_bold_rounded,
              size: 20,
              color: _n.isBold
                  ? const Color(0xFF5B6AF6)
                  : const Color(0xFF9CA3AF)),
          const SizedBox(width: 10),
          Text('ตัวหนา',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      _n.isBold ? FontWeight.w700 : FontWeight.w400,
                  color: _n.isBold
                      ? const Color(0xFF5B6AF6)
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
          const Spacer(),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 42,
            height: 24,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: _n.isBold
                  ? const Color(0xFF5B6AF6)
                  : Theme.of(context).colorScheme.outline,
              borderRadius: BorderRadius.circular(12),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment:
                  _n.isBold ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  // ─── Text field ────────────────────────────────────────────────────────────

  Widget _textField(
      TextEditingController ctrl, String label, IconData prefixIcon) {
    return TextField(
      controller: ctrl,
      style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(color: Color(0xFFBEC3CF), fontSize: 14),
        prefixIcon:
            Icon(prefixIcon, size: 18, color: const Color(0xFFBEC3CF)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEEF0F4), width: 1)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF5B6AF6), width: 1.5),
        ),
      ),
    );
  }

  // ─── Color grid ────────────────────────────────────────────────────────────

  Widget _colorGrid(
    List<Color> colors,
    int selected,
    void Function(Color) onSelect, {
    bool showBorder = false,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: colors.map((c) {
        final isSelected = c.value == selected;
        return GestureDetector(
          onTap: () => onSelect(c),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Colors.white
                    : (showBorder
                        ? Colors.grey.shade200
                        : Colors.transparent),
                width: isSelected ? 2.5 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                          color: c.withOpacity(0.55),
                          blurRadius: 10,
                          spreadRadius: 1,
                          offset: const Offset(0, 3)),
                      const BoxShadow(
                          color: Colors.black12, blurRadius: 3),
                    ]
                  : [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 4,
                          offset: const Offset(0, 1)),
                    ],
            ),
            child: isSelected
                ? Icon(Icons.check_rounded,
                    size: 17,
                    color: c.computeLuminance() > 0.45
                        ? Colors.black87
                        : Colors.white)
                : null,
          ),
        );
      }).toList(),
    );
  }

  // ─── Icon grid ─────────────────────────────────────────────────────────────

  Widget _iconGrid(Color textColor, Color bgColor) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: kDecorIcons.map((icon) {
        final isSelected = icon == null
            ? _n.decorIconCode == null
            : _n.decorIconCode == icon.codePoint;
        // Use bgColor as selected background so textColor always has contrast
        final selectedBg = bgColor;
        final selectedIconColor = textColor;
        return GestureDetector(
          onTap: () => _n.setDecorIconCode(icon?.codePoint),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isSelected ? selectedBg : const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? bgColor.withOpacity(0.6)
                    : const Color(0xFFEEF0F4),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                          color: bgColor.withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4)),
                    ]
                  : null,
            ),
            child: icon == null
                ? Icon(Icons.block_rounded,
                    size: 22, color: Colors.grey.shade300)
                : Icon(icon,
                    size: 26,
                    color: isSelected
                        ? selectedIconColor
                        : const Color(0xFFB0B7C3)),
          ),
        );
      }).toList(),
    );
  }

  // ─── Image section ─────────────────────────────────────────────────────────

  Widget _imageSection() {
    if (_n.imagePath != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
              child: Stack(children: [
              _n.imageBytes != null
                ? Image.memory(_n.imageBytes!,
                  height: 100, width: double.infinity, fit: BoxFit.cover)
                : Image.file(File(_n.imagePath!),
                  height: 100, width: double.infinity, fit: BoxFit.cover),
              Positioned(
                top: 8,
                right: 8,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  _imageActionChip(
                      Icons.tune_rounded, 'ปรับตำแหน่ง', _adjustPosition),
                  const SizedBox(width: 6),
                  _imageActionChip(
                      Icons.swap_horiz_rounded, 'เปลี่ยน', _pickImage),
                  const SizedBox(width: 6),
                  _imageActionChip(Icons.close_rounded, '',
                      _n.removeImage,
                      isDelete: true),
                ]),
              ),
            ]),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 110,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: const Color(0xFFD1D5DB),
              width: 1.5,
              style: BorderStyle.solid),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined,
                size: 32, color: Color(0xFF9CA3AF)),
            SizedBox(height: 8),
            Text('แตะเพื่อเลือกภาพ',
                style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _imageActionChip(IconData icon, String label, VoidCallback onTap,
      {bool isDelete = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: label.isEmpty ? 8 : 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDelete
              ? Colors.red.withOpacity(0.85)
              : Colors.black.withOpacity(0.55),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: Colors.white),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
          ],
        ]),
      ),
    );
  }
}

// ─── Image position picker ────────────────────────────────────────────────────

class _ImagePositionPicker extends StatefulWidget {
  const _ImagePositionPicker({
    required this.imagePath,
    this.imageBytes,
    required this.initialAlignment,
    required this.initialDim,
    required this.bannerTitle,
    required this.bannerSubtitle,
  });

  final String imagePath;
  final Uint8List? imageBytes;
  final Alignment initialAlignment;
  final double initialDim;
  final String bannerTitle;
  final String bannerSubtitle;

  @override
  State<_ImagePositionPicker> createState() => _ImagePositionPickerState();
}

class _ImagePositionPickerState extends State<_ImagePositionPicker> {
  late double _fracX;
  late double _fracY;
  late double _dim;
  Size? _imageSize;

  Alignment get _alignment => Alignment(_fracX * 2 - 1, _fracY * 2 - 1);

  @override
  void initState() {
    super.initState();
    _fracX = (widget.initialAlignment.x + 1) / 2;
    _fracY = (widget.initialAlignment.y + 1) / 2;
    _dim = widget.initialDim;
    _resolveImageSize();
  }

  void _resolveImageSize() {
    final ImageProvider provider = widget.imageBytes != null
      ? MemoryImage(widget.imageBytes!)
      : FileImage(File(widget.imagePath));
    provider.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((info, _) {
        if (mounted) {
          setState(() => _imageSize = Size(
                info.image.width.toDouble(),
                info.image.height.toDouble(),
              ));
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    const bannerH = 160.0;
    final bannerAspect = (screenW - 40) / bannerH;

    final previewTitle =
        widget.bannerTitle.isNotEmpty ? widget.bannerTitle : 'หัวข้อหลัก';
    final previewSubtitle =
        widget.bannerSubtitle.isNotEmpty ? widget.bannerSubtitle : 'หัวข้อรอง';

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
        title: const Text('เลือกตำแหน่งภาพ',
            style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              onPressed: () => Navigator.pop(context, (_alignment, _dim)),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('ยืนยัน',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.swipe, color: Colors.white38, size: 16),
                SizedBox(width: 6),
                Text('ลากภาพเพื่อเลือกส่วนที่ต้องการแสดง',
                    style: TextStyle(color: Colors.white38, fontSize: 13)),
              ],
            ),
          ),
          Expanded(
            child: _imageSize == null
                ? const Center(
                    child:
                        CircularProgressIndicator(color: Colors.white))
                : LayoutBuilder(builder: (ctx, constraints) {
                    final iAspect =
                        _imageSize!.width / _imageSize!.height;
                    double rW, rH;
                    if (constraints.maxWidth / constraints.maxHeight >
                        iAspect) {
                      rH = constraints.maxHeight;
                      rW = rH * iAspect;
                    } else {
                      rW = constraints.maxWidth;
                      rH = rW / iAspect;
                    }
                    final offX = (constraints.maxWidth - rW) / 2;
                    final offY = (constraints.maxHeight - rH) / 2;

                    double cW, cH;
                    if (rW / rH > bannerAspect) {
                      cH = rH;
                      cW = cH * bannerAspect;
                    } else {
                      cW = rW;
                      cH = cW / bannerAspect;
                    }
                    final rangeX = rW - cW;
                    final rangeY = rH - cH;
                    final cX = offX + _fracX * rangeX;
                    final cY = offY + _fracY * rangeY;

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanUpdate: (d) {
                        setState(() {
                          if (rangeX > 0) {
                            _fracX = (_fracX - d.delta.dx / rangeX)
                                .clamp(0.0, 1.0);
                          }
                          if (rangeY > 0) {
                            _fracY = (_fracY - d.delta.dy / rangeY)
                                .clamp(0.0, 1.0);
                          }
                        });
                      },
                      child: Stack(children: [
                        Positioned(
                          left: offX,
                          top: offY,
                          width: rW,
                          height: rH,
                          child: widget.imageBytes != null
                              ? Image.memory(widget.imageBytes!, fit: BoxFit.fill)
                              : Image.file(File(widget.imagePath), fit: BoxFit.fill),
                        ),
                        if (cY > offY)
                          Positioned(
                              left: 0,
                              top: offY,
                              width: constraints.maxWidth,
                              height: cY - offY,
                              child: ColoredBox(
                                  color: Colors.black.withOpacity(0.6))),
                        if (cY + cH < offY + rH)
                          Positioned(
                              left: 0,
                              top: cY + cH,
                              width: constraints.maxWidth,
                              height: offY + rH - (cY + cH),
                              child: ColoredBox(
                                  color: Colors.black.withOpacity(0.6))),
                        if (cX > offX)
                          Positioned(
                              left: offX,
                              top: cY,
                              width: cX - offX,
                              height: cH,
                              child: ColoredBox(
                                  color: Colors.black.withOpacity(0.6))),
                        if (cX + cW < offX + rW)
                          Positioned(
                              left: cX + cW,
                              top: cY,
                              width: offX + rW - (cX + cW),
                              height: cH,
                              child: ColoredBox(
                                  color: Colors.black.withOpacity(0.6))),
                        Positioned(
                          left: cX,
                          top: cY,
                          width: cW,
                          height: cH,
                          child: const _CropBorder(),
                        ),
                      ]),
                    );
                  }),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(children: [
              const Icon(Icons.wb_sunny_outlined,
                  color: Colors.white60, size: 18),
              const SizedBox(width: 4),
              const Text('ความมืด',
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _dim,
                  min: 0.0,
                  max: 0.7,
                  activeColor: Colors.white,
                  inactiveColor: Colors.white24,
                  onChanged: (v) => setState(() => _dim = v),
                ),
              ),
              Text('${(_dim * 100).round()}%',
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 12)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 3,
                    height: 14,
                    decoration: BoxDecoration(
                        color: Colors.white54,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(width: 8),
                  const Text('ตัวอย่าง',
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                ]),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    height: bannerH,
                    child: Stack(fit: StackFit.expand, children: [
                      widget.imageBytes != null
                          ? Image.memory(widget.imageBytes!, fit: BoxFit.cover, alignment: _alignment)
                          : Image.file(
                              File(widget.imagePath),
                              fit: BoxFit.cover,
                              alignment: _alignment,
                            ),
                      ColoredBox(color: Colors.black.withOpacity(_dim)),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              previewTitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withOpacity(
                                    widget.bannerTitle.isEmpty ? 0.35 : 1.0),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              previewSubtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(
                                    widget.bannerSubtitle.isEmpty
                                        ? 0.25
                                        : 0.75),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Crop border with corner handles ─────────────────────────────────────────

class _CropBorder extends StatelessWidget {
  const _CropBorder();

  @override
  Widget build(BuildContext context) {
    const c = Colors.white;
    const len = 18.0;
    const t = 2.5;
    return Stack(fit: StackFit.expand, children: [
      DecoratedBox(
          decoration: BoxDecoration(
              border: Border.all(color: c.withOpacity(0.5), width: 1))),
      Positioned(
          left: 0,
          top: 0,
          child: _Corner(c, len, t, top: true, left: true)),
      Positioned(
          right: 0,
          top: 0,
          child: _Corner(c, len, t, top: true, left: false)),
      Positioned(
          left: 0,
          bottom: 0,
          child: _Corner(c, len, t, top: false, left: true)),
      Positioned(
          right: 0,
          bottom: 0,
          child: _Corner(c, len, t, top: false, left: false)),
      const Center(
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.swipe, color: Colors.white54, size: 16),
          SizedBox(width: 4),
          Text('ลาก', style: TextStyle(color: Colors.white54, fontSize: 11)),
        ]),
      ),
    ]);
  }
}

class _Corner extends StatelessWidget {
  const _Corner(this.color, this.len, this.thick,
      {required this.top, required this.left});
  final Color color;
  final double len;
  final double thick;
  final bool top;
  final bool left;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: len,
      height: len,
      child: CustomPaint(
          painter: _CornerPainter(color, thick, top: top, left: left)),
    );
  }
}

class _CornerPainter extends CustomPainter {
  _CornerPainter(this.color, this.thick,
      {required this.top, required this.left});
  final Color color;
  final double thick;
  final bool top;
  final bool left;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = thick
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;
    final x = left ? 0.0 : size.width;
    final y = top ? 0.0 : size.height;
    canvas.drawLine(Offset(x, y), Offset(left ? size.width : 0, y), p);
    canvas.drawLine(Offset(x, y), Offset(x, top ? size.height : 0), p);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => false;
}

// ignore_for_file: deprecated_member_use, prefer_null_aware_operators, unused_element

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_settings.dart';
import 'banner_editor_screen.dart';
import 'tasks_screen.dart';
import 'notes_screen.dart';
import 'shopping_screen.dart';
import 'budget_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _bannerTitle = '';
  String _bannerSubtitle = '';
  int _bannerTextColor = 0xFFFFFFFF;
  int _bannerIconColor = 0xFFFFFFFF;
  int? _bannerTextStrokeColor;
  double _bannerTitleSize = 18.0;
  bool _bannerIsBold = true;
  int _bannerBgColor = 0xFF1565C0;
  int? _bannerDecorIconCode;
  String? _bannerImagePath;
  Alignment _bannerImageAlignment = Alignment.center;
  double _bannerDimOpacity = 0.35;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  Future<void> _loadBanner() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bannerTitle = prefs.getString('banner_title') ?? '';
      _bannerSubtitle = prefs.getString('banner_subtitle') ?? '';
      _bannerTextColor = prefs.getInt('banner_text_color') ?? 0xFFFFFFFF;
      _bannerIconColor = prefs.getInt('banner_icon_color') ?? 0xFFFFFFFF;
      _bannerTextStrokeColor = prefs.getInt('banner_text_stroke');
      _bannerTitleSize = prefs.getDouble('banner_title_size') ?? 18.0;
      _bannerIsBold = prefs.getBool('banner_is_bold') ?? true;
      _bannerBgColor = prefs.getInt('banner_bg_color') ?? 0xFF1565C0;
      _bannerDecorIconCode = prefs.getInt('banner_decor_icon');
      _bannerImagePath = prefs.getString('banner_image_path');
      _bannerImageAlignment = Alignment(
        prefs.getDouble('banner_align_x') ?? 0.0,
        prefs.getDouble('banner_align_y') ?? 0.0,
      );
      _bannerDimOpacity = prefs.getDouble('banner_dim') ?? 0.35;
    });
  }

  Future<void> _saveBanner() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('banner_title', _bannerTitle);
    await prefs.setString('banner_subtitle', _bannerSubtitle);
    await prefs.setInt('banner_text_color', _bannerTextColor);
    await prefs.setInt('banner_icon_color', _bannerIconColor);
    if (_bannerTextStrokeColor != null) {
      await prefs.setInt('banner_text_stroke', _bannerTextStrokeColor!);
    } else {
      await prefs.remove('banner_text_stroke');
    }
    await prefs.setDouble('banner_title_size', _bannerTitleSize);
    await prefs.setBool('banner_is_bold', _bannerIsBold);
    await prefs.setInt('banner_bg_color', _bannerBgColor);
    if (_bannerDecorIconCode != null) {
      await prefs.setInt('banner_decor_icon', _bannerDecorIconCode!);
    } else {
      await prefs.remove('banner_decor_icon');
    }
    if (_bannerImagePath != null) {
      await prefs.setString('banner_image_path', _bannerImagePath!);
    } else {
      await prefs.remove('banner_image_path');
    }
    await prefs.setDouble('banner_align_x', _bannerImageAlignment.x);
    await prefs.setDouble('banner_align_y', _bannerImageAlignment.y);
    await prefs.setDouble('banner_dim', _bannerDimOpacity);
  }

  Future<void> _openBannerEditor() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => BannerEditorScreen(
          initialTitle: _bannerTitle,
          initialSubtitle: _bannerSubtitle,
          initialTextColor: _bannerTextColor,
          initialIconColor: _bannerIconColor,
          initialTextStrokeColor: _bannerTextStrokeColor,
          initialTitleSize: _bannerTitleSize,
          initialIsBold: _bannerIsBold,
          initialBgColor: _bannerBgColor,
          initialDecorIconCode: _bannerDecorIconCode,
          initialImagePath: _bannerImagePath,
          initialImageAlignX: _bannerImageAlignment.x,
          initialImageAlignY: _bannerImageAlignment.y,
          initialImageDim: _bannerDimOpacity,
        ),
      ),
    );
    if (result == null) return;
    setState(() {
      _bannerTitle = result['title'] as String;
      _bannerSubtitle = result['subtitle'] as String;
      _bannerTextColor = result['textColor'] as int;
      _bannerIconColor = result['iconColor'] as int;
      _bannerTextStrokeColor = result['textStrokeColor'] as int?;
      _bannerTitleSize = result['titleSize'] as double;
      _bannerIsBold = result['isBold'] as bool;
      _bannerBgColor = result['bgColor'] as int;
      _bannerDecorIconCode = result['decorIconCode'] as int?;
      _bannerImagePath = result['imagePath'] as String?;
      _bannerImageAlignment = Alignment(
        result['imageAlignX'] as double,
        result['imageAlignY'] as double,
      );
      _bannerDimOpacity = result['imageDim'] as double;
    });
    await _saveBanner();
  }

  // ── End Drawer ──────────────────────────────────────────────────────────────

  Widget _buildEndDrawer(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tune_rounded, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'ตั้งค่า',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // เปลี่ยนธีม (Switch)
            ValueListenableBuilder<ThemeMode>(
              valueListenable: appThemeMode,
              builder: (context, mode, _) {
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      mode == ThemeMode.dark
                          ? Icons.nightlight_round
                          : Icons.wb_sunny_outlined,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  title: const Text('เปลี่ยนธีม',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: Switch(
                    value: mode == ThemeMode.dark,
                    onChanged: (val) async {
                      final newMode = val ? ThemeMode.dark : ThemeMode.light;
                      await saveThemeMode(newMode);
                    },
                  ),
                  subtitle: Text(
                    mode == ThemeMode.dark ? 'ธีมมืด' : 'ธีมสว่าง',
                    style: TextStyle(
                        color: theme.colorScheme.primary, fontSize: 12),
                  ),
                  onTap: () {
                    final newMode = mode == ThemeMode.dark
                        ? ThemeMode.light
                        : ThemeMode.dark;
                    saveThemeMode(newMode);
                  },
                );
              },
            ),
            // วิธีใช้
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.help_outline_rounded,
                    color: Colors.teal.shade700),
              ),
              title: const Text('วิธีใช้',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('คำแนะนำการใช้งานแอป',
                  style:
                      TextStyle(color: Colors.teal.shade700, fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                _showHelpDialog(context);
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'DailyTask v1.0',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline_rounded, color: Colors.teal),
            SizedBox(width: 8),
            Text('วิธีใช้งาน'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              _HelpItem(
                icon: Icons.check_circle_rounded,
                color: Color(0xFF1976D2),
                title: 'จดบันทึกงาน',
                desc:
                    'เพิ่ม แก้ไข และลบงานประจำวัน\nทำเครื่องหมายงานที่เสร็จแล้วได้',
              ),
              _HelpItem(
                icon: Icons.sticky_note_2_rounded,
                color: Color(0xFFFF8F00),
                title: 'โน็ต / บันทึก',
                desc: 'จดบันทึกข้อความที่ต้องการเก็บไว้\nรองรับหลายโน็ต',
              ),
              _HelpItem(
                icon: Icons.shopping_cart_rounded,
                color: Color(0xFF388E3C),
                title: 'รายการช้อปปิ้ง',
                desc:
                    'สร้างลิสต์สิ่งของที่ต้องซื้อ\nทำเครื่องหมายเมื่อซื้อแล้ว',
              ),
              _HelpItem(
                icon: Icons.account_balance_wallet_rounded,
                color: Color(0xFF7B1FA2),
                title: 'บันทึกการเงิน',
                desc: 'บันทึกรายรับและรายจ่าย\nดูสรุปยอดรวมได้',
              ),
              _HelpItem(
                icon: Icons.image_outlined,
                color: Color(0xFF0D47A1),
                title: 'แบนเนอร์',
                desc:
                    'แตะที่แบนเนอร์บนหน้าหลัก\nเพื่อตกแต่งข้อความ สี และรูปภาพ',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'อรุณสวัสดิ์';
    if (hour < 17) return 'สวัสดีตอนบ่าย';
    if (hour < 20) return 'สวัสดีตอนเย็น';
    return 'สวัสดีตอนค่ำ';
  }

  String _shortDate() {
    final now = DateTime.now();
    const thDays = ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'];
    const thMonths = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
    ];
    final day = thDays[now.weekday - 1];
    final month = thMonths[now.month - 1];
    return '$day ${now.day} $month';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = Color(_bannerTextColor);
    final iconColor = Color(_bannerIconColor);
    final strokeColor =
        _bannerTextStrokeColor != null ? Color(_bannerTextStrokeColor!) : null;
    final bgColor = Color(_bannerBgColor);
    final decorIcon = _bannerDecorIconCode != null
        ? kDecorIcons
            .whereType<IconData>()
            .firstWhere((i) => i.codePoint == _bannerDecorIconCode,
                orElse: () => Icons.auto_awesome)
        : null;
    final hasContent = _bannerTitle.isNotEmpty ||
        _bannerSubtitle.isNotEmpty ||
        _bannerImagePath != null ||
        decorIcon != null;

    return Scaffold(
      endDrawer: _buildEndDrawer(context),
      appBar: AppBar(
        backgroundColor: theme.brightness == Brightness.dark
            ? Colors.transparent
            : Colors.transparent,
        elevation: 2,
        shadowColor: theme.brightness == Brightness.dark
            ? const Color(0xFF26263A).withOpacity(0.25)
            : const Color(0xFF0D47A1).withOpacity(0.25),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: theme.brightness == Brightness.dark
                ? const LinearGradient(
                    colors: [Color(0xFF23233A), Color(0xFF35355A)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : const LinearGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
          ),
        ),
        titleSpacing: 20,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'DailyTask',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : Colors.white,
                letterSpacing: 0.3,
              ),
            ),
            Text(
              _greeting(),
              style: TextStyle(
                fontSize: 11,
                color: theme.brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.white70,
                height: 1.3,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.10)
                      : Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _shortDate(),
                  style: TextStyle(
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Builder(
            builder: (ctx) => IconButton(
              icon: Icon(Icons.menu_rounded, color: theme.brightness == Brightness.dark ? Colors.white : Colors.white),
              tooltip: 'เมนู',
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Banner ──────────────────────────────────────────────
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _openBannerEditor,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 172,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(20),
                  image: _bannerImagePath != null
                      ? DecorationImage(
                          image: FileImage(File(_bannerImagePath!)),
                          fit: BoxFit.cover,
                          alignment: _bannerImageAlignment,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(_bannerDimOpacity),
                            BlendMode.darken,
                          ),
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: bgColor.withOpacity(0.45),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(fit: StackFit.expand, children: [
                    if (decorIcon != null)
                      Positioned(
                        right: -8,
                        bottom: -8,
                        child: Icon(decorIcon,
                            size: 100, color: iconColor.withOpacity(0.08)),
                      ),
                    // Edit chip overlay
                    Positioned(
                      top: 10,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                        ),
                      ),
                    ),
                    if (hasContent)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (decorIcon != null) ...[
                              Icon(decorIcon,
                                  size: 26,
                                  color: iconColor.withOpacity(0.9)),
                              const SizedBox(height: 6),
                            ],
                            if (_bannerTitle.isNotEmpty)
                              _bannerStyledText(
                                _bannerTitle,
                                _bannerTitleSize,
                                _bannerIsBold
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                textColor,
                                strokeColor,
                              ),
                            if (_bannerSubtitle.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              _bannerStyledText(
                                _bannerSubtitle,
                                _bannerTitleSize * 0.68,
                                FontWeight.normal,
                                textColor.withOpacity(0.8),
                                strokeColor != null
                                    ? strokeColor.withOpacity(0.6)
                                    : null,
                              ),
                            ],
                          ],
                        ),
                      )
                    else
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 26,
                                color: Colors.white60),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'แตะเพื่อตกแต่งแบนเนอร์',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'เพิ่มข้อความ · สี · ไอคอน · รูปภาพ',
                            style: TextStyle(
                                color: Colors.white38, fontSize: 11),
                          ),
                        ],
                      ),
                  ]),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Section header ───────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'เมนูหลัก',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white70
                        : const Color(0xFF3D3D3D),
                    letterSpacing: 0.2,
                  ),
                ),
                const Spacer(),
                Text(
                  'เลือกหมวดที่ต้องการ',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.primary.withOpacity(0.7),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── 4 nav cards ─────────────────────────────────────────
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,                childAspectRatio: 0.95,                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _NavCard(
                    label: 'จดบันทึกงาน',
                    subtitle: 'จัดการงานประจำวัน',
                    icon: Icons.check_circle_rounded,
                    lightGradient: const LinearGradient(
                      colors: [Color(0xFFE3F2FD), Color(0xFFE3DFFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    darkGradient: const LinearGradient(
                      colors: [Color(0xFF181E3A), Color(0xFF1E1A3A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    iconColor: const Color(0xFF5B5FC4),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TasksScreen()),
                    ),
                  ),
                  _NavCard(
                    label: 'โน็ต / บันทึก',
                    subtitle: 'บันทึกความคิดไว้ที่นี่',
                    icon: Icons.sticky_note_2_rounded,
                    lightGradient: const LinearGradient(
                      colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    darkGradient: const LinearGradient(
                      colors: [Color(0xFF2A2010), Color(0xFF332A10)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    iconColor: const Color(0xFFFF8F00),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotesScreen()),
                    ),
                  ),
                  _NavCard(
                    label: 'รายการช้อปปิ้ง',
                    subtitle: 'ของที่ต้องซื้อวันนี้',
                    icon: Icons.shopping_cart_rounded,
                    lightGradient: LinearGradient(
                      colors: [const Color(0xFFE8F5E9), Colors.green.shade100],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    darkGradient: const LinearGradient(
                      colors: [Color(0xFF102018), Color(0xFF152515)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    iconColor: Colors.green.shade700,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ShoppingScreen()),
                    ),
                  ),
                  _NavCard(
                    label: 'บันทึกการเงิน',
                    subtitle: 'รายรับ-รายจ่ายของคุณ',
                    icon: Icons.account_balance_wallet_rounded,
                    lightGradient: LinearGradient(
                      colors: [
                        const Color(0xFFF3E5F5),
                        Colors.purple.shade100,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    darkGradient: const LinearGradient(
                      colors: [Color(0xFF1E1028), Color(0xFF251530)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    iconColor: Colors.purple.shade700,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BudgetScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Styled text with optional stroke ─────────────────────────────────────────

Widget _bannerStyledText(String text, double fontSize, FontWeight weight,
    Color fillColor, Color? strokeColor) {
  final ts = TextStyle(fontSize: fontSize, fontWeight: weight, height: 1.25);
  if (strokeColor == null) {
    return Text(text,
        textAlign: TextAlign.center, style: ts.copyWith(color: fillColor));
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
          textAlign: TextAlign.center, style: ts.copyWith(color: fillColor)),
    ],
  );
}

// ── Navigation card widget ────────────────────────────────────────────────────

class _NavCard extends StatelessWidget {
  const _NavCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.lightGradient,
    required this.darkGradient,
    required this.iconColor,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Gradient lightGradient;
  final Gradient darkGradient;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = isDark ? darkGradient : lightGradient;
    final labelColor =
        isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subtitleColor =
        isDark ? Colors.white54 : const Color(0xFF757575);
    final borderColor =
        isDark ? Colors.white.withOpacity(0.06) : Colors.transparent;

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : iconColor.withOpacity(0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: iconColor.withOpacity(0.12),
          highlightColor: iconColor.withOpacity(0.06),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(isDark ? 0.22 : 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 28, color: iconColor),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: labelColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: subtitleColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11,
                      color: isDark
                          ? Colors.white30
                          : iconColor.withOpacity(0.4),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Theme radio tile ──────────────────────────────────────────────────────────

class _ThemeRadioTile extends StatelessWidget {
  const _ThemeRadioTile({
    required this.label,
    required this.icon,
    required this.value,
    required this.groupValue,
  });

  final String label;
  final IconData icon;
  final ThemeMode value;
  final ThemeMode groupValue;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<ThemeMode>(
      value: value,
      groupValue: groupValue,
      title: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      onChanged: (v) {
        if (v != null) saveThemeMode(v);
      },
      contentPadding: EdgeInsets.zero,
    );
  }
}

// ── Help item ─────────────────────────────────────────────────────────────────

class _HelpItem extends StatelessWidget {
  const _HelpItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 2),
                Text(desc,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

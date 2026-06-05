// ignore_for_file: dead_code, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/budget.dart';
import '../services/storage_service.dart';

const List<IconData> _kBudgetIcons = [
  Icons.attach_money,
  Icons.fastfood,
  Icons.directions_car,
  Icons.shopping_cart,
  Icons.home,
  Icons.card_giftcard,
  Icons.savings,
  Icons.school,
  Icons.local_hospital,
  Icons.sports_soccer,
  Icons.coffee,
  Icons.pets,
  Icons.flight,
  Icons.more_horiz,
];

IconData _budgetIconFromCodePoint(int codePoint) {
  return _kBudgetIcons.firstWhere(
    (icon) => icon.codePoint == codePoint,
    orElse: () => Icons.attach_money,
  );
}

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  List<Budget> _budgets = [];
  bool _isLoading = true;
  final _fmt = NumberFormat('#,##0.00');

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    final budgets = await StorageService.getBudgets();
    setState(() {
      _budgets = budgets;
      _isLoading = false;
    });
  }

  Future<void> _saveBudgets() async {
    await StorageService.saveBudgets(_budgets);
  }

  void _showAddBudgetDialog() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    String? amountHint = 'เช่น 10000';
    int iconCode = 0xef63; // Default: attach_money
    BudgetType budgetType = BudgetType.expense;
    final icons = [
      Icons.attach_money,
      Icons.fastfood,
      Icons.directions_car,
      Icons.shopping_cart,
      Icons.home,
      Icons.card_giftcard,
      Icons.savings,
      Icons.school,
      Icons.local_hospital,
      Icons.sports_soccer,
      Icons.coffee,
      Icons.pets,
      Icons.flight,
      Icons.more_horiz,
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (dialogContext, setStateDialog) => SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('สร้างงบประมาณใหม่', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: SegmentedButton<BudgetType>(
                          segments: const [
                            ButtonSegment(
                              value: BudgetType.expense,
                              label: Text('งบประมาณใช้จ่าย'),
                              icon: Icon(Icons.account_balance_wallet, color: Colors.purple),
                            ),
                            ButtonSegment(
                              value: BudgetType.saving,
                              label: Text('งบออม/สะสม'),
                              icon: Icon(Icons.savings, color: Colors.green),
                            ),
                          ],
                          selected: {budgetType},
                          onSelectionChanged: (v) {
                            setStateDialog(() => budgetType = v.first);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'ชื่องบประมาณ',
                      border: const OutlineInputBorder(),
                      hintText: 'เช่น เงินเดือนมิถุนายน, เงินออม',
                      helperText: 'หากเป็นการเก็บออม เช่น เงินออม ให้ใส่ยอดเงินเป็น 0',
                    ),
                    autofocus: true,
                    onChanged: (value) {
                      // แนะนำผู้ใช้ถ้าพิมพ์คำว่าออม
                      if (value.contains('ออม') || value.contains('เก็บ')) {
                        amountHint = 'ใส่ 0 หากเป็นการเก็บออม';
                      } else {
                        amountHint = 'เช่น 10000';
                      }
                      setStateDialog(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(
                      labelText: 'จำนวนเงินรวม (บาท)',
                      border: const OutlineInputBorder(),
                      prefixText: '฿ ',
                      hintText: amountHint,
                      helperText: nameController.text.contains('ออม') || nameController.text.contains('เก็บ')
                          ? 'หากเป็นการเก็บออม ให้ใส่ยอดเงินเป็น 0'
                          : null,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 18),
                  Text('เลือกไอคอน', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 44,
                    child: Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for (final ic in icons) ...[
                                  GestureDetector(
                                    onTap: () {
                                      setStateDialog(() => iconCode = ic.codePoint);
                                    },
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color: iconCode == ic.codePoint ? Colors.purple[100] : Colors.grey[100],
                                        borderRadius: BorderRadius.circular(12),
                                        border: iconCode == ic.codePoint ? Border.all(color: Colors.purple, width: 2) : null,
                                      ),
                                      child: Icon(ic, color: iconCode == ic.codePoint ? Colors.purple : Colors.grey[600]),
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('ยกเลิก'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () {
                          final name = nameController.text.trim();
                          final amount = double.tryParse(amountController.text);
                          if (name.isEmpty || amount == null || amount <= 0) return;
                          setState(() {
                            _budgets.add(Budget(
                              name: name,
                              totalAmount: amount,
                              parts: [],
                              iconCodePoint: iconCode,
                              budgetType: budgetType,
                            ));
                          });
                          _saveBudgets();
                          Navigator.pop(context);
                        },
                        child: const Text('บันทึก'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _deleteBudget(Budget budget) {
    setState(() {
      _budgets.removeWhere((b) => b.id == budget.id);
    });
    _saveBudgets();
  }

  @override
  Widget build(BuildContext context) {
    final expenseBudgets = _budgets.where((b) => b.budgetType == BudgetType.expense).toList();
    final savingBudgets = _budgets.where((b) => b.budgetType == BudgetType.saving).toList();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('บันทึกรายรับรายจ่าย'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'งบประมาณ'),
              Tab(text: 'สะสม'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  // งบประมาณ
                  expenseBudgets.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.pie_chart_outline, size: 72, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text('ยังไม่มีบันทึกรายรับรายจ่าย', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                              const SizedBox(height: 8),
                              Text('กด + เพื่อสร้างบันทึกรายรับรายจ่าย', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: expenseBudgets.length,
                          itemBuilder: (ctx, i) {
                            final budget = expenseBudgets[i];
                            final allocated = budget.allocatedAmount;
                            final remaining = budget.remainingAmount;
                            final progress = budget.totalAmount > 0
                                ? (allocated / budget.totalAmount).clamp(0.0, 1.0)
                                : 0.0;
                            final progressColor = progress > 0.9
                                ? Colors.red
                                : progress > 0.7
                                    ? Colors.orange
                                    : Colors.purple;
                            return Dismissible(
                              key: Key(budget.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              confirmDismiss: (_) async {
                                return await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('ลบงบประมาณ?'),
                                    content: Text('ต้องการลบ "${budget.name}" หรือไม่?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('ยกเลิก'),
                                      ),
                                      FilledButton(
                                        style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('ลบ'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onDismissed: (_) => _deleteBudget(budget),
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BudgetDetailScreen(
                                          budget: budget,
                                          onSave: () {
                                            _saveBudgets();
                                          },
                                        ),
                                      ),
                                    );
                                    await _loadBudgets();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              _budgetIconFromCodePoint(budget.iconCodePoint),
                                              color: Colors.purple,
                                              size: 22,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                budget.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '฿${_fmt.format(budget.totalAmount)}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.purple,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: progress,
                                            minHeight: 8,
                                            backgroundColor: Colors.grey[200],
                                            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text(
                                              'จัดสรร: ฿${_fmt.format(allocated)}',
                                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                            ),
                                            const Spacer(),
                                            Text(
                                              remaining >= 0
                                                  ? 'คงเหลือ: ฿${_fmt.format(remaining)}'
                                                  : 'เกินงบ: ฿${_fmt.format(remaining.abs())}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: remaining < 0 ? Colors.red : Colors.green[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (budget.parts.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            '${budget.parts.length} หมวดหมู่',
                                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                  // สะสม
                  savingBudgets.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.pie_chart_outline, size: 72, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text('ยังไม่มีงบสะสม', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                              const SizedBox(height: 8),
                              Text('กด + เพื่อสร้างงบสะสม', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: savingBudgets.length,
                          itemBuilder: (ctx, i) {
                            final budget = savingBudgets[i];
                            final allocated = budget.allocatedAmount;
                            final progress = budget.totalAmount > 0 ? (allocated / budget.totalAmount).clamp(0.0, 1.0) : 0.0;
                            return Dismissible(
                              key: Key(budget.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              confirmDismiss: (_) async {
                                return await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('ลบงบสะสม?'),
                                    content: Text('ต้องการลบ "${budget.name}" หรือไม่?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('ยกเลิก'),
                                      ),
                                      FilledButton(
                                        style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('ลบ'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onDismissed: (_) => _deleteBudget(budget),
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BudgetDetailScreen(
                                          budget: budget,
                                          onSave: () {
                                            _saveBudgets();
                                          },
                                        ),
                                      ),
                                    );
                                    await _loadBudgets();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              _budgetIconFromCodePoint(budget.iconCodePoint),
                                              color: Colors.purple,
                                              size: 22,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                budget.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              'สะสม',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        if (budget.totalAmount > 0)
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                              value: progress,
                                              minHeight: 8,
                                              backgroundColor: Colors.grey[200],
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                                            ),
                                          ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text(
                                              'จัดสรร: ฿${_fmt.format(allocated)}',
                                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                            ),
                                            const Spacer(),
                                            if (budget.totalAmount > 0)
                                              Text(
                                                'เป้าหมาย: ฿${_fmt.format(budget.totalAmount)}',
                                                style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600),
                                              ),
                                          ],
                                        ),
                                        if (budget.parts.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            '${budget.parts.length} หมวดหมู่',
                                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'budget_fab',
          onPressed: _showAddBudgetDialog,
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

}

// ─── Budget Detail Screen ─────────────────────────────────────────────────────

class BudgetDetailScreen extends StatefulWidget {
  final Budget budget;
  final VoidCallback onSave;

  const BudgetDetailScreen({super.key, required this.budget, required this.onSave});

  @override
  State<BudgetDetailScreen> createState() => _BudgetDetailScreenState();
}

class _BudgetDetailScreenState extends State<BudgetDetailScreen> {
  final _fmt = NumberFormat('#,##0.00');

  static const List<Color> _partColors = [
    Colors.blue,
    Colors.orange,
    Colors.green,
    Colors.red,
    Colors.teal,
    Color(0xFFFFC107),
    Colors.indigo,
    Colors.pink,
  ];

  void _showAddPartDialog({BudgetPart? editPart}) {
    final nameController = TextEditingController(text: editPart?.name ?? '');
    final amountController = TextEditingController(text: editPart?.amount.toStringAsFixed(2) ?? '');
    BudgetPartType type = editPart?.type ?? BudgetPartType.expense;
    int iconCode = editPart?.iconCodePoint ?? 0xef63; // attach_money
    final icons = [
      Icons.attach_money,
      Icons.fastfood,
      Icons.directions_car,
      Icons.shopping_cart,
      Icons.home,
      Icons.card_giftcard,
      Icons.savings,
      Icons.school,
      Icons.local_hospital,
      Icons.sports_soccer,
      Icons.coffee,
      Icons.pets,
      Icons.flight,
      Icons.more_horiz,
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (dialogContext, setStateDialog) => SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(type == BudgetPartType.income ? Icons.south_west : _budgetIconFromCodePoint(iconCode), color: type == BudgetPartType.income ? Colors.green : Colors.purple),
                      const SizedBox(width: 8),
                      Text(editPart == null ? 'เพิ่มหมวดหมู่' : 'แก้ไขหมวดหมู่', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SegmentedButton<BudgetPartType>(
                    segments: const [
                      ButtonSegment(
                        value: BudgetPartType.expense,
                        label: Text('รายจ่าย'),
                        icon: Icon(Icons.south_east, color: Colors.purple),
                      ),
                      ButtonSegment(
                        value: BudgetPartType.income,
                        label: Text('รายรับ'),
                        icon: Icon(Icons.south_west, color: Colors.green),
                      ),
                    ],
                    selected: {type},
                    onSelectionChanged: (v) {
                      setStateDialog(() => type = v.first);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'ชื่อหมวดหมู่',
                      border: OutlineInputBorder(),
                      hintText: 'เช่น ค่าอาหาร, ค่าเดินทาง',
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(
                      labelText: type == BudgetPartType.income ? 'จำนวนเงิน (รายรับ)' : 'จำนวนเงิน (รายจ่าย)',
                      border: const OutlineInputBorder(),
                      prefixText: '฿ ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 18),
                  Text('เลือกไอคอน', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 44,
                    child: Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for (final ic in icons) ...[
                                  GestureDetector(
                                    onTap: () {
                                      setStateDialog(() => iconCode = ic.codePoint);
                                    },
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color: iconCode == ic.codePoint ? (type == BudgetPartType.income ? Colors.green[100] : Colors.purple[100]) : Colors.grey[100],
                                        borderRadius: BorderRadius.circular(12),
                                        border: iconCode == ic.codePoint ? Border.all(color: type == BudgetPartType.income ? Colors.green : Colors.purple, width: 2) : null,
                                      ),
                                      child: Icon(ic, color: iconCode == ic.codePoint ? (type == BudgetPartType.income ? Colors.green : Colors.purple) : Colors.grey[600]),
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('ยกเลิก'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () {
                          final name = nameController.text.trim();
                          final amount = double.tryParse(amountController.text);
                          if (name.isEmpty || amount == null || amount <= 0) return;
                          if (editPart != null) {
                            setState(() {
                              editPart.name = name;
                              editPart.amount = amount;
                              editPart.type = type;
                              editPart.iconCodePoint = iconCode;
                            });
                          } else {
                            setState(() {
                              widget.budget.parts.add(BudgetPart(
                                name: name,
                                amount: amount,
                                type: type,
                                iconCodePoint: iconCode,
                              ));
                            });
                          }
                          widget.onSave();
                          Navigator.pop(context);
                        },
                        child: const Text('บันทึก'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _deletePart(BudgetPart part) {
    setState(() =>
        widget.budget.parts.removeWhere((p) => p.id == part.id));
    widget.onSave();
  }

  @override
  Widget build(BuildContext context) {
    final budget = widget.budget;
    final allocated = budget.allocatedAmount;
    final remaining = budget.remainingAmount;
    final isSaving = budget.budgetType == BudgetType.saving;
    final progress = !isSaving && budget.totalAmount > 0
      ? (allocated / budget.totalAmount).clamp(0.0, 1.0)
      : 0.0;
    final progressColor = progress > 0.9
      ? Colors.red
      : progress > 0.7
        ? Colors.orange
        : Colors.purple;

    return Scaffold(
      appBar: AppBar(
        title: Text(budget.name),
      ),
      body: Column(
        children: [
          // ── Summary header ───────────────────────────────────────────────────────────
          Container(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      isSaving ? 'ยอดสะสม' : 'งบประมาณรวม',
                      style: TextStyle(
                          color: Colors.grey[600], fontSize: 13),
                    ),
                    Text(
                      isSaving
                          ? '฿${_fmt.format(allocated)}'
                          : '฿${_fmt.format(budget.totalAmount)}',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: isSaving ? Colors.green : Colors.purple,
                      ),
                    ),
                    if (isSaving && budget.totalAmount > 0) ...[
                      const SizedBox(height: 8),
                      Text('เป้าหมาย: ฿${_fmt.format(budget.totalAmount)}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: (allocated / budget.totalAmount).clamp(0.0, 1.0),
                          minHeight: 12,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'คิดเป็น ${(allocated / budget.totalAmount * 100).clamp(0, 100).toStringAsFixed(1)}% ของเป้าหมาย',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ),
                    ],
                    if (!isSaving) ...[
                      const SizedBox(height: 8),
                      Text(
                        remaining >= 0 ? 'คงเหลือ' : 'เกินงบ',
                        style: TextStyle(
                            color: Colors.grey[600], fontSize: 13),
                      ),
                      Text(
                        '฿${_fmt.format(remaining.abs())}',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: remaining < 0
                              ? Colors.red
                              : Colors.green[700],
                        ),
                      ),
                    ],
                  ],
                ),
                if (!isSaving) ...[
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      backgroundColor: Colors.grey[200],
                      valueColor:
                          AlwaysStoppedAnimation<Color>(progressColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'จัดสรรแล้ว ฿${_fmt.format(allocated)} (${(progress * 100).toStringAsFixed(1)}%)',
                      style:
                          TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ),
                ],
                if (isSaving && budget.totalAmount == 0) ...[
                  const SizedBox(height: 8),
                  Text('ยอดรวมที่เพิ่มเข้ามาทั้งหมด', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                ],
              ],
            ),
          ),
          // ── Parts list ──────────────────────────────────────────────────
          Expanded(
            child: budget.parts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.pie_chart_outline,
                            size: 72, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'ยังไม่มีหมวดหมู่',
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'กด + เพื่อเพิ่มหมวดหมู่',
                          style: TextStyle(
                              color: Colors.grey[400], fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: budget.parts.length,
                    itemBuilder: (ctx, i) {
                      final part = budget.parts[i];
                      final color = part.type == BudgetPartType.income ? Colors.green : _partColors[i % _partColors.length];
                      final partProgress = budget.totalAmount > 0
                          ? (part.amount / budget.totalAmount)
                              .clamp(0.0, 1.0)
                          : 0.0;

                      return Dismissible(
                        key: Key(part.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete,
                              color: Colors.white),
                        ),
                        onDismissed: (_) => _deletePart(part),
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _showAddPartDialog(editPart: part),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        _budgetIconFromCodePoint(part.iconCodePoint),
                                        color: part.type == BudgetPartType.income ? Colors.green : color,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          part.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        (part.type == BudgetPartType.income ? '+' : '-') + '฿${_fmt.format(part.amount)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: part.type == BudgetPartType.income ? Colors.green : color,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: partProgress,
                                      minHeight: 6,
                                      backgroundColor: Colors.grey[200],
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              color),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${(partProgress * 100).toStringAsFixed(1)}% ของงบรวม',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'budget_detail_fab',
        onPressed: () => _showAddPartDialog(),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/budget.dart';
import '../services/storage_service.dart';

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

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('สร้างงบประมาณใหม่'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'ชื่องบประมาณ',
                border: OutlineInputBorder(),
                hintText: 'เช่น เงินเดือนมิถุนายน',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'จำนวนเงินรวม (บาท)',
                border: OutlineInputBorder(),
                prefixText: '฿ ',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              final amount = double.tryParse(amountController.text);
              if (name.isEmpty || amount == null || amount <= 0) return;
              setState(() {
                _budgets.add(Budget(name: name, totalAmount: amount));
              });
              _saveBudgets();
              Navigator.pop(context);
            },
            child: const Text('สร้าง'),
          ),
        ],
      ),
    );
  }

  void _deleteBudget(Budget budget) {
    setState(() => _budgets.removeWhere((b) => b.id == budget.id));
    _saveBudgets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('งบประมาณ'),
        backgroundColor: const Color(0xFFF3E5F5),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _budgets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_balance_wallet_outlined,
                          size: 72, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'ยังไม่มีงบประมาณ',
                        style: TextStyle(
                            color: Colors.grey[500], fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'กด + เพื่อสร้างงบประมาณ',
                        style: TextStyle(
                            color: Colors.grey[400], fontSize: 14),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _budgets.length,
                  itemBuilder: (ctx, i) {
                    final budget = _budgets[i];
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
                            content:
                                Text('ต้องการลบ "${budget.name}" หรือไม่?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text('ยกเลิก'),
                              ),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                    backgroundColor: Colors.red),
                                onPressed: () =>
                                    Navigator.pop(context, true),
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
                                    setState(() {});
                                  },
                                ),
                              ),
                            );
                            setState(() {});
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                        Icons.account_balance_wallet,
                                        color: Colors.purple,
                                        size: 20),
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
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                            progressColor),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      'จัดสรร: ฿${_fmt.format(allocated)}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600]),
                                    ),
                                    const Spacer(),
                                    Text(
                                      remaining >= 0
                                          ? 'คงเหลือ: ฿${_fmt.format(remaining)}'
                                          : 'เกินงบ: ฿${_fmt.format(remaining.abs())}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: remaining < 0
                                            ? Colors.red
                                            : Colors.green[700],
                                      ),
                                    ),
                                  ],
                                ),
                                if (budget.parts.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '${budget.parts.length} หมวดหมู่',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500]),
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
      floatingActionButton: FloatingActionButton(
        heroTag: 'budget_fab',
        onPressed: _showAddBudgetDialog,
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ─── Budget Detail Screen ─────────────────────────────────────────────────────

class BudgetDetailScreen extends StatefulWidget {
  final Budget budget;
  final VoidCallback onSave;

  const BudgetDetailScreen(
      {super.key, required this.budget, required this.onSave});

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
    final nameController =
        TextEditingController(text: editPart?.name ?? '');
    final amountController = TextEditingController(
        text: editPart?.amount.toStringAsFixed(2) ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(editPart == null ? 'เพิ่มหมวดหมู่' : 'แก้ไขหมวดหมู่'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'ชื่อหมวดหมู่',
                border: OutlineInputBorder(),
                hintText: 'เช่น ค่าอาหาร, ค่าเดินทาง',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'จำนวนเงิน (บาท)',
                border: OutlineInputBorder(),
                prefixText: '฿ ',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              final amount = double.tryParse(amountController.text);
              if (name.isEmpty || amount == null || amount <= 0) return;
              setState(() {
                if (editPart != null) {
                  editPart.name = name;
                  editPart.amount = amount;
                } else {
                  widget.budget.parts
                      .add(BudgetPart(name: name, amount: amount));
                }
              });
              widget.onSave();
              Navigator.pop(context);
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
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
    final progress = budget.totalAmount > 0
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
        backgroundColor: const Color(0xFFF3E5F5),
      ),
      body: Column(
        children: [
          // ── Summary header ──────────────────────────────────────────────
          Container(
            color: const Color(0xFFF3E5F5),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'งบประมาณรวม',
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 13),
                        ),
                        Text(
                          '฿${_fmt.format(budget.totalAmount)}',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
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
                    ),
                  ],
                ),
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
                      final color = _partColors[i % _partColors.length];
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
                                        '฿${_fmt.format(part.amount)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: color,
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

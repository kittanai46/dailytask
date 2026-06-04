import 'package:flutter/material.dart';
import '../models/shopping_bill.dart';
import '../services/storage_service.dart';
import 'shopping_bill_detail_screen.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  List<ShoppingBill> _bills = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  Future<void> _loadBills() async {
    final bills = await StorageService.getShoppingBills();
    setState(() {
      _bills = bills;
      _isLoading = false;
    });
  }

  Future<void> _saveBills() async {
    await StorageService.saveShoppingBills(_bills);
  }

  void _showAddBillDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.receipt_long, color: Colors.green, size: 22),
            ),
            const SizedBox(width: 12),
            const Text('สร้างบิลใหม่'),
          ],
        ),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'ชื่อบิล (เช่น Makro, Lotus)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            prefixIcon: const Icon(Icons.shopping_bag_outlined),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (_) => _submitBill(nameController),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: const Text('สร้าง'),
            onPressed: () => _submitBill(nameController),
          ),
        ],
      ),
    );
  }

  void _submitBill(TextEditingController controller) {
    final name = controller.text.trim();
    if (name.isEmpty) return;
    final bill = ShoppingBill(name: name);
    setState(() => _bills.insert(0, bill));
    _saveBills();
    Navigator.pop(context);
    _openBill(bill);
  }

  void _openBill(ShoppingBill bill) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShoppingBillDetailScreen(bill: bill),
      ),
    ).then((_) => _loadBills());
  }

  Color _statusColor(ShoppingBill bill) {
    if (bill.totalCount == 0) return Colors.blueGrey;
    if (bill.isCompleted) return Colors.green;
    return Colors.orange;
  }

  IconData _statusIcon(ShoppingBill bill) {
    if (bill.totalCount == 0) return Icons.shopping_cart_outlined;
    if (bill.isCompleted) return Icons.check_circle_outline;
    return Icons.shopping_cart;
  }

  String _formatDate(DateTime date) {
    const months = [
      '', 'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
    ];
    return '${date.day} ${months[date.month]} ${date.year + 543}';
  }

  Widget _buildBillCard(ShoppingBill bill) {
    final color = _statusColor(bill);
    final icon = _statusIcon(bill);
    final progress =
        bill.totalCount > 0 ? bill.checkedCount / bill.totalCount : 0.0;

    return Dismissible(
      key: Key(bill.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text('ลบ', style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        bool confirmed = false;
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('ลบบิล?'),
            content: Text(
                'ลบบิล "${bill.name}" และรายการทั้งหมด ${bill.totalCount} รายการ'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ยกเลิก'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  confirmed = true;
                  Navigator.pop(context);
                },
                child: const Text('ลบ'),
              ),
            ],
          ),
        );
        return confirmed;
      },
      onDismissed: (_) {
        setState(() => _bills.removeWhere((b) => b.id == bill.id));
        _saveBills();
      },
      child: Card(
        elevation: 2,
        shadowColor: color.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openBill(bill),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bill.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(bill.createdAt),
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                    if (bill.isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'ครบแล้ว',
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                      )
                    else
                      Icon(Icons.chevron_right, color: Colors.grey[400]),
                  ],
                ),
                if (bill.totalCount > 0) ...[
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.checklist_rounded,
                          size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        '${bill.checkedCount}/${bill.totalCount} รายการ',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      if (bill.totalPrice > 0) ...[
                        Icon(Icons.payments_outlined,
                            size: 14, color: Colors.green[600]),
                        const SizedBox(width: 4),
                        Text(
                          '฿${bill.totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.green[700]),
                        ),
                      ],
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 10),
                  Text(
                    'ยังไม่มีรายการ — แตะเพื่อเพิ่ม',
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryHeader() {
    final totalBills = _bills.length;
    final completedBills = _bills.where((b) => b.isCompleted).length;
    final totalItems = _bills.fold(0, (sum, b) => sum + b.totalCount);
    final checkedItems = _bills.fold(0, (sum, b) => sum + b.checkedCount);
    final grandTotal =
        _bills.fold(0.0, (s, b) => s + b.totalPrice);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _summaryTile(
            icon: Icons.receipt_long,
            value: '$completedBills/$totalBills',
            label: 'บิล',
          ),
          Container(width: 1, height: 40, color: Colors.white24),
          _summaryTile(
            icon: Icons.checklist_rounded,
            value: '$checkedItems/$totalItems',
            label: 'รายการ',
          ),
          Container(width: 1, height: 40, color: Colors.white24),
          _summaryTile(
            icon: Icons.payments_outlined,
            value: totalItems > 0
                ? '฿${grandTotal.toStringAsFixed(0)}'
                : '—',
            label: 'ยอดรวม',
          ),
        ],
      ),
    );
  }

  Widget _summaryTile(
      {required IconData icon,
      required String value,
      required String label}) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการช้อปปิ้ง'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'สร้างบิลใหม่',
            onPressed: _showAddBillDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bills.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.receipt_long_outlined,
                          size: 72,
                          color: Colors.green.withOpacity(0.4),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'ยังไม่มีบิล',
                        style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 18,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'กด + เพื่อสร้างบิลช้อปปิ้งใหม่',
                        style:
                            TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                      const SizedBox(height: 28),
                      FilledButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('สร้างบิลใหม่'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _showAddBillDialog,
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    _buildSummaryHeader(),
                    Expanded(
                      child: ListView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(16, 12, 16, 80),
                        itemCount: _bills.length,
                        itemBuilder: (_, i) => _buildBillCard(_bills[i]),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: _bills.isNotEmpty
          ? FloatingActionButton.extended(
              heroTag: 'shopping_fab',
              onPressed: _showAddBillDialog,
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('สร้างบิล'),
            )
          : null,
    );
  }
}

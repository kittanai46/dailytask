// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../models/shopping_bill.dart';
import '../models/shopping_item.dart';
import '../services/storage_service.dart';

class ShoppingBillDetailScreen extends StatefulWidget {
  final ShoppingBill bill;

  const ShoppingBillDetailScreen({super.key, required this.bill});

  @override
  State<ShoppingBillDetailScreen> createState() =>
      _ShoppingBillDetailScreenState();
}

class _ShoppingBillDetailScreenState extends State<ShoppingBillDetailScreen> {
  late List<ShoppingItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.bill.items);
  }

  Future<void> _saveItems() async {
    final allBills = await StorageService.getShoppingBills();
    final idx = allBills.indexWhere((b) => b.id == widget.bill.id);
    if (idx >= 0) {
      allBills[idx].items = _items;
      await StorageService.saveShoppingBills(allBills);
    }
  }

  void _toggleItem(ShoppingItem item) {
    setState(() => item.isChecked = !item.isChecked);
    _saveItems();
  }

  void _deleteItem(ShoppingItem item) {
    setState(() => _items.removeWhere((i) => i.id == item.id));
    _saveItems();
  }

  void _clearChecked() {
    setState(() => _items.removeWhere((i) => i.isChecked));
    _saveItems();
  }

  void _showAddItemDialog({ShoppingItem? editItem}) {
    final nameController =
        TextEditingController(text: editItem?.name ?? '');
    final qtyController =
        TextEditingController(text: editItem?.quantity.toString() ?? '1');
    final priceController = TextEditingController(
        text: editItem?.price?.toStringAsFixed(2) ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    editItem == null
                        ? Icons.add_shopping_cart
                        : Icons.edit_outlined,
                    color: Colors.green,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  editItem == null ? 'เพิ่มสินค้า' : 'แก้ไขสินค้า',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'ชื่อสินค้า',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                filled: true,
                prefixIcon: const Icon(Icons.inventory_2_outlined),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: qtyController,
                    decoration: InputDecoration(
                      labelText: 'จำนวน',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      prefixIcon: const Icon(Icons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: 'ราคา/ชิ้น',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      prefixText: '฿ ',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('ยกเลิก'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    icon: Icon(
                        editItem == null ? Icons.add : Icons.check, size: 18),
                    label: Text(editItem == null ? 'เพิ่มสินค้า' : 'บันทึก'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (nameController.text.trim().isEmpty) return;
                      final qty = int.tryParse(qtyController.text) ?? 1;
                      final price = double.tryParse(priceController.text);
                      if (editItem != null) {
                        setState(() {
                          editItem.name = nameController.text.trim();
                          editItem.quantity = qty < 1 ? 1 : qty;
                          editItem.price = price;
                        });
                      } else {
                        setState(() {
                          _items.add(ShoppingItem(
                            name: nameController.text.trim(),
                            quantity: qty < 1 ? 1 : qty,
                            price: price,
                          ));
                        });
                      }
                      _saveItems();
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double get _totalPrice => _items
      .where((i) => i.price != null)
      .fold(0.0, (sum, i) => sum + (i.price! * i.quantity));

  int get _checkedCount => _items.where((i) => i.isChecked).length;

  Widget _buildHeader() {
    final progress =
        _items.isNotEmpty ? _checkedCount / _items.length : 0.0;
    final isCompleted = _items.isNotEmpty && _checkedCount == _items.length;
    final headerColor = isCompleted ? Colors.green : const Color(0xFF1E8449);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCompleted
              ? [const Color(0xFF1B5E20), const Color(0xFF43A047)]
              : [const Color(0xFF2E7D32), const Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: headerColor.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ยอดรวม',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _totalPrice > 0
                          ? '฿${_totalPrice.toStringAsFixed(2)}'
                          : '—',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$_checkedCount/${_items.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'รายการ',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          if (_items.isNotEmpty) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withOpacity(0.25),
                valueColor:
                    const AlwaysStoppedAnimation(Colors.white),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            if (isCompleted)
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'ช้อปครบแล้ว!',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemTile(ShoppingItem item) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 26),
      ),
      onDismissed: (_) => _deleteItem(item),
      child: Card(
        elevation: item.isChecked ? 0 : 1,
        margin: const EdgeInsets.only(bottom: 8),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        color: item.isChecked
            ? Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5)
            : null,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _toggleItem(item),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Transform.scale(
                  scale: 1.1,
                  child: Checkbox(
                    value: item.isChecked,
                    onChanged: (_) => _toggleItem(item),
                    activeColor: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          decoration: item.isChecked
                              ? TextDecoration.lineThrough
                              : null,
                          color: item.isChecked ? Colors.grey[400] : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'x${item.quantity}',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          if (item.price != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              '฿${item.price!.toStringAsFixed(2)}/ชิ้น',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[500]),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (item.price != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: item.isChecked
                          ? Colors.grey[100]
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '฿${(item.price! * item.quantity).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: item.isChecked
                            ? Colors.grey[400]
                            : Colors.green[700],
                      ),
                    ),
                  ),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(Icons.edit_outlined,
                      size: 18, color: Colors.grey[400]),
                  onPressed: () => _showAddItemDialog(editItem: item),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unchecked = _items.where((i) => !i.isChecked).toList();
    final checked = _items.where((i) => i.isChecked).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bill.name),
        actions: [
          if (checked.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'ลบที่ซื้อแล้ว',
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  title: const Text('ลบรายการที่ซื้อแล้ว?'),
                  content:
                      Text('จะลบ ${checked.length} รายการที่เช็คแล้ว'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('ยกเลิก'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: Colors.red),
                      onPressed: () {
                        _clearChecked();
                        Navigator.pop(context);
                      },
                      child: const Text('ลบ'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_shopping_cart_outlined,
                            size: 60,
                            color: Colors.green.withOpacity(0.4),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'ยังไม่มีสินค้าในบิลนี้',
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'กด + เพื่อเพิ่มสินค้า',
                          style: TextStyle(
                              color: Colors.grey[400], fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding:
                        const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    children: [
                      ...unchecked.map(_buildItemTile),
                      if (checked.isNotEmpty) ...[
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline,
                                  size: 16, color: Colors.grey[400]),
                              const SizedBox(width: 6),
                              Text(
                                'ซื้อแล้ว (${checked.length})',
                                style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Divider(color: Colors.grey[300])),
                            ],
                          ),
                        ),
                        ...checked.map(_buildItemTile),
                      ],
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'bill_detail_fab',
        onPressed: _showAddItemDialog,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มสินค้า'),
      ),
    );
  }
}

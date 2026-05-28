import 'package:flutter/material.dart';
import '../models/shopping_item.dart';
import '../services/storage_service.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  List<ShoppingItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await StorageService.getShoppingItems();
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  Future<void> _saveItems() async {
    await StorageService.saveShoppingItems(_items);
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
    final priceController =
        TextEditingController(text: editItem?.price?.toStringAsFixed(2) ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(editItem == null ? 'เพิ่มสินค้า' : 'แก้ไขสินค้า'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'ชื่อสินค้า',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: qtyController,
                    decoration: const InputDecoration(
                      labelText: 'จำนวน',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'ราคา/ชิ้น',
                      border: OutlineInputBorder(),
                      prefixText: '฿',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                  ),
                ),
              ],
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
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  double get _totalPrice {
    return _items
        .where((i) => i.price != null)
        .fold(0, (sum, i) => sum + (i.price! * i.quantity));
  }

  Widget _buildShoppingTile(ShoppingItem item) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _deleteItem(item),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Checkbox(
            value: item.isChecked,
            onChanged: (_) => _toggleItem(item),
            activeColor: Colors.green,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4)),
          ),
          title: Text(
            item.name,
            style: TextStyle(
              decoration:
                  item.isChecked ? TextDecoration.lineThrough : null,
              color: item.isChecked ? Colors.grey : null,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Row(
            children: [
              Text(
                'จำนวน: ${item.quantity}',
                style: const TextStyle(fontSize: 12),
              ),
              if (item.price != null) ...[
                const SizedBox(width: 8),
                Text(
                  '฿${(item.price! * item.quantity).toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 12, color: Colors.green),
                ),
              ],
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => _showAddItemDialog(editItem: item),
          ),
          onTap: () => _toggleItem(item),
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
        title: const Text('รายการช้อปปิ้ง'),
        backgroundColor: const Color(0xFFE8F5E9),
        actions: [
          if (checked.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'ลบที่ซื้อแล้ว',
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('ลบรายการที่ซื้อแล้ว?'),
                  content: Text(
                      'จะลบ ${checked.length} รายการที่เช็คแล้ว'),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_items.isNotEmpty && _totalPrice > 0)
                  Container(
                    color: const Color(0xFFE8F5E9),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.receipt_long,
                            size: 18, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          'ราคารวม: ฿${_totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Text(
                          '${checked.length}/${_items.length} รายการ',
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: _items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_cart_outlined,
                                  size: 72, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text(
                                'รายการว่าง',
                                style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'กด + เพื่อเพิ่มสินค้า',
                                style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            ...unchecked.map(_buildShoppingTile),
                            if (checked.isNotEmpty) ...[
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Text(
                                      'ซื้อแล้ว (${checked.length})',
                                      style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 13),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                        child:
                                            Divider(color: Colors.grey[300])),
                                  ],
                                ),
                              ),
                              ...checked.map(_buildShoppingTile),
                            ],
                          ],
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'shopping_fab',
        onPressed: () => _showAddItemDialog(),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

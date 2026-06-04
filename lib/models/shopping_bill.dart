import 'package:uuid/uuid.dart';
import 'shopping_item.dart';

class ShoppingBill {
  final String id;
  String name;
  final DateTime createdAt;
  List<ShoppingItem> items;

  ShoppingBill({
    String? id,
    required this.name,
    DateTime? createdAt,
    List<ShoppingItem>? items,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        items = items ?? [];

  double get totalPrice => items
      .where((i) => i.price != null)
      .fold(0.0, (sum, i) => sum + (i.price! * i.quantity));

  int get checkedCount => items.where((i) => i.isChecked).length;
  int get totalCount => items.length;
  bool get isCompleted => totalCount > 0 && checkedCount == totalCount;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
      };

  factory ShoppingBill.fromJson(Map<String, dynamic> json) => ShoppingBill(
        id: json['id'] as String,
        name: json['name'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        items: (json['items'] as List)
            .map((e) => ShoppingItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

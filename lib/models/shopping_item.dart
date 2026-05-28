import 'package:uuid/uuid.dart';

class ShoppingItem {
  final String id;
  String name;
  int quantity;
  double? price;
  bool isChecked;

  ShoppingItem({
    String? id,
    required this.name,
    this.quantity = 1,
    this.price,
    this.isChecked = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'quantity': quantity,
        'price': price,
        'isChecked': isChecked,
      };

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
        id: json['id'] as String,
        name: json['name'] as String,
        quantity: json['quantity'] as int? ?? 1,
        price: (json['price'] as num?)?.toDouble(),
        isChecked: json['isChecked'] as bool? ?? false,
      );
}

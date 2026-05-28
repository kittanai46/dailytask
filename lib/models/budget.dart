import 'package:uuid/uuid.dart';

class BudgetPart {
  final String id;
  String name;
  double amount;

  BudgetPart({
    String? id,
    required this.name,
    required this.amount,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
      };

  factory BudgetPart.fromJson(Map<String, dynamic> json) => BudgetPart(
        id: json['id'] as String,
        name: json['name'] as String,
        amount: (json['amount'] as num).toDouble(),
      );
}

class Budget {
  final String id;
  String name;
  double totalAmount;
  List<BudgetPart> parts;
  DateTime createdAt;

  Budget({
    String? id,
    required this.name,
    required this.totalAmount,
    List<BudgetPart>? parts,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        parts = parts ?? [],
        createdAt = createdAt ?? DateTime.now();

  double get allocatedAmount => parts.fold(0, (sum, p) => sum + p.amount);
  double get remainingAmount => totalAmount - allocatedAmount;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'totalAmount': totalAmount,
        'parts': parts.map((p) => p.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
        id: json['id'] as String,
        name: json['name'] as String,
        totalAmount: (json['totalAmount'] as num).toDouble(),
        parts: (json['parts'] as List)
            .map((p) => BudgetPart.fromJson(p as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

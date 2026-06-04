
import 'package:uuid/uuid.dart';
enum BudgetType { expense, saving }

enum BudgetPartType { income, expense }

class BudgetPart {
  final String id;
  String name;
  double amount;
  BudgetPartType type;
  int iconCodePoint;

  BudgetPart({
    String? id,
    required this.name,
    required this.amount,
    this.type = BudgetPartType.expense,
    this.iconCodePoint = 0xef63, // Default: Icons.attach_money
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'type': type.name,
        'icon': iconCodePoint,
      };

  factory BudgetPart.fromJson(Map<String, dynamic> json) => BudgetPart(
        id: json['id'] as String,
        name: json['name'] as String,
        amount: (json['amount'] as num).toDouble(),
        type: json['type'] == 'income' ? BudgetPartType.income : BudgetPartType.expense,
        iconCodePoint: json['icon'] is int ? json['icon'] as int : 0xef63,
      );
}

class Budget {

  final String id;
  String name;
  double totalAmount;
  List<BudgetPart> parts;
  DateTime createdAt;
  int iconCodePoint;

  BudgetType budgetType;

  Budget({
    String? id,
    required this.name,
    required this.totalAmount,
    List<BudgetPart>? parts,
    DateTime? createdAt,
    this.iconCodePoint = 0xef63,
    this.budgetType = BudgetType.expense,
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
        'icon': iconCodePoint,
        'budgetType': budgetType.name,
      };

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
        id: json['id'] as String,
        name: json['name'] as String,
        totalAmount: (json['totalAmount'] as num).toDouble(),
        parts: (json['parts'] as List)
            .map((p) => BudgetPart.fromJson(p as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        iconCodePoint: json['icon'] is int ? json['icon'] as int : 0xef63,
        budgetType: json['budgetType'] == 'saving' ? BudgetType.saving : BudgetType.expense,
      );
}

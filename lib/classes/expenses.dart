class Expense {
  final int expenseId;
  final DateTime createdAt;
  final int shopId;
  final String? name;
  final String? description;
  final double? amount;
  final Map<String, dynamic>? unit;

  Expense({
    required this.expenseId,
    required this.createdAt,
    required this.shopId,
    this.name,
    this.description,
    this.amount,
    this.unit,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      expenseId: json['expense_id'],
      createdAt: DateTime.parse(json['created_at']),
      shopId: json['shop_id'],
      name: json['name'],
      description: json['description'],
      amount: (json['amount'] as num?)?.toDouble(),
      unit:
          json['unit'] != null
              ? Map<String, dynamic>.from(json['unit'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expense_id': expenseId,
      'created_at': createdAt.toIso8601String(),
      'shop_id': shopId,
      'name': name,
      'description': description,
      'amount': amount,
      'unit': unit,
    };
  }
}

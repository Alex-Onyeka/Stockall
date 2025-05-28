class TempExpensesClass {
  final int? id;
  final DateTime? createdDate;
  final int shopId;
  final String name;
  final String? description;
  final double amount;
  final double? quantity;
  final String? unit;
  final String userId;

  TempExpensesClass({
    required this.name,
    this.description,
    required this.amount,
    this.quantity,
    this.unit,
    required this.shopId,
    this.id,
    this.createdDate,
    required this.userId,
  });

  factory TempExpensesClass.fromJson(
    Map<String, dynamic> json,
  ) {
    return TempExpensesClass(
      id: json['id'] as int?,
      createdDate:
          json['created_date'] != null
              ? DateTime.parse(json['created_date'])
              : null,
      shopId: json['shop_id'],
      name: json['name'],
      description: json['description'] as String?,
      amount: (json['amount'] as num).toDouble(),
      quantity:
          json['quantity'] != null
              ? (json['quantity'] as num).toDouble()
              : null,
      unit: json['unit'],
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shop_id': shopId,
      'name': name,
      'description': description,
      'amount': amount,
      'quantity': quantity,
      'unit': unit,
      'user_id': userId,
    };
  }
}

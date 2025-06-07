class TempMainReceipt {
  final int? id;
  final String? barcode;
  final DateTime createdAt;
  final int shopId;
  final String staffId;
  final String staffName;
  final int? customerId;
  final String paymentMethod;
  final double cashAlt;
  final double bank;
  String? departmentName;
  int? departmentId;

  TempMainReceipt({
    this.id,
    this.barcode,
    required this.createdAt,
    required this.shopId,
    required this.staffId,
    required this.staffName,
    this.customerId,
    required this.paymentMethod,
    required this.bank,
    required this.cashAlt,
    this.departmentName,
    this.departmentId,
  });

  factory TempMainReceipt.fromJson(
    Map<String, dynamic> json,
  ) {
    return TempMainReceipt(
      id: json['id'] as int?,
      barcode: json['barcode'] as String?,
      createdAt: DateTime.parse(json['created_at']),
      shopId: json['shop_id'],
      staffId: json['staff_id'],
      staffName: json['staff_name'],
      customerId: json['customer_id'],
      paymentMethod: json['payment_method'],
      cashAlt: (json['cash_alt'] as num).toDouble(),
      bank: (json['bank'] as num).toDouble(),
      departmentId: json['department_id'],
      departmentName: json['department_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'barcode': barcode,
      'created_at': createdAt.toIso8601String(),
      'shop_id': shopId,
      'staff_id': staffId,
      'staff_name': staffName,
      'customer_id': customerId,
      'payment_method': paymentMethod,
      'cash_alt': cashAlt,
      'bank': bank,
      'department_id': departmentId,
      'department_name': departmentName,
    };
  }
}

class RefundedRecord {
  final int id;
  final DateTime createdAt;
  final int? receiptId;
  final List<String>? productRecordId;
  final int? shopId;
  final String? staffId;
  final String? staffName;
  final int? customerId;

  RefundedRecord({
    required this.id,
    required this.createdAt,
    this.receiptId,
    this.productRecordId,
    this.shopId,
    this.staffId,
    this.staffName,
    this.customerId,
  });

  factory RefundedRecord.fromJson(
    Map<String, dynamic> json,
  ) {
    return RefundedRecord(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      receiptId: json['receipt_id'],
      productRecordId:
          (json['product_record_id'] as List?)
              ?.cast<String>(),
      shopId: json['shop_id'],
      staffId: json['staff_id'],
      staffName: json['staff_name'],
      customerId: json['customer_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'receipt_id': receiptId,
      'product_record_id': productRecordId,
      'shop_id': shopId,
      'staff_id': staffId,
      'staff_name': staffName,
      'customer_id': customerId,
    };
  }
}

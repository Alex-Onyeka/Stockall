class MainReceipt {
  final int id;
  final String? barcode;
  final DateTime createdAt;
  final List<String>? productRecordId;
  final int? shopId;
  final String? staffId;
  final String? staffName;
  final int? customerId;

  MainReceipt({
    required this.id,
    this.barcode,
    required this.createdAt,
    this.productRecordId,
    this.shopId,
    this.staffId,
    this.staffName,
    this.customerId,
  });

  factory MainReceipt.fromJson(Map<String, dynamic> json) {
    return MainReceipt(
      id: json['id'],
      barcode: json['barcode'],
      createdAt: DateTime.parse(json['created_at']),
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
      'barcode': barcode,
      'created_at': createdAt.toIso8601String(),
      'product_record_id': productRecordId,
      'shop_id': shopId,
      'staff_id': staffId,
      'staff_name': staffName,
      'customer_id': customerId,
    };
  }
}

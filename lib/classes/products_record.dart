class ProductRecord {
  final int productRecordId;
  final DateTime createdAt;
  final int productId;
  final int shopId;
  final String? staffId;
  final int? customerId;
  final String? staffName;
  final int? recepitId;
  final double? quantity;
  final int? revenue;

  ProductRecord({
    required this.productRecordId,
    required this.createdAt,
    required this.productId,
    required this.shopId,
    this.staffId,
    this.customerId,
    this.staffName,
    this.recepitId,
    this.quantity,
    this.revenue,
  });

  factory ProductRecord.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProductRecord(
      productRecordId: json['product_record_id'],
      createdAt: DateTime.parse(json['created_at']),
      productId: json['product_id'],
      shopId: json['shop_id'],
      staffId: json['staff_id'],
      customerId: json['customer_id'],
      staffName: json['staff_name'],
      recepitId: json['recepit_id'],
      quantity: (json['quantity'] as num?)?.toDouble(),
      revenue: json['revenue'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_record_id': productRecordId,
      'created_at': createdAt.toIso8601String(),
      'product_id': productId,
      'shop_id': shopId,
      'staff_id': staffId,
      'customer_id': customerId,
      'staff_name': staffName,
      'recepit_id': recepitId,
      'quantity': quantity,
      'revenue': revenue,
    };
  }
}

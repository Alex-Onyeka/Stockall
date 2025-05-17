class TempProductSaleRecord {
  final int? productRecordId;
  final DateTime createdAt;
  final int productId;
  final int shopId;
  final String staffId;
  final int? customerId;
  final String staffName;
  final int recepitId;
  final double? discount;
  final double quantity;
  final double revenue;
  final double? discountedAmount;
  final double? originalCost;

  TempProductSaleRecord({
    this.productRecordId,
    required this.createdAt,
    required this.productId,
    required this.shopId,
    required this.staffId,
    this.customerId,
    required this.staffName,
    required this.recepitId,
    required this.quantity,
    required this.revenue,
    required this.discountedAmount,
    required this.originalCost,
    required this.discount,
  });

  factory TempProductSaleRecord.fromJson(
    Map<String, dynamic> json,
  ) {
    return TempProductSaleRecord(
      productRecordId: json['product_record_id'] as int?,
      createdAt: DateTime.parse(
        json['created_at'] as String,
      ),
      productId: json['product_id'] as int,
      shopId: json['shop_id'] as int,
      staffId: json['staff_id'] as String,
      customerId: json['customer_id'] as int?,
      staffName: json['staff_name'] as String,
      recepitId: json['recepit_id'] as int,
      discount: (json['discount'] as num?)?.toDouble(),
      quantity: (json['quantity'] as num).toDouble(),
      revenue: (json['revenue'] as num).toDouble(),
      discountedAmount:
          (json['discounted_amount'] as num?)?.toDouble(),
      originalCost:
          (json['original_cost'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt.toIso8601String(),
      'product_id': productId,
      'shop_id': shopId,
      'staff_id': staffId,
      'customer_id': customerId,
      'staff_name': staffName,
      'recepit_id': recepitId,
      'discount': discount,
      'quantity': quantity,
      'revenue': revenue,
      'discounted_amount': discountedAmount,
      'original_cost': originalCost,
    };
  }
}

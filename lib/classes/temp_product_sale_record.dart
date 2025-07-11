class TempProductSaleRecord {
  final int? productRecordId;
  final DateTime createdAt;
  final int productId;
  final String productName;
  final int shopId;
  final String staffId;
  final int? customerId;
  final String? customerName;
  final String staffName;
  final int recepitId;
  final double? discount;
  final double quantity;
  final double revenue;
  final double? discountedAmount;
  final double? originalCost;
  final double? costPrice;
  final bool customPriceSet;
  String? departmentName;
  int? departmentId;
  bool? addToStock;

  TempProductSaleRecord({
    this.productRecordId,
    required this.createdAt,
    required this.productId,
    required this.productName,
    required this.shopId,
    required this.staffId,
    this.customerId,
    this.customerName,
    required this.staffName,
    required this.recepitId,
    required this.quantity,
    required this.revenue,
    required this.discountedAmount,
    required this.originalCost,
    required this.discount,
    this.costPrice,
    required this.customPriceSet,
    this.departmentName,
    this.departmentId,
    this.addToStock,
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
      productName: json['product_name'] as String,
      shopId: json['shop_id'] as int,
      staffId: json['staff_id'] as String,
      customerId: json['customer_id'] as int?,
      customerName: json['customer_name'] as String?,
      staffName: json['staff_name'] as String,
      recepitId: json['recepit_id'] as int,
      discount: (json['discount'] as num?)?.toDouble(),
      quantity: (json['quantity'] as num).toDouble(),
      revenue: (json['revenue'] as num).toDouble(),
      discountedAmount:
          (json['discounted_amount'] as num?)?.toDouble(),
      originalCost:
          (json['original_cost'] as num?)?.toDouble(),
      costPrice: (json['cost_price'] as num?)?.toDouble(),
      customPriceSet: json['custom_price_set'],
      departmentId: json['department_id'],
      departmentName: json['department_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt.toIso8601String(),
      'product_id': productId,
      'product_name': productName,
      'shop_id': shopId,
      'staff_id': staffId,
      'customer_id': customerId,
      'customer_name': customerName,
      'staff_name': staffName,
      'recepit_id': recepitId,
      'discount': discount,
      'quantity': quantity,
      'revenue': revenue,
      'discounted_amount': discountedAmount,
      'original_cost': originalCost,
      'cost_price': costPrice,
      'custom_price_set': customPriceSet,
      'department_id': departmentId,
      'department_name': departmentName,
    };
  }
}

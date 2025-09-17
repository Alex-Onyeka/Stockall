import 'package:hive/hive.dart';

part 'temp_product_sale_record.g.dart';

@HiveType(typeId: 6)
class TempProductSaleRecord {
  @HiveField(0)
  final int? productRecordId;

  @HiveField(1)
  final DateTime createdAt;

  @HiveField(2)
  final int productId;

  @HiveField(3)
  final String productName;

  @HiveField(4)
  final int shopId;

  @HiveField(5)
  final String staffId;

  @HiveField(6)
  final int? customerId;

  @HiveField(7)
  final String? customerName;

  @HiveField(8)
  final String staffName;

  @HiveField(9)
  final int recepitId;

  @HiveField(10)
  final double? discount;

  @HiveField(11)
  final double quantity;

  @HiveField(12)
  final double revenue;

  @HiveField(13)
  final double? discountedAmount;

  @HiveField(14)
  final double? originalCost;

  @HiveField(15)
  final double? costPrice;

  @HiveField(16)
  final bool customPriceSet;

  @HiveField(17)
  String? departmentName;

  @HiveField(18)
  int? departmentId;

  @HiveField(19)
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
      customPriceSet: json['custom_price_set'] as bool,
      departmentId: json['department_id'] as int?,
      departmentName: json['department_name'] as String?,
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

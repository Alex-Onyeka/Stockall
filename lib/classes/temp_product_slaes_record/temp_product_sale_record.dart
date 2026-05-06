import 'package:hive/hive.dart';

part 'temp_product_sale_record.g.dart';

@HiveType(typeId: 6)
class TempProductSaleRecord {
  @HiveField(0)
  int? productRecordId;

  @HiveField(1)
  DateTime createdAt;

  @HiveField(2)
  final int productId;

  @HiveField(3)
  String productName;

  @HiveField(4)
  int shopId;

  @HiveField(5)
  String staffId;

  @HiveField(6)
  int? customerId;

  @HiveField(7)
  String? customerName;

  @HiveField(8)
  String staffName;

  @HiveField(9)
  int recepitId;

  @HiveField(10)
  double? discount;

  @HiveField(11)
  double quantity;

  @HiveField(12)
  double revenue;

  @HiveField(13)
  double? discountedAmount;

  @HiveField(14)
  double? originalCost;

  @HiveField(15)
  double? costPrice;

  @HiveField(16)
  bool customPriceSet;

  @HiveField(17)
  String? departmentName;

  @HiveField(18)
  String? departmentUuid;

  @HiveField(19)
  bool? addToStock;

  @HiveField(20)
  String? uuid;

  @HiveField(21)
  String? productUuid;

  @HiveField(22)
  String? customerUuid;

  @HiveField(23)
  String? receiptUuid;

  @HiveField(24)
  bool? isProductManaged;

  @HiveField(25)
  bool? setTotalPrice;

  @HiveField(26)
  String? invoiceUuid;

  @HiveField(27)
  double? fixedDiscount;

  @HiveField(28)
  String? unit;

  @HiveField(29)
  bool? useWholeSalePrice;

  @HiveField(30)
  bool? useGroupQuantity;

  @HiveField(31)
  double? qttyPerGroup;

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
    required this.departmentName,
    required this.departmentUuid,
    this.addToStock,
    this.uuid,
    this.productUuid,
    this.customerUuid,
    this.receiptUuid,
    required this.isProductManaged,
    this.setTotalPrice,
    this.invoiceUuid,
    this.fixedDiscount,
    this.unit,
    this.useWholeSalePrice,
    required this.useGroupQuantity,
    required this.qttyPerGroup,
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
      departmentUuid: json['department_uuid'] as String?,
      departmentName: json['department_name'] as String?,
      uuid: json['uuid'] as String?,
      productUuid: json['product_uuid'] as String?,
      customerUuid: json['customer_uuid'] as String?,
      receiptUuid: json['receipt_uuid'] as String?,
      isProductManaged: json['is_product_managed'] as bool?,
      setTotalPrice: json['set_total_price'] as bool?,
      invoiceUuid: json['invoice_uuid'] as String?,
      fixedDiscount:
          (json['fixed_discount'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      useWholeSalePrice: json['use_whole_sale_price'],
      useGroupQuantity: json['sell_group'],
      qttyPerGroup:
          (json['qtty_per_group'] as num?)?.toDouble(),
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
      'department_uuid': departmentUuid,
      'department_name': departmentName,
      'uuid': uuid,
      'product_uuid': productUuid,
      'receipt_uuid': receiptUuid,
      'customer_uuid': customerUuid,
      'is_product_managed': isProductManaged,
      'set_total_price': setTotalPrice,
      'invoice_uuid': invoiceUuid,
      'fixed_discount': fixedDiscount,
      'unit': unit,
      'use_whole_sale_price': useWholeSalePrice,
      'sell_group': useGroupQuantity,
      'qtty_per_group': qttyPerGroup,
    };
  }

  TempProductSaleRecord copy({
    int? productRecordId,
    DateTime? createdAt,
    int? productId,
    String? productName,
    int? shopId,
    String? staffId,
    int? customerId,
    String? customerName,
    String? staffName,
    int? recepitId,
    double? discount,
    double? quantity,
    double? revenue,
    double? discountedAmount,
    double? originalCost,
    double? costPrice,
    bool? customPriceSet,
    String? departmentName,
    String? departmentUuid,
    bool? addToStock,
    String? uuid,
    String? productUuid,
    String? customerUuid,
    String? receiptUuid,
    bool? isProductManaged,
    bool? setTotalPrice,
    String? unit,
    bool? useWholeSalePrice,
    bool? useGroupQuantity,
    double? qttyPerGroup,
  }) {
    return TempProductSaleRecord(
      productRecordId:
          productRecordId ?? this.productRecordId,
      createdAt: createdAt ?? this.createdAt,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      shopId: shopId ?? this.shopId,
      staffId: staffId ?? this.staffId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      staffName: staffName ?? this.staffName,
      recepitId: recepitId ?? this.recepitId,
      discount: discount ?? this.discount,
      quantity: quantity ?? this.quantity,
      revenue: revenue ?? this.revenue,
      discountedAmount:
          discountedAmount ?? this.discountedAmount,
      originalCost: originalCost ?? this.originalCost,
      costPrice: costPrice ?? this.costPrice,
      customPriceSet: customPriceSet ?? this.customPriceSet,
      departmentName: departmentName ?? this.departmentName,
      departmentUuid: departmentUuid ?? this.departmentUuid,
      addToStock: addToStock ?? this.addToStock,
      uuid: uuid ?? this.uuid,
      productUuid: productUuid ?? this.productUuid,
      customerUuid: customerUuid ?? this.customerUuid,
      receiptUuid: receiptUuid ?? this.receiptUuid,
      isProductManaged:
          isProductManaged ?? this.isProductManaged,
      setTotalPrice: setTotalPrice ?? this.setTotalPrice,
      unit: unit ?? this.unit,
      useWholeSalePrice:
          useWholeSalePrice ?? this.useWholeSalePrice,
      useGroupQuantity:
          useGroupQuantity ?? this.useGroupQuantity,
      qttyPerGroup: qttyPerGroup ?? this.qttyPerGroup,
    );
  }
}

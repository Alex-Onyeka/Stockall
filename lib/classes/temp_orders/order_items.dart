import 'package:hive/hive.dart';

part 'order_items.g.dart';

@HiveType(typeId: 133)
class OrderItems extends HiveObject {
  @HiveField(0)
  final String uuid;

  @HiveField(1)
  final String orderId;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  String productName;

  @HiveField(4)
  String productUuid;

  @HiveField(5)
  String staffId;

  @HiveField(6)
  String staffName;

  @HiveField(7)
  String? customerName;

  @HiveField(8)
  String? customerUuid;

  @HiveField(9)
  double? discount;

  @HiveField(10)
  double quantity;

  @HiveField(11)
  double revenue;

  @HiveField(12)
  double? discountedAmount;

  @HiveField(13)
  double? originalCost;

  @HiveField(14)
  double? costPrice;

  @HiveField(15)
  bool customPriceSet;

  @HiveField(16)
  String? departmentName;

  @HiveField(17)
  String? departmentUuid;

  @HiveField(18)
  bool? addToStock;

  @HiveField(19)
  bool? isProductManaged;

  @HiveField(20)
  bool? setTotalPrice;

  @HiveField(21)
  double? fixedDiscount;

  @HiveField(22)
  String? unit;

  @HiveField(23)
  String? groupUnit;

  @HiveField(24)
  bool? useWholeSalePrice;

  @HiveField(25)
  bool? useGroupQuantity;

  @HiveField(26)
  double? qttyPerGroup;

  OrderItems({
    required this.uuid,
    required this.orderId,
    required this.productName,
    required this.productUuid,
    required this.createdAt,
    required this.staffName,
    required this.staffId,
    required this.costPrice,
    required this.customerName,
    required this.customerUuid,
    required this.departmentName,
    required this.departmentUuid,
    required this.qttyPerGroup,
    required this.quantity,
    required this.revenue,
    required this.unit,
    required this.useGroupQuantity,
    required this.useWholeSalePrice,
    required this.groupUnit,
    required this.addToStock,
    required this.customPriceSet,
    required this.discount,
    required this.discountedAmount,
    required this.fixedDiscount,
    required this.isProductManaged,
    required this.originalCost,
    required this.setTotalPrice,
  });

  factory OrderItems.fromJson(Map<String, dynamic> json) {
    return OrderItems(
      uuid: json['uuid'],
      orderId: json['order_id'],
      createdAt: DateTime.parse(json['created_at']),
      productName: json['product_name'] as String,
      productUuid: json['product_uuid'] as String,
      staffName: json['staff_name'],
      staffId: json['staff_uuid'] as String,
      costPrice: (json['cost_price'] as num?)?.toDouble(),
      quantity: (json['quantity'] as num).toDouble(),
      revenue: (json['revenue'] as num).toDouble(),
      customerName: json['customer_name'] as String?,
      customerUuid: json['customer_uuid'] as String?,
      departmentName: json['department_name'] as String?,
      departmentUuid: json['department_uuid'] as String?,
      qttyPerGroup:
          (json['qtty_per_group'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      groupUnit: json['group_unit'] as String?,
      useGroupQuantity: json['use_group_quantity'] as bool?,
      useWholeSalePrice:
          json['use_whole_sale_price'] as bool?,
      addToStock: json['add_to_stock'] as bool?,
      customPriceSet: json['custom_price_set'] as bool,
      discount: (json['discount'] as num?)?.toDouble(),
      discountedAmount:
          (json['discounted_amount'] as num?)?.toDouble(),
      fixedDiscount:
          (json['fixed_discount'] as num?)?.toDouble(),
      isProductManaged: json['is_product_managed'] as bool,
      originalCost:
          (json['original_cost'] as num?)?.toDouble(),
      setTotalPrice: json['set_total_price'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'order_id': orderId,
      'created_at': createdAt.toIso8601String(),
      'product_uuid': productUuid,
      'product_name': productName,
      'staff_name': staffName,
      'staff_uuid': staffId,
      'cost_price': costPrice,
      'quantity': quantity,
      'revenue': revenue,
      'customer_name': customerName,
      'customer_uuid': customerUuid,
      'department_name': departmentName,
      'department_uuid': departmentUuid,
      'qtty_per_group': qttyPerGroup,
      'unit': unit,
      'group_unit': groupUnit,
      'use_group_quantity': useGroupQuantity,
      'use_whole_sale_price': useWholeSalePrice,
      'add_to_stock': addToStock,
      'custom_price_set': customPriceSet,
      'discount': discount,
      'discounted_amount': discountedAmount,
      'fixed_discount': fixedDiscount,
      'is_product_managed': isProductManaged,
      'original_cost': originalCost,
      'set_total_price': setTotalPrice,
    };
  }

  OrderItems copyWith({
    String? uuid,
    String? orderId,
    DateTime? createdAt,
    String? productUuid,
    String? productName,
    String? staffId,
    String? staffName,
    String? customerUuid,
    String? customerName,
    double? quantity,
    double? revenue,
    double? costPrice,
    String? departmentName,
    String? departmentUuid,
    String? unit,
    bool? useWholeSalePrice,
    bool? useGroupQuantity,
    double? qttyPerGroup,
    String? groupUnit,
    bool? addToStock,
    bool? customPriceSet,
    double? discount,
    double? discountedAmount,
    double? fixedDiscount,
    bool? isProductManaged,
    double? originalCost,
    bool? setTotalPrice,
  }) {
    return OrderItems(
      uuid: uuid ?? this.uuid,
      orderId: orderId ?? this.orderId,
      createdAt: createdAt ?? this.createdAt,
      productUuid: productUuid ?? this.productUuid,
      productName: productName ?? this.productName,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      customerUuid: customerUuid ?? this.customerUuid,
      customerName: customerName ?? this.customerName,
      quantity: quantity ?? this.quantity,
      revenue: revenue ?? this.revenue,
      costPrice: costPrice ?? this.costPrice,
      departmentName: departmentName ?? this.departmentName,
      departmentUuid: departmentUuid ?? this.departmentUuid,
      unit: unit ?? this.unit,
      useWholeSalePrice:
          useWholeSalePrice ?? this.useWholeSalePrice,
      useGroupQuantity:
          useGroupQuantity ?? this.useGroupQuantity,
      qttyPerGroup: qttyPerGroup ?? this.qttyPerGroup,
      groupUnit: groupUnit ?? this.groupUnit,
      addToStock: addToStock ?? this.addToStock,
      customPriceSet: customPriceSet ?? this.customPriceSet,
      discount: discount ?? this.discount,
      discountedAmount:
          discountedAmount ?? this.discountedAmount,
      fixedDiscount: fixedDiscount ?? this.fixedDiscount,
      isProductManaged:
          isProductManaged ?? this.isProductManaged,
      originalCost: originalCost ?? this.originalCost,
      setTotalPrice: setTotalPrice ?? this.setTotalPrice,
    );
  }
}

class StaffGroupOrders {
  final String? staffUuid;
  final String? staffName;
  int number;
  double totalBalance;
  double totalOriginalCost;
  double totalRevenue;

  StaffGroupOrders({
    required this.staffUuid,
    required this.staffName,
    required this.number,
    required this.totalBalance,
    required this.totalOriginalCost,
    required this.totalRevenue,
  });
}

class CustomerGroupOrders {
  final String? customerUuid;
  final String? customerName;
  int number;
  double totalBalance;
  double totalOriginalCost;
  double totalRevenue;

  CustomerGroupOrders({
    required this.customerUuid,
    required this.customerName,
    required this.number,
    required this.totalBalance,
    required this.totalOriginalCost,
    required this.totalRevenue,
  });
}

class DepartmentGroupOrders {
  final String departmentUuid;
  final String? departmentName;
  int number;
  double totalBalance;
  double totalOriginalCost;
  double totalRevenue;

  DepartmentGroupOrders({
    required this.departmentUuid,
    required this.departmentName,
    required this.number,
    required this.totalBalance,
    required this.totalOriginalCost,
    required this.totalRevenue,
  });
}

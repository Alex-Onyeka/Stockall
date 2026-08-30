import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_orders/order_items.dart';

part 'orders.g.dart';

@HiveType(typeId: 134)
class Orders extends HiveObject {
  @HiveField(0)
  String? uuid;

  @HiveField(1)
  DateTime createdAt;

  @HiveField(2)
  int shopId;

  @HiveField(3)
  String? staffId;

  @HiveField(4)
  String? staffName;

  @HiveField(5)
  String? customerId;

  @HiveField(6)
  String? customerName;

  @HiveField(7)
  String? departmentUuid;

  @HiveField(8)
  String? departmentName;

  @HiveField(9)
  double? total;

  @HiveField(10)
  List<OrderItems> orderItems;

  @HiveField(11)
  DateTime? updatedAt;

  @HiveField(12)
  String? barcode;

  @HiveField(13)
  double? vat;

  @HiveField(14)
  String? comment;

  @HiveField(15)
  double? originalCost;

  @HiveField(16)
  double? balance;

  @HiveField(17)
  double? generalDiscount;

  @HiveField(18)
  double? fixedDiscount;

  @HiveField(19)
  String? cartName;

  @HiveField(20)
  String? subStaffName;

  @HiveField(21)
  String? subStaffUuid;

  Orders({
    required this.createdAt,
    required this.shopId,
    this.staffId,
    this.staffName,
    this.departmentName,
    this.departmentUuid,
    this.uuid,
    this.total,
    this.customerId,
    required this.customerName,
    required this.orderItems,
    required this.updatedAt,
    required this.barcode,
    required this.vat,
    required this.comment,
    required this.originalCost,
    required this.balance,
    required this.cartName,
    required this.fixedDiscount,
    required this.generalDiscount,
    required this.subStaffName,
    required this.subStaffUuid,
  });

  factory Orders.fromJson(Map<String, dynamic> json) {
    return Orders(
      createdAt:
          DateTime.parse(json['created_at']).toLocal(),
      shopId: json['shop_id'],
      staffId: json['staff_id'] as String?,
      staffName: json['staff_name'] as String?,
      departmentUuid: json['department_uuid'] as String?,
      departmentName: json['department_name'] as String?,
      uuid: json['uuid'] as String?,
      total: (json['total'] as num?)?.toDouble(),
      customerId: json['customer_uuid'] as String?,
      customerName: json['customer_name'] as String?,
      orderItems:
          (json['items'] as List<dynamic>? ?? [])
              .map(
                (e) => OrderItems.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
      barcode: json['barcode'] as String?,
      vat: (json['vat'] as num?)?.toDouble(),
      comment: json['comment'] as String?,
      originalCost:
          (json['original_cost'] as num?)?.toDouble(),
      balance: (json['balance'] as num?)?.toDouble(),
      cartName: json['cart_name'] as String?,
      fixedDiscount:
          (json['fixed_discount'] as num?)?.toDouble(),
      generalDiscount:
          (json['general_discount'] as num?)?.toDouble(),
      subStaffName: json['sub_staff_name'] as String?,
      subStaffUuid: json['sub_staff_uuid'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'created_at': createdAt.toIso8601String(),
      'shop_id': shopId,
      'staff_id': staffId,
      'staff_name': staffName,
      'department_uuid': departmentUuid,
      'department_name': departmentName,
      'uuid': uuid,
      'customer_uuid': customerId,
      'customer_name': customerName,
      'total': total,
      'items': orderItems.map((e) => e.toJson()).toList(),
      'updated_at': updatedAt?.toIso8601String(),
      'barcode': barcode,
      'vat': vat,
      'comment': comment,
      'original_cost': originalCost,
      'balance': balance,
      'general_discount': generalDiscount,
      'fixed_discount': fixedDiscount,
      'cart_name': cartName,
      'sub_staff_name': subStaffName,
      'sub_staff_uuid': subStaffUuid,
    };
  }

  Orders copyWith({
    String? uuid,
    DateTime? createdAt,
    int? shopId,
    String? staffId,
    String? staffName,
    String? departmentName,
    String? departmentUuid,
    double? total,
    String? customerId,
    String? customerName,
    bool? isCustomPriceSet,
    List<OrderItems>? orderItems,
    DateTime? updatedAt,
    String? barcode,
    double? vat,
    String? comment,
    double? originalCost,
    double? balance,
    double? generalDiscount,
    double? fixedDiscount,
    String? cartName,
    String? subStaffName,
    String? subStaffUuid,
  }) {
    return Orders(
      uuid: uuid ?? this.uuid,
      createdAt: createdAt ?? this.createdAt,
      orderItems: orderItems ?? this.orderItems,
      shopId: shopId ?? this.shopId,
      customerName: customerName ?? this.customerName,
      departmentName: departmentName ?? this.departmentName,
      departmentUuid: departmentUuid ?? this.departmentUuid,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      customerId: customerId ?? this.customerId,
      total: total ?? this.total,
      updatedAt: updatedAt ?? this.updatedAt,
      barcode: barcode ?? this.barcode,
      vat: vat ?? this.vat,
      comment: comment ?? this.comment,
      originalCost: originalCost ?? this.originalCost,
      balance: balance ?? this.balance,
      cartName: cartName ?? this.cartName,
      fixedDiscount: fixedDiscount ?? this.fixedDiscount,
      generalDiscount:
          generalDiscount ?? this.generalDiscount,
      subStaffName: subStaffName ?? this.subStaffName,
      subStaffUuid: subStaffUuid ?? this.subStaffUuid,
    );
  }
}

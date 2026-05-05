import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_waybills/waybill_items.dart';

part 'temp_way_bills.g.dart';

@HiveType(typeId: 85)
class TempWayBills {
  @HiveField(0)
  String? uuid;

  @HiveField(1)
  DateTime? createdAt;

  @HiveField(2)
  int? shopId;

  @HiveField(3)
  String? staffId;

  @HiveField(4)
  String? staffName;

  @HiveField(5)
  String? customerId;

  @HiveField(6)
  String? customCustomerName;

  @HiveField(7)
  String? customCustomerEmail;

  @HiveField(8)
  String? customCustomerPhone;

  @HiveField(9)
  String? customCustomerAddress;

  @HiveField(10)
  String? departmentId;

  @HiveField(11)
  String? departmentName;

  @HiveField(12)
  double? totalAmount;

  @HiveField(13)
  String? receiptId;

  @HiveField(14)
  String? invoiceId;

  @HiveField(15)
  String? status;

  @HiveField(16)
  DateTime? updatedAt;

  @HiveField(17)
  List<WaybillItems> items;

  @HiveField(18)
  String? deliveryLocation;

  @HiveField(19)
  String? courierName;

  @HiveField(20)
  String? courierPhone;

  TempWayBills({
    required this.uuid,
    required this.createdAt,
    required this.shopId,
    this.staffId,
    this.staffName,
    this.customerId,
    this.customCustomerName,
    this.customCustomerEmail,
    this.customCustomerPhone,
    this.customCustomerAddress,
    this.departmentId,
    this.departmentName,
    this.totalAmount,
    this.receiptId,
    this.invoiceId,
    required this.status,
    this.updatedAt,
    required this.deliveryLocation,
    required this.courierName,
    required this.courierPhone,
    required this.items,
  });

  /// FROM JSON
  factory TempWayBills.fromJson(Map<String, dynamic> json) {
    return TempWayBills(
      uuid: json['uuid'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      shopId: json['shop_id'],
      staffId: json['staff_id'],
      staffName: json['staff_name'],
      customerId: json['customer_id'],
      customCustomerName: json['custom_customer_name'],
      customCustomerEmail: json['custom_customer_email'],
      customCustomerPhone: json['custom_customer_phone'],
      customCustomerAddress:
          json['custom_customer_address'],
      departmentId: json['department_id'],
      departmentName: json['department_name'],
      totalAmount:
          (json['total_amount'] as num?)?.toDouble(),
      receiptId: json['receipt_id'],
      invoiceId: json['invoice_id'],
      status: json['status'],
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      items:
          (json['payments'] as List<dynamic>? ?? [])
              .map(
                (e) => WaybillItems.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList(),
      deliveryLocation: json['delivery_location'],
      courierName: json['courier_name'],
      courierPhone: json['courier_phone'],
    );
  }

  /// TO JSON
  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'created_at': createdAt?.toIso8601String(),
      'shop_id': shopId,
      'staff_id': staffId,
      'staff_name': staffName,
      'customer_id': customerId,
      'custom_customer_name': customCustomerName,
      'custom_customer_email': customCustomerEmail,
      'custom_customer_phone': customCustomerPhone,
      'custom_customer_address': customCustomerAddress,
      'department_id': departmentId,
      'department_name': departmentName,
      'total_amount': totalAmount,
      'receipt_id': receiptId,
      'invoice_id': invoiceId,
      'status': status,
      'updated_at': updatedAt?.toIso8601String(),
      'items': items.map((e) => e.toJson()).toList(),
      'delivery_location': deliveryLocation,
      'courier_name': courierName,
      'courier_phone': courierPhone,
    };
  }

  /// COPY WITH
  TempWayBills copyWith({
    String? uuid,
    DateTime? createdAt,
    int? shopId,
    String? staffId,
    String? staffName,
    String? customerId,
    String? customCustomerName,
    String? customCustomerEmail,
    String? customCustomerPhone,
    String? customCustomerAddress,
    String? departmentId,
    String? departmentName,
    double? totalAmount,
    String? receiptId,
    String? invoiceId,
    String? status,
    DateTime? updatedAt,
    List<WaybillItems>? items,
    String? deliveryLocation,
    String? courierName,
    String? courierPhone,
  }) {
    return TempWayBills(
      uuid: uuid ?? this.uuid,
      createdAt: createdAt ?? this.createdAt,
      shopId: shopId ?? this.shopId,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      customerId: customerId ?? this.customerId,
      customCustomerName:
          customCustomerName ?? this.customCustomerName,
      customCustomerEmail:
          customCustomerEmail ?? this.customCustomerEmail,
      customCustomerPhone:
          customCustomerPhone ?? this.customCustomerPhone,
      customCustomerAddress:
          customCustomerAddress ??
          this.customCustomerAddress,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      totalAmount: totalAmount ?? this.totalAmount,
      receiptId: receiptId ?? this.receiptId,
      invoiceId: invoiceId ?? this.invoiceId,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
      deliveryLocation:
          deliveryLocation ?? this.deliveryLocation,
      courierName: courierName ?? this.courierName,
      courierPhone: courierPhone ?? this.courierPhone,
    );
  }
}

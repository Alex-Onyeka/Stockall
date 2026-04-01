import 'package:hive/hive.dart';

part 'temp_main_receipt.g.dart';

@HiveType(typeId: 3)
class TempMainReceipt extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String? barcode;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  int shopId;

  @HiveField(4)
  String staffId;

  @HiveField(5)
  String staffName;

  @HiveField(6)
  int? customerId;

  @HiveField(7)
  String? customerName;

  @HiveField(8)
  String paymentMethod;

  @HiveField(9)
  double cashAlt;

  @HiveField(10)
  double bank;

  @HiveField(11)
  String? departmentName;

  @HiveField(12)
  int? departmentUuid;

  @HiveField(13)
  bool isInvoice;

  @HiveField(14)
  String? uuid;

  @HiveField(15)
  String? customerUuid;

  @HiveField(16)
  double? generalDiscount;

  @HiveField(17)
  double? fixedDiscount;

  @HiveField(18)
  double? vat;

  @HiveField(19)
  double? originalCost;

  @HiveField(20)
  String? invoiceUuid;

  @HiveField(21)
  double? balance;

  @HiveField(22)
  String? subStaffUuid;

  @HiveField(23)
  String? departmentUuidNew;

  @HiveField(24)
  String? cartName;

  TempMainReceipt({
    this.id,
    this.barcode,
    required this.createdAt,
    required this.shopId,
    required this.staffId,
    required this.staffName,
    this.customerId,
    this.customerName,
    required this.paymentMethod,
    required this.bank,
    required this.cashAlt,
    required this.departmentName,
    this.departmentUuid,
    required this.isInvoice,
    this.uuid,
    this.customerUuid,
    this.generalDiscount,
    this.fixedDiscount,
    this.vat,
    this.originalCost,
    this.invoiceUuid,
    this.balance,
    this.subStaffUuid,
    required this.departmentUuidNew,
    required this.cartName,
  });

  factory TempMainReceipt.fromJson(
    Map<String, dynamic> json,
  ) {
    return TempMainReceipt(
      id: json['id'] as int?,
      barcode: json['barcode'] as String?,
      createdAt:
          DateTime.parse(json['created_at']).toLocal(),
      shopId: json['shop_id'],
      staffId: json['staff_id'],
      staffName: json['staff_name'],
      customerId: json['customer_id'],
      customerName: json['customer_name'] as String?,
      paymentMethod: json['payment_method'],
      cashAlt: (json['cash_alt'] as num).toDouble(),
      bank: (json['bank'] as num).toDouble(),
      originalCost:
          (json['original_cost'] as num?)?.toDouble(),
      departmentUuid: json['department_uuid'],
      departmentName: json['department_name'],
      isInvoice: json['is_invoice'],
      uuid: json['uuid'] as String?,
      customerUuid: json['customer_uuid'] as String?,
      generalDiscount:
          (json['general_discount'] as num?)?.toDouble(),
      fixedDiscount:
          (json['fixed_discount'] as num?)?.toDouble(),
      vat: (json['vat'] as num?)?.toDouble(),
      invoiceUuid: json['invoice_uuid'] as String?,
      balance: (json['balance'] as num?)?.toDouble(),
      subStaffUuid: json['sub_staff_uuid'] as String?,
      departmentUuidNew:
          json['department_uuid_new'] as String?,
      cartName: json['cart_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'barcode': barcode,
      'created_at': createdAt.toIso8601String(),
      'shop_id': shopId,
      'staff_id': staffId,
      'staff_name': staffName,
      'customer_id': customerId,
      'customer_name': customerName,
      'payment_method': paymentMethod,
      'cash_alt': cashAlt,
      'bank': bank,
      'original_cost': originalCost,
      'department_uuid': departmentUuid,
      'department_name': departmentName,
      'is_invoice': isInvoice,
      'uuid': uuid,
      'customer_uuid': customerUuid,
      'general_discount': generalDiscount,
      'fixed_discount': fixedDiscount,
      'vat': vat,
      'invoice_uuid': invoiceUuid,
      'balance': balance,
      'sub_staff_uuid': subStaffUuid,
      'department_uuid_new': departmentUuidNew,
      'cart_name': cartName,
    };
  }
}

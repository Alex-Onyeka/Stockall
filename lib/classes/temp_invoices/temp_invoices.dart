import 'package:hive/hive.dart';

part 'temp_invoices.g.dart';

@HiveType(typeId: 43)
class TempInvoice extends HiveObject {
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
  String? customerName;

  @HiveField(7)
  String paymentMethod;

  @HiveField(8)
  double cashAlt;

  @HiveField(9)
  double bank;

  @HiveField(10)
  String? departmentName;

  @HiveField(11)
  int? departmentUuid;

  @HiveField(12)
  String? uuid;

  @HiveField(13)
  String? customerUuid;

  @HiveField(14)
  double? generalDiscount;

  @HiveField(15)
  double? fixedDiscount;

  @HiveField(16)
  double? vat;

  @HiveField(17)
  double? originalCost;

  // @HiveField(18)
  // int status;

  // @HiveField(19)
  // double? balance;

  @HiveField(20)
  DateTime? updatedAt;

  TempInvoice({
    this.id,
    this.barcode,
    required this.createdAt,
    required this.shopId,
    required this.staffId,
    required this.staffName,
    this.customerName,
    required this.paymentMethod,
    required this.bank,
    required this.cashAlt,
    this.departmentName,
    this.departmentUuid,
    // required this.status,
    this.uuid,
    this.customerUuid,
    this.generalDiscount,
    this.fixedDiscount,
    this.vat,
    this.originalCost,
    // this.balance,
    this.updatedAt,
  });

  factory TempInvoice.fromJson(Map<String, dynamic> json) {
    return TempInvoice(
      id: json['id'] as int?,
      barcode: json['barcode'] as String?,
      createdAt:
          DateTime.parse(json['created_at']).toLocal(),
      shopId: json['shop_id'],
      staffId: json['staff_id'],
      staffName: json['staff_name'],
      customerName: json['customer_name'] as String?,
      paymentMethod: json['payment_method'],
      cashAlt: (json['cash_alt'] as num).toDouble(),
      bank: (json['bank'] as num).toDouble(),
      originalCost:
          (json['original_cost'] as num?)?.toDouble(),
      departmentUuid: json['department_uuid'],
      departmentName: json['department_name'],
      uuid: json['invoice_uuid'] as String?,
      customerUuid: json['customer_uuid'] as String?,
      generalDiscount:
          (json['general_discount'] as num?)?.toDouble(),
      fixedDiscount:
          (json['fixed_discount'] as num?)?.toDouble(),
      vat: (json['vat'] as num?)?.toDouble(),
      // status: (json['status'] as num).toInt(),
      // balance: (json['balance'] as num?)?.toDouble(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
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
      'customer_name': customerName,
      'payment_method': paymentMethod,
      'cash_alt': cashAlt,
      'bank': bank,
      'original_cost': originalCost,
      'department_uuid': departmentUuid,
      'department_name': departmentName,
      'invoice_uuid': uuid,
      'customer_uuid': customerUuid,
      'general_discount': generalDiscount,
      'fixed_discount': fixedDiscount,
      'vat': vat,
      // 'status': status,
      // 'balance': balance,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

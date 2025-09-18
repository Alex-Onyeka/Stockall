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
  int? departmentId;

  @HiveField(13)
  bool isInvoice;

  @HiveField(11)
  String? uuid;

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
    this.departmentName,
    this.departmentId,
    required this.isInvoice,
    this.uuid,
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
      departmentId: json['department_id'],
      departmentName: json['department_name'],
      isInvoice: json['is_invoice'],
      uuid: json['uuid'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'department_id': departmentId,
      'department_name': departmentName,
      'is_invoice': isInvoice,
      'uuid': uuid,
    };
  }
}

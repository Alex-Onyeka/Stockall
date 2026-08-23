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
  String? staffId;

  @HiveField(5)
  String? staffName;

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

  @HiveField(25)
  String? subStaffName;

  @HiveField(26)
  String? comment;

  @HiveField(27)
  double? customerAccount;

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
    required this.subStaffName,
    required this.comment,
    required this.customerAccount,
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
      staffId: json['staff_id'] as String?,
      staffName: json['staff_name'] as String?,
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
      subStaffName: json['sub_staff_name'] as String?,
      comment: json['comment'] as String?,
      customerAccount:
          (json['customer_account'] as num?)?.toDouble(),
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
      'sub_staff_name': subStaffName,
      'comment': comment,
      'customer_account': customerAccount,
    };
  }

  TempMainReceipt copyWith({
    int? id,
    String? barcode,
    DateTime? createdAt,
    int? shopId,
    String? staffId,
    String? staffName,
    int? customerId,
    String? customerName,
    String? paymentMethod,
    double? cashAlt,
    double? bank,
    String? departmentName,
    int? departmentUuid,
    bool? isInvoice,
    String? uuid,
    String? customerUuid,
    double? generalDiscount,
    double? fixedDiscount,
    double? vat,
    double? originalCost,
    String? invoiceUuid,
    double? balance,
    String? subStaffUuid,
    String? departmentUuidNew,
    String? cartName,
    String? subStaffName,
    String? comment,
    double? customerAccount,
  }) {
    return TempMainReceipt(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      createdAt: createdAt ?? this.createdAt,
      shopId: shopId ?? this.shopId,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      cashAlt: cashAlt ?? this.cashAlt,
      bank: bank ?? this.bank,
      departmentName: departmentName ?? this.departmentName,
      departmentUuid: departmentUuid ?? this.departmentUuid,
      isInvoice: isInvoice ?? this.isInvoice,
      uuid: uuid ?? this.uuid,
      customerUuid: customerUuid ?? this.customerUuid,
      generalDiscount:
          generalDiscount ?? this.generalDiscount,
      fixedDiscount: fixedDiscount ?? this.fixedDiscount,
      vat: vat ?? this.vat,
      originalCost: originalCost ?? this.originalCost,
      invoiceUuid: invoiceUuid ?? this.invoiceUuid,
      balance: balance ?? this.balance,
      subStaffUuid: subStaffUuid ?? this.subStaffUuid,
      departmentUuidNew:
          departmentUuidNew ?? this.departmentUuidNew,
      cartName: cartName ?? this.cartName,
      subStaffName: subStaffName ?? this.subStaffName,
      comment: comment ?? this.comment,
      customerAccount:
          customerAccount ?? this.customerAccount,
    );
  }

  double getTotalRevenue() {
    return bank + cashAlt + (customerAccount ?? 0);
  }
}

class StaffGroupReceipts {
  final String? staffUuid;
  final String? staffName;
  int number;
  double totalBalance;
  double totalOriginalCost;
  double totalRevenue;

  StaffGroupReceipts({
    required this.staffUuid,
    required this.staffName,
    required this.number,
    required this.totalBalance,
    required this.totalOriginalCost,
    required this.totalRevenue,
  });
}

class CustomerGroupReceipts {
  final String? customerUuid;
  final String? customerName;
  int number;
  double totalBalance;
  double totalOriginalCost;
  double totalRevenue;

  CustomerGroupReceipts({
    required this.customerUuid,
    required this.customerName,
    required this.number,
    required this.totalBalance,
    required this.totalOriginalCost,
    required this.totalRevenue,
  });
}

class ChannelGroupReceipts {
  final String paymentMethod;
  int number;
  double totalBalance;
  double totalOriginalCost;
  double totalRevenue;

  ChannelGroupReceipts({
    required this.paymentMethod,
    required this.number,
    required this.totalBalance,
    required this.totalOriginalCost,
    required this.totalRevenue,
  });
}

class DepartmentGroupReceipts {
  final String departmentUuid;
  final String? departmentName;
  int number;
  double totalBalance;
  double totalOriginalCost;
  double totalRevenue;

  DepartmentGroupReceipts({
    required this.departmentUuid,
    required this.departmentName,
    required this.number,
    required this.totalBalance,
    required this.totalOriginalCost,
    required this.totalRevenue,
  });
}

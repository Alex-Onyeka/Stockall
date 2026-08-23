import 'package:hive/hive.dart';
part 'customer_account_receipts.g.dart';

@HiveType(typeId: 127)
class CustomerAccountReceipts {
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
  String? customerUuid;

  @HiveField(6)
  String? customerName;

  @HiveField(7)
  DateTime? updatedAt;

  @HiveField(9)
  double? amount;

  @HiveField(10)
  double? oldBalance;

  @HiveField(11)
  double? newBalance;

  @HiveField(12)
  bool isAdd;

  @HiveField(13)
  String? comment;

  @HiveField(14)
  String? title;

  @HiveField(15)
  bool? isBalance;

  @HiveField(16)
  String? receiptUuid;

  CustomerAccountReceipts({
    this.uuid,
    this.createdAt,
    this.shopId,
    this.staffId,
    this.staffName,
    this.updatedAt,
    required this.amount,
    required this.customerName,
    required this.customerUuid,
    this.newBalance,
    this.oldBalance,
    required this.isAdd,
    this.comment,
    this.title,
    required this.isBalance,
    required this.receiptUuid,
  });

  /// FROM JSON
  factory CustomerAccountReceipts.fromJson(
    Map<String, dynamic> json,
  ) {
    return CustomerAccountReceipts(
      uuid: json['uuid'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      shopId: json['shop_id'] as int,
      staffId: json['staff_uuid'] as String?,
      staffName: json['staff_name'] as String?,
      customerUuid: json['customer_uuid'] as String?,
      customerName: json['customer_name'] as String?,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      amount: (json['amount'] as num?)?.toDouble(),
      newBalance: (json['new_balance'] as num?)?.toDouble(),
      oldBalance: (json['old_balance'] as num?)?.toDouble(),
      isAdd: json['is_add'] as bool,
      comment: json['comment'] as String?,
      title: json['title'] as String?,
      isBalance: json['is_balance'] as bool,
      receiptUuid: json['receipt_uuid'] as String?,
    );
  }

  /// TO JSON
  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'created_at': createdAt?.toIso8601String(),
      'shop_id': shopId,
      'staff_uuid': staffId,
      'staff_name': staffName,
      'customer_uuid': customerUuid,
      'customer_name': customerName,
      'updated_at': updatedAt?.toIso8601String(),
      'amount': amount,
      'new_balance': newBalance,
      'old_balance': oldBalance,
      'is_add': isAdd,
      'comment': comment,
      'title': title,
      'is_balance': isBalance,
      'receipt_uuid': receiptUuid,
    };
  }

  /// COPY WITH
  CustomerAccountReceipts copyWith({
    String? uuid,
    DateTime? createdAt,
    int? shopId,
    String? staffId,
    String? staffName,
    String? customerUuid,
    String? customerName,
    DateTime? updatedAt,
    double? amount,
    double? newBalance,
    double? oldBalance,
    bool? isAdd,
    String? comment,
    String? title,
    bool? isBalance,
    String? receiptUuid,
  }) {
    return CustomerAccountReceipts(
      uuid: uuid ?? this.uuid,
      createdAt: createdAt ?? this.createdAt,
      shopId: shopId ?? this.shopId,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      customerUuid: customerUuid ?? this.customerUuid,
      customerName: customerName ?? this.customerName,
      updatedAt: updatedAt ?? this.updatedAt,
      amount: amount ?? this.amount,
      newBalance: newBalance ?? this.newBalance,
      oldBalance: oldBalance ?? this.oldBalance,
      isAdd: isAdd ?? this.isAdd,
      comment: comment ?? this.comment,
      title: title ?? this.title,
      isBalance: isBalance ?? this.isBalance,
      receiptUuid: receiptUuid ?? this.receiptUuid,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:stockall/constants/calculations.dart';

part 'payment_method.g.dart';

class PaymentChannelType {
  static const int others = 0;
  static const int bank = 1;
  static const int pos = 2;

  static const List<int> all = [bank, pos, others];

  static String getLabel(int type) {
    switch (type) {
      case bank:
        return 'Bank';
      case pos:
        return 'POS Machine';
      case others:
      default:
        return 'Others';
    }
  }

  static IconData getIcon(int type) {
    switch (type) {
      case bank:
        return Icons.account_balance_outlined;
      case pos:
        return Icons.point_of_sale_outlined;
      case others:
      default:
        return Icons.devices_other_outlined;
    }
  }
}

@HiveType(typeId: 154)
class PaymentMethod extends HiveObject {
  @HiveField(0)
  String uuid;

  @HiveField(1)
  String bankName;

  @HiveField(2)
  String? accountNumber;

  @HiveField(3)
  String? accountName;

  @HiveField(4, defaultValue: 1)
  int type; // 0: Others, 1: Bank, 2: POS

  @HiveField(5)
  String? note;

  PaymentMethod({
    String? uuid,
    required this.bankName,
    this.accountNumber,
    this.accountName,
    this.type = 1,
    this.note,
  }) : uuid = uuid ?? uuidGen();

  IconData get icon => PaymentChannelType.getIcon(type);
  String get typeLabel => PaymentChannelType.getLabel(type);

  String get displayName {
    final acc = accountNumber?.trim();
    if (acc != null && acc.isNotEmpty) {
      return '$bankName ($acc)';
    }
    final n = note?.trim();
    if (n != null && n.isNotEmpty) {
      return '$bankName ($n)';
    }
    return bankName;
  }

  factory PaymentMethod.fromJson(dynamic json) {
    if (json is String) {
      return PaymentMethod(
        uuid: uuidGen(),
        bankName: json,
        type: 1,
      );
    }
    if (json is Map) {
      final map = Map<String, dynamic>.from(json);
      return PaymentMethod(
        uuid: map['uuid'] as String? ?? uuidGen(),
        bankName: (map['bank_name'] ?? map['name'] ?? '').toString(),
        accountNumber: map['account_number']?.toString(),
        accountName: map['account_name']?.toString(),
        type: map['type'] is int
            ? map['type'] as int
            : int.tryParse(map['type']?.toString() ?? '1') ?? 1,
        note: (map['note'] ?? map['others'])?.toString(),
      );
    }
    return PaymentMethod(
      uuid: uuidGen(),
      bankName: json.toString(),
      type: 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'bank_name': bankName,
      'account_number': accountNumber,
      'account_name': accountName,
      'type': type,
      'note': note,
    };
  }

  PaymentMethod copyWith({
    String? uuid,
    String? bankName,
    String? accountNumber,
    String? accountName,
    int? type,
    String? note,
  }) {
    return PaymentMethod(
      uuid: uuid ?? this.uuid,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      accountName: accountName ?? this.accountName,
      type: type ?? this.type,
      note: note ?? this.note,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentMethod &&
          runtimeType == other.runtimeType &&
          uuid == other.uuid;

  @override
  int get hashCode => uuid.hashCode;
}

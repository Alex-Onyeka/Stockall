import 'package:hive/hive.dart';
import 'package:stockall/constants/calculations.dart';

part 'payment_method.g.dart';

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

  PaymentMethod({
    String? uuid,
    required this.bankName,
    this.accountNumber,
    this.accountName,
  }) : uuid = uuid ?? uuidGen();

  String get displayName {
    final acc = accountNumber?.trim();
    if (acc != null && acc.isNotEmpty) {
      return '$bankName ($acc)';
    }
    return bankName;
  }

  factory PaymentMethod.fromJson(dynamic json) {
    if (json is String) {
      return PaymentMethod(
        uuid: uuidGen(),
        bankName: json,
      );
    }
    if (json is Map) {
      final map = Map<String, dynamic>.from(json);
      return PaymentMethod(
        uuid: map['uuid'] as String? ?? uuidGen(),
        bankName: (map['bank_name'] ?? map['name'] ?? '').toString(),
        accountNumber: map['account_number']?.toString(),
        accountName: map['account_name']?.toString(),
      );
    }
    return PaymentMethod(
      uuid: uuidGen(),
      bankName: json.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'bank_name': bankName,
      'account_number': accountNumber,
      'account_name': accountName,
    };
  }

  PaymentMethod copyWith({
    String? uuid,
    String? bankName,
    String? accountNumber,
    String? accountName,
  }) {
    return PaymentMethod(
      uuid: uuid ?? this.uuid,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      accountName: accountName ?? this.accountName,
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

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/payment_entry/payment_entry.dart';
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

  /// The label shown and saved for this method: the bank name only.
  /// Two methods at one bank share it, so inputs are keyed by [uuid].
  String get displayName => bankName;

  /// Whether a saved label belongs to this method: the bank name,
  /// or the older "Bank (account)" / "Bank (note)" form.
  bool matchesLabel(String? stored) => labelMatchesBank(stored, bankName);

  /// [matchesLabel] without an instance (testable, also used for
  /// labels of methods not loaded).
  static bool labelMatchesBank(String? stored, String bankName) {
    final s = stored?.trim();
    final bank = bankName.trim();
    if (s == null || s.isEmpty || bank.isEmpty) return false;
    if (s == bank) return true;
    return s.startsWith('$bank (') && s.endsWith(')');
  }

  static bool _isFixedMethod(String method) =>
      method == PaymentMethods.cash ||
      method == PaymentMethods.bank ||
      method == PaymentMethods.account;

  /// Split-payment input keys for saved [entries], in order: Cash,
  /// Bank and Customer Account keep their constant; a custom label
  /// goes to the uuid of the first of [methods] it matches
  /// ([matchesLabel]) that no earlier entry took; an unmatched label
  /// stays its own key.
  static List<String> keysForEntries(
    List<PaymentEntry> entries,
    List<PaymentMethod> methods,
  ) {
    final taken = <String>{};
    final keys = <String>[];
    for (final entry in entries) {
      var key = entry.method;
      if (!_isFixedMethod(entry.method)) {
        for (final m in methods) {
          if (!taken.contains(m.uuid) &&
              m.matchesLabel(entry.method)) {
            key = m.uuid;
            break;
          }
        }
      }
      taken.add(key);
      keys.add(key);
    }
    return keys;
  }

  /// The label saved for split-payment input [key] (see
  /// [keysForEntries]): a custom method's [displayName], otherwise
  /// the key itself.
  static String labelForKey(
    String key,
    List<PaymentMethod> methods,
  ) {
    if (_isFixedMethod(key)) return key;
    for (final m in methods) {
      if (m.uuid == key) return m.displayName;
    }
    return key;
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
        bankName:
            (map['bank_name'] ?? map['name'] ?? '')
                .toString(),
        accountNumber: map['account_number']?.toString(),
        accountName: map['account_name']?.toString(),
        type:
            map['type'] is int
                ? map['type'] as int
                : int.tryParse(
                      map['type']?.toString() ?? '1',
                    ) ??
                    1,
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

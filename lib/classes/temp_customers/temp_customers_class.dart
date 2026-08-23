import 'package:hive/hive.dart';

part 'temp_customers_class.g.dart';

@HiveType(typeId: 1)
class TempCustomersClass extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  DateTime dateAdded;

  @HiveField(2)
  int shopId;

  @HiveField(3)
  String? country;

  @HiveField(4)
  String name;

  @HiveField(5)
  String email;

  @HiveField(6)
  String phone;

  @HiveField(7)
  String? address;

  @HiveField(8)
  String? city;

  @HiveField(9)
  String? state;

  @HiveField(10)
  String? departmentName;

  @HiveField(11)
  String? departmentUuid;

  @HiveField(12)
  String? uuid;

  @HiveField(13)
  DateTime? updatedAt;

  @HiveField(14)
  double? balance;

  @HiveField(15)
  double? cashReward;

  TempCustomersClass({
    this.country,
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.dateAdded,
    required this.shopId,
    required this.departmentName,
    required this.departmentUuid,
    this.uuid,
    this.updatedAt,
    required this.balance,
    required this.cashReward,
  });

  factory TempCustomersClass.fromJson(
    Map<String, dynamic> json,
  ) {
    return TempCustomersClass(
      id: json['id'] as int?,
      uuid: json['uuid'] as String?,
      dateAdded: DateTime.parse(json['date_added']),
      shopId: json['shop_id'] as int,
      country: json['country'] as String?,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      departmentUuid: json['department_uuid'] as String?,
      departmentName: json['department_name'] as String?,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      balance: (json['balance'] as num?)?.toDouble(),
      cashReward: (json['cash_reward'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson({
    required bool isMoneyUpdate,
  }) {
    if (isMoneyUpdate) {
      return {
        'date_added': dateAdded.toIso8601String(),
        'shop_id': shopId,
        'country': country,
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'city': city,
        'state': state,
        'department_uuid': departmentUuid,
        'department_name': departmentName,
        'uuid': uuid,
        'updated_at': updatedAt?.toIso8601String(),
        'balance': balance,
        'cash_reward': cashReward,
      };
    } else {
      return {
        'date_added': dateAdded.toIso8601String(),
        'shop_id': shopId,
        'country': country,
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'city': city,
        'state': state,
        'department_uuid': departmentUuid,
        'department_name': departmentName,
        'uuid': uuid,
        'updated_at': updatedAt?.toIso8601String(),
        // 'balance': balance,
        // 'cash_reward': cashReward,
      };
    }
  }

  TempCustomersClass copyWith({
    DateTime? dateAdded,
    int? shopId,
    String? country,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? departmentName,
    String? departmentUuid,
    String? uuid,
    DateTime? updatedAt,
    double? balance,
    double? cashReward,
  }) {
    return TempCustomersClass(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      dateAdded: dateAdded ?? this.dateAdded,
      shopId: shopId ?? this.shopId,
      departmentName: departmentName ?? this.departmentName,
      departmentUuid: departmentUuid ?? this.departmentUuid,
      balance: balance ?? this.balance,
      cashReward: cashReward ?? this.cashReward,
      country: country ?? this.country,
      updatedAt: updatedAt ?? this.updatedAt,
      uuid: uuid ?? this.uuid,
    );
  }

  double getBalance() {
    return (balance ?? 0);
  }
}

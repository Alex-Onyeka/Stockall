import 'package:hive/hive.dart';

part 'temp_expenses_class.g.dart';

@HiveType(typeId: 2)
class TempExpensesClass extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  DateTime? createdDate;

  @HiveField(2)
  int shopId;

  @HiveField(3)
  String name;

  @HiveField(4)
  String creator;

  @HiveField(5)
  String? description;

  @HiveField(6)
  double amount;

  @HiveField(7)
  double? quantity;

  @HiveField(8)
  String? unit;

  @HiveField(9)
  String userId;

  @HiveField(10)
  String? departmentName;

  @HiveField(11)
  int? departmentId;

  @HiveField(12)
  String? uuid;

  TempExpensesClass({
    required this.name,
    this.description,
    required this.amount,
    required this.creator,
    this.quantity,
    this.unit,
    required this.shopId,
    this.id,
    this.createdDate,
    required this.userId,
    this.departmentName,
    this.departmentId,
    this.uuid,
  });

  factory TempExpensesClass.fromJson(
    Map<String, dynamic> json,
  ) {
    return TempExpensesClass(
      id: json['id'] as int?,
      createdDate:
          json['created_date'] != null
              ? DateTime.parse(json['created_date'])
              : null,
      shopId: json['shop_id'],
      name: json['name'],
      description: json['description'] as String?,
      amount: (json['amount'] as num).toDouble(),
      quantity:
          json['quantity'] != null
              ? (json['quantity'] as num).toDouble()
              : null,
      unit: json['unit'],
      userId: json['user_id'],
      creator: json['creator'],
      departmentId: json['department_id'],
      departmentName: json['department_name'],
      uuid: json['uuid'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_date': createdDate?.toIso8601String(),
      'shop_id': shopId,
      'name': name,
      'description': description,
      'amount': amount,
      'quantity': quantity,
      'unit': unit,
      'user_id': userId,
      'creator': creator,
      'department_id': departmentId,
      'department_name': departmentName,
      'uuid': uuid,
    };
  }
}

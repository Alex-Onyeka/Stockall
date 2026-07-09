import 'package:hive/hive.dart';

part 'temp_storage_products.g.dart';

@HiveType(typeId: 66)
class TempStorageProducts {
  @HiveField(0)
  String? uuid;

  @HiveField(1)
  DateTime? createdAt;

  @HiveField(2)
  int shopId;

  @HiveField(3)
  String name;

  @HiveField(4)
  String? desc;

  @HiveField(5)
  double? quantity;

  @HiveField(6)
  String? unit;

  @HiveField(7)
  String? groupUnit;

  @HiveField(8)
  DateTime? updatedAt;

  @HiveField(9)
  double? qttyPerGroup;

  @HiveField(10)
  double? costPrice;

  @HiveField(11)
  double? sellingPrice;

  TempStorageProducts({
    this.uuid,
    this.createdAt,
    required this.shopId,
    required this.name,
    this.desc,
    this.quantity,
    this.unit,
    this.groupUnit,
    this.updatedAt,
    this.qttyPerGroup,
    required this.costPrice,
    required this.sellingPrice,
  });

  factory TempStorageProducts.fromJson(
    Map<String, dynamic> json,
  ) {
    return TempStorageProducts(
      uuid: json['uuid'] as String?,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      shopId: json['shop_id'] as int,
      name: json['name'] as String,
      desc: json['desc'] as String?,
      quantity:
          json['quantity'] != null
              ? (json['quantity'] as num).toDouble()
              : null,
      unit: json['single_unit'] as String?,
      groupUnit: json['group_unit'] as String?,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      qttyPerGroup:
          json['qtty_per_group'] != null
              ? (json['qtty_per_group'] as num).toDouble()
              : null,
      costPrice:
          json['cost_price'] != null
              ? (json['cost_price'] as num).toDouble()
              : null,
      sellingPrice:
          json['selling_price'] != null
              ? (json['selling_price'] as num).toDouble()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'created_at': createdAt?.toIso8601String(),
      'shop_id': shopId,
      'name': name,
      'description': desc,
      // 'quantity': quantity,
      'single_unit': unit,
      'group_unit': groupUnit,
      'updated_at': updatedAt?.toIso8601String(),
      'qtty_per_group': qttyPerGroup,
      'cost_price': costPrice,
      'selling_price': sellingPrice,
    };
  }

  TempStorageProducts copyWith({
    String? uuid,
    DateTime? createdAt,
    int? shopId,
    String? name,
    String? desc,
    double? quantity,
    String? unit,
    String? groupUnit,
    DateTime? updatedAt,
    double? qttyPerGroup,
    double? costPrice,
    double? sellingPrice,
  }) {
    return TempStorageProducts(
      uuid: uuid ?? this.uuid,
      createdAt: createdAt ?? this.createdAt,
      shopId: shopId ?? this.shopId,
      name: name ?? this.name,
      desc: desc ?? this.desc,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      groupUnit: groupUnit ?? this.groupUnit,
      updatedAt: updatedAt ?? this.updatedAt,
      qttyPerGroup: qttyPerGroup ?? this.qttyPerGroup,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
    );
  }
}

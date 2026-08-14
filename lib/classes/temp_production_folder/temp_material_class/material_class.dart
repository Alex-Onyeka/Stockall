import 'package:hive/hive.dart';

part 'material_class.g.dart';

@HiveType(typeId: 104)
class MaterialClass {
  @HiveField(0)
  String? uuid;

  @HiveField(1)
  String name;

  @HiveField(2)
  final int shopId;

  @HiveField(3)
  DateTime? createdAt;

  @HiveField(4)
  String? barcode;

  @HiveField(5)
  String unit;

  @HiveField(6)
  String? sizeType;

  @HiveField(7)
  double costPrice;

  @HiveField(8)
  double? quantity;

  @HiveField(9)
  String? departmentName;

  @HiveField(10)
  String? departmentUuid;

  @HiveField(11)
  double? lowQtty;

  @HiveField(12)
  DateTime? expiryDate;

  @HiveField(13)
  bool isManaged;

  @HiveField(14)
  DateTime? updatedAt;

  @HiveField(15)
  String? groupUnit;

  @HiveField(16)
  double? qttyPerGroup;

  @HiveField(17)
  String? categoryUuid;

  @HiveField(18)
  List<String>? categories;

  @HiveField(19)
  bool? useGroupUnit;

  MaterialClass({
    required this.name,
    this.barcode,
    this.quantity,
    required this.unit,
    this.sizeType,
    required this.costPrice,
    required this.shopId,
    this.createdAt,
    required this.departmentName,
    required this.departmentUuid,
    this.lowQtty,
    this.expiryDate,
    required this.isManaged,
    this.updatedAt,
    this.uuid,
    required this.groupUnit,
    required this.qttyPerGroup,
    this.categoryUuid,
    required this.categories,
    required this.useGroupUnit,
  });

  factory MaterialClass.fromJson(
    Map<String, dynamic> json,
  ) {
    return MaterialClass(
      name: json['name'] as String,
      shopId: json['shop_id'] as int,
      quantity: (json['quantity'] as num?)?.toDouble(),
      barcode: json['barcode'] as String?,
      unit: json['unit'] as String,
      sizeType: json['size_type'] as String?,
      lowQtty: (json['low_qtty'] as num?)?.toDouble(),
      costPrice: (json['cost_price'] as num).toDouble(),
      expiryDate:
          json['expiry_date'] != null
              ? DateTime.parse(
                json['expiry_date'] as String,
              )
              : null,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
      departmentUuid: json['department_uuid'] as String?,
      departmentName: json['department_name'] as String?,
      isManaged: json['is_managed'] as bool,
      uuid: json['uuid'] as String?,
      groupUnit: json['group_unit'] as String?,
      qttyPerGroup:
          (json['qtty_per_group'] as num?)?.toDouble(),
      categoryUuid: json['category_uuid'] as String?,
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      useGroupUnit: json['use_group_unit'] as bool?,
    );
  }

  Map<String, dynamic> toJson({
    required bool isIncludeQuantity,
  }) {
    if (isIncludeQuantity) {
      return {
        'name': name,
        'shop_id': shopId,
        'barcode': barcode,
        'unit': unit,
        'size_type': sizeType,
        'cost_price': costPrice,
        'expiry_date':
            expiryDate?.toIso8601String().split('T').first,
        'quantity': quantity,
        'department_uuid': departmentUuid,
        'department_name': departmentName,
        'low_qtty': lowQtty,
        'is_managed': isManaged,
        'updated_at': updatedAt?.toIso8601String(),
        'uuid': uuid,
        'group_unit': groupUnit,
        'qtty_per_group': qttyPerGroup,
        'category_uuid': categoryUuid,
        'categories': categories ?? [],
        'use_group_unit': useGroupUnit,
      };
    } else {
      return {
        'name': name,
        'shop_id': shopId,
        'barcode': barcode,
        'unit': unit,
        'size_type': sizeType,
        'cost_price': costPrice,
        'expiry_date':
            expiryDate?.toIso8601String().split('T').first,
        'department_uuid': departmentUuid,
        'department_name': departmentName,
        'low_qtty': lowQtty,
        'is_managed': isManaged,
        'updated_at': updatedAt?.toIso8601String(),
        'uuid': uuid,
        'group_unit': groupUnit,
        'qtty_per_group': qttyPerGroup,
        'category_uuid': categoryUuid,
        'categories': categories ?? [],
        'use_group_unit': useGroupUnit,
      };
    }
  }

  MaterialClass copyWith({
    String? name,
    int? shopId,
    DateTime? createdAt,
    String? barcode,
    String? unit,
    String? sizeType,
    double? costPrice,
    double? quantity,
    String? departmentName,
    String? departmentUuid,
    double? lowQtty,
    DateTime? expiryDate,
    DateTime? updatedAt,
    String? uuid,
    String? groupUnit,
    double? qttyPerGroup,
    String? categoryUuid,
    bool? isManaged,
    List<String>? categories,
    bool? useGroupUnit,
  }) {
    return MaterialClass(
      name: name ?? this.name,
      shopId: shopId ?? this.shopId,
      createdAt: createdAt ?? this.createdAt,
      barcode: barcode ?? this.barcode,
      unit: unit ?? this.unit,
      sizeType: sizeType ?? this.sizeType,
      costPrice: costPrice ?? this.costPrice,
      departmentName: departmentName ?? this.departmentName,
      departmentUuid: departmentUuid ?? this.departmentUuid,
      lowQtty: lowQtty ?? this.lowQtty,
      expiryDate: expiryDate ?? this.expiryDate,
      isManaged: isManaged ?? this.isManaged,
      updatedAt: updatedAt ?? this.updatedAt,
      uuid: uuid ?? this.uuid,
      groupUnit: groupUnit ?? this.groupUnit,
      qttyPerGroup: qttyPerGroup ?? this.qttyPerGroup,
      categoryUuid: categoryUuid ?? this.categoryUuid,
      quantity: quantity ?? this.quantity,
      categories: categories ?? this.categories,
      useGroupUnit: useGroupUnit ?? this.useGroupUnit,
    );
  }

  double getRealQuantity() {
    if (useGroupUnit == true) {
      return (quantity ?? 0) * (qttyPerGroup ?? 1);
    } else {
      return quantity ?? 0;
    }
  }

  double getRealQuantityForSales({
    required double qtty,
    required bool useGroup,
  }) {
    if (useGroup == true) {
      return (qtty) * (qttyPerGroup ?? 1);
    } else {
      return qtty;
    }
  }

  String getUnitForSales({required bool useGroup}) {
    if (useGroup == true) {
      return groupUnit ?? 'Group(s)';
    } else {
      return unit == 'Others' ? 'Unit(s)' : unit;
    }
  }

  double getRealCost() {
    return costPrice * getRealQuantity();
  }

  double getRealCostForSales({
    required double qtty,
    required bool useGroup,
  }) {
    return costPrice *
        getRealQuantityForSales(
          qtty: qtty,
          useGroup: useGroup,
        );
  }
}

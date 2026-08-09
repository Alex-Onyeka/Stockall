import 'package:hive/hive.dart';

part 'temp_product_class.g.dart';

@HiveType(typeId: 5)
class TempProductClass {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String name;

  @HiveField(2)
  final int shopId;

  @HiveField(3)
  String? brand;

  @HiveField(4)
  DateTime? createdAt;

  @HiveField(5)
  String? category;

  @HiveField(6)
  String? barcode;

  @HiveField(7)
  String unit;

  @HiveField(8)
  bool isRefundable;

  @HiveField(9)
  String? color;

  @HiveField(10)
  String? sizeType;

  @HiveField(11)
  String? size;

  @HiveField(12)
  double costPrice;

  @HiveField(13)
  double? sellingPrice;

  @HiveField(14)
  double? discount;

  @HiveField(15)
  DateTime? startDate;

  @HiveField(16)
  DateTime? endDate;

  @HiveField(17)
  double? quantity;

  @HiveField(18)
  bool setCustomPrice;

  @HiveField(19)
  String? departmentName;

  @HiveField(20)
  String? departmentUuid;

  @HiveField(21)
  double? lowQtty;

  @HiveField(22)
  DateTime? expiryDate;

  @HiveField(23)
  bool isManaged;

  @HiveField(24)
  DateTime? updatedAt;

  @HiveField(25)
  String? uuid;

  @HiveField(26)
  int? totalQttyInStorage;

  @HiveField(27)
  double? totalQttyInStorageDouble;

  @HiveField(28)
  String? groupUnit;

  @HiveField(29)
  double? qttyPerGroup;

  @HiveField(30)
  String? categoryUuid;

  @HiveField(31)
  double? wholeSalePrice;

  @HiveField(32)
  String? storageUuid;

  @HiveField(33)
  List<String>? categories;

  TempProductClass({
    this.id,
    required this.name,
    this.brand,
    this.category,
    this.barcode,
    required this.unit,
    required this.isRefundable,
    this.color,
    this.sizeType,
    this.size,
    required this.costPrice,
    this.sellingPrice,
    this.discount,
    this.startDate,
    this.endDate,
    this.quantity,
    required this.shopId,
    this.createdAt,
    required this.setCustomPrice,
    required this.departmentName,
    required this.departmentUuid,
    this.lowQtty,
    this.expiryDate,
    required this.isManaged,
    this.updatedAt,
    this.uuid,
    this.totalQttyInStorage,
    this.totalQttyInStorageDouble,
    required this.groupUnit,
    required this.qttyPerGroup,
    this.categoryUuid,
    required this.wholeSalePrice,
    required this.storageUuid,
    required this.categories,
  });

  factory TempProductClass.fromJson(
    Map<String, dynamic> json,
  ) {
    return TempProductClass(
      id: json['id'] as int?,
      name: json['name'] as String,
      shopId: json['shop_id'] as int,
      brand: json['brand'] as String?,
      // category: json['category'] as String?,
      barcode: json['barcode'] as String?,
      unit: json['unit'] as String,
      isRefundable: json['is_refundable'] as bool,
      color: json['color'] as String?,
      sizeType: json['size_type'] as String?,
      size: json['size'] as String?,
      lowQtty: (json['low_qtty'] as num?)?.toDouble(),
      costPrice: (json['cost_price'] as num).toDouble(),
      sellingPrice:
          (json['selling_price'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      startDate:
          json['starting_date'] != null
              ? DateTime.parse(
                json['starting_date'] as String,
              )
              : null,
      endDate:
          json['ending_date'] != null
              ? DateTime.parse(
                json['ending_date'] as String,
              )
              : null,
      expiryDate:
          json['expiry_date'] != null
              ? DateTime.parse(
                json['expiry_date'] as String,
              )
              : null,
      quantity: (json['quantity'] as num?)?.toDouble(),
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
      setCustomPrice: json['set_custom_price'] as bool,
      departmentUuid: json['department_uuid'] as String?,
      departmentName: json['department_name'] as String?,
      isManaged: json['is_managed'] as bool,
      uuid: json['uuid'] as String?,
      totalQttyInStorage:
          (json['total_qtty_in_storage'] as num?)?.toInt(),
      totalQttyInStorageDouble:
          (json['total_qtty_in_storage_double'] as num?)
              ?.toDouble(),
      groupUnit: json['group_unit'] as String?,
      qttyPerGroup:
          (json['qtty_per_group'] as num?)?.toDouble(),
      categoryUuid: json['category_uuid'] as String?,
      wholeSalePrice:
          (json['whole_sale_price'] as num?)?.toDouble(),
      storageUuid: json['storage_uuid'] as String?,
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson({
    required bool isIncludeQuantity,
  }) {
    if (isIncludeQuantity) {
      return {
        'name': name,
        'shop_id': shopId,
        'brand': brand,
        // 'category': category,
        'barcode': barcode,
        'unit': unit,
        'is_refundable': isRefundable,
        'color': color,
        'size_type': sizeType,
        'size': size,
        'cost_price': costPrice,
        'selling_price': sellingPrice,
        'discount': discount,
        'starting_date':
            startDate?.toIso8601String().split('T').first,
        'ending_date':
            endDate?.toIso8601String().split('T').first,
        'expiry_date':
            expiryDate?.toIso8601String().split('T').first,
        'quantity': quantity,
        'set_custom_price': setCustomPrice,
        'department_uuid': departmentUuid,
        'department_name': departmentName,
        'low_qtty': lowQtty,
        'is_managed': isManaged,
        'updated_at': updatedAt?.toIso8601String(),
        'uuid': uuid,
        'total_qtty_in_storage': totalQttyInStorage,
        'total_qtty_in_storage_double':
            totalQttyInStorageDouble,
        'group_unit': groupUnit,
        'qtty_per_group': qttyPerGroup,
        'category_uuid': categoryUuid,
        'whole_sale_price': wholeSalePrice,
        'storage_uuid': storageUuid,
        'categories': categories ?? [],
      };
    } else {
      return {
        'name': name,
        'shop_id': shopId,
        'brand': brand,
        // 'category': category,
        'barcode': barcode,
        'unit': unit,
        'is_refundable': isRefundable,
        'color': color,
        'size_type': sizeType,
        'size': size,
        'cost_price': costPrice,
        'selling_price': sellingPrice,
        'discount': discount,
        'starting_date':
            startDate?.toIso8601String().split('T').first,
        'ending_date':
            endDate?.toIso8601String().split('T').first,
        'expiry_date':
            expiryDate?.toIso8601String().split('T').first,
        // 'quantity': quantity,
        'set_custom_price': setCustomPrice,
        'department_uuid': departmentUuid,
        'department_name': departmentName,
        'low_qtty': lowQtty,
        'is_managed': isManaged,
        'updated_at': updatedAt?.toIso8601String(),
        'uuid': uuid,
        'total_qtty_in_storage': totalQttyInStorage,
        'total_qtty_in_storage_double':
            totalQttyInStorageDouble,
        'group_unit': groupUnit,
        'qtty_per_group': qttyPerGroup,
        'category_uuid': categoryUuid,
        'whole_sale_price': wholeSalePrice,
        'storage_uuid': storageUuid,
        'categories': categories ?? [],
      };
    }
  }

  TempProductClass copyWith({
    int? id,
    String? name,
    int? shopId,
    String? brand,
    DateTime? createdAt,
    String? category,
    String? barcode,
    String? unit,
    bool? isRefundable,
    String? color,
    String? sizeType,
    String? size,
    double? costPrice,
    double? sellingPrice,
    double? discount,
    DateTime? startDate,
    DateTime? endDate,
    double? quantity,
    bool? setCustomPrice,
    String? departmentName,
    String? departmentUuid,
    double? lowQtty,
    DateTime? expiryDate,
    bool? isManaged,
    DateTime? updatedAt,
    String? uuid,
    int? totalQttyInStorage,
    double? totalQttyInStorageDouble,
    String? groupUnit,
    double? qttyPerGroup,
    String? categoryUuid,
    double? wholeSalePrice,
    String? storageUuid,
    List<String>? categories,
  }) {
    return TempProductClass(
      id: id ?? this.id,
      name: name ?? this.name,
      shopId: shopId ?? this.shopId,
      brand: brand ?? this.brand,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      barcode: barcode ?? this.barcode,
      unit: unit ?? this.unit,
      isRefundable: isRefundable ?? this.isRefundable,
      color: color ?? this.color,
      sizeType: sizeType ?? this.sizeType,
      size: size ?? this.size,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      discount: discount ?? this.discount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      quantity: quantity ?? this.quantity,
      setCustomPrice: setCustomPrice ?? this.setCustomPrice,
      departmentName: departmentName ?? this.departmentName,
      departmentUuid: departmentUuid ?? this.departmentUuid,
      lowQtty: lowQtty ?? this.lowQtty,
      expiryDate: expiryDate ?? this.expiryDate,
      isManaged: isManaged ?? this.isManaged,
      updatedAt: updatedAt ?? this.updatedAt,
      uuid: uuid ?? this.uuid,
      totalQttyInStorage:
          totalQttyInStorage ?? this.totalQttyInStorage,
      totalQttyInStorageDouble:
          totalQttyInStorageDouble ??
          this.totalQttyInStorageDouble,
      groupUnit: groupUnit ?? this.groupUnit,
      qttyPerGroup: qttyPerGroup ?? this.qttyPerGroup,
      categoryUuid: categoryUuid ?? this.categoryUuid,
      wholeSalePrice: wholeSalePrice ?? this.wholeSalePrice,
      storageUuid: storageUuid ?? this.storageUuid,
      categories: categories ?? this.categories,
    );
  }
}

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
  int? departmentId;

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
    this.departmentName,
    this.departmentId,
    this.lowQtty,
    this.expiryDate,
    required this.isManaged,
    this.updatedAt,
    this.uuid,
  });

  factory TempProductClass.fromJson(
    Map<String, dynamic> json,
  ) {
    return TempProductClass(
      id: json['id'] as int?,
      name: json['name'] as String,
      shopId: json['shop_id'] as int,
      brand: json['brand'] as String?,
      category: json['category'] as String?,
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
      departmentId: json['department_id'] as int?,
      departmentName: json['department_name'] as String?,
      isManaged: json['is_managed'] as bool,
      uuid: json['uuid'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'shop_id': shopId,
      'brand': brand,
      'category': category,
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
      'department_id': departmentId,
      'department_name': departmentName,
      'low_qtty': lowQtty,
      'is_managed': isManaged,
      'updated_at': updatedAt?.toIso8601String(),
      // 'uuid': uuid,
    };
  }
}

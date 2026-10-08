import 'package:hive/hive.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';

part 'product_prices_class.g.dart';

@HiveType(typeId: 147)
class ProductPricesClass extends HiveObject {
  @HiveField(0)
  String uuid;

  @HiveField(1)
  DateTime createdAt;

  @HiveField(2)
  String? staffName;

  @HiveField(3)
  String? staffUuid;

  @HiveField(4)
  double priceValue;

  @HiveField(5)
  String? name;

  @HiveField(6)
  bool isPrimary;

  @HiveField(7)
  String itemUuid;

  @HiveField(8)
  bool isFixed;

  ProductPricesClass({
    required this.uuid,
    required this.staffUuid,
    required this.createdAt,
    required this.staffName,
    required this.priceValue,
    required this.name,
    required this.isPrimary,
    required this.itemUuid,
    this.isFixed = false,
  });

  factory ProductPricesClass.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProductPricesClass(
      uuid: json['uuid'] as String,
      createdAt: DateTime.parse(json['created_at']),
      staffName: json['staff_name'] as String?,
      staffUuid: json['staff_uuid'] as String?,
      priceValue: (json['price_value'] as num).toDouble(),
      name: json['name'] as String?,
      isPrimary: json['is_primary'] as bool,
      itemUuid: json['item_uuid'] as String,
      isFixed: json['is_fixed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'created_at': createdAt.toIso8601String(),
      'staff_name': staffName,
      'staff_uuid': staffUuid,
      'uuid': uuid,
      'price_value': priceValue,
      'name': name,
      'is_primary': isPrimary,
      'item_uuid': itemUuid,
      'is_fixed': isFixed,
    };
  }

  ProductPricesClass copyWith({
    String? uuid,
    String? staffUuid,
    String? staffName,
    DateTime? createdAt,
    double? priceValue,
    String? name,
    bool? isPrimary,
    String? itemUuid,
    bool? isFixed,
  }) {
    return ProductPricesClass(
      uuid: uuid ?? this.uuid,
      staffUuid: staffUuid ?? this.staffUuid,
      createdAt: createdAt ?? this.createdAt,
      staffName: staffName ?? this.staffName,
      priceValue: priceValue ?? this.priceValue,
      name: name ?? this.name,
      isPrimary: isPrimary ?? this.isPrimary,
      itemUuid: itemUuid ?? this.itemUuid,
      isFixed: isFixed ?? this.isFixed,
    );
  }

  static List<ProductPricesClass> getPricesList({
    required String? itemUuid,
    double? price,
    required List<ProductPricesClass>? tempPricesList,
  }) {
    if (tempPricesList == null ||
        tempPricesList.isEmpty == true) {
      ProductPricesClass value = ProductPricesClass(
        uuid: uuidGen(),
        staffUuid: currentUser().userId,
        createdAt: DateTime.now(),
        staffName: currentUser().name,
        priceValue: price ?? 0,
        name: 'Prices',
        isPrimary: true,
        itemUuid: itemUuid ?? '',
      );
      return [value];
    } else {
      return tempPricesList;
    }
  }

  String getPricesName() {
    return name?.toUpperCase() ?? 'Price';
  }
}

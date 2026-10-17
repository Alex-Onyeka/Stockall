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
  bool? isFixed;

  @HiveField(9)
  int? priceType;

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
    this.priceType = 1,
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
      priceType: json['price_type'] as int? ?? 1,
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
      'price_type': priceType,
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
    int? priceType,
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
      priceType: priceType ?? this.priceType,
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
        priceType: 1,
      );
      return [value];
    } else {
      return tempPricesList;
    }
  }

  String getPricesName() {
    return name?.toUpperCase() ?? 'Price';
  }

  // Single / multiple prices mode. The mode is not stored:
  // an item with more than one price is in multiple mode.
  static bool hasMultiple(List<ProductPricesClass>? prices) {
    return (prices?.length ?? 0) > 1;
  }

  static ProductPricesClass? primaryOf(
    List<ProductPricesClass>? prices,
  ) {
    if (prices == null || prices.isEmpty) {
      return null;
    }
    var items = prices.where((item) => item.isPrimary);
    return items.isNotEmpty ? items.first : prices.first;
  }

  // Sets the primary price's value and keeps the other prices.
  static List<ProductPricesClass> withPrimaryValue({
    required List<ProductPricesClass> prices,
    required double priceValue,
    required ProductPricesClass Function() newPrice,
  }) {
    var primary = primaryOf(prices);
    if (primary == null) {
      return [
        newPrice().copyWith(
          priceValue: priceValue,
          isPrimary: true,
        ),
      ];
    }
    return prices.map((item) {
      if (item.uuid == primary.uuid) {
        return item.copyWith(
          priceValue: priceValue,
          isPrimary: true,
        );
      } else {
        return item.copyWith();
      }
    }).toList();
  }

  // Keeps only the primary price (same uuid), for single
  // price mode. Empty with no value stays empty so the
  // default price from getPricesList is used.
  static List<ProductPricesClass> singlePriceList({
    required List<ProductPricesClass> prices,
    required double? priceValue,
    required ProductPricesClass Function() newPrice,
  }) {
    var primary = primaryOf(prices);
    if (primary == null && priceValue == null) {
      return [];
    }
    return [
      (primary ?? newPrice()).copyWith(
        priceValue: priceValue ?? 0,
        isPrimary: true,
      ),
    ];
  }
}

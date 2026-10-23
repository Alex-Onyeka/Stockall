import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_product_class/prices_class/product_prices_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';

part 'draft_items.g.dart';

@HiveType(typeId: 148)
class DraftItems extends HiveObject {
  @HiveField(0)
  final String uuid;

  @HiveField(1)
  final String draftId;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  String? productUuid;

  @HiveField(4)
  String productName;

  @HiveField(5)
  double quantity;

  @HiveField(6)
  double? customPrice;

  @HiveField(7)
  bool setCustomPrice;

  @HiveField(8)
  bool setTotalPrice;

  @HiveField(9)
  bool useWholeSalePrice;

  @HiveField(10)
  bool addToStock;

  @HiveField(11)
  double? discount;

  @HiveField(12)
  double? fixedDiscount;

  @HiveField(13)
  bool? useGroupQuantity;

  @HiveField(14)
  double? qttyPerGroup;

  @HiveField(15)
  bool? isVoid;

  @HiveField(16)
  String? unit;

  @HiveField(17)
  String? groupUnit;

  @HiveField(18)
  String? unitUuid;

  @HiveField(19)
  List<ProductUnitsClass>? unitsList;

  @HiveField(20)
  String? priceUuid;

  @HiveField(21)
  List<ProductPricesClass>? pricesList;

  @HiveField(22)
  double? sellingPrice;

  @HiveField(23)
  double? costPrice;

  @HiveField(24)
  bool? isProductManaged;

  @HiveField(25)
  double? revenue;

  @HiveField(26)
  double? widthDimension;

  @HiveField(27)
  double? heightDimension;

  @HiveField(28)
  int? quantityType;

  @HiveField(29)
  bool? manageSalesWastage;

  @HiveField(30)
  bool? isPercentageWastage;

  @HiveField(31)
  double? wastageAmount;

  // Unit the fixed wastage amount was entered in. Null on lines
  // from before wastage units: their fixed amount is area.
  @HiveField(32)
  String? wastageUnitUuid;

  @HiveField(33)
  String? dimensionUnit;

  @HiveField(34)
  double? dimensionUnitConversion;

  DraftItems({
    required this.uuid,
    required this.draftId,
    required this.createdAt,
    required this.productUuid,
    required this.productName,
    required this.quantity,
    required this.customPrice,
    required this.setCustomPrice,
    required this.setTotalPrice,
    required this.useWholeSalePrice,
    required this.addToStock,
    required this.discount,
    required this.fixedDiscount,
    required this.useGroupQuantity,
    required this.qttyPerGroup,
    required this.isVoid,
    required this.unit,
    required this.groupUnit,
    required this.unitUuid,
    required this.unitsList,
    required this.priceUuid,
    required this.pricesList,
    required this.sellingPrice,
    required this.costPrice,
    required this.isProductManaged,
    required this.revenue,
    required this.widthDimension,
    required this.heightDimension,
    required this.quantityType,
    required this.manageSalesWastage,
    required this.isPercentageWastage,
    required this.wastageAmount,
    this.wastageUnitUuid,
    this.dimensionUnit,
    this.dimensionUnitConversion,
  });

  factory DraftItems.fromJson(Map<String, dynamic> json) {
    return DraftItems(
      uuid: json['uuid'] as String,
      draftId: json['draft_id'] as String,
      createdAt: DateTime.parse(json['created_at']),
      productUuid: json['product_uuid'] as String?,
      productName: json['product_name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      customPrice:
          (json['custom_price'] as num?)?.toDouble(),
      setCustomPrice:
          json['set_custom_price'] as bool? ?? false,
      setTotalPrice:
          json['set_total_price'] as bool? ?? false,
      useWholeSalePrice:
          json['use_whole_sale_price'] as bool? ?? false,
      addToStock: json['add_to_stock'] as bool? ?? false,
      discount: (json['discount'] as num?)?.toDouble(),
      fixedDiscount:
          (json['fixed_discount'] as num?)?.toDouble(),
      useGroupQuantity: json['use_group_quantity'] as bool?,
      qttyPerGroup:
          (json['qtty_per_group'] as num?)?.toDouble(),
      isVoid: json['is_void'] as bool?,
      unit: json['unit'] as String?,
      groupUnit: json['group_unit'] as String?,
      unitUuid: json['unit_uuid'] as String?,
      unitsList:
          (json['units_list'] as List<dynamic>? ?? [])
              .map(
                (item) => ProductUnitsClass.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(),
      priceUuid: json['price_uuid'] as String?,
      pricesList:
          (json['prices_list'] as List<dynamic>? ?? [])
              .map(
                (item) => ProductPricesClass.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(),
      sellingPrice:
          (json['selling_price'] as num?)?.toDouble(),
      costPrice: (json['cost_price'] as num?)?.toDouble(),
      isProductManaged: json['is_product_managed'] as bool?,
      revenue: (json['revenue'] as num?)?.toDouble(),
      widthDimension:
          (json['width_dimension'] as num?)?.toDouble(),
      heightDimension:
          (json['height_dimension'] as num?)?.toDouble(),
      quantityType: json['quantity_type'] as int?,
      manageSalesWastage:
          json['manage_sales_wastage'] as bool?,
      isPercentageWastage:
          json['is_percentage_wastage'] as bool?,
      wastageAmount:
          (json['wastage_amount'] as num?)?.toDouble(),
      wastageUnitUuid: json['wastage_unit_uuid'] as String?,
      dimensionUnit: json['dimension_unit'] as String?,
      dimensionUnitConversion:
          (json['dimension_unit_conversion'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'draft_id': draftId,
      'created_at': createdAt.toIso8601String(),
      'product_uuid': productUuid,
      'product_name': productName,
      'quantity': quantity,
      'custom_price': customPrice,
      'set_custom_price': setCustomPrice,
      'set_total_price': setTotalPrice,
      'use_whole_sale_price': useWholeSalePrice,
      'add_to_stock': addToStock,
      'discount': discount,
      'fixed_discount': fixedDiscount,
      'use_group_quantity': useGroupQuantity,
      'qtty_per_group': qttyPerGroup,
      'is_void': isVoid,
      'unit': unit,
      'group_unit': groupUnit,
      'unit_uuid': unitUuid,
      'units_list':
          (unitsList ?? []).map((e) => e.toJson()).toList(),
      'price_uuid': priceUuid,
      'prices_list':
          (pricesList ?? [])
              .map((e) => e.toJson())
              .toList(),
      'selling_price': sellingPrice,
      'cost_price': costPrice,
      'is_product_managed': isProductManaged,
      'revenue': revenue,
      'width_dimension': widthDimension,
      'height_dimension': heightDimension,
      'quantity_type': quantityType,
      'manage_sales_wastage': manageSalesWastage,
      'is_percentage_wastage': isPercentageWastage,
      'wastage_amount': wastageAmount,
      'wastage_unit_uuid': wastageUnitUuid,
      'dimension_unit': dimensionUnit,
      'dimension_unit_conversion': dimensionUnitConversion,
    };
  }
}

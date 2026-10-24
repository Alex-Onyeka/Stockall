import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_product_class/prices_class/product_prices_class.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';

part 'order_items.g.dart';

@HiveType(typeId: 133)
class OrderItems extends HiveObject {
  @HiveField(0)
  final String uuid;

  @HiveField(1)
  final String orderId;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  String productName;

  @HiveField(4)
  String productUuid;

  @HiveField(5)
  String staffId;

  @HiveField(6)
  String staffName;

  @HiveField(7)
  String? customerName;

  @HiveField(8)
  String? customerUuid;

  @HiveField(9)
  double? discount;

  @HiveField(10)
  double quantity;

  @HiveField(11)
  double revenue;

  @HiveField(12)
  double? discountedAmount;

  @HiveField(13)
  double? originalCost;

  @HiveField(14)
  double? costPrice;

  @HiveField(15)
  bool customPriceSet;

  @HiveField(16)
  String? departmentName;

  @HiveField(17)
  String? departmentUuid;

  @HiveField(18)
  bool? addToStock;

  @HiveField(19)
  bool? isProductManaged;

  @HiveField(20)
  bool? setTotalPrice;

  @HiveField(21)
  double? fixedDiscount;

  @HiveField(22)
  String? unit;

  @HiveField(23)
  String? groupUnit;

  @HiveField(24)
  bool? useWholeSalePrice;

  @HiveField(25)
  bool? useGroupQuantity;

  @HiveField(26)
  double? qttyPerGroup;

  @HiveField(27)
  double? remainingQuantity;

  @HiveField(28)
  double? remainingBalance;

  @HiveField(29)
  double? tempQuantity;

  @HiveField(30)
  bool? originalUseGroupQuantity;

  @HiveField(31)
  bool? tempUseGroupQuantity;

  @HiveField(32)
  List<ProductUnitsClass>? unitsList;

  @HiveField(33)
  String? unitUuid;

  @HiveField(34)
  List<ProductPricesClass>? pricesList;

  @HiveField(35)
  String? priceUuid;

  @HiveField(36)
  double? widthDimension;

  @HiveField(37)
  double? heightDimension;

  @HiveField(38)
  int? quantityType;

  @HiveField(39)
  bool? manageSalesWastage;

  @HiveField(40)
  bool? isPercentageWastage;

  @HiveField(41)
  double? wastageAmount;

  @HiveField(42)
  String? dimensionUnit;

  @HiveField(43)
  double? dimensionUnitConversion;

  @HiveField(44)
  String? wastageUnitUuid;

  OrderItems({
    required this.uuid,
    required this.orderId,
    required this.productName,
    required this.productUuid,
    required this.createdAt,
    required this.staffName,
    required this.staffId,
    required this.costPrice,
    required this.customerName,
    required this.customerUuid,
    required this.departmentName,
    required this.departmentUuid,
    required this.qttyPerGroup,
    required this.quantity,
    required this.revenue,
    required this.unit,
    required this.useGroupQuantity,
    required this.useWholeSalePrice,
    required this.groupUnit,
    required this.addToStock,
    required this.customPriceSet,
    required this.discount,
    required this.discountedAmount,
    required this.fixedDiscount,
    required this.isProductManaged,
    required this.originalCost,
    required this.setTotalPrice,
    this.remainingBalance,
    required this.remainingQuantity,
    this.tempQuantity,
    required this.originalUseGroupQuantity,
    required this.tempUseGroupQuantity,
    required this.unitsList,
    required this.unitUuid,
    required this.pricesList,
    required this.priceUuid,
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

  factory OrderItems.fromJson(Map<String, dynamic> json) {
    return OrderItems(
      uuid: json['uuid'],
      orderId: json['order_id'],
      createdAt: DateTime.parse(json['created_at']),
      productName: json['product_name'] as String,
      productUuid: json['product_uuid'] as String,
      staffName: json['staff_name'],
      staffId: json['staff_uuid'] as String,
      costPrice: (json['cost_price'] as num?)?.toDouble(),
      quantity: (json['quantity'] as num).toDouble(),
      revenue: (json['revenue'] as num).toDouble(),
      customerName: json['customer_name'] as String?,
      customerUuid: json['customer_uuid'] as String?,
      departmentName: json['department_name'] as String?,
      departmentUuid: json['department_uuid'] as String?,
      qttyPerGroup:
          (json['qtty_per_group'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      groupUnit: json['group_unit'] as String?,
      useGroupQuantity: json['use_group_quantity'] as bool?,
      useWholeSalePrice:
          json['use_whole_sale_price'] as bool?,
      addToStock: json['add_to_stock'] as bool?,
      customPriceSet: json['custom_price_set'] as bool,
      discount: (json['discount'] as num?)?.toDouble(),
      discountedAmount:
          (json['discounted_amount'] as num?)?.toDouble(),
      fixedDiscount:
          (json['fixed_discount'] as num?)?.toDouble(),
      isProductManaged: json['is_product_managed'] as bool,
      originalCost:
          (json['original_cost'] as num?)?.toDouble(),
      setTotalPrice: json['set_total_price'] as bool,
      remainingBalance:
          (json['remaining_balance'] as num?)?.toDouble(),
      remainingQuantity:
          (json['remaining_quantity'] as num?)?.toDouble(),
      originalUseGroupQuantity:
          json['original_use_group_quantity'] as bool?,
      tempUseGroupQuantity:
          json['temp_use_group_quantity'] as bool?,
      unitsList:
          (json['units_list'] as List<dynamic>? ?? [])
              .map(
                (item) => ProductUnitsClass.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(),
      unitUuid: json['unit_uuid'] as String?,
      pricesList:
          (json['prices_list'] as List<dynamic>? ?? [])
              .map(
                (item) => ProductPricesClass.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(),
      priceUuid: json['price_uuid'] as String?,
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
          (json['dimension_unit_conversion'] as num?)
              ?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'order_id': orderId,
      'created_at': createdAt.toIso8601String(),
      'product_uuid': productUuid,
      'product_name': productName,
      'staff_name': staffName,
      'staff_uuid': staffId,
      'cost_price': costPrice,
      'quantity': quantity,
      'revenue': revenue,
      'customer_name': customerName,
      'customer_uuid': customerUuid,
      'department_name': departmentName,
      'department_uuid': departmentUuid,
      'qtty_per_group': qttyPerGroup,
      'unit': unit,
      'group_unit': groupUnit,
      'use_group_quantity': useGroupQuantity,
      'use_whole_sale_price': useWholeSalePrice,
      'add_to_stock': addToStock,
      'custom_price_set': customPriceSet,
      'discount': discount,
      'discounted_amount': discountedAmount,
      'fixed_discount': fixedDiscount,
      'is_product_managed': isProductManaged,
      'original_cost': originalCost,
      'set_total_price': setTotalPrice,
      'remaining_balance': remainingBalance,
      'remaining_quantity': remainingQuantity,
      'original_use_group_quantity':
          originalUseGroupQuantity,
      'temp_use_group_quantity': tempUseGroupQuantity,
      'units_list': ProductUnitsClass.getUnitList(
        tempUnitList: unitsList,
        productUuid: uuid,
      ),
      'unit_uuid': unitUuid,
      'prices_list': ProductPricesClass.getPricesList(
        tempPricesList: pricesList,
        itemUuid: uuid,
      ),
      'price_uuid': priceUuid,
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

  OrderItems copyWith({
    String? uuid,
    String? orderId,
    DateTime? createdAt,
    String? productUuid,
    String? productName,
    String? staffId,
    String? staffName,
    String? customerUuid,
    String? customerName,
    double? quantity,
    double? revenue,
    double? costPrice,
    String? departmentName,
    String? departmentUuid,
    String? unit,
    bool? useWholeSalePrice,
    bool? useGroupQuantity,
    double? qttyPerGroup,
    String? groupUnit,
    bool? addToStock,
    bool? customPriceSet,
    double? discount,
    double? discountedAmount,
    double? fixedDiscount,
    bool? isProductManaged,
    double? originalCost,
    bool? setTotalPrice,
    double? remainingBalance,
    double? remainingQuantity,
    bool? originalUseGroupQuantity,
    bool? tempUseGroupQuantity,
    List<ProductUnitsClass>? unitsList,
    String? unitUuid,
    List<ProductPricesClass>? pricesList,
    String? priceUuid,
    double? widthDimension,
    double? heightDimension,
    int? quantityType,
    bool? manageSalesWastage,
    bool? isPercentageWastage,
    double? wastageAmount,
    String? wastageUnitUuid,
    String? dimensionUnit,
    double? dimensionUnitConversion,
  }) {
    return OrderItems(
      uuid: uuid ?? this.uuid,
      orderId: orderId ?? this.orderId,
      createdAt: createdAt ?? this.createdAt,
      productUuid: productUuid ?? this.productUuid,
      productName: productName ?? this.productName,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      customerUuid: customerUuid ?? this.customerUuid,
      customerName: customerName ?? this.customerName,
      quantity: quantity ?? this.quantity,
      revenue: revenue ?? this.revenue,
      costPrice: costPrice ?? this.costPrice,
      departmentName: departmentName ?? this.departmentName,
      departmentUuid: departmentUuid ?? this.departmentUuid,
      unit: unit ?? this.unit,
      useWholeSalePrice:
          useWholeSalePrice ?? this.useWholeSalePrice,
      useGroupQuantity:
          useGroupQuantity ?? this.useGroupQuantity,
      qttyPerGroup: qttyPerGroup ?? this.qttyPerGroup,
      groupUnit: groupUnit ?? this.groupUnit,
      addToStock: addToStock ?? this.addToStock,
      customPriceSet: customPriceSet ?? this.customPriceSet,
      discount: discount ?? this.discount,
      discountedAmount:
          discountedAmount ?? this.discountedAmount,
      fixedDiscount: fixedDiscount ?? this.fixedDiscount,
      isProductManaged:
          isProductManaged ?? this.isProductManaged,
      originalCost: originalCost ?? this.originalCost,
      setTotalPrice: setTotalPrice ?? this.setTotalPrice,
      remainingQuantity:
          remainingQuantity ?? this.remainingQuantity,
      remainingBalance:
          remainingBalance ?? this.remainingBalance,
      originalUseGroupQuantity:
          originalUseGroupQuantity ??
          this.originalUseGroupQuantity,
      tempUseGroupQuantity:
          tempUseGroupQuantity ?? this.tempUseGroupQuantity,
      unitsList: unitsList ?? this.unitsList,
      unitUuid: unitUuid ?? this.unitUuid,
      pricesList: pricesList ?? this.pricesList,
      priceUuid: priceUuid ?? this.priceUuid,
      widthDimension: widthDimension ?? this.widthDimension,
      heightDimension:
          heightDimension ?? this.heightDimension,
      quantityType: quantityType ?? this.quantityType,
      manageSalesWastage:
          manageSalesWastage ?? this.manageSalesWastage,
      isPercentageWastage:
          isPercentageWastage ?? this.isPercentageWastage,
      wastageAmount: wastageAmount ?? this.wastageAmount,
      wastageUnitUuid:
          wastageUnitUuid ?? this.wastageUnitUuid,
      dimensionUnit: dimensionUnit ?? this.dimensionUnit,
      dimensionUnitConversion:
          dimensionUnitConversion ??
          this.dimensionUnitConversion,
    );
  }

  //
  //
  //
  //
  //

  List<ProductPricesClass> getPriceListFinal() {
    return getPricesList()
        .map((item) => item.copyWith())
        .toList();
  }

  ProductPricesClass getSelectedPrice({
    String? priceUuidNew,
  }) {
    final requestedPriceUuid = priceUuidNew ?? priceUuid;
    var items = getPricesList().where(
      (item) => item.uuid == requestedPriceUuid,
    );
    if (items.isEmpty) {
      return getPrimaryPrice();
    } else {
      return getPricesList().firstWhere(
        (item) => item.uuid == requestedPriceUuid,
      );
    }
  }

  ProductPricesClass getPrimaryPrice() {
    if (getPricesList().isEmpty == true ||
        getPricesList()
            .where((item) => item.isPrimary == true)
            .isEmpty) {
      return ProductPricesClass(
        uuid: uuidGen(),
        staffUuid: currentUser().userId,
        createdAt: DateTime.now(),
        staffName: currentUser().name,
        priceValue: revenue,
        name: 'Price',
        isPrimary: true,
        itemUuid: uuid,
        priceType: 1,
      );
    } else {
      return getPricesList()
          .where((item) => item.isPrimary == true)
          .first;
    }
  }

  List<ProductPricesClass> getPricesList() {
    List<ProductPricesClass> tempList() {
      if (pricesList == null ||
          pricesList?.isEmpty == true) {
        List<ProductPricesClass> tempList = [
          ProductPricesClass(
            uuid: uuidGen(),
            staffUuid: currentUser().userId,
            createdAt: DateTime.now(),
            staffName: currentUser().name,
            priceValue: 0,
            name: 'Price',
            isPrimary: true,
            itemUuid: uuid,
            priceType: 1,
          ),
        ];

        return tempList;
      } else {
        return pricesList ?? [];
      }
    }

    if (tempList().length < 2) {
      return tempList();
    } else {
      return [
        tempList().firstWhere((item) => item.isPrimary),
        ...tempList().where((item) => !item.isPrimary),
      ];
    }
  }

  //
  //
  //
  //
  //
  //

  List<ProductUnitsClass> getUnitListFinal() {
    return getUnitsList()
        .map((item) => item.copyWith())
        .toList();
  }

  double getSelectedUnitQuantity({BuildContext? context}) {
    if (unitsList == null || unitsList?.isEmpty == true) {
      return quantity;
    } else {
      var items = unitsList!.where(
        (item) => item.uuid == unitUuid,
      );
      if (items.isEmpty) {
        return quantity;
      } else {
        var item = items.first;
        return item.getQuantityEquivDivided(
          index: 1,
          context: context,
          newQuantity: quantity,
        );
      }
    }
  }

  double getSelectedUnitQuantityMultiplied({
    BuildContext? context,
  }) {
    if (unitsList == null || unitsList?.isEmpty == true) {
      return quantity;
    } else {
      var items = unitsList!.where(
        (item) => item.uuid == unitUuid,
      );
      if (items.isEmpty) {
        return quantity;
      } else {
        var item = items.first;
        return item.getQuantityEquivMultiplied(
          index: 1,
          newQuantity: quantity,
          context: context,
        );
      }
    }
  }

  ProductUnitsClass getSelectedUnit({String? unitUuidNew}) {
    final requestedUnitUuid = unitUuidNew ?? unitUuid;
    var items = getUnitsList().where(
      (item) => item.uuid == requestedUnitUuid,
    );
    if (items.isEmpty) {
      if (useGroupQuantity == true) {
        final groupUnits = getUnitsList().where(
          (item) => !item.isPrimary,
        );
        if (groupUnits.isNotEmpty) {
          return groupUnits.first;
        }
      }
      return getPrimaryUnit();
    } else {
      return getUnitsList().firstWhere(
        (item) => item.uuid == requestedUnitUuid,
      );
    }
  }

  ProductUnitsClass getPrimaryUnit() {
    if (getUnitsList().isEmpty == true ||
        getUnitsList()
            .where((item) => item.isPrimary == true)
            .isEmpty) {
      return ProductUnitsClass(
        uuid: uuidGen(),
        staffUuid: currentUser().userId,
        createdAt: DateTime.now(),
        staffName: currentUser().name,
        conversion: 1,
        name:
            unit == 'Others'
                ? 'Unit(s)'
                : unit ?? 'Unit(s)',
        isPrimary: true,
        productUuid: uuid,
      );
    } else {
      return getUnitsList()
          .where((item) => item.isPrimary == true)
          .first;
    }
  }

  List<ProductUnitsClass> getUnitsList() {
    List<ProductUnitsClass> tempList() {
      if (unitsList == null || unitsList?.isEmpty == true) {
        List<ProductUnitsClass> tempList = [
          ProductUnitsClass(
            uuid: uuidGen(),
            staffUuid: currentUser().userId,
            createdAt: DateTime.now(),
            staffName: currentUser().name,
            conversion: 1,
            name:
                unit == 'Others'
                    ? 'Unit(s)'
                    : unit ?? 'Unit(s)',
            isPrimary: true,
            productUuid: uuid,
          ),
        ];
        if (useGroupQuantity == true) {
          var newItem = ProductUnitsClass(
            uuid: uuidGen(),
            staffUuid: currentUser().userId,
            createdAt: DateTime.now(),
            staffName: currentUser().name,
            conversion: qttyPerGroup ?? 1,
            name: 'Group(s)',
            isPrimary: false,
            productUuid: uuid,
          );
          tempList.add(newItem);
        }
        return tempList;
      } else {
        final tempList = List<ProductUnitsClass>.from(
          unitsList!,
        );
        if (useGroupQuantity == true &&
            tempList.every((item) => item.isPrimary)) {
          tempList.add(
            ProductUnitsClass(
              uuid: uuidGen(),
              staffUuid: currentUser().userId,
              createdAt: DateTime.now(),
              staffName: currentUser().name,
              conversion: qttyPerGroup ?? 1,
              name: groupUnit ?? 'Group(s)',
              isPrimary: false,
              productUuid: productUuid,
            ),
          );
        }
        return tempList;
      }
    }

    if (tempList().length < 2) {
      return tempList();
    } else {
      return [
        tempList().firstWhere((item) => item.isPrimary),
        ...tempList().where((item) => !item.isPrimary),
      ];
    }
  }

  bool getTempUseGroupQuantity() {
    return tempUseGroupQuantity ?? false;
  }

  bool getOriginalUseGroupQuantity() {
    return originalUseGroupQuantity ?? false;
  }

  double getRemainingBalance() {
    return (getActualRemainingQuantity() * (revenue));
  }

  double getActualRemainingQuantity({String? unitUuidNew}) {
    return getQuantityInPrimaryUnits(
      remainingQuantity ?? quantity,
      unitUuid: unitUuidNew ?? unitUuid,
    );
  }

  double getTotalRevenue({String? unitUuidNew}) {
    return (revenue *
        getActualQuantity(
          unitUuidNew: unitUuidNew ?? unitUuid,
        ));
  }

  double getTotalOriginalSellingPrice({
    String? unitUuidNew,
  }) {
    return ((originalCost ?? 0) *
        getActualQuantity(
          unitUuidNew: unitUuidNew ?? unitUuid,
        ));
  }

  double getTotalCostPrice() {
    return ((costPrice ?? 0) * getActualQuantity());
  }

  double getActualQuantity({String? unitUuidNew}) {
    return getQuantityInPrimaryUnits(
      quantity,
      unitUuid: unitUuidNew ?? unitUuid,
    );
  }

  double getActualQuantityDuringDeliveryCheckout() {
    return getActualQuantity();
  }

  double calcQuantity({
    required double quantity,
    String? unitUuidNew,
  }) {
    return getQuantityInPrimaryUnits(
      quantity,
      unitUuid: unitUuidNew ?? unitUuid,
    );
  }

  double getQuantityInPrimaryUnits(
    double quantity, {
    String? unitUuid,
  }) {
    final selectedUnit = getSelectedUnit(
      unitUuidNew: unitUuid,
    );
    final conversion = selectedUnit.conversion;
    if (!conversion.isFinite || conversion <= 0) {
      throw StateError(
        'Unit conversion must be greater than zero to convert quantities.',
      );
    }
    if (quantityType == 2 &&
        selectedUnit.dimensionType ==
            ProductUnitsClass.areaUnit) {
      return quantity * conversion;
    }
    return quantity * conversion * dimensionArea();
  }

  // Wastage area this line took from stock. Only lines saved
  // with manageSalesWastage == true applied it; older lines count as 0.
  double wastageArea() {
    if (quantityType != 2 || manageSalesWastage != true) {
      return 0;
    }
    return computeWastageArea(
      baseArea: getActualQuantity(),
      amount:
          isPercentageWastage == true ||
                  wastageAmount == null
              ? wastageAmount
              : wastageAmount! * wastageAreaPerUnit(),
      isPercentage: isPercentageWastage,
    );
  }

  // Area one unit of fixed wastage stands for, as the cart line
  // converts it (piece units at the line's size). 1 without a
  // stored unit: older lines kept the amount in area.
  double wastageAreaPerUnit() {
    final prim = getPrimaryUnit();
    final targetUuid = wastageUnitUuid ?? prim.uuid;
    final unit =
        getUnitsList()
            .where((unit) => unit.uuid == targetUuid)
            .firstOrNull ??
        prim;
    if (quantityType == 2 &&
        unit.dimensionType == ProductUnitsClass.areaUnit) {
      return unit.conversion > 0 ? unit.conversion : 1.0;
    }
    if (quantityType == 2) {
      final area =
          dimensionArea() > 0 ? dimensionArea() : 1.0;
      return (unit.conversion > 0 ? unit.conversion : 1.0) *
          area;
    }
    return unit.conversion > 0 ? unit.conversion : 1.0;
  }

  // Quantity this line takes from stock: actual quantity + wastage.
  double getStockQuantity() {
    return getActualQuantity() + wastageArea();
  }

  bool get hasCustomDimensions =>
      (widthDimension != null && widthDimension! > 0) ||
      (heightDimension != null && heightDimension! > 0);

  // Total line quantity displayed in Cart Tile, Orders and Receipts.
  // When a 2D item has custom dimensions, this is the equivalent quantity
  // in the primary unit (e.g. 1.0 M²).
  // For all other lines, it is the line quantity in the selected unit.
  double displayQuantity({TempProductClass? product}) {
    if (quantityType == 2 && hasCustomDimensions) {
      return getStockQuantity();
    }
    return historyQuantityChange(product: product);
  }

  // Decimal fraction / unit quantity for ItemHistory (e.g. 0.5 Slabs).
  double historyQuantityChange({
    TempProductClass? product,
  }) {
    if (quantityType == 2) {
      final unit = getSelectedUnit();
      if (unit.dimensionType ==
          ProductUnitsClass.areaUnit) {
        return getStockQuantity() /
            (unit.conversion > 0 ? unit.conversion : 1.0);
      }
      final wholeArea =
          (product != null && product.dimensionArea() > 0)
              ? product.dimensionArea() *
                  (unit.conversion > 0
                      ? unit.conversion
                      : 1.0)
              : (unit.conversion > 0
                      ? unit.conversion
                      : 1.0) *
                  dimensionArea();
      if (wholeArea > 0) {
        return getStockQuantity() / wholeArea;
      }
    }
    final wastage = wastageArea();
    if (wastage <= 0) return quantity;
    final base = getActualQuantity();
    if (base <= 0) return quantity;
    return quantity + quantity * wastage / base;
  }

  // Unit name displayed in Cart Tile, Orders and Receipts.
  String displayUnitName() {
    if (quantityType == 2 && hasCustomDimensions) {
      final pUnit = getPrimaryUnit();
      return pUnit.name == 'Others'
          ? 'Unit(s)'
          : pUnit.name;
    }
    final sel = getSelectedUnit();
    return sel.name == 'Others' ? 'Unit(s)' : sel.name;
  }

  double baseQuantityInSaleUnit({
    TempProductClass? product,
  }) {
    if (quantityType == 2) {
      final unit = getSelectedUnit();
      if (unit.dimensionType ==
          ProductUnitsClass.areaUnit) {
        return getActualQuantity() /
            (unit.conversion > 0 ? unit.conversion : 1.0);
      }
      final wholeArea =
          (product != null && product.dimensionArea() > 0)
              ? product.dimensionArea() *
                  (unit.conversion > 0
                      ? unit.conversion
                      : 1.0)
              : (unit.conversion > 0
                      ? unit.conversion
                      : 1.0) *
                  dimensionArea();
      if (wholeArea > 0) {
        return getActualQuantity() / wholeArea;
      }
    }
    return quantity;
  }

  // Wastage calculated in the primary unit (e.g. 0.1 Slabs, or 2.0 M²).
  double wastageInPrimaryUnit({TempProductClass? product}) {
    final wArea = wastageArea();
    if (wArea <= 0) return 0;
    final primUnit =
        product?.getPrimaryUnit() ?? getPrimaryUnit();
    final productArea =
        (product != null && product.dimensionArea() > 0)
            ? product.dimensionArea()
            : dimensionArea();
    final areaPerUnit =
        primUnit.dimensionType == ProductUnitsClass.areaUnit
            ? (primUnit.conversion > 0
                ? primUnit.conversion
                : 1.0)
            : (primUnit.conversion > 0
                    ? primUnit.conversion
                    : 1.0) *
                (productArea > 0 ? productArea : 1.0);
    if (!areaPerUnit.isFinite || areaPerUnit <= 0) return 0;
    return wArea / areaPerUnit;
  }

  // Backward compatibility alias: wastage is now always in primary unit.
  double wastageInSaleUnit({TempProductClass? product}) =>
      wastageInPrimaryUnit(product: product);

  // "incl. 0.1 Slab wastage", or '' without wastage (always in primary unit).
  String wastageNote({TempProductClass? product}) {
    final wastage = wastageInPrimaryUnit(product: product);
    if (wastage <= 1e-9) return '';
    final primUnit =
        product?.getPrimaryUnit() ?? getPrimaryUnit();
    final unitName =
        primUnit.name == 'Others'
            ? 'Unit(s)'
            : primUnit.name;
    return 'incl. ${formatDimension(wastage)} $unitName wastage';
  }

  // Quantity text for item-history records.
  String historyQuantityText({TempProductClass? product}) {
    return formatDimension(
      historyQuantityChange(product: product),
    );
  }

  // Quantity text for receipts and order display.
  String quantityText({TempProductClass? product}) {
    return formatDimension(
      displayQuantity(product: product),
    );
  }

  // Unit label for ItemHistory.
  // Shows selected unit, plus primary unit equiv in brackets if they differ:
  // e.g. "bottles (0.2 Crates)" or "Slabs (0.5 M²)", or just "Crates" / "M²".
  String historyUnit({TempProductClass? product}) {
    final selUnit = getSelectedUnit();
    final primUnit =
        product?.getPrimaryUnit() ?? getPrimaryUnit();
    final selName =
        selUnit.name == 'Others'
            ? 'Unit(s)'
            : selUnit.name.trim();
    final primName =
        primUnit.name == 'Others'
            ? 'Unit(s)'
            : primUnit.name.trim();

    if (selName.isEmpty) return primName;
    if (primName.isEmpty ||
        selName.toLowerCase() == primName.toLowerCase()) {
      return selName;
    }

    final primaryQty = primUnit.getQuantityEquivDivided(
      index: 1,
      newQuantity: getStockQuantity(),
      product: product,
    );

    return formatHistoryUnit(
      selectedUnit: selName,
      primaryUnit: primName,
      primaryQuantity: primaryQty,
    );
  }

  String historyWastageText({TempProductClass? product}) {
    final wastage = wastageInPrimaryUnit(product: product);
    if (wastage <= 1e-9) return '';
    final primUnit =
        product?.getPrimaryUnit() ?? getPrimaryUnit();
    final unitName =
        primUnit.name == 'Others'
            ? 'Unit(s)'
            : primUnit.name;
    return ' (incl. ${formatDimension(wastage)} $unitName wastage)';
  }

  double getQuantityFromPrimaryUnits(
    double quantity, {
    String? unitUuid,
  }) {
    final selectedUnit = getSelectedUnit(
      unitUuidNew: unitUuid,
    );
    final conversion = selectedUnit.conversion;
    if (!conversion.isFinite || conversion <= 0) {
      throw StateError(
        'Unit conversion must be greater than zero to convert quantities.',
      );
    }
    final areaPerUnit =
        quantityType == 2 &&
                selectedUnit.dimensionType ==
                    ProductUnitsClass.areaUnit
            ? conversion
            : conversion * dimensionArea();
    return quantity / areaPerUnit;
  }

  // Width × height this line was ordered at, converted to base unit area. 1 when not set.
  double dimensionArea() {
    if (widthDimension == null ||
        heightDimension == null ||
        widthDimension! * heightDimension! <= 0) {
      return 1;
    }
    final dConversion =
        (dimensionUnitConversion != null &&
                dimensionUnitConversion! > 0)
            ? dimensionUnitConversion!
            : 1.0;
    return (widthDimension! * heightDimension!) /
        dConversion;
  }

  String dimensionsLabel() {
    return formatDimensionsLabel(
      widthDimension,
      heightDimension,
      unit: dimensionUnit,
    );
  }

  String getUnit() {
    return getSelectedUnit().name;
  }
}

class StaffGroupOrders {
  final String? staffUuid;
  final String? staffName;
  int number;
  double totalBalance;
  double totalOriginalCost;
  double totalRevenue;

  StaffGroupOrders({
    required this.staffUuid,
    required this.staffName,
    required this.number,
    required this.totalBalance,
    required this.totalOriginalCost,
    required this.totalRevenue,
  });
}

class CustomerGroupOrders {
  final String? customerUuid;
  final String? customerName;
  int number;
  double totalBalance;
  double totalOriginalCost;
  double totalRevenue;

  CustomerGroupOrders({
    required this.customerUuid,
    required this.customerName,
    required this.number,
    required this.totalBalance,
    required this.totalOriginalCost,
    required this.totalRevenue,
  });
}

class DepartmentGroupOrders {
  final String departmentUuid;
  final String? departmentName;
  int number;
  double totalBalance;
  double totalOriginalCost;
  double totalRevenue;

  DepartmentGroupOrders({
    required this.departmentUuid,
    required this.departmentName,
    required this.number,
    required this.totalBalance,
    required this.totalOriginalCost,
    required this.totalRevenue,
  });
}

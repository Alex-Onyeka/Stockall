import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/prices_class/product_prices_class.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:hive/hive.dart';

part 'temp_cart_item.g.dart';

@HiveType(typeId: 72)
class TempCartItem extends HiveObject {
  @HiveField(0)
  TempProductClass item;

  @HiveField(1)
  double? discount;

  @HiveField(2)
  double? fixedDiscount;

  @HiveField(3)
  double quantity;

  @HiveField(4)
  double? customPrice;

  @HiveField(5)
  bool setCustomPrice;

  @HiveField(6)
  bool useWholeSalePrice;

  @HiveField(7)
  bool setTotalPrice;

  @HiveField(8)
  bool addToStock;

  @HiveField(9)
  String? salesRecordId;

  @HiveField(10)
  bool? useGroupQuantity;

  @HiveField(11)
  double? qttyPerGroup;

  @HiveField(12)
  bool? isVoid;

  @HiveField(13)
  String? itemUuid;

  @HiveField(14)
  String? uuid;

  @HiveField(15)
  double? remainingQuantity;

  @HiveField(16)
  double? remainingBalance;

  @HiveField(17)
  String? unitUuid;

  @HiveField(18)
  String? priceUuid;

  @HiveField(19)
  double? widthDimension;

  @HiveField(20)
  double? heightDimension;

  @HiveField(21)
  int? quantityType;

  @HiveField(22)
  bool? manageSalesWastage;

  @HiveField(23)
  bool? isPercentageWastage;

  @HiveField(24)
  double? wastageAmount;

  // Unit the fixed wastage amount was entered in. Null on lines
  // from before wastage units: their fixed amount is area.
  @HiveField(25)
  String? wastageUnitUuid;

  TempCartItem({
    required this.item,
    required this.itemUuid,
    required this.quantity,
    required this.discount,
    this.fixedDiscount,
    this.customPrice,
    this.setCustomPrice = true,
    required this.addToStock,
    required this.setTotalPrice,
    required this.useWholeSalePrice,
    this.salesRecordId,
    required this.useGroupQuantity,
    required this.qttyPerGroup,
    required this.isVoid,
    required this.uuid,
    this.remainingQuantity,
    this.remainingBalance,
    required this.unitUuid,
    required this.priceUuid,
    required this.widthDimension,
    required this.heightDimension,
    required this.quantityType,
    required this.manageSalesWastage,
    required this.isPercentageWastage,
    required this.wastageAmount,
    this.wastageUnitUuid,
  });

  // A line for [product] added without the sale dialog (barcode
  // scans), with the fields the dialog path sets. 2D lines take
  // the item's full size; no wastage is entered.
  factory TempCartItem.forProduct(
    TempProductClass product, {
    double quantity = 1,
  }) {
    final is2D = product.quantityType == 2;
    return TempCartItem(
      item: product,
      itemUuid: product.uuid,
      quantity: quantity,
      discount: product.discount,
      setCustomPrice: false,
      addToStock: false,
      setTotalPrice: false,
      useWholeSalePrice: false,
      useGroupQuantity: false,
      qttyPerGroup: product.qttyPerGroup,
      isVoid: false,
      uuid: uuidGen(),
      unitUuid:
          product.unitsList
              ?.where((unit) => unit.isPrimary)
              .firstOrNull
              ?.uuid,
      priceUuid:
          product.pricesList
              ?.where((price) => price.isPrimary)
              .firstOrNull
              ?.uuid,
      widthDimension: is2D ? product.widthDimension : null,
      heightDimension:
          is2D ? product.heightDimension : null,
      quantityType: product.quantityType,
      manageSalesWastage:
          is2D && product.manageSalesWastage == true
              ? true
              : null,
      isPercentageWastage: null,
      wastageAmount: null,
    );
  }

  factory TempCartItem.fromJson(Map<String, dynamic> json) {
    return TempCartItem(
      item: TempProductClass.fromJson(json['item']),
      uuid: json['uuid'],
      itemUuid: json['item_uuid'],
      discount: json['discount'],
      quantity: json['quantity'],
      customPrice: json['customPrice'],
      setCustomPrice: json['setCustomPrice'],
      addToStock: json['addToStock'],
      setTotalPrice: json['setTotalPrice'],
      salesRecordId: json['salesRecordId'],
      fixedDiscount: json['fixed_discount'],
      useWholeSalePrice: json['use_whole_sale_price'],
      useGroupQuantity: json['sell_group'],
      qttyPerGroup: json['qtty_per_group'],
      isVoid: json['is_void'],
      remainingBalance: json['remaining_balance'],
      remainingQuantity: json['remaining_quantity'],
      unitUuid: json['unit_uuid'],
      priceUuid: json['price_uuid'],
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
    );
  }

  Map<String, dynamic> toJson() => {
    'item': item.toJson(isIncludeQuantity: true),
    'item_uuid': itemUuid,
    'discount': discount,
    'fixed_discount': fixedDiscount,
    'quantity': quantity,
    'customPrice': customPrice,
    'setCustomPrice': setCustomPrice,
    'setTotalPrice': setTotalPrice,
    'addToStock': addToStock,
    'salesRecordId': salesRecordId,
    'use_whole_sale_price': useWholeSalePrice,
    'sell_group': useGroupQuantity,
    'qtty_per_group': qttyPerGroup,
    'is_void': isVoid,
    'uuid': uuid,
    'remaining_quantity': remainingQuantity,
    'remaining_balance': remainingBalance,
    'unit_uuid': unitUuid,
    'price_uuid': priceUuid,
    'width_dimension': widthDimension,
    'height_dimension': heightDimension,
    'quantity_type': quantityType,
    'manage_sales_wastage': manageSalesWastage,
    'is_percentage_wastage': isPercentageWastage,
    'wastage_amount': wastageAmount,
    'wastage_unit_uuid': wastageUnitUuid,
  };

  TempCartItem copyWith({
    TempProductClass? item,
    double? discount,
    double? fixedDiscount,
    double? quantity,
    double? customPrice,
    bool? setCustomPrice,
    bool? useWholeSalePrice,
    bool? setTotalPrice,
    bool? addToStock,
    String? salesRecordId,
    bool? useGroupQuantity,
    double? qttyPerGroup,
    bool? isVoid,
    String? itemUuid,
    String? uuid,
    double? remainingQuantity,
    double? remainingBalance,
    String? unitUuid,
    String? priceUuid,
    double? widthDimension,
    double? heightDimension,
    int? quantityType,
    bool? manageSalesWastage,
    bool? isPercentageWastage,
    double? wastageAmount,
    String? wastageUnitUuid,
  }) {
    return TempCartItem(
      item: item ?? this.item,
      discount: discount ?? this.discount,
      fixedDiscount: fixedDiscount ?? this.fixedDiscount,
      quantity: quantity ?? this.quantity,
      customPrice: customPrice ?? this.customPrice,
      setCustomPrice: setCustomPrice ?? this.setCustomPrice,
      useWholeSalePrice:
          useWholeSalePrice ?? this.useWholeSalePrice,
      setTotalPrice: setTotalPrice ?? this.setTotalPrice,
      addToStock: addToStock ?? this.addToStock,
      salesRecordId: salesRecordId ?? this.salesRecordId,
      useGroupQuantity:
          useGroupQuantity ?? this.useGroupQuantity,
      qttyPerGroup: qttyPerGroup ?? this.qttyPerGroup,
      isVoid: isVoid ?? this.isVoid,
      itemUuid: itemUuid ?? this.itemUuid,
      uuid: uuid ?? this.uuid,
      remainingQuantity:
          remainingQuantity ?? this.remainingQuantity,
      remainingBalance:
          remainingBalance ?? this.remainingBalance,
      unitUuid: unitUuid ?? this.unitUuid,
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
    var items = getPricesList().where(
      (item) => item.uuid == (priceUuidNew ?? priceUuid),
    );
    if (items.isNotEmpty) {
      return items.first;
    } else {
      return getPricesList().firstWhere(
        (item) => item.isPrimary,
      );
    }
  }

  ProductPricesClass getPrimaryPrice({
    String? priceUuidNew,
  }) {
    var items = getPricesList().where(
      (item) => item.isPrimary,
    );
    if (items.isNotEmpty) {
      return items.first;
    } else {
      return getPricesList()
          .where(
            (item) =>
                item.uuid == (priceUuidNew ?? priceUuid),
          )
          .first;
    }
  }

  ProductPricesClass defaultPrice() {
    return ProductPricesClass(
      uuid: uuidGen(),
      staffUuid: currentUser().userId,
      createdAt: DateTime.now(),
      staffName: currentUser().name,
      priceValue: 0,
      name: 'Price',
      isPrimary: true,
      itemUuid: uuid!,
      priceType: 1,
    );
  }

  List<ProductPricesClass> getPricesList() {
    return item.getPricesList();
  }

  //
  //
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

  double getSelectedUnitQuantity({
    BuildContext? context,
    String? unitUuidNew,
  }) {
    if (getUnitsList().isEmpty == true) {
      return quantity;
    } else {
      var items = getUnitsList().where(
        (item) => item.uuid == (unitUuidNew ?? unitUuid),
      );
      if (items.isEmpty == true) {
        return quantity;
      } else {
        var item = items.first;
        return item.getQuantityEquivDivided(
          index: 1,
          context: context,
        );
      }
    }
  }

  ProductUnitsClass getSelectedUnit({String? unitUuidNew}) {
    var items = getUnitsList().where(
      (item) => item.uuid == (unitUuidNew ?? unitUuid),
    );
    if (items.isNotEmpty) {
      return items.first;
    } else {
      return getUnitsList().firstWhere(
        (item) => item.isPrimary,
      );
    }
  }

  ProductUnitsClass getPrimaryUnit({String? unitUuidNew}) {
    var items = getUnitsList().where(
      (item) => item.isPrimary,
    );
    if (items.isNotEmpty) {
      return items.first;
    } else {
      return getUnitsList()
          .where(
            (item) =>
                item.uuid == (unitUuidNew ?? unitUuid),
          )
          .first;
    }
  }

  ProductUnitsClass defaultUnit() {
    return ProductUnitsClass(
      uuid: uuidGen(),
      staffUuid: currentUser().userId,
      createdAt: DateTime.now(),
      staffName: currentUser().name,
      conversion: 1,
      name: 'Unit(s)',
      isPrimary: true,
      productUuid: uuid!,
    );
  }

  List<ProductUnitsClass> getUnitsList() {
    return item.getUnitsList();
  }

  TempProductClass? getItem() {
    // List<TempProductClass> products =
    //     returnData().productListMain
    //         .where(
    //           (pro) =>
    //               pro.uuid == itemUuid ||
    //               pro.uuid == item.uuid,
    //         )
    //         .toList();
    // if (products.isNotEmpty) {
    //   var newItem = products.first.copyWith();
    //   return newItem;
    // } else {
    return item;
    // }
  }

  double? returnDiscount() {
    return discount;
  }

  double? returnFixedDiscount() {
    return fixedDiscount;
  }

  double discountCost() {
    if (returnDiscount() != null) {
      return (totalCost() *
          ((returnDiscount() ?? 0) / 100));
    } else if (returnFixedDiscount() != null) {
      return returnFixedDiscount() ?? 0;
    } else if (getItem()?.discount != null) {
      return (totalCost() *
          ((getItem()?.discount ?? 0) / 100));
    } else {
      return 0;
    }
  }

  double totalCost() {
    if (customPrice != null) {
      if (setTotalPrice) {
        return customPrice!;
      } else {
        return customPrice! * getStockQuantity();
      }
    } else {
      final selectedPrice = getSelectedPrice();
      if ((selectedPrice.priceType ?? 1) == 1 ||
          item.quantityType == 2) {
        return selectedPrice.priceValue *
            getStockQuantity();
      } else {
        return selectedPrice.priceValue * quantity;
      }
    }
  }

  double revenue() {
    final netAmount = totalCost() - discountCost();
    if (returnShopProvider().userShop()!.applyVAT!) {
      return netAmount + (netAmount * (vat / 100));
    } else {
      return netAmount;
    }
  }

  double revenuePerItem() {
    return revenue() /
        getSelectedUnit().getQuantityEquivMultiplied(
          index: 1,
          product: item,
          newQuantity: quantity,
          customWidth: widthDimension,
          customHeight: heightDimension,
        );
  }

  double? costPrice() {
    return (getItem()?.costPrice ?? 0) == 0
        ? null
        : (getItem()?.costPrice ?? 0) * getStockQuantity();
  }

  double getItemDiscountedRemainingCost() {
    if (getItem()?.discount != null) {
      return (((getItem()?.getPrimaryPrice().priceValue ??
                  0) -
              ((getItem()?.getPrimaryPrice().priceValue ??
                      0) *
                  (getItem()?.discount ?? 0) /
                  100)) *
          getStockQuantity());
      // }
    } else {
      return totalCost();
    }
  }

  double getRealQuantity() {
    return getSelectedUnit().getQuantityEquivMultiplied(
      index: 1,
      product: item,
      newQuantity: quantity,
      customWidth: widthDimension,
      customHeight: heightDimension,
    );
  }

  // Area one unit of fixed wastage stands for: its unit converted
  // to base area. Defaults to the primary unit.
  double wastageAreaPerUnit() {
    final prim = getPrimaryUnit();
    final targetUuid = wastageUnitUuid ?? prim.uuid;
    final unit =
        getUnitsList()
            .where((unit) => unit.uuid == targetUuid)
            .firstOrNull ??
        prim;
    if (unit.dimensionType == ProductUnitsClass.areaUnit) {
      return unit.conversion > 0 ? unit.conversion : 1.0;
    }
    return (unit.conversion > 0 ? unit.conversion : 1.0) *
        item.dimensionArea();
  }

  // Wastage area on a 2D line, from [baseArea] (the line's
  // area by default). 0 for other items.
  double wastageArea({double? baseArea}) {
    if (item.quantityType != 2) return 0;
    return computeWastageArea(
      baseArea: baseArea ?? getRealQuantity(),
      amount:
          isPercentageWastage == true ||
                  wastageAmount == null
              ? wastageAmount
              : wastageAmount! * wastageAreaPerUnit(),
      isPercentage: isPercentageWastage,
    );
  }

  // Area taken from stock and billed: line area + wastage.
  double getStockQuantity() {
    return getRealQuantity() + wastageArea();
  }

  bool get hasCustomDimensions =>
      (widthDimension != null && widthDimension! > 0) ||
      (heightDimension != null && heightDimension! > 0);

  // Total line quantity displayed in the Bottom Sheet, Cart Tile, and Receipts.
  // When a 2D item has custom dimensions, this is the equivalent quantity
  // in the primary unit (e.g. 1.0 M²).
  // For all other lines, it is the line quantity in the selected unit.
  double displayQuantity() {
    if (item.quantityType == 2 && hasCustomDimensions) {
      return getStockQuantity();
    }
    return historyQuantityChange();
  }

  // Decimal fraction / unit quantity for ItemHistory (e.g. 0.5 Slabs).
  double historyQuantityChange() {
    final unit = getSelectedUnit();
    if (item.quantityType == 2) {
      if (unit.dimensionType ==
          ProductUnitsClass.areaUnit) {
        return getStockQuantity() /
            (unit.conversion > 0 ? unit.conversion : 1.0);
      }
      final wholeArea =
          item.dimensionArea() *
          (unit.conversion > 0 ? unit.conversion : 1.0);
      if (wholeArea > 0) {
        return getStockQuantity() / wholeArea;
      }
    }
    final wastage = wastageArea();
    if (wastage <= 0) return quantity;
    final base = getRealQuantity();
    if (base <= 0) return quantity;
    return quantity + quantity * wastage / base;
  }

  // Unit name displayed in the Bottom Sheet, Cart Tile, and Receipts.
  // When a 2D item has custom dimensions, returns the primary unit name (e.g. M²).
  String displayUnitName() {
    if (item.quantityType == 2 && hasCustomDimensions) {
      final pUnit = getPrimaryUnit();
      return pUnit.name == 'Others'
          ? 'Unit(s)'
          : pUnit.name;
    }
    final sel = getSelectedUnit();
    return sel.name == 'Others' ? 'Unit(s)' : sel.name;
  }

  double baseQuantityInSaleUnit() {
    final unit = getSelectedUnit();
    if (item.quantityType == 2) {
      if (unit.dimensionType ==
          ProductUnitsClass.areaUnit) {
        return getRealQuantity() /
            (unit.conversion > 0 ? unit.conversion : 1.0);
      }
      final wholeArea =
          item.dimensionArea() *
          (unit.conversion > 0 ? unit.conversion : 1.0);
      if (wholeArea > 0) {
        return getRealQuantity() / wholeArea;
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
    final prod = product ?? item;
    final productArea = prod.dimensionArea();
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
  double wastageInSaleUnit() => wastageInPrimaryUnit();

  // Quantity text for item-history text.
  String historyQuantityText() {
    return formatDimension(historyQuantityChange());
  }

  // Quantity text for receipts and cart display.
  String quantityText() {
    return formatDimension(displayQuantity());
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

    final prod = product ?? item;
    final primaryQty = primUnit.getQuantityEquivDivided(
      index: 1,
      newQuantity: getStockQuantity(),
      product: prod,
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

  // A separate copy of this line with the sale dialog's pending
  // values, so its totalCost() is what the line will cost once
  // added. This line and its item are left untouched.
  TempCartItem previewWith({
    required double quantity,
    required String? unitUuid,
    required String? priceUuid,
    required List<ProductUnitsClass> units,
    required List<ProductPricesClass> prices,
    required double? width,
    required double? height,
    required double? customPrice,
    required bool setTotalPrice,
    required double? wastageAmount,
    required bool? isPercentageWastage,
    required String? wastageUnitUuid,
  }) {
    // Same default as SalesProvider.applyDefaultDimensions.
    final useItemSize =
        item.quantityType == 2 &&
        width == null &&
        height == null;
    return TempCartItem(
      item: item.copyWith(
        unitsList:
            units.map((unit) => unit.copyWith()).toList(),
        pricesList:
            prices
                .map((price) => price.copyWith())
                .toList(),
      ),
      itemUuid: itemUuid,
      quantity: quantity,
      discount: discount,
      fixedDiscount: fixedDiscount,
      customPrice: customPrice,
      setCustomPrice: customPrice != null,
      addToStock: addToStock,
      setTotalPrice: setTotalPrice,
      useWholeSalePrice: useWholeSalePrice,
      useGroupQuantity: useGroupQuantity,
      qttyPerGroup: qttyPerGroup,
      isVoid: isVoid,
      uuid: uuid,
      unitUuid: unitUuid,
      priceUuid: priceUuid,
      widthDimension:
          useItemSize ? item.widthDimension : width,
      heightDimension:
          useItemSize ? item.heightDimension : height,
      quantityType: quantityType,
      manageSalesWastage: manageSalesWastage,
      isPercentageWastage: isPercentageWastage,
      wastageAmount: wastageAmount,
      wastageUnitUuid: wastageUnitUuid,
    );
  }

  double getRealQuantityDivided() {
    return getSelectedUnit().getQuantityEquivDivided(
      index: 1,
      product: item,
      newQuantity: quantity,
    );
  }

  String dimensionsLabel() {
    if (quantityType == 1) {
      return '';
    } else if (getSelectedUnit().dimensionType == 1) {
      return '';
    } else {
      return formatDimensionsLabel(
        widthDimension,
        heightDimension,
        unit: item.dimensionUnit,
      );
    }
  }

  String getUnit() {
    return displayUnitName();
  }
}

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_product_class/prices_class/product_prices_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';

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

  @HiveField(34)
  bool? useGroupUnit;

  @HiveField(35)
  List<ProductUnitsClass>? unitsList;

  @HiveField(36)
  List<ProductPricesClass>? pricesList;

  @HiveField(37)
  double? widthDimension;

  @HiveField(38)
  double? heightDimension;

  @HiveField(39)
  int? quantityType;

  @HiveField(40)
  bool? manageSalesWastage;

  @HiveField(41)
  String? dimensionUnit;

  @HiveField(42)
  double? dimensionUnitConversion;

  // Lets the sale dialog take a price and work out the
  // quantity for it (1D items only).
  @HiveField(43)
  bool? deriveQuantityFromPrice;

  @HiveField(44)
  String? globalProductId;

  @HiveField(45)
  String? globalDepartmentProductId;

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
    required this.useGroupUnit,
    required this.unitsList,
    required this.pricesList,
    required this.widthDimension,
    required this.heightDimension,
    this.quantityType = 1,
    required this.manageSalesWastage,
    this.dimensionUnit,
    this.dimensionUnitConversion,
    this.deriveQuantityFromPrice,
    this.globalProductId,
    this.globalDepartmentProductId,
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
      useGroupUnit: json['use_group_unit'] as bool?,
      unitsList:
          (json['units_list'] as List<dynamic>? ?? [])
              .map(
                (item) =>
                    item is ProductUnitsClass
                        ? item
                        : ProductUnitsClass.fromJson(
                          item as Map<String, dynamic>,
                        ),
              )
              .toList(),
      pricesList:
          (json['prices_list'] as List<dynamic>? ?? [])
              .map(
                (item) =>
                    item is ProductPricesClass
                        ? item
                        : ProductPricesClass.fromJson(
                          item as Map<String, dynamic>,
                        ),
              )
              .toList(),
      widthDimension:
          (json['width_dimension'] as num?)?.toDouble(),
      heightDimension:
          (json['height_dimension'] as num?)?.toDouble(),
      quantityType: json['quantity_type'] as int? ?? 1,
      manageSalesWastage:
          json['manage_sales_wastage'] as bool? ?? false,
      dimensionUnit: json['dimension_unit'] as String?,
      dimensionUnitConversion:
          (json['dimension_unit_conversion'] as num?)
              ?.toDouble(),
      deriveQuantityFromPrice:
          json['derive_quantity_from_price'] as bool? ??
          false,
      globalProductId:
          json['global_product_id'] as String?,
      globalDepartmentProductId:
          json['global_department_product_id'] as String?,
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
        'use_group_unit': useGroupUnit,
        'units_list': ProductUnitsClass.getUnitList(
          tempUnitList: unitsList,
          productUuid: uuid,
          dimensionType:
              quantityType == 2
                  ? (ProductUnitsClass.isAreaUnitName(unit)
                      ? ProductUnitsClass.areaUnit
                      : ProductUnitsClass.sheetUnit)
                  : null,
        ),
        'prices_list': ProductPricesClass.getPricesList(
          tempPricesList: pricesList,
          itemUuid: uuid,
        ),
        'width_dimension': widthDimension,
        'height_dimension': heightDimension,
        'quantity_type': quantityType ?? 1,
        'manage_sales_wastage': manageSalesWastage,
        'dimension_unit': dimensionUnit,
        'dimension_unit_conversion':
            dimensionUnitConversion,
        'derive_quantity_from_price':
            deriveQuantityFromPrice,
        'global_product_id': globalProductId,
        'global_department_product_id': globalDepartmentProductId,
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
        'use_group_unit': useGroupUnit,
        'units_list': ProductUnitsClass.getUnitList(
          tempUnitList: unitsList,
          productUuid: uuid,
          dimensionType:
              quantityType == 2
                  ? (ProductUnitsClass.isAreaUnitName(unit)
                      ? ProductUnitsClass.areaUnit
                      : ProductUnitsClass.sheetUnit)
                  : null,
        ),
        'prices_list': ProductPricesClass.getPricesList(
          tempPricesList: pricesList,
          itemUuid: uuid,
        ),
        'width_dimension': widthDimension,
        'height_dimension': heightDimension,
        'quantity_type': quantityType ?? 1,
        'manage_sales_wastage': manageSalesWastage,
        'dimension_unit': dimensionUnit,
        'dimension_unit_conversion':
            dimensionUnitConversion,
        'derive_quantity_from_price':
            deriveQuantityFromPrice,
        'global_product_id': globalProductId,
        'global_department_product_id': globalDepartmentProductId,
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
    bool? useGroupUnit,
    List<ProductUnitsClass>? unitsList,
    List<ProductPricesClass>? pricesList,
    double? widthDimension,
    double? heightDimension,
    int? quantityType,
    bool? manageSalesWastage,
    String? dimensionUnit,
    double? dimensionUnitConversion,
    bool? deriveQuantityFromPrice,
    String? globalProductId,
    String? globalDepartmentProductId,
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
      useGroupUnit: useGroupUnit ?? this.useGroupUnit,
      unitsList: unitsList ?? this.unitsList,
      pricesList: pricesList ?? this.pricesList,
      widthDimension: widthDimension ?? this.widthDimension,
      heightDimension:
          heightDimension ?? this.heightDimension,
      quantityType: quantityType ?? this.quantityType,
      manageSalesWastage:
          manageSalesWastage ?? this.manageSalesWastage,
      dimensionUnit: dimensionUnit ?? this.dimensionUnit,
      dimensionUnitConversion:
          dimensionUnitConversion ??
          this.dimensionUnitConversion,
      deriveQuantityFromPrice:
          deriveQuantityFromPrice ??
          this.deriveQuantityFromPrice,
      globalProductId:
          globalProductId ?? this.globalProductId,
      globalDepartmentProductId: globalDepartmentProductId ??
          this.globalDepartmentProductId,
    );
  }

  double? getActualQuantity({
    double? tempWidth,
    double? tempHeight,
  }) {
    if (quantityType == 1) {
      return quantity;
    } else if (quantityType == 2) {
      final effectiveWidth = tempWidth ?? widthDimension;
      final effectiveHeight = tempHeight ?? heightDimension;
      if (effectiveWidth == null ||
          effectiveHeight == null ||
          effectiveWidth <= 0 ||
          effectiveHeight <= 0) {
        return quantity;
      }
      final conv =
          (dimensionUnitConversion != null &&
                  dimensionUnitConversion! > 0)
              ? dimensionUnitConversion!
              : 1.0;
      return (quantity ?? 0) *
          ((effectiveWidth * effectiveHeight) / conv);
    } else {
      return quantity;
    }
  }

  bool get hasDimensions =>
      (widthDimension != null && widthDimension! > 0) &&
      (heightDimension != null && heightDimension! > 0);

  // Area of one stock unit (sheet) for 2D items, 1 otherwise.
  // Converts area back to the stored sheet count.
  double dimensionArea() {
    if (quantityType == 2) {
      if (!hasDimensions) return 1.0;
      final area =
          (widthDimension ?? 1) * (heightDimension ?? 1);
      final conv =
          (dimensionUnitConversion != null &&
                  dimensionUnitConversion! > 0)
              ? dimensionUnitConversion!
              : 1.0;
      final converted = area / conv;
      return converted > 0 ? converted : 1;
    } else {
      return 1;
    }
  }

  // Stored quantity left after removing [removedQuantity]
  // (in getActualQuantity units, i.e. area for 2D items).
  double quantityAfterRemoving(double removedQuantity) {
    return ((getActualQuantity() ?? 0) - removedQuantity) /
        dimensionArea();
  }

  //
  //
  //
  //

  List<ProductPricesClass> getPriceListFinal() {
    return getPricesList()
        .map((item) => item.copyWith())
        .toList();
  }

  ProductPricesClass getProductPrice({String? priceUuid}) {
    var items = getPricesList().where(
      (item) => item.uuid == priceUuid,
    );
    if (priceUuid == null || items.isEmpty) {
      return getPrimaryPrice();
    } else {
      return getPricesList().firstWhere(
        (item) => item.uuid == priceUuid,
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
        priceValue: sellingPrice ?? 0,
        name: 'Price',
        isPrimary: true,
        itemUuid: uuid!,
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
            priceValue: sellingPrice ?? 0,
            name: 'Price',
            isPrimary: true,
            itemUuid: uuid!,
            priceType: 1,
          ),
        ];
        if (wholeSalePrice != null) {
          ProductPricesClass newItem = ProductPricesClass(
            uuid: uuidGen(),
            staffUuid: currentUser().userId,
            createdAt: DateTime.now(),
            staffName: currentUser().name,
            priceValue: wholeSalePrice ?? 0,
            name: 'Whole-Sale Price',
            isPrimary: false,
            itemUuid: uuid!,
            priceType: 1,
          );
          tempList.add(newItem);
        }
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

  String getItemTilePriceWithDiscount({
    required BuildContext context,
  }) {
    if (discount == null) {
      return getItemTilePriceNoDiscount(context: context);
    } else {
      return formatMoneyMid(
        amount:
            (getPrimaryPrice().priceType == 1
                ? getPrimaryUnit().conversion
                : 1) *
            ((getPrimaryPrice().priceValue -
                (getPrimaryPrice().priceValue *
                    (discount! / 100)))),
        context: context,
      );
    }
  }

  String getItemTilePriceNoDiscount({
    required BuildContext context,
  }) {
    if (getPrimaryPrice().priceValue != 0) {
      return formatMoneyBig(
        amount: getItemPrice(context: context),
        context: context,
      );
    } else {
      return 'Price Not Set';
    }
  }

  double getItemPrice({BuildContext? context}) {
    final primaryUnit = getPrimaryUnit();
    final areaConversion =
        quantityType == 2 &&
                primaryUnit.dimensionType ==
                    ProductUnitsClass.sheetUnit
            ? primaryUnit.conversion * dimensionArea()
            : primaryUnit.conversion;
    return getPrimaryPrice().priceType == 1
        ? areaConversion * getPrimaryPrice().priceValue
        : getPrimaryPrice().priceValue;
  }

  String getQuantityText({
    BuildContext? context,
    required int index,
  }) {
    if (!authorization(
      authorized: Authorizations().viewItemQuantity,
    )) {
      return '****';
    } else {
      if (isExpired()) {
        return 'Expired';
      } else {
        if (quantity == null || quantity == 0) {
          return 'Stock Out';
        } else {
          return "${formatLargeNumberDouble(getPrimaryUnitQuantity(context: context, index: index))}${getPrimaryUnit().name == 'Others' ? '' : ' ${cutLongText(getProductUnit().name, 7)}'}";
        }
      }
    }
  }

  String getQuantityTextCartTileSearch({
    BuildContext? context,
    required int index,
  }) {
    if (!authorization(
      authorized: Authorizations().viewItemQuantity,
    )) {
      return '****';
    } else {
      if (isExpired()) {
        return 'Expired';
      } else {
        var products = returnData(
          context: context,
          listen: false,
        ).productListMain.where(
          (item) => item.uuid == uuid,
        );
        double tempQuantity = 0;
        if (products.isNotEmpty) {
          tempQuantity =
              context == null
                  ? returnSalesProvider()
                      .remainingItemQttyInAllCarts(
                        product: products.first,
                      )
                  : returnSalesProviderContext(
                    context,
                    listen: false,
                  ).remainingItemQttyInAllCarts(
                    product: products.first,
                  );
        } else {
          tempQuantity = (getActualQuantity() ?? 0);
        }
        if (tempQuantity <= 0) {
          return 'Stock Out';
        } else {
          return "${formatLargeNumberDouble(getPrimaryUnitQuantity(context: context, index: index, newQuantity: tempQuantity))}${getPrimaryUnit().name == 'Others' ? '' : ' ${cutLongText(getProductUnit().name, 7)}'}";
        }
      }
    }
  }

  double getPrimaryUnitQuantity({
    BuildContext? context,
    required int index,
    double? newQuantity,
  }) {
    if (unitsList == null || unitsList?.isEmpty == true) {
      return (getActualQuantity() ?? 0);
    } else {
      var items = unitsList!.where(
        (item) => item.isPrimary,
      );
      if (items.isEmpty) {
        return (getActualQuantity() ?? 0);
      } else {
        var item = items.first;
        return item.getQuantityEquivDivided(
          index: index,
          context: context,
          newQuantity: newQuantity,
          product: this,
        );
      }
    }
  }

  String getSelectedUnitForProductEdit(
    BuildContext context,
  ) {
    var selectedUnits =
        returnData(
          context: context,
          listen: false,
        ).tempUnitsList;
    if (selectedUnits.isEmpty) {
      return 'Unit Not Set';
    } else {
      return "${selectedUnits.firstWhere((item) => item.isPrimary).name} and (${selectedUnits.length - 1}) More";
    }
  }

  ProductUnitsClass getProductUnit({String? unitUuid}) {
    var items = getUnitsList().where(
      (item) => item.uuid == unitUuid,
    );
    if (unitUuid == null || items.isEmpty) {
      return getPrimaryUnit();
    } else {
      return getUnitsList().firstWhere(
        (item) => item.uuid == unitUuid,
      );
    }
  }

  ProductUnitsClass getPrimaryUnit() {
    final list = getUnitsList();
    final primaries = list.where(
      (item) => item.isPrimary == true,
    );
    if (list.isEmpty || primaries.isEmpty) {
      final isArea =
          quantityType == 2 &&
          ProductUnitsClass.isAreaUnitName(unit);
      return ProductUnitsClass(
        uuid: '${uuid ?? ''}_primary_unit',
        staffUuid: currentUser().userId,
        createdAt: DateTime.now(),
        staffName: currentUser().name,
        conversion: 1,
        name: unit == 'Others' ? 'Unit(s)' : unit,
        isPrimary: true,
        productUuid: uuid ?? '',
        dimensionType:
            quantityType == 2
                ? (isArea
                    ? ProductUnitsClass.areaUnit
                    : ProductUnitsClass.sheetUnit)
                : null,
      );
    } else {
      return primaries.first;
    }
  }

  List<ProductUnitsClass> getUnitsList() {
    String? safeStaffUuid() {
      try {
        return currentUser().userId;
      } catch (_) {
        return null;
      }
    }

    String? safeStaffName() {
      try {
        return currentUser().name;
      } catch (_) {
        return null;
      }
    }

    List<ProductUnitsClass> buildList() {
      if (unitsList == null || unitsList?.isEmpty == true) {
        final isArea =
            quantityType == 2 &&
            ProductUnitsClass.isAreaUnitName(unit);
        List<ProductUnitsClass> tempList = [
          ProductUnitsClass(
            uuid: '${uuid ?? ''}_primary_unit',
            staffUuid: currentUser().userId,
            createdAt: DateTime.now(),
            staffName: currentUser().name,
            conversion: 1,
            name: unit == 'Others' ? 'Unit(s)' : unit,
            isPrimary: true,
            productUuid: uuid ?? '',
            dimensionType:
                quantityType == 2
                    ? (isArea
                        ? ProductUnitsClass.areaUnit
                        : ProductUnitsClass.sheetUnit)
                    : null,
          ),
        ];
        if (useGroupUnit == true &&
            (qttyPerGroup ?? 0) > 0) {
          ProductUnitsClass newItem = ProductUnitsClass(
            uuid: '${uuid ?? ''}_group_unit',
            staffUuid: currentUser().userId,
            createdAt: DateTime.now(),
            staffName: currentUser().name,
            conversion: qttyPerGroup ?? 1,
            name:
                groupUnit == 'Others' || groupUnit == null
                    ? 'Group(s)'
                    : groupUnit ?? '',
            isPrimary: false,
            productUuid: uuid ?? '',
            dimensionType:
                quantityType == 2
                    ? ProductUnitsClass.sheetUnit
                    : null,
          );
          tempList.add(newItem);
        }
        if (quantityType == 2) {
          final hasArea = tempList.any((u) => u.isAreaUnit);
          final hasWhole = tempList.any(
            (u) => !u.isAreaUnit,
          );
          if (hasArea && !hasWhole) {
            tempList.add(
              ProductUnitsClass(
                uuid: '${uuid ?? ''}_sheet_unit',
                staffUuid: safeStaffUuid(),
                createdAt: DateTime.now(),
                staffName: safeStaffName(),
                conversion: 1,
                name: 'Sheet',
                isPrimary: false,
                productUuid: uuid ?? '',
                dimensionType: ProductUnitsClass.sheetUnit,
              ),
            );
          } else if (hasWhole && !hasArea) {
            tempList.add(
              ProductUnitsClass(
                uuid: '${uuid ?? ''}_area_unit',
                staffUuid: safeStaffUuid(),
                createdAt: DateTime.now(),
                staffName: safeStaffName(),
                conversion: 1,
                name: 'Square Meter',
                isPrimary: false,
                productUuid: uuid ?? '',
                dimensionType: ProductUnitsClass.areaUnit,
              ),
            );
          }
        }
        return tempList;
      } else {
        List<ProductUnitsClass> tempList = [
          ...(unitsList ?? []),
        ];
        if (useGroupUnit == true &&
            (qttyPerGroup ?? 0) > 0 &&
            tempList.every((item) => item.isPrimary)) {
          tempList.add(
            ProductUnitsClass(
              uuid: '${uuid ?? ''}_group_unit',
              staffUuid: currentUser().userId,
              createdAt: DateTime.now(),
              staffName: currentUser().name,
              conversion: qttyPerGroup ?? 1,
              name:
                  groupUnit == 'Others' || groupUnit == null
                      ? 'Group(s)'
                      : groupUnit ?? '',
              isPrimary: false,
              productUuid: uuid ?? '',
              dimensionType:
                  quantityType == 2
                      ? ProductUnitsClass.sheetUnit
                      : null,
            ),
          );
        }
        if (quantityType == 2) {
          final hasArea = tempList.any((u) => u.isAreaUnit);
          final hasWhole = tempList.any(
            (u) => !u.isAreaUnit,
          );
          if (hasArea && !hasWhole) {
            tempList.add(
              ProductUnitsClass(
                uuid: '${uuid ?? ''}_sheet_unit',
                staffUuid: safeStaffUuid(),
                createdAt: DateTime.now(),
                staffName: safeStaffName(),
                conversion: 1,
                name: 'Sheet',
                isPrimary: false,
                productUuid: uuid ?? '',
                dimensionType: ProductUnitsClass.sheetUnit,
              ),
            );
          } else if (hasWhole && !hasArea) {
            tempList.add(
              ProductUnitsClass(
                uuid: '${uuid ?? ''}_area_unit',
                staffUuid: safeStaffUuid(),
                createdAt: DateTime.now(),
                staffName: safeStaffName(),
                conversion: 1,
                name: 'Square Meter',
                isPrimary: false,
                productUuid: uuid ?? '',
                dimensionType: ProductUnitsClass.areaUnit,
              ),
            );
          }
        }
        return tempList;
      }
    }

    final resolved = buildList();
    if (resolved.length < 2) {
      return resolved;
    } else {
      final primaries = resolved.where(
        (item) => item.isPrimary,
      );
      return [
        if (primaries.isNotEmpty) primaries.first,
        ...resolved.where((item) => !item.isPrimary),
      ];
    }
  }

  // For a line reopened for editing (draft, order, invoice,
  // receipt): units/prices the line uses that were removed from
  // this item are added back from the line's snapshot, on a copy
  // for that line only. Returns this item unchanged when nothing
  // is missing. Items without stored lists are left as they are.
  TempProductClass withLineSnapshot({
    List<String?> unitUuids = const [],
    List<ProductUnitsClass>? snapshotUnits,
    String? priceUuid,
    List<ProductPricesClass>? snapshotPrices,
    void Function(String message)? onMissing,
  }) {
    List<ProductUnitsClass>? newUnits;
    final liveUnits = unitsList;
    if (liveUnits != null && liveUnits.isNotEmpty) {
      for (final unitUuid in unitUuids.toSet()) {
        if (unitUuid == null ||
            liveUnits.any(
              (item) => item.uuid == unitUuid,
            )) {
          continue;
        }
        final snapshot =
            (snapshotUnits ?? [])
                .where((item) => item.uuid == unitUuid)
                .firstOrNull;
        if (snapshot == null) {
          onMissing?.call(
            'Unit $unitUuid of item $uuid ($name) is not in the line snapshot. Using the primary unit.',
          );
          continue;
        }
        newUnits = [
          ...(newUnits ?? liveUnits),
          snapshot.copyWith(isPrimary: false),
        ];
      }
    }

    List<ProductPricesClass>? newPrices;
    final livePrices = pricesList;
    if (priceUuid != null &&
        livePrices != null &&
        livePrices.isNotEmpty &&
        !livePrices.any((item) => item.uuid == priceUuid)) {
      final snapshot =
          (snapshotPrices ?? [])
              .where((item) => item.uuid == priceUuid)
              .firstOrNull;
      if (snapshot == null) {
        onMissing?.call(
          'Price $priceUuid of item $uuid ($name) is not in the line snapshot. Using the primary price.',
        );
      } else {
        newPrices = [
          ...livePrices,
          snapshot.copyWith(isPrimary: false),
        ];
      }
    }

    if (newUnits == null && newPrices == null) {
      return this;
    }
    return copyWith(
      unitsList: newUnits,
      pricesList: newPrices,
    );
  }

  bool canSelectForCart() {
    if (!isManaged) {
      return true;
    } else {
      if (returnSalesProvider().isStockFreeCartType(
        currentCart().cartItemTypeIndex,
      )) {
        return true;
      } else {
        if (getActualQuantity() == null ||
            (getActualQuantity() ?? 0) <= 0) {
          return false;
        } else {
          return true;
        }
      }
    }
  }

  bool isExpired() {
    if (isManaged) {
      if (returnSalesProvider().isStockFreeCartType(
        currentCart().cartItemTypeIndex,
      )) {
        return false;
      } else {
        if (expiryDate != null) {
          if (expiryDate?.isBefore(DateTime.now()) ==
              true) {
            return true;
          } else {
            return false;
          }
        } else {
          return false;
        }
      }
    } else {
      return false;
    }
  }

  bool isExpiredReal() {
    if (isManaged) {
      if (expiryDate != null) {
        if (expiryDate?.isBefore(DateTime.now()) == true) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  String getUnitForSales({required bool useGroup}) {
    if (useGroup == true) {
      return groupUnit ?? 'Group(s)';
    } else {
      return unit == 'Others' ? 'Unit(s)' : unit;
    }
  }

  double getGroupQuantity() {
    if (useGroupUnit == true) {
      return (getActualQuantity() ?? 0) /
          (qttyPerGroup ?? 1);
    } else {
      return 0;
    }
  }

  String getSingleUnit() {
    if (storageUuid != null) {
      if (returnShopProvider()
              .userShop()
              ?.manageInventoryStorage ==
          true) {
        return returnStorageProductProvider()
                .storageProductListMain
                .where(
                  (storage) => storage.uuid == storageUuid,
                )
                .first
                .unit ??
            'Unit(s)';
      } else {
        return '${unit.substring(0, 1).toUpperCase()}${unit.substring(1)}';
      }
    } else {
      return '${unit.substring(0, 1).toUpperCase()}${unit.substring(1)}';
    }
  }

  String getGroupUnit() {
    if (storageUuid != null) {
      if (returnShopProvider()
              .userShop()
              ?.manageInventoryStorage ==
          true) {
        return returnStorageProductProvider()
                .storageProductListMain
                .where(
                  (storage) => storage.uuid == storageUuid,
                )
                .first
                .groupUnit ??
            'Group(s)';
      } else {
        return '${groupUnit?.substring(0, 1).toUpperCase()}${groupUnit?.substring(1) ?? 'Unit(s)'}';
      }
    } else {
      return '${groupUnit?.substring(0, 1).toUpperCase()}${groupUnit?.substring(1) ?? 'Unit(s)'}';
    }
  }

  bool canUpdateQuantity() {
    if (authorization(
          authorized: Authorizations().updateProduct,
        ) &&
        authorization(
          authorized: Authorizations().updateItemQuantity,
        ) &&
        !isPartOfStorage()) {
      return true;
    } else {
      return false;
    }
  }

  bool isPartOfStorage() {
    if (storageUuid != null &&
        returnShopProvider()
                .userShop()
                ?.manageInventoryStorage ==
            true) {
      return true;
    } else {
      return false;
    }
  }
}

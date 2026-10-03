import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_product_class/prices_class/product_prices_class.dart';
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
            priceValue: 1,
            name: 'Price',
            isPrimary: true,
            itemUuid: uuid,
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
    final conversion =
        getSelectedUnit(unitUuidNew: unitUuid).conversion;
    if (!conversion.isFinite || conversion <= 0) {
      throw StateError(
        'Unit conversion must be greater than zero to convert quantities.',
      );
    }
    return quantity * conversion;
  }

  double getQuantityFromPrimaryUnits(
    double quantity, {
    String? unitUuid,
  }) {
    final conversion =
        getSelectedUnit(unitUuidNew: unitUuid).conversion;
    if (!conversion.isFinite || conversion <= 0) {
      throw StateError(
        'Unit conversion must be greater than zero to convert quantities.',
      );
    }
    return quantity / conversion;
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

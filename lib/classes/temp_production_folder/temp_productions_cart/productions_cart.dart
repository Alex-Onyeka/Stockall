import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions_cart/temp_production_material_cart_item/production_material_cart_item.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions_cart/temp_productions_cart_item/productions_cart_item.dart';

part 'productions_cart.g.dart';

@HiveType(typeId: 119)
class ProductionsCart extends HiveObject {
  @HiveField(0)
  ProductionsCartItem? productionsCartItem;

  @HiveField(1)
  String? uuid;

  @HiveField(2)
  bool isEdit;

  @HiveField(3)
  String? productionUuidEdit;

  @HiveField(4)
  DateTime? createdDate;

  @HiveField(5)
  int selectCostPriceToUse;

  @HiveField(6)
  String? staffName;

  @HiveField(7)
  String? staffId;

  @HiveField(8)
  String? departmentUuid;

  @HiveField(9)
  String? departmentName;

  @HiveField(10)
  DateTime? customDate;

  @HiveField(11)
  TimeOfDay? timeOfDay;

  @HiveField(12)
  String? comment;

  @HiveField(13)
  double? customPrice;

  @HiveField(14)
  List<ProductionMaterialCartItem> materialsCartItems;

  @HiveField(15)
  double? originalCostPerItem;

  @HiveField(16)
  bool? originalUseGroupQuantity;

  // @HiveField(17)
  // bool? useGroupQuantity;

  ProductionsCart({
    required this.productionsCartItem,
    this.uuid,
    this.isEdit = false,
    this.selectCostPriceToUse = 1,
    this.createdDate,
    required this.staffName,
    required this.staffId,
    required this.departmentName,
    required this.departmentUuid,
    required this.customDate,
    required this.timeOfDay,
    required this.comment,
    this.customPrice,
    this.productionUuidEdit,
    required this.materialsCartItems,
    required this.originalCostPerItem,
    required this.originalUseGroupQuantity,
    // required this.useGroupQuantity,
  });

  List<ProductionMaterialCartItem>
  getMaterialsCartItemsAll() {
    return materialsCartItems.toList();
  }

  double getCostPrice() {
    if (selectCostPriceToUse == 1) {
      return (productionsCartItem?.costPrice ?? 0);
    } else if (selectCostPriceToUse == 2) {
      return materialsCartItems
          .map((item) => item.costPrice ?? 0)
          .fold(0, (a, b) => a + b);
    } else {
      return (customPrice ?? 0);
    }
  }

  DateTime returnDate() {
    var newDate = DateTime(
      (customDate?.year ??
          createdDate?.year ??
          DateTime.now().year),
      (customDate?.month ??
          createdDate?.month ??
          DateTime.now().month),
      (customDate?.day ??
          createdDate?.day ??
          DateTime.now().day),
      (timeOfDay?.hour ??
          createdDate?.hour ??
          DateTime.now().hour),
      (timeOfDay?.minute ??
          createdDate?.minute ??
          DateTime.now().minute),
    );
    return newDate;
  }
}

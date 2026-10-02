import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_usage_cart/materials_usage_cart.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_usage_cart/temp_materials_usage_cart_item/materials_usage_cart_item.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_materials_usage/production_materials_usage.dart';
import 'package:stockall/local_database/materials_usage_cart_func/materials_usage_cart_func.dart';
import 'package:stockall/main.dart';

class MaterialsUsageActionProvider extends ChangeNotifier {
  static final MaterialsUsageActionProvider _instance =
      MaterialsUsageActionProvider._internal();
  factory MaterialsUsageActionProvider() => _instance;
  MaterialsUsageActionProvider._internal();
  bool isLoading = false;
  void toggleIsLoading(bool value) {
    isLoading = value;
    mainLocalLog(
      'Materials Usage Action is ${value ? 'Loading on' : 'Loading Off'}',
    );
    notifyListeners();
  }

  Future<void> createMaterialsUsageCart({
    required MaterialsUsageCart cartItem,
  }) async {
    await MaterialsUsageCartFunc().createMaterialsUsageCart(
      cartItem,
    );
    notifyListeners();
  }

  Future<void> initMaterialsUsageCart() async {
    await MaterialsUsageCartFunc().initMaterialUsageCart();
    notifyListeners();
  }

  Future<void> removeMaterialItemFromCart({
    required String itemUuid,
  }) async {
    await MaterialsUsageCartFunc()
        .removeMaterialsUsageMaterialItemFromCart(
          itemUuid: itemUuid,
        );
    notifyListeners();
  }

  Future<void> resetMaterialsUsageCart() async {
    await MaterialsUsageCartFunc()
        .updateMaterialsUsageCart();
    notifyListeners();
  }

  Future<void> clearMaterialsUsageMainCart() async {
    await MaterialsUsageCartFunc()
        .clearMaterialsUsageCart();
    notifyListeners();
  }

  Future<void> clearMaterialsFromCart() async {
    await MaterialsUsageCartFunc().clearMaterialsFromCart();
    notifyListeners();
  }

  MaterialsUsageCart? getMaterialsUsageCart() {
    return MaterialsUsageCartFunc().getMaterialsUsageCart();
  }

  List<MaterialsUsageCartItem> getMaterials() {
    return MaterialsUsageCartFunc().getMaterials();
  }

  MaterialsUsageCartItem? getSingleMaterial({
    required String itemUuid,
  }) {
    return MaterialsUsageCartFunc().getSingleMaterial(
      itemUuid: itemUuid,
    );
  }

  bool isCartEmpty() {
    return MaterialsUsageCartFunc()
                .getMaterialsUsageCart() ==
            null ||
        MaterialsUsageCartFunc().getMaterials().isEmpty;
  }

  Future<void> addMaterialItemToCart({
    required MaterialsUsageCartItem item,
  }) async {
    await MaterialsUsageCartFunc()
        .addMaterialsUsageItemToCart(
          materialsUsageCartItem: item,
        );
    notifyListeners();
  }

  Future<int> createMaterialsUsageAction() async {
    try {
      List<MaterialsUsageCartItem> items = getMaterials();
      var supabaseItems =
          MaterialsUsageCartItem.fromCartMaterialItem(
            items: items,
          );
      final usageProvider = returnMaterialsUsageProvider();
      for (var item in supabaseItems) {
        var isEdit = getMaterialsUsageCart()?.isEdit;
        ProductionMaterialsUsage? existingUsage;
        if (isEdit == true) {
          for (final usage
              in usageProvider.productionMaterialsUsage) {
            if (usage.uuid == item.uuid) {
              existingUsage = usage;
              break;
            }
          }
          if (existingUsage == null) return 0;
          final deleteResult =
              await returnMaterialsUsageProvider()
                  .deleteProductionMaterialsUsage(
                    existingUsage,
                    true,
                    true,
                  );
          if (deleteResult != 1) return 0;
        }
        final createdUsage = await usageProvider
            .createProductionMaterialsUsage(item);
        if (createdUsage == null) {
          if (existingUsage != null) {
            final restoredUsage = await usageProvider
                .createProductionMaterialsUsage(
                  existingUsage,
                );
            if (restoredUsage == null) {
              await mainLocalLog(
                'Failed to restore material usage ${existingUsage.uuid} after its replacement failed.',
              );
            }
          }
          return 0;
        }
      }
      await returnMaterialsUsageProvider()
          .getProductionMaterialsUsageOffline();
      if (getMaterialsUsageCart()?.isEdit == true) {
        await MaterialsUsageCartFunc().toggleIsEdit(false);
      }
      syncData();
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error Creating Materials Usage Items IN the Action Function: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> editMaterialsUsageRecord({
    required ProductionMaterialsUsage record,
  }) async {
    try {
      if (record.productionRecordUuid != null) {
        await mainLocalLog(
          'Production-linked material usage must be changed by editing its production record.',
        );
        return 0;
      }
      var item = MaterialsUsageCartItem.toCartMaterialsItem(
        items: [record],
      );
      await addMaterialItemToCart(item: item.first);
      await MaterialsUsageCartFunc().toggleIsEdit(true);
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error Converting Usage Record to Cart Item: ${e.toString()}',
      );
      return 0;
    }
  }
}

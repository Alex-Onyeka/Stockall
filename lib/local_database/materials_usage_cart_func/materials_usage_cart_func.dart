import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_usage_cart/materials_usage_cart.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_usage_cart/temp_materials_usage_cart_item/materials_usage_cart_item.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';

class MaterialsUsageCartFunc {
  static final MaterialsUsageCartFunc instance =
      MaterialsUsageCartFunc._internal();
  factory MaterialsUsageCartFunc() => instance;
  MaterialsUsageCartFunc._internal();
  late Box<MaterialsUsageCart> materialsUsageCartBox;
  final String materialsUsageCartBoxName =
      'materialsUsageCartBoxStockall';

  Future<void> init() async {
    Hive.registerAdapter(MaterialsUsageCartAdapter());
    Hive.registerAdapter(MaterialsUsageCartItemAdapter());
    materialsUsageCartBox = await Hive.openBox(
      materialsUsageCartBoxName,
    );
    await initMaterialUsageCart();
    await mainLocalLog(
      'Main Materials Usage Cart Box Initialized',
    );
  }

  MaterialsUsageCart? getMaterialsUsageCart() {
    List<MaterialsUsageCart> materialsUsageCarts =
        materialsUsageCartBox.values.toList();
    return materialsUsageCarts.isEmpty
        ? null
        : materialsUsageCarts.first;
  }

  List<MaterialsUsageCartItem> getMaterials() {
    return getMaterialsUsageCart()?.cartItems ?? [];
  }

  MaterialsUsageCartItem? getSingleMaterial({
    required String itemUuid,
  }) {
    return getMaterials()
            .where((item) => item.uuid == itemUuid)
            .isNotEmpty
        ? getMaterials()
            .where((item) => item.uuid == itemUuid)
            .first
        : null;
  }

  Future<void> initMaterialUsageCart() async {
    if (getMaterialsUsageCart() == null) {
      await updateMaterialsUsageCart();
    }
  }

  Future<int> createMaterialsUsageCart(
    MaterialsUsageCart materialsUsageCart,
  ) async {
    try {
      await clearMaterialsUsageCart();
      await materialsUsageCartBox.put(
        materialsUsageCart.uuid,
        materialsUsageCart,
      );
      await mainLocalLog(
        'Offline MaterialsUsage Cart Created',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline MaterialsUsage Cart Creation Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> updateMaterialsUsageCart({
    MaterialsUsageCart? materialsUsageCart,
  }) async {
    try {
      final MaterialsUsageCart newMaterialsUsageCart =
          MaterialsUsageCart(
            cartItems: [],
            isEdit: false,
            uuid: uuidGen(),
          );
      MaterialsUsageCart newItem =
          materialsUsageCart ?? newMaterialsUsageCart;
      await clearMaterialsUsageCart();
      await materialsUsageCartBox.put(
        newItem.uuid,
        newItem,
      );
      await mainLocalLog(
        'Offline Materials Usage Cart ${materialsUsageCart == null ? "Resetted" : 'Updated'}',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Materials Usage Cart ${materialsUsageCart == null ? "Reseting" : 'Update'} Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> addMaterialsUsageItemToCart({
    required MaterialsUsageCartItem materialsUsageCartItem,
  }) async {
    try {
      var cartItem = getMaterialsUsageCart();
      if (cartItem == null) {
        await initMaterialUsageCart();
      }
      var items = cartItem!.cartItems.where(
        (item) =>
            item.materialItemUuid ==
            materialsUsageCartItem.materialItemUuid,
      );
      if (items.isNotEmpty) {
        var material = items.first;
        material.uuid = materialsUsageCartItem.uuid;
        material.addToStock =
            materialsUsageCartItem.addToStock;
        material.costPrice =
            materialsUsageCartItem.costPrice;
        material.customPrice =
            materialsUsageCartItem.customPrice;
        material.groupUnit =
            materialsUsageCartItem.groupUnit;
        material.materialItemUuid =
            materialsUsageCartItem.materialItemUuid;
        material.name = materialsUsageCartItem.name;
        material.originalCostPerItem =
            materialsUsageCartItem.originalCostPerItem;
        material.qttyPerGroup =
            materialsUsageCartItem.qttyPerGroup;
        material.quantity = materialsUsageCartItem.quantity;
        material.selectedCostInt =
            materialsUsageCartItem.selectedCostInt;
        material.unit = materialsUsageCartItem.unit;
        material.useGroupQuantity =
            materialsUsageCartItem.useGroupQuantity;
        material.customUnit =
            materialsUsageCartItem.customUnit;
        material.originalUseGroupQuantity =
            materialsUsageCartItem.originalUseGroupQuantity;
        material.productionItemId =
            materialsUsageCartItem.productionItemId;
        material.productionItemName =
            materialsUsageCartItem.productionItemName;
        cartItem.save();
        await mainLocalLog(
          'Offline Materials Cart Item Updated Success',
        );
      } else {
        cartItem.cartItems.add(materialsUsageCartItem);
        await mainLocalLog(
          'Offline Materials Cart Item Added To Cart',
        );
      }
      await materialsUsageCartBox.put(
        cartItem.uuid,
        cartItem,
      );

      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Materials Cart Item Adding/Update To Cart Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> removeMaterialsUsageMaterialItemFromCart({
    required String itemUuid,
  }) async {
    try {
      var cartItem = getMaterialsUsageCart();
      if (cartItem == null) {
        await initMaterialUsageCart();
      }
      cartItem!.cartItems.removeWhere(
        (item) => item.uuid == itemUuid,
      );
      await materialsUsageCartBox.put(
        cartItem.uuid,
        cartItem,
      );
      await mainLocalLog(
        'Offline Material Cart Item Removed To Cart',
      );

      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Material Cart Item Removal From Cart Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearMaterialsFromCart() async {
    try {
      var cartItem = getMaterialsUsageCart();
      if (cartItem == null) {
        await initMaterialUsageCart();
      }
      cartItem!.cartItems.clear();
      await materialsUsageCartBox.put(
        cartItem.uuid,
        cartItem,
      );
      await mainLocalLog(
        'Offline Materials Cleared From Cart',
      );
      await mainLocalLog(
        'Offline Materials Clearing Failed',
      );

      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline MaterialsUsage Item Adding To Cart Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearMaterialsUsageCart() async {
    try {
      await materialsUsageCartBox.clear();
      await mainLocalLog(
        'Offline MaterialsUsage Cart Cleared',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'MaterialsUsage Cart Clear Failed: ${e.toString()}',
      );
      return 0;
    }
  }
}

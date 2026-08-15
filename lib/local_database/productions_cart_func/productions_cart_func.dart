import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions_cart/temp_production_material_cart_item/production_material_cart_item.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions_cart/productions_cart.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions_cart/temp_productions_cart_item/productions_cart_item.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';

class ProductionsCartFunc {
  static final ProductionsCartFunc instance =
      ProductionsCartFunc._internal();
  factory ProductionsCartFunc() => instance;
  ProductionsCartFunc._internal();
  late Box<ProductionsCart> productionsCartBox;
  final String productionsCartBoxName =
      'productionsCartBoxStockall';

  Future<void> init() async {
    Hive.registerAdapter(ProductionsCartAdapter());
    Hive.registerAdapter(ProductionsCartItemAdapter());
    Hive.registerAdapter(
      ProductionMaterialCartItemAdapter(),
    );
    productionsCartBox = await Hive.openBox(
      productionsCartBoxName,
    );
    await initProductionCart();
    await mainLocalLog(
      'Main Productions Cart Box Initialized',
    );
  }

  ProductionsCart? getProductionsCart() {
    List<ProductionsCart> productionsCarts =
        productionsCartBox.values.toList();
    return productionsCarts.isEmpty
        ? null
        : productionsCarts.first;
  }

  Future<void> initProductionCart() async {
    if (getProductionsCart() == null) {
      await updateProductionsCart();
    }
  }

  Future<int> createProductionsCart(
    ProductionsCart productionsCart,
  ) async {
    try {
      await clearProductionsCart();
      await productionsCartBox.put(
        productionsCart.uuid,
        productionsCart,
      );
      await mainLocalLog(
        'Offline Productions Cart Created',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Productions Cart Creation Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> updateProductionsCart({
    ProductionsCart? productionsCart,
  }) async {
    try {
      final ProductionsCart newProductionsCart =
          ProductionsCart(
            productionsCartItem: null,
            staffName: currentUser().name,
            staffId: currentUser().userId,
            departmentName: currentDepartment()?.name,
            departmentUuid: currentDepartment()?.uuid,
            customDate: null,
            timeOfDay: null,
            comment: null,
            materialsCartItems: [],
            createdDate: DateTime.now(),
            uuid: uuidGen(),
            customPrice: null,
            productionUuidEdit: null,
            selectCostPriceToUse: 1,
            isEdit: false,
            // originalCostPerItem: 0,
            originalUseGroupQuantity: false,
          );
      ProductionsCart newItem =
          productionsCart ?? newProductionsCart;
      await clearProductionsCart();
      await productionsCartBox.put(newItem.uuid, newItem);
      await mainLocalLog(
        'Offline Productions Cart ${productionsCart == null ? "Resetted" : 'Updated'}',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Productions Cart ${productionsCart == null ? "Reseting" : 'Update'} Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> addProductionsItemToCart({
    required ProductionsCartItem? productionsCartItem,
  }) async {
    try {
      var cartItem = getProductionsCart();
      if (cartItem == null) {
        await initProductionCart();
      }
      if (productionsCartItem != null) {
        cartItem!.productionsCartItem = productionsCartItem;
        await productionsCartBox.put(
          cartItem.uuid,
          cartItem,
        );
        await mainLocalLog(
          'Offline Productions Item Added To Cart',
        );
      } else {
        cartItem!.productionsCartItem = null;
        await productionsCartBox.put(
          cartItem.uuid,
          cartItem,
        );
        await mainLocalLog(
          'Offline Productions Item Added To Cart',
        );
      }

      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Productions Item Adding To Cart Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> addProductionsMaterialItemToCart({
    required ProductionMaterialCartItem
    productionsMaterialCartItem,
  }) async {
    try {
      var cartItem = getProductionsCart();
      if (cartItem == null) {
        await initProductionCart();
      }
      var items = cartItem!.materialsCartItems.where(
        (item) =>
            item.materialItemUuid ==
            productionsMaterialCartItem.materialItemUuid,
      );
      if (items.isNotEmpty) {
        var material = items.first;
        material.uuid = productionsMaterialCartItem.uuid;
        material.addToStock =
            productionsMaterialCartItem.addToStock;
        material.costPrice =
            productionsMaterialCartItem.costPrice;
        material.customPrice =
            productionsMaterialCartItem.customPrice;
        material.groupUnit =
            productionsMaterialCartItem.groupUnit;
        material.materialItemUuid =
            productionsMaterialCartItem.materialItemUuid;
        material.name = productionsMaterialCartItem.name;
        material.originalCostPerItem =
            productionsMaterialCartItem.originalCostPerItem;
        material.qttyPerGroup =
            productionsMaterialCartItem.qttyPerGroup;
        material.quantity =
            productionsMaterialCartItem.quantity;
        material.setCustomPrice =
            productionsMaterialCartItem.setCustomPrice;
        material.unit = productionsMaterialCartItem.unit;
        material.useGroupQuantity =
            productionsMaterialCartItem.useGroupQuantity;
        material.customUnit =
            productionsMaterialCartItem.customUnit;
        material.originalUseGroupQuantity =
            productionsMaterialCartItem
                .originalUseGroupQuantity;
        material.productionItemId =
            productionsMaterialCartItem.productionItemId;
        material.productionItemName =
            productionsMaterialCartItem.productionItemName;
        cartItem.save();
        await mainLocalLog(
          'Offline Materials Item Updated Success',
        );
      } else {
        cartItem.materialsCartItems.add(
          productionsMaterialCartItem,
        );
        await mainLocalLog(
          'Offline Materials Item Added To Cart',
        );
      }
      await productionsCartBox.put(cartItem.uuid, cartItem);

      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Materials Item Adding/Update To Cart Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> removeProductionsMaterialItemFromCart({
    required ProductionMaterialCartItem
    productionsMaterialCartItem,
  }) async {
    try {
      var cartItem = getProductionsCart();
      if (cartItem == null) {
        await initProductionCart();
      }
      cartItem!.materialsCartItems.remove(
        productionsMaterialCartItem,
      );
      await productionsCartBox.put(cartItem.uuid, cartItem);
      await mainLocalLog(
        'Offline Material Item Removed To Cart',
      );

      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Material Item Removal From Cart Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearMaterialsFromCart() async {
    try {
      var cartItem = getProductionsCart();
      if (cartItem == null) {
        await initProductionCart();
      }
      cartItem!.materialsCartItems.clear();
      await productionsCartBox.put(cartItem.uuid, cartItem);
      await mainLocalLog(
        'Offline Materials Cleared From Cart',
      );
      await mainLocalLog(
        'Offline Materials Clearing Failed',
      );

      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Productions Item Adding To Cart Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> setTotalCost({
    required double? customCost,
    required int selection,
  }) async {
    try {
      ProductionsCart? cartItem;
      cartItem = getProductionsCart();
      if (cartItem == null) {
        await initProductionCart();
      }
      cartItem!.customPrice = customCost;
      cartItem.selectCostPriceToUse = selection;
      cartItem.save();
      await productionsCartBox.put(cartItem.uuid, cartItem);
      await mainLocalLog('Cost Price Updated Success');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Cost Price Update Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearProductionsCart() async {
    try {
      await productionsCartBox.clear();
      await mainLocalLog(
        'Offline Productions Cart Cleared',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Productions Cart Clear Failed: ${e.toString()}',
      );
      return 0;
    }
  }
}

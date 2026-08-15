import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions_cart/temp_production_material_cart_item/production_material_cart_item.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions_cart/productions_cart.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions_cart/temp_productions_cart_item/productions_cart_item.dart';
import 'package:stockall/local_database/productions_cart_func/productions_cart_func.dart';
import 'package:stockall/main.dart';

class ProductionsActionProvider extends ChangeNotifier {
  static final ProductionsActionProvider _instance =
      ProductionsActionProvider._internal();
  factory ProductionsActionProvider() => _instance;
  ProductionsActionProvider._internal();
  bool isLoading = false;
  void toggleIsLoading(bool value) {
    isLoading = value;
    mainLocalLog(
      'Production Action is ${value ? 'Loading on' : 'Loading Off'}',
    );
    notifyListeners();
  }

  Future<void> createProductionsCart({
    required ProductionsCart cartItem,
  }) async {
    await ProductionsCartFunc().createProductionsCart(
      cartItem,
    );
    notifyListeners();
  }

  Future<void> initProductionsCart() async {
    await ProductionsCartFunc().initProductionCart();
    notifyListeners();
  }

  Future<void> removeProductionItemFromCart() async {
    await ProductionsCartFunc().addProductionsItemToCart(
      productionsCartItem: null,
    );
    notifyListeners();
  }

  Future<void> resetProductionCart() async {
    await ProductionsCartFunc().updateProductionsCart();
    notifyListeners();
  }

  Future<void> clearProductionMainCart() async {
    await ProductionsCartFunc().clearProductionsCart();
    notifyListeners();
  }

  Future<void> clearProductionMaterials() async {
    await ProductionsCartFunc().clearMaterialsFromCart();
    notifyListeners();
  }

  ProductionsCart? getProductionsCart() {
    return ProductionsCartFunc().getProductionsCart();
  }

  bool isCartEmpty() {
    return ProductionsCartFunc().getProductionsCart() ==
            null ||
        (ProductionsCartFunc()
                    .getProductionsCart()
                    ?.productionsCartItem ==
                null &&
            ProductionsCartFunc()
                    .getProductionsCart()
                    ?.materialsCartItems
                    .isEmpty ==
                true);
  }

  Future<void> addItemToCart({
    required ProductionsCartItem item,
  }) async {
    await ProductionsCartFunc().addProductionsItemToCart(
      productionsCartItem: item,
    );
    notifyListeners();
  }

  Future<void> addMaterialItemToCart({
    required ProductionMaterialCartItem item,
  }) async {
    await ProductionsCartFunc()
        .addProductionsMaterialItemToCart(
          productionsMaterialCartItem: item,
        );
    notifyListeners();
  }

  Future<void> removeMaterialItemFromCart({
    required ProductionMaterialCartItem item,
  }) async {
    await ProductionsCartFunc()
        .removeProductionsMaterialItemFromCart(
          productionsMaterialCartItem: item,
        );
    notifyListeners();
  }

  Future<void> setTotalCost({
    required double? customCost,
    required int selection,
  }) async {
    await ProductionsCartFunc().setTotalCost(
      customCost: customCost,
      selection: selection,
    );
    notifyListeners();
  }
}

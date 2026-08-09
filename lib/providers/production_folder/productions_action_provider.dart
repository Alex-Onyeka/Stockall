import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions_cart/productions_cart.dart';
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

  Future<void> initProductionsCart() async {
    await ProductionsCartFunc().initProductionCart();
    notifyListeners();
  }

  Future<void> clearProductionCart() async {
    await ProductionsCartFunc().updateProductionsCart();
    notifyListeners();
  }

  ProductionsCart? getProductionsCart() {
    return ProductionsCartFunc().getProductionsCart();
  }
}

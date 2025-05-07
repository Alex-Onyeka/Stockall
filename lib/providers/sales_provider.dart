import 'package:flutter/widgets.dart';
import 'package:stockitt/classes/temp_cart_item.dart';
import 'package:stockitt/classes/temp_product_class.dart';
import 'package:stockitt/providers/data_provider.dart';

class SalesProvider extends ChangeNotifier {
  List<TempCartItem> cartItems = [];

  void addItemToCart(TempCartItem item) {
    cartItems.add(item);
    notifyListeners();
  }

  void removeItemFromCart(TempCartItem item) {
    cartItems.remove(item);
    notifyListeners();
  }

  DataProvider dataProvider = DataProvider();

  List<TempProductClass> searchProductsName(String text) {
    List<TempProductClass> tempProducts =
        dataProvider.products
            .where(
              (product) => product.name
                  .toLowerCase()
                  .contains(text.toLowerCase()),
            )
            .toList();

    return tempProducts;
  }

  List<TempProductClass> searchProductsBarcode(
    String text,
  ) {
    return dataProvider.products
        .where(
          (product) =>
              product.barcode != null &&
              product.barcode!.contains(text),
        )
        .toList();
  }
}

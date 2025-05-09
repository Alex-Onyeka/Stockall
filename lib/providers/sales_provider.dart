import 'package:flutter/widgets.dart';
import 'package:stockitt/classes/temp_cart_item.dart';
import 'package:stockitt/classes/temp_product_class.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/providers/data_provider.dart';

class SalesProvider extends ChangeNotifier {
  List<TempCartItem> cartItems = [];

  void clearCart() {
    cartItems.clear();
    notifyListeners();
  }

  double discountCheck(TempProductClass product) {
    double tempValue = 0;
    if (product.discount == null) {
      tempValue = product.sellingPrice;
    } else {
      tempValue =
          (product.sellingPrice *
              (product.discount! / 100));
    }
    return tempValue;
  }

  double calcTotalMain(List<TempCartItem> items) {
    double tempTotal = 0;
    for (var item in items) {
      tempTotal += item.totalCost();
    }
    return tempTotal;
  }

  double calcDiscountMain(List<TempCartItem> items) {
    double tempTotalDiscount = 0;
    for (var item in items) {
      if (item.item.discount != null) {
        double discountPerUnit =
            item.item.sellingPrice *
            (item.item.discount! / 100);
        tempTotalDiscount +=
            discountPerUnit * item.quantity;
      }
    }
    return tempTotalDiscount;
  }

  double calcFinalTotalMain(List<TempCartItem> items) {
    return calcTotalMain(items) - calcDiscountMain(items);
  }

  String addItemToCart(TempCartItem newItem) {
    String result = '';
    final index = cartItems.indexWhere(
      (item) => item.item.id == newItem.item.id,
    );

    if (index != -1) {
      // Item exists
      cartItems[index].quantity += newItem.quantity;
      result = 'Item Updated Successfully';
    } else {
      cartItems.add(newItem);
      result = 'Item Added Successfully';
    }

    notifyListeners();
    return result;
  }

  void editCartItemQuantity(
    TempCartItem cartItem,
    double number,
  ) {
    cartItem.quantity = number;
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

  void resetPaymentMethod() {
    currentPayment = 0;
    notifyListeners();
  }

  int currentPayment = 0;
  List<Map<String, dynamic>> paymentMethods = [
    {
      'number': 0,
      'method': 'Pay with Cash',
      'subText': 'Use Cash to Make Payment',
    },
    {
      'number': 1,
      'method': 'Pay with Transfer / Atm',
      'subText': 'Use Bank to Proceed with Payment',
    },
    {
      'number': 2,
      'method': 'Split Payment',
      'subText': 'Use Both Cash and Bank to Pay',
    },
  ];

  void changeMethod(int index) {
    currentPayment = index;
    notifyListeners();
  }

  void checkOut(BuildContext context) {
    resetPaymentMethod();
    clearCart();
    returnCustomers(
      context,
      listen: false,
    ).clearSelectedCustomer();
    returnNavProvider(context, listen: false).navigate(0);
    returnCompProvider(
      context,
      listen: false,
    ).successAction(
      () => Navigator.popUntil(
        context,
        ModalRoute.withName('/'),
      ),
    );
  }
}

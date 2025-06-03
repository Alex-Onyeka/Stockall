import 'package:storrec/classes/temp_cart_item.dart';

class TempMainCart {
  final List<TempCartItem> cartItems;

  TempMainCart({required this.cartItems});

  double total() {
    double tempTotal = 0;
    for (var item in cartItems) {
      tempTotal += item.item.sellingPrice;
    }
    return tempTotal;
  }
}

import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';

class TempMainCart {
  final List<TempCartItem> cartItems;

  TempMainCart({required this.cartItems});

  double total() {
    double tempTotal = 0;
    for (var item in cartItems) {
      tempTotal += item.item.sellingPrice ?? 0;
    }
    return tempTotal;
  }
}

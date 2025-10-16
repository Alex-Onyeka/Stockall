import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';

class TempCart {
  List<TempCartItem> cartItems;
  bool isInvoice;
  TempCart({
    required this.cartItems,
    required this.isInvoice,
  });
}

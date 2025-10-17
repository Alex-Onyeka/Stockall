import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';

class TempCart {
  List<TempCartItem> cartItems;
  bool isInvoice;
  String? selectedCustomer;
  String? selectedCustomerName;
  int paymentMethod;
  TempCart({
    required this.cartItems,
    required this.isInvoice,
    this.selectedCustomer,
    this.selectedCustomerName,
    this.paymentMethod = 0,
  });
}

import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';

class TempCart {
  List<TempCartItem> cartItems;
  bool isInvoice;
  String? selectedCustomer;
  String? selectedCustomerName;
  int paymentMethod;
  double? discount;
  double? fixedDiscount;
  bool isSettingDiscountOpen;
  TempCart({
    required this.cartItems,
    required this.isInvoice,
    this.selectedCustomer,
    this.selectedCustomerName,
    this.paymentMethod = 0,
    this.discount,
    this.isSettingDiscountOpen = false,
    this.fixedDiscount,
  });
}

import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';

class TempCart {
  List<TempCartItem> cartItems;
  String? id;
  bool isInvoice;
  String? selectedCustomer;
  String? selectedCustomerName;
  int paymentMethod;
  double? discount;
  bool isReceiptEdit;
  // bool isInvoiceEdit;
  String? receiptUuidEdit;
  String? invoiceUuidEdit;
  DateTime? createdDate;
  bool setCustomPrice;
  double? fixedDiscount;
  bool isSettingDiscountOpen;
  String? cartName;
  String? subStaffUuid;

  TempCart({
    required this.cartItems,
    required this.isInvoice,
    this.id,
    this.selectedCustomer,
    this.selectedCustomerName,
    this.paymentMethod = 0,
    this.discount,
    this.isSettingDiscountOpen = false,
    this.isReceiptEdit = false,
    // this.isInvoiceEdit = false,
    this.receiptUuidEdit,
    this.invoiceUuidEdit,
    this.setCustomPrice = false,
    this.createdDate,
    this.fixedDiscount,
    this.cartName,
    this.subStaffUuid,
  });

  // String id() {
  //   var uuid = uuidGen();
  //   return uuid;
  // }
}

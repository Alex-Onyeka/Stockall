import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';

part 'temp_cart.g.dart';

@HiveType(typeId: 71)
class TempCart extends HiveObject {
  @HiveField(0)
  List<TempCartItem> cartItems;

  @HiveField(1)
  String? id;

  @HiveField(2)
  bool isInvoice;

  @HiveField(3)
  String? selectedCustomer;

  @HiveField(4)
  String? selectedCustomerName;

  @HiveField(5)
  int paymentMethod;

  @HiveField(6)
  double? discount;

  @HiveField(7)
  bool isReceiptEdit;

  @HiveField(8)
  String? receiptUuidEdit;

  @HiveField(9)
  String? invoiceUuidEdit;

  @HiveField(10)
  DateTime? createdDate;

  @HiveField(11)
  bool setCustomPrice;

  @HiveField(12)
  double? fixedDiscount;

  @HiveField(13)
  bool isSettingDiscountOpen;

  @HiveField(14)
  String? cartName;

  @HiveField(15)
  String? subStaffUuid;

  @HiveField(16)
  String? staffName;

  @HiveField(17)
  String? staffId;

  @HiveField(18)
  String? departmentUuid;

  @HiveField(19)
  String? departmentName;

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
    this.receiptUuidEdit,
    this.invoiceUuidEdit,
    this.setCustomPrice = false,
    this.createdDate,
    this.fixedDiscount,
    this.cartName,
    this.subStaffUuid,
    required this.staffName,
    required this.staffId,
    required this.departmentName,
    required this.departmentUuid,
  });
}

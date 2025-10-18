import 'package:stockall/classes/temp_product_class/temp_product_class.dart';

class TempCartItem {
  final TempProductClass item;
  double? discount;
  double quantity;
  double? customPrice;
  bool setCustomPrice;
  bool setTotalPrice;
  bool addToStock;

  TempCartItem({
    required this.item,
    required this.quantity,
    required this.discount,
    this.customPrice,
    this.setCustomPrice = true,
    required this.addToStock,
    required this.setTotalPrice,
  });

  double? returnDiscount(double? generalDiscount) {
    return generalDiscount ?? item.discount;
  }

  double discountCost(double? generalDiscount) {
    if (returnDiscount(generalDiscount) != null) {
      return (totalCost() *
          (returnDiscount(generalDiscount)! / 100));
    } else {
      return 0;
    }
  }

  double totalCost() {
    if (customPrice != null) {
      if (setTotalPrice) {
        return customPrice!;
      } else {
        return customPrice! * quantity;
      }
    } else {
      return item.sellingPrice != null
          ? item.sellingPrice! * quantity
          : 0;
    }
  }

  double revenue(double? generalDiscount) {
    return totalCost() - discountCost(generalDiscount);
  }

  double? costPrice() {
    return item.costPrice == 0
        ? null
        : item.costPrice * quantity;
  }

  double profitOrLoss() {
    return item.costPrice == 0
        ? 0
        : totalCost() - (costPrice() ?? 0);
  }
}

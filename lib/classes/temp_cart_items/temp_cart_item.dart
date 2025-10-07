import 'package:stockall/classes/temp_product_class/temp_product_class.dart';

class TempCartItem {
  final TempProductClass item;
  final double? discount;
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

  double discountCost() {
    if (item.discount != null) {
      return (item.sellingPrice ??
              0 * (item.discount! / 100)) *
          quantity;
    }
    return 0;
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

  double revenue() {
    if (customPrice != null) {
      if (setTotalPrice) {
        return customPrice!;
      } else {
        return customPrice! * quantity;
      }
    } else {
      return totalCost() - discountCost();
    }
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

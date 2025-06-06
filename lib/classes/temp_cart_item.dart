import 'package:stockall/classes/temp_product_class.dart';

class TempCartItem {
  final TempProductClass item;
  final double? discount;
  double quantity;
  double? customPrice;
  bool setCustomPrice;

  TempCartItem({
    required this.item,
    required this.quantity,
    required this.discount,
    this.customPrice,
    this.setCustomPrice = true,
  });

  double discountCost() {
    if (item.discount != null) {
      return (item.sellingPrice * (item.discount! / 100)) *
          quantity;
    }
    return 0;
  }

  double totalCost() {
    if (customPrice != null) {
      return customPrice!;
    } else {
      return item.sellingPrice * quantity;
    }
  }

  double revenue() {
    if (customPrice != null) {
      return customPrice!;
    } else {
      return totalCost() - discountCost();
    }
  }

  double costPrice() {
    return item.costPrice * quantity;
  }

  double profitOrLoss() {
    return (item.sellingPrice - item.costPrice) * quantity;
  }
}

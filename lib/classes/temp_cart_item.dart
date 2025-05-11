import 'package:stockitt/classes/temp_product_class.dart';

class TempCartItem {
  final TempProductClass item;
  final double? discount;
  double quantity;

  TempCartItem({
    required this.item,
    required this.quantity,
    required this.discount,
  });

  double discountCost() {
    if (item.discount != null) {
      return (item.sellingPrice * (item.discount! / 100)) *
          quantity;
    }
    return 0;
  }

  double totalCost() {
    return item.sellingPrice * quantity;
  }

  double revenue() {
    return totalCost() - discountCost();
  }
}

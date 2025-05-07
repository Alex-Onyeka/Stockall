import 'package:stockitt/classes/temp_product_class.dart';

class TempCartItem {
  final TempProductClass item;
  final double quantity;

  TempCartItem({
    required this.item,
    required this.quantity,
  });

  double totalCost() {
    return item.sellingPrice * quantity;
  }
}

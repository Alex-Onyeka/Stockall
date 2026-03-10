import 'package:flutter/cupertino.dart';
import 'package:stockall/classes/product_quantity_summary/product_quantity_summary.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/main.dart';

class ReportProvider extends ChangeNotifier {
  // bool setDate = false;
  // bool isDateSet = false;
  // String? dateSet;

  // void openDatePicker() {
  //   setDate = true;
  //   notifyListeners();
  // }

  void setDay(BuildContext context, DateTime day) {
    returnExpensesProvider(
      context,
      listen: false,
    ).setDate(day);
    returnReceiptProvider(
      context,
      listen: false,
    ).setDate(day);
    // dateSet = 'For ${formatDateTime(day)}';
    notifyListeners();
  }

  void setWeek(
    BuildContext context,
    DateTime weekStart,
    DateTime endOfWeek,
  ) {
    returnExpensesProvider(
      context,
      listen: false,
    ).setRange(weekStart, endOfWeek);
    returnReceiptProvider(
      context,
      listen: false,
    ).setRange(weekStart, endOfWeek);
    notifyListeners();
  }

  void clearDate(BuildContext context) {
    returnExpensesProvider(
      context,
      listen: false,
    ).clearDate();
    returnReceiptProvider(
      context,
      listen: false,
    ).clearDate();
    notifyListeners();
  }

  List<ProductQuantitySummary>?
  getTopThreeProductsByQuantity(
    List<TempProductClass> allProducts,
    List<TempProductSaleRecord> records,
  ) {
    // Step 1: Group sold products by productId and sum quantities
    final Map<String, double> quantityMap = {};
    for (var record in records) {
      quantityMap[record.uuid!] =
          (quantityMap[record.uuid] ?? 0) + record.quantity;
    }

    // Step 2: Create ProductQuantitySummary for all products
    final List<ProductQuantitySummary> summaryList =
        allProducts.map((product) {
          return ProductQuantitySummary(
            productUuid: product.uuid!,
            productName: product.name,
            totalQuantity: quantityMap[product.uuid] ?? 0,
          );
        }).toList();

    // Step 3: Sort by quantity descending and return top 3
    summaryList.sort(
      (a, b) => b.totalQuantity.compareTo(a.totalQuantity),
    );
    return summaryList.take(3).toList();
  }

  List<ProductQuantitySummary>?
  getBottomThreeProductsByQuantity(
    List<TempProductClass> allProducts,
    List<TempProductSaleRecord> records,
  ) {
    final Map<String, double> quantityMap = {};
    for (var record in records) {
      quantityMap[record.uuid!] =
          (quantityMap[record.uuid] ?? 0) + record.quantity;
    }

    final List<ProductQuantitySummary> summaryList =
        allProducts.map((product) {
          return ProductQuantitySummary(
            productUuid: product.uuid!,
            productName: product.name,
            totalQuantity: quantityMap[product.uuid] ?? 0,
          );
        }).toList();

    summaryList.sort(
      (a, b) => a.totalQuantity.compareTo(b.totalQuantity),
    );
    return summaryList.take(3).toList();
  }
}

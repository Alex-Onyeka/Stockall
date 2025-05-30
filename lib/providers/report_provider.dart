import 'package:flutter/cupertino.dart';
import 'package:stockitt/classes/product_quantity_summary.dart';
import 'package:stockitt/classes/temp_product_class.dart';
import 'package:stockitt/classes/temp_product_sale_record.dart';
import 'package:stockitt/constants/calculations.dart';
import 'package:stockitt/main.dart';

class ReportProvider extends ChangeNotifier {
  bool setDate = false;
  bool isDateSet = false;
  String? dateSet;

  void openDatePicker() {
    setDate = true;
    notifyListeners();
  }

  void setDay(BuildContext context, DateTime day) {
    returnExpensesProvider(
      context,
      listen: false,
    ).setExpenseDay(day);
    returnReceiptProvider(
      context,
      listen: false,
    ).setReceiptDay(day);
    setDate = false;
    isDateSet = true;
    dateSet = 'For ${formatDateTime(day)}';
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
    ).setExpenseWeek(weekStart, endOfWeek);
    returnReceiptProvider(
      context,
      listen: false,
    ).setReceiptWeek(weekStart, endOfWeek);
    setDate = false;
    isDateSet = true;
    dateSet =
        '${formatDateWithoutYear(weekStart)} - ${formatDateWithoutYear(endOfWeek)}';
    notifyListeners();
  }

  void clearDate(BuildContext context) {
    returnExpensesProvider(
      context,
      listen: false,
    ).clearExpenseDate();
    returnReceiptProvider(
      context,
      listen: false,
    ).clearReceiptDate();
    setDate = false;
    isDateSet = false;
    dateSet = null;
    notifyListeners();
  }

  List<ProductQuantitySummary>?
  getTopThreeProductsByQuantity(
    List<TempProductClass> allProducts,
    List<TempProductSaleRecord> records,
  ) {
    // Step 1: Group sold products by productId and sum quantities
    final Map<int, double> quantityMap = {};
    for (var record in records) {
      quantityMap[record.productId] =
          (quantityMap[record.productId] ?? 0) +
          record.quantity;
    }

    // Step 2: Create ProductQuantitySummary for all products
    final List<ProductQuantitySummary> summaryList =
        allProducts.map((product) {
          return ProductQuantitySummary(
            productId: product.id!,
            productName: product.name,
            totalQuantity: quantityMap[product.id] ?? 0,
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
    final Map<int, double> quantityMap = {};
    for (var record in records) {
      quantityMap[record.productId] =
          (quantityMap[record.productId] ?? 0) +
          record.quantity;
    }

    final List<ProductQuantitySummary> summaryList =
        allProducts.map((product) {
          return ProductQuantitySummary(
            productId: product.id!,
            productName: product.name,
            totalQuantity: quantityMap[product.id] ?? 0,
          );
        }).toList();

    summaryList.sort(
      (a, b) => a.totalQuantity.compareTo(b.totalQuantity),
    );
    return summaryList.take(3).toList();
  }
}

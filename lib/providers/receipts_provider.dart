import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_main_receipt.dart';
import 'package:stockitt/classes/temp_product_sale_record.dart';
import 'package:stockitt/constants/calculations.dart';
import 'package:stockitt/main.dart';

class ReceiptsProvider extends ChangeNotifier {
  List<TempProductSaleRecord> productSaleRecords = [
    TempProductSaleRecord(
      discount: 10,
      discountedAmount: 3000,
      originalCost: 5000,
      productRecordId: 1,
      createdAt: DateTime(2025, 5, 1, 10, 30),
      productId: 1,
      shopId: 1,
      staffId: 'staff001',
      customerId: 1,
      staffName: 'Alice Johnson',
      recepitId: 2,
      quantity: 3,
      revenue: 4500.0,
    ),
    TempProductSaleRecord(
      discount: 10,
      discountedAmount: 2100,
      originalCost: 4000,
      productRecordId: 2,
      createdAt: DateTime(2025, 5, 3, 14, 15),
      productId: 2,
      shopId: 1,
      staffId: 'staff002',
      customerId: 1,
      staffName: 'Bob Smith',
      recepitId: 1,
      quantity: 2,
      revenue: 3000.0,
    ),
    TempProductSaleRecord(
      discount: 10,
      discountedAmount: 5000,
      originalCost: 2500,
      productRecordId: 3,
      createdAt: DateTime(2025, 5, 5, 9, 0),
      productId: 3,
      shopId: 2,
      staffId: 'staff003',
      customerId: 2,
      staffName: 'Chinwe Okafor',
      recepitId: 3,
      quantity: 5,
      revenue: 7500.0,
    ),
  ];

  List<TempProductSaleRecord> getOwnProductSalesRecord(
    BuildContext context,
  ) {
    return returnProductSalesRecordsByDate(context)
        .where(
          (record) =>
              record.shopId ==
              returnShopProvider(
                context,
                listen: false,
              ).returnShop(userId()).shopId,
        )
        .toList();
  }

  List<TempProductSaleRecord>
  returnProductSalesRecordsByDate(BuildContext context) {
    final sortedList =
        productSaleRecords.toList()..sort(
          (a, b) => b.createdAt.compareTo(a.createdAt),
        );
    return sortedList;
  }

  List<TempProductSaleRecord> getProductRecordsByReceiptId(
    int receiptId,
    BuildContext context,
  ) {
    return getOwnProductSalesRecord(context)
        .where((product) => product.recepitId == receiptId)
        .toList();
  }

  void createProductSalesRecord(
    BuildContext context,
    int newReceiptId,
    int? customerId,
  ) {
    for (var item
        in returnSalesProvider(
          context,
          listen: false,
        ).cartItems) {
      productSaleRecords.add(
        TempProductSaleRecord(
          discount: item.discount,
          originalCost: item.totalCost(),
          customerId: customerId,
          discountedAmount: item.discountCost(),
          productRecordId: productSaleRecords.length + 1,
          createdAt: DateTime.now(),
          productId: item.item.id,
          shopId: item.item.shopId,
          staffId: 'staffId',
          staffName: 'staffName',
          recepitId: newReceiptId,
          quantity: item.quantity,
          revenue: item.revenue(),
        ),
      );
    }

    notifyListeners();
  }

  //
  //
  //
  //
  //
  //
  List<TempMainReceipt> mainReceipts = [
    TempMainReceipt(
      id: 1,
      barcode: 'B12345',
      createdAt: DateTime(2025, 5, 5),
      shopId: 1,
      staffId: 's001',
      staffName: 'Alice Johnson',
      customerId: 1,
      bank: 0,
      cashAlt: 20000,
      paymentMethod: 'Cash',
    ),
    TempMainReceipt(
      id: 1,
      barcode: 'B12346',
      createdAt: DateTime(2025, 5, 7),
      shopId: 1,
      staffId: 's002',
      staffName: 'Bob Smith',
      customerId: 1,
      bank: 40000,
      cashAlt: 0,
      paymentMethod: 'Bank',
    ),
    TempMainReceipt(
      id: 1,
      barcode: 'B12347',
      createdAt: DateTime(2025, 5, 6),
      shopId: 1,
      staffId: 's001',
      staffName: 'Alice Johnson',
      customerId: 1,
      bank: 2500,
      cashAlt: 3000,
      paymentMethod: 'Split',
    ),
  ];

  void deleteMainReceipt(int id) {
    mainReceipts.removeWhere((receipt) => receipt.id == id);
    notifyListeners();
  }

  DateTime? singleDay;
  DateTime? weekStartDate;

  bool setDate = false;
  bool isDateSet = false;
  String? dateSet;

  void openDatePicker() {
    setDate = true;
    notifyListeners();
  }

  void setReceiptDay(DateTime day) {
    singleDay = day;
    weekStartDate = null;
    isDateSet = true;
    setDate = false;
    dateSet = 'For ${formatDateTime(day)}';
    notifyListeners();
  }

  void setReceiptWeek(
    DateTime weekStart,
    DateTime endOfWeek,
  ) {
    weekStartDate = weekStart;
    singleDay = null;
    isDateSet = true;
    setDate = false;
    dateSet =
        'From ${formatDateWithoutYear(weekStart)} - ${formatDateWithoutYear(endOfWeek)}';
    notifyListeners();
  }

  void clearReceiptDate() {
    singleDay = null;
    weekStartDate = null;
    setDate = false;
    isDateSet = false;
    dateSet = null;
    notifyListeners();
  }

  List<TempMainReceipt> returnOwnReceiptsByDayOrWeek(
    BuildContext context,
  ) {
    final shopId =
        returnShopProvider(
          context,
        ).returnShop(userId()).shopId;

    if (weekStartDate != null) {
      final weekEndDate = weekStartDate!.add(
        const Duration(days: 6),
      );

      return getSortedReceiptsByDate(context).where((
        receipt,
      ) {
        return receipt.shopId == shopId &&
            receipt.createdAt.isAfter(
              weekStartDate!.subtract(
                const Duration(seconds: 1),
              ),
            ) &&
            receipt.createdAt.isBefore(
              weekEndDate.add(const Duration(days: 1)),
            );
      }).toList();
    }

    final targetDate = singleDay ?? DateTime.now();

    return mainReceipts.where((receipt) {
      return receipt.shopId == shopId &&
          receipt.createdAt.year == targetDate.year &&
          receipt.createdAt.month == targetDate.month &&
          receipt.createdAt.day == targetDate.day;
    }).toList();
  }

  double getTotalRevenueForSelectedDay(
    BuildContext context,
  ) {
    double tempTotalRevenue = 0;

    for (var receipt in returnOwnReceiptsByDayOrWeek(
      context,
    )) {
      var productRecords =
          getOwnProductSalesRecord(context)
              .where(
                (record) => record.recepitId == receipt.id,
              )
              .toList();

      for (var record in productRecords) {
        tempTotalRevenue += record.revenue;
      }
    }

    return tempTotalRevenue;
  }

  List<TempMainReceipt> returnOwnReceipts(
    BuildContext context,
  ) {
    return mainReceipts
        .where(
          (receipt) =>
              receipt.shopId ==
              returnShopProvider(
                context,
                listen: false,
              ).returnShop(userId()).shopId,
        )
        .toList();
  }

  List<TempMainReceipt> getSortedReceiptsByDate(
    BuildContext context,
  ) {
    final sortedList =
        returnOwnReceipts(context).toList()..sort(
          (a, b) => a.createdAt.compareTo(b.createdAt),
        );
    return sortedList;
  }

  int createMainReceipt(TempMainReceipt mainReceipt) {
    final newId = mainReceipts.length + 1;
    mainReceipts.add(
      TempMainReceipt(
        id: newId,
        createdAt: DateTime.now(),
        barcode: mainReceipt.barcode,
        customerId: mainReceipt.customerId,
        shopId: mainReceipt.shopId,
        staffId: mainReceipt.staffId,
        staffName: mainReceipt.staffName,
        bank: mainReceipt.bank,
        cashAlt: mainReceipt.cashAlt,
        paymentMethod: mainReceipt.paymentMethod,
      ),
    );
    notifyListeners();
    return newId;
  }

  double getSubTotalRevenueForReceipt(
    BuildContext context,
    TempMainReceipt mainReceipt,
  ) {
    double tempRev = 0;
    var beans =
        getOwnProductSalesRecord(context)
            .where(
              (bean) => bean.recepitId == mainReceipt.id,
            )
            .toList();

    for (var bean in beans) {
      tempRev += bean.originalCost!;
    }
    return tempRev;
  }

  double getTotalMainRevenueReceipt(
    TempMainReceipt mainReceipt,
    BuildContext context,
  ) {
    double tempTotal = 0;
    var productRecords =
        getOwnProductSalesRecord(context)
            .where(
              (test) => test.recepitId == mainReceipt.id,
            )
            .toList();

    for (var productRecord in productRecords) {
      tempTotal += productRecord.revenue;
    }

    return tempTotal;
  }
}

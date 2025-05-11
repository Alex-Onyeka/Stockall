import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_main_receipt.dart';
import 'package:stockitt/classes/temp_product_sale_record.dart';
import 'package:stockitt/main.dart';

class ReceiptsProvider extends ChangeNotifier {
  List<TempProductSaleRecord> productSaleRecords = [
    TempProductSaleRecord(
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
  ) {
    for (var item
        in returnSalesProvider(
          context,
          listen: false,
        ).cartItems) {
      productSaleRecords.add(
        TempProductSaleRecord(
          productRecordId: productSaleRecords.length + 1,
          createdAt: DateTime.now(),
          productId: item.item.id,
          shopId: item.item.shopId,
          staffId: 'staffId',
          staffName: 'staffName',
          recepitId: newReceiptId,
          quantity: item.quantity,
          revenue: item.totalCost(),
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
      createdAt: DateTime(2025, 5, 5, 9, 30),
      shopId: 1,
      staffId: 's001',
      staffName: 'Alice Johnson',
      customerId: 2,
    ),
    TempMainReceipt(
      id: 2,
      barcode: 'B12346',
      createdAt: DateTime(2025, 5, 7, 14, 0),
      shopId: 2,
      staffId: 's002',
      staffName: 'Bob Smith',
      customerId: 3,
    ),
    TempMainReceipt(
      id: 3,
      barcode: 'B12347',
      createdAt: DateTime(2025, 5, 6, 11, 15),
      shopId: 1,
      staffId: 's001',
      staffName: 'Alice Johnson',
      customerId: 1,
    ),
  ];

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
          (a, b) => b.createdAt.compareTo(a.createdAt),
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
      ),
    );
    notifyListeners();
    return newId;
  }

  double getTotalRevenue(
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
      tempRev += bean.revenue;
    }
    return tempRev;
  }

  double getTotalDiscountMainReceipt(
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
      var product = returnData(context, listen: false)
          .returnOwnProducts(context)
          .firstWhere(
            (test) => test.id == productRecord.productId,
          );

      if (product.discount != null) {
        tempTotal +=
            product.sellingPrice *
            (product.discount! / 100) *
            productRecord.quantity;
      }
    }

    return tempTotal;
  }
}

import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_cart_item.dart';
import 'package:stockitt/classes/temp_main_receipt.dart';
import 'package:stockitt/classes/temp_product_class.dart';
import 'package:stockitt/classes/temp_product_sale_record.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/sales/make_sales/receipt_page/receipt_page.dart';
import 'package:stockitt/providers/data_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SalesProvider extends ChangeNotifier {
  List<TempCartItem> cartItems = [];

  final SupabaseClient supabase = Supabase.instance.client;

  Future<TempMainReceipt> checkoutMain({
    required BuildContext context,
    required List<TempCartItem> cartItems,
    required String staffId,
    required String staffName,
    required int shopId,
    required String paymentMethod,
    required double cashAlt,
    required double bank,
    int? customerId,
  }) async {
    final createdAt = DateTime.now();

    // Step 1: Create the receipt
    final receiptData = {
      'created_at': createdAt.toIso8601String(),
      'shop_id': shopId,
      'staff_id': staffId,
      'staff_name': staffName,
      'customer_id': customerId,
      'payment_method': paymentMethod,
      'cash_alt': cashAlt,
      'bank': bank,
    };

    final receiptRes =
        await supabase
            .from('receipts')
            .insert(receiptData)
            .select()
            .single();

    final receipt = TempMainReceipt.fromJson(receiptRes);
    final receiptId = receipt.id!;

    // Step 2: Create product sale records
    final productSaleRecords =
        cartItems.map((cartItem) {
          final product = cartItem.item;

          return TempProductSaleRecord(
            createdAt: createdAt,
            productId: product.id!,
            productName: product.name,
            shopId: product.shopId,
            staffId: staffId,
            customerId: customerId,
            staffName: staffName,
            recepitId: receiptId,
            quantity: cartItem.quantity,
            revenue: cartItem.revenue(),
            discountedAmount: cartItem.discountCost(),
            originalCost: cartItem.totalCost(),
            discount: cartItem.discount,
          );
        }).toList();

    final dataToInsert =
        productSaleRecords.map((e) => e.toJson()).toList();

    await supabase
        .from('product_sales')
        .insert(dataToInsert);

    // ✅ Step 3: Decrement product quantities using the Supabase RPC
    for (final cartItem in cartItems) {
      await supabase.rpc(
        'decrement_product_quantity',
        params: {
          'p_product_id': cartItem.item.id,
          'p_quantity': cartItem.quantity,
        },
      );
    }

    // Step 4: Reset everything
    resetPaymentMethod();
    clearCart();

    // if (!context.mounted) {
    //   return;
    // }
    if (context.mounted) {
      returnCustomers(
        context,
        listen: false,
      ).clearSelectedCustomer();
      returnNavProvider(context, listen: false).navigate(0);
    }

    notifyListeners();
    return receipt;
  }

  void clearCart() {
    cartItems.clear();
    notifyListeners();
  }

  double discountCheck(TempProductClass product) {
    double tempValue = 0;
    if (product.discount == null) {
      tempValue = product.sellingPrice;
    } else {
      tempValue =
          (product.sellingPrice *
              (product.discount! / 100));
    }
    return tempValue;
  }

  double calcTotalMain(List<TempCartItem> items) {
    double tempTotal = 0;
    for (var item in items) {
      tempTotal += item.totalCost();
    }
    return tempTotal;
  }

  double calcDiscountMain(List<TempCartItem> items) {
    double tempTotalDiscount = 0;
    for (var item in items) {
      if (item.item.discount != null) {
        double discountPerUnit =
            item.item.sellingPrice *
            (item.item.discount! / 100);
        tempTotalDiscount +=
            discountPerUnit * item.quantity;
      }
    }
    return tempTotalDiscount;
  }

  double calcFinalTotalMain(List<TempCartItem> items) {
    return calcTotalMain(items) - calcDiscountMain(items);
  }

  String addItemToCartMain(TempCartItem newItem) {
    String result = '';
    final index = cartItems.indexWhere(
      (item) => item.item.id == newItem.item.id,
    );

    if (index != -1) {
      // Item exists
      cartItems[index].quantity += newItem.quantity;
      result = 'Item Updated Successfully';
    } else {
      cartItems.add(newItem);
      result = 'Item Added Successfully';
    }

    notifyListeners();
    return result;
  }

  String addItemToCart(TempCartItem newItem) {
    String result = '';
    final index = cartItems.indexWhere(
      (item) => item.item.id == newItem.item.id,
    );

    if (index != -1) {
      // Item exists
      cartItems[index].quantity += newItem.quantity;
      result = 'Item Updated Successfully';
    } else {
      cartItems.add(newItem);
      result = 'Item Added Successfully';
    }

    notifyListeners();
    return result;
  }

  void editCartItemQuantity(
    TempCartItem cartItem,
    double number,
  ) {
    cartItem.quantity = number;
    notifyListeners();
  }

  void removeItemFromCart(TempCartItem item) {
    cartItems.remove(item);
    notifyListeners();
  }

  DataProvider dataProvider = DataProvider();

  List<TempProductClass> searchProductsName(String text) {
    List<TempProductClass> tempProducts =
        dataProvider.products
            .where(
              (product) => product.name
                  .toLowerCase()
                  .contains(text.toLowerCase()),
            )
            .toList();

    return tempProducts;
  }

  List<TempProductClass> searchProductsBarcode(
    String text,
  ) {
    return dataProvider.products
        .where(
          (product) =>
              product.barcode != null &&
              product.barcode!.contains(text),
        )
        .toList();
  }

  void resetPaymentMethod() {
    currentPayment = 0;
    notifyListeners();
  }

  int currentPayment = 0;
  List<Map<String, dynamic>> paymentMethods = [
    {
      'number': 0,
      'method': 'Pay with Cash',
      'subText': 'Use Cash to Make Payment',
    },
    {
      'number': 1,
      'method': 'Pay with Transfer / Atm',
      'subText': 'Use Bank to Proceed with Payment',
    },
    {
      'number': 2,
      'method': 'Split Payment',
      'subText': 'Use Both Cash and Bank to Pay',
    },
  ];

  void changeMethod(int index) {
    currentPayment = index;
    notifyListeners();
  }

  String returnPaymentMethod() {
    switch (currentPayment) {
      case 0:
        return 'Cash';
      case 1:
        return 'Bank';
      case 2:
        return 'Split';
      default:
        return 'Cash';
    }
  }

  List<int> productIdsToRefund = [];
  void addproductIdToRefund(int index) {
    productIdsToRefund.add(index);
    notifyListeners();
  }

  void removeProductIdFromRefund(int index) {
    productIdsToRefund.remove(index);
    notifyListeners();
  }

  void refundProducts(
    List<int> productRecordIds,
    TempMainReceipt mainReceipt,
    BuildContext context,
  ) {
    final dataProvider = returnData(context, listen: false);
    final receiptProvider = returnReceiptProvider(
      context,
      listen: false,
    );

    final productSalesRecords =
        receiptProvider.productSaleRecords;

    // Make a copy of the list to avoid modifying it while iterating
    final idsToRefund = List<int>.from(productRecordIds);

    for (var id in idsToRefund) {
      final saleRecord = productSalesRecords.firstWhere(
        (record) => record.productRecordId == id,
        orElse:
            () =>
                throw Exception(
                  "Sale record not found: $id",
                ),
      );

      final product = dataProvider.products.firstWhere(
        (p) => p.id == saleRecord.productId,
        orElse:
            () =>
                throw Exception(
                  "Product not found: ${saleRecord.productId}",
                ),
      );

      // Restore quantity
      product.quantity += saleRecord.quantity;

      // Remove the product sale record
      productSalesRecords.removeWhere(
        (record) => record.productRecordId == id,
      );

      // ✅ Remove the refunded ID from the refund list
      removeProductIdFromRefund(id);
    }

    // 🧹 Optional: If all records for this receipt are gone, delete the receipt
    final remainingProductsForThisReceipt =
        productSalesRecords
            .where(
              (record) =>
                  record.recepitId == mainReceipt.id,
            )
            .toList();

    if (remainingProductsForThisReceipt.isEmpty) {
      receiptProvider.deleteMainReceipt(mainReceipt.id!);
      Navigator.of(context).pop();
    }

    dataProvider.notifyListeners();
    receiptProvider.notifyListeners();
  }

  void createProductSalesRecord(
    BuildContext context,
    TempMainReceipt mainReceipt,
    List<TempProductSaleRecord> productRecords,
    int? customerId,
  ) async {
    await returnReceiptProvider(
      context,
      listen: false,
    ).createReceipt(mainReceipt);
    if (!context.mounted) return;
    returnReceiptProvider(
      context,
      listen: false,
    ).createProductSaleRecord(productRecords);
    notifyListeners();
  }

  void createSales(
    BuildContext context,
    TempMainReceipt mainReceipt,
    TempProductSaleRecord productRecord,
    int? customerId,
  ) async {
    await returnReceiptProvider(
      context,
      listen: false,
    ).createReceipt(mainReceipt);
    if (!context.mounted) return;
    returnReceiptProvider(
      context,
      listen: false,
    ).createProductSalesRecord(
      context,
      mainReceipt.id!,
      customerId,
    );
    notifyListeners();
  }

  void updateProductQuantities(BuildContext context) {
    final productList = returnData(
      context,
      listen: false,
    ).returnOwnProducts(context);

    for (var item in cartItems) {
      final actualProduct = productList.firstWhere(
        (product) => product.id == item.item.id,
      );

      actualProduct.quantity -= item.quantity;
    }

    notifyListeners();
  }

  void checkOut({
    required BuildContext context,
    required TempMainReceipt mainReceipt,
    required TempProductSaleRecord productRecord,
    required int? customerId,
  }) {
    createSales(
      context,
      mainReceipt,
      productRecord,
      customerId,
    );
    updateProductQuantities(context);
    resetPaymentMethod();
    clearCart();
    returnCustomers(
      context,
      listen: false,
    ).clearSelectedCustomer();
    returnNavProvider(context, listen: false).navigate(0);
    returnCompProvider(
      context,
      listen: false,
    ).successAction(() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return ReceiptPage(
              isMain: true,
              mainReceipt: mainReceipt,
            );
          },
        ),
      );
    });
  }
}

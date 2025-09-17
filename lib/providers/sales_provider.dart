import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/data_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SalesProvider extends ChangeNotifier {
  bool isLoading = false;
  void toggleIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  bool setTotalPrice = false;
  void toggleSetTotalPrice(bool value) {
    setTotalPrice = value;
    notifyListeners();
  }

  List<TempCartItem> cartItems = [];
  bool isInvoice = false;

  void switchInvoiceSale() {
    isInvoice = !isInvoice;
    notifyListeners();
  }

  bool addToStock = true;
  void toggleAddToStock(bool value) {
    addToStock = value;
    notifyListeners();
  }

  void offInvoice() {
    isInvoice = false;
    notifyListeners();
  }

  void onInvoice() {
    isInvoice = true;
    notifyListeners();
  }

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
    String? customerName,
  }) async {
    final createdAt = DateTime.now().toUtc();

    // Step 1: Create the receipt
    final receiptData = {
      'created_at': createdAt.toIso8601String(),
      'shop_id': shopId,
      'staff_id': staffId,
      'staff_name': staffName,
      'customer_id': customerId,
      'payment_method': paymentMethod,
      'cash_alt': cashAlt,
      'customer_name': customerName,
      'bank': bank,
      'is_invoice': isInvoice,
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
            customPriceSet: cartItem.item.setCustomPrice,
            createdAt: createdAt,
            productId: product.id!,
            productName: product.name,
            shopId: product.shopId,
            staffId: staffId,
            customerId: customerId,
            customerName: customerName,
            staffName: staffName,
            recepitId: receiptId,
            quantity: cartItem.quantity,
            revenue: cartItem.revenue(),
            discountedAmount: cartItem.discountCost(),
            originalCost: cartItem.totalCost(),
            discount: cartItem.discount,
            costPrice: cartItem.costPrice(),
            addToStock: cartItem.addToStock,
            departmentName: cartItem.item.departmentName,
            departmentId: cartItem.item.departmentId,
          );
        }).toList();

    final dataToInsert =
        productSaleRecords.map((e) => e.toJson()).toList();

    await supabase
        .from('product_sales')
        .insert(dataToInsert);

    // Step 3: Decrement quantity via RPC
    for (final cartItem in cartItems) {
      if ((cartItem.item.quantity ?? 0) > 0) {
        await supabase.rpc(
          'decrement_product_quantity',
          params: {
            'p_product_id': cartItem.item.id,
            'p_quantity': cartItem.quantity,
          },
        );
      }
    }

    // Step 4: Create new product for items with addToStock == true
    for (final record in productSaleRecords) {
      if (record.addToStock == true) {
        final double costPrice =
            (record.costPrice == null ||
                    record.costPrice == 0)
                ? 0
                : record.costPrice!;

        final double sellingPrice =
            record.revenue / record.quantity;

        await supabase.from('products').insert({
          'name': record.productName,
          'shop_id': record.shopId,
          'unit': 'Others',
          'is_refundable': false,
          'cost_price': costPrice,
          'selling_price': sellingPrice,
          'low_qtty': 10,
          'set_custom_price': true,
          'is_managed': false,

          // nullable values
          'brand': null,
          'category': null,
          'barcode': null,
          'color': null,
          'size_type': null,
          'size': null,
          'discount': null,
          'quantity': null,
          'starting_date': null,
          'ending_date': null,
          'department_name': record.departmentName,
          'department_id': record.departmentId,
          'expiry_date': null,
        });
      }
    }

    // Step 5: Reset state
    resetPaymentMethod();
    clearCart();

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
    if (product.discount == null || product.discount == 0) {
      tempValue = product.sellingPrice ?? 0;
    } else {
      tempValue =
          product.sellingPrice ??
          0 -
              (product.sellingPrice ??
                  0 * (product.discount! / 100));
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
      if (item.item.discount != null &&
          item.customPrice == null) {
        double discountPerUnit =
            item.item.sellingPrice ??
            0 * (item.item.discount! / 100);
        tempTotalDiscount +=
            discountPerUnit * item.quantity;
      }
    }
    return tempTotalDiscount;
  }

  double calcFinalTotalMain(List<TempCartItem> items) {
    return calcTotalMain(items) - calcDiscountMain(items);
  }

  bool isSetCustomPrice = false;

  void toggleSetCustomPrice() {
    isSetCustomPrice = !isSetCustomPrice;
    notifyListeners();
  }

  void closeCustomPrice() {
    isSetCustomPrice = false;
    notifyListeners();
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

  void editCartItemQuantity({
    required TempCartItem cartItem,
    required double number,
    double? customPrice,
    required bool setTotalPrice,
    required bool setCustomPrice,
  }) {
    cartItem.quantity = number;
    cartItem.customPrice = customPrice;
    cartItem.setTotalPrice = setTotalPrice;
    cartItem.setCustomPrice = setCustomPrice;
    notifyListeners();
  }

  void removeItemFromCart(TempCartItem item) {
    cartItems.remove(item);
    notifyListeners();
  }

  DataProvider dataProvider = DataProvider();

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
}

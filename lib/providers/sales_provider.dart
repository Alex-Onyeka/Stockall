import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
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
  final ConnectivityProvider connectivity =
      ConnectivityProvider();

  // final ReceiptsProvider receiptsProvider =
  //     ReceiptsProvider();
  // final DataProvider dataProvider = DataProvider();

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
    String? customerUuid,
    String? customerName,
  }) async {
    bool isOnline = await connectivity.isOnline();
    final createdAt = DateTime.now().toUtc();
    final uuid = uuidGen();
    print('Checkout Started');

    TempMainReceipt receipt = TempMainReceipt(
      createdAt: createdAt,
      shopId: shopId,
      staffId: staffId,
      staffName: staffName,
      paymentMethod: paymentMethod,
      bank: bank,
      cashAlt: cashAlt,
      isInvoice: isInvoice,
      customerId: customerId,
      customerName: customerName,
      customerUuid: customerUuid,
      uuid: uuid,
    );
    final receiptRes = await returnReceiptProvider(
      context,
      listen: false,
    ).createReceipt(
      receipt,
      // ignore: use_build_context_synchronously
      context,
    );
    print('Receipt Created');

    final receiptId = receiptRes.id;
    final receiptUuid = receiptRes.uuid;
    print(receiptId);
    print(receiptUuid);

    // Step 2: Create product sale records
    final productSaleRecords =
        cartItems.map((cartItem) {
          final product = cartItem.item;
          print('Sales Record about to be Created');
          return TempProductSaleRecord(
            customPriceSet: cartItem.item.setCustomPrice,
            createdAt: createdAt,
            productId: product.id ?? 0,
            productUuid: product.uuid,
            productName: product.name,
            shopId: product.shopId,
            staffId: staffId,
            customerId: customerId,
            customerUuid: customerUuid,
            customerName: customerName,
            staffName: staffName,
            recepitId: receiptId ?? 0,
            receiptUuid: receiptUuid,
            quantity: cartItem.quantity,
            revenue: cartItem.revenue(),
            discountedAmount: cartItem.discountCost(),
            originalCost: cartItem.totalCost(),
            discount: cartItem.discount,
            costPrice: cartItem.costPrice(),
            addToStock: cartItem.addToStock,
            departmentName: cartItem.item.departmentName,
            departmentId: cartItem.item.departmentId,
            uuid: uuidGen(),
            isProductManaged: cartItem.item.isManaged,
          );
        }).toList();

    if (context.mounted) {
      await returnReceiptProvider(
        context,
        listen: false,
      ).createProductSaleRecord(
        productSaleRecords,
        context,
      );
    }
    print('Sales Record Inserted');

    // Step 3: Decrement quantity via RPC
    for (final cartItem in cartItems) {
      if (((cartItem.item.quantity ?? 0) > 0) &&
          cartItem.item.isManaged) {
        if (isOnline) {
          await supabase.rpc(
            'decrement_product_quantity_new',
            params: {
              'p_product_uuid': cartItem.item.uuid,
              'p_quantity': cartItem.quantity.toInt(),
            },
          );
          // await ProductsFunc().deductQuantity(
          //   isOnline: isOnline,
          //   quantity: cartItem.quantity,
          //   uuid: cartItem.item.uuid!,
          // );
        } else {
          await ProductsFunc().deductQuantity(
            isOnline: isOnline,
            quantity: cartItem.quantity,
            uuid: cartItem.item.uuid!,
          );
        }
      }
    }

    print('Products Decrementation Done');

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

        TempProductClass product = TempProductClass(
          name: record.productName,
          unit: 'Others',
          isRefundable: false,
          costPrice: costPrice,
          shopId: record.shopId,
          setCustomPrice: true,
          isManaged: false,
          barcode: null,
          brand: null,
          category: null,
          color: null,
          createdAt: DateTime.now(),
          departmentId: record.departmentId,
          departmentName: record.departmentName,
          discount: null,
          endDate: null,
          expiryDate: null,
          lowQtty: 10,
          quantity: null,
          sellingPrice: sellingPrice,
          size: null,
          sizeType: null,
          startDate: null,
          updatedAt: DateTime.now(),
          uuid: uuidGen(),
        );
        if (context.mounted) {
          await returnData(
            context,
            listen: false,
          ).createProduct(product, context);
        } else {
          print(
            'Context Not Mounted to Created New Product',
          );
        }
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
      await returnReceiptProvider(
        context,
        listen: false,
      ).loadReceipts(shopId, context);
      if (context.mounted) {
        returnNavProvider(
          context,
          listen: false,
        ).navigate(0);
      }
    }

    notifyListeners();
    return receipt;
  }

  void clearCart() {
    cartItems.clear();
    print('Cart Cleared');
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
      (item) => item.item.uuid == newItem.item.uuid,
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
      (item) => item.item.uuid == newItem.item.uuid,
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

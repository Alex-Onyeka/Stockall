import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_cart/temp_cart.dart';
import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/sales/make_sales/page1/make_sales_page.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/receipt_page.dart';
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

  List<TempCart> cartQueue = [
    TempCart(cartItems: [], isInvoice: false),
  ];

  int cartIndex = 0;

  TempCart currentCart() {
    return cartQueue[cartIndex];
  }

  void addNewCart() {
    cartQueue.add(
      TempCart(cartItems: [], isInvoice: false),
    );
    cartIndex == cartQueue.length + 1;
    notifyListeners();
  }

  void deleteCart(int index) {
    cartQueue.removeWhere(
      (cart) => cartQueue.indexOf(cart) == index,
    );
    index == 0 ? cartIndex = 0 : cartIndex = index - 1;
    notifyListeners();
  }

  void selectCart(int index) {
    cartIndex = index;
    notifyListeners();
  }

  void switchInvoiceSale() {
    currentCart().isInvoice = !currentCart().isInvoice;
    // currentCart().
    notifyListeners();
  }

  bool addToStock = true;
  void toggleAddToStock(bool value) {
    addToStock = value;
    notifyListeners();
  }

  void offInvoice() {
    currentCart().isInvoice = false;
    notifyListeners();
  }

  void onInvoice() {
    currentCart().isInvoice = true;
    notifyListeners();
  }

  List<int> fixedDiscounts = [
    1000,
    2000,
    5000,
    10000,
    15000,
    20000,
    25000,
    30000,
    50000,
  ];

  List<int> returnSomeFixedDiscounts(
    int startAmount,
    int end,
  ) {
    return fixedDiscounts
        .getRange(startAmount, end)
        .toList();
  }

  void addGeneralFixedDiscount(double? discount) {
    currentCart().fixedDiscount = discount;
    currentCart().discount = null;
    var disc = (((discount ?? 0) / calcTotalMain()) * 100);
    for (var item in currentCart().cartItems) {
      item.discount = disc;
      print("${item.item.name}: ${item.discount}");
    }
    print(currentCart().fixedDiscount);
    notifyListeners();
  }

  void addGeneralDiscount(double? discount) {
    currentCart().discount = discount;
    currentCart().fixedDiscount = null;
    for (var item in currentCart().cartItems) {
      item.discount = discount;
      print("${item.item.name}: ${item.discount}");
    }
    notifyListeners();
  }

  List<double> discounts = [
    1,
    2,
    5,
    10,
    15,
    20,
    25,
    30,
    50,
  ];

  List<String> returnSomeDiscounts(
    int startAmount,
    int end,
  ) {
    return discounts
        .getRange(startAmount, end)
        .map((m) => m.toStringAsFixed(0))
        .toList();
  }

  void toggleSetDiscount(bool value) {
    currentCart().isSettingDiscountOpen = value;
    print(currentCart().isSettingDiscountOpen);
    notifyListeners();
  }

  final SupabaseClient supabase = Supabase.instance.client;
  final ConnectivityProvider connectivity =
      ConnectivityProvider();

  Future<TempMainReceipt> checkoutMain({
    required BuildContext context,
    required TempCart salesCartItem,
    required String staffId,
    required String staffName,
    required int shopId,
    required String paymentMethod,
    required double cashAlt,
    required double bank,
    // int? customerId,
    String? customerUuid,
    String? customerName,
  }) async {
    bool isOnline = await connectivity.isOnline();
    if (currentCart().receiptUuidEdit != null) {
      await returnReceiptProvider(
        // ignore: use_build_context_synchronously
        context,
        listen: false,
      ).deleteReceipt(
        currentCart().receiptUuidEdit!,
        // ignore: use_build_context_synchronously
        context,
      );
    }
    final createdAt =
        currentCart().createdDate ?? DateTime.now().toUtc();
    final uuid = currentCart().receiptUuidEdit ?? uuidGen();

    print('Checkout Started');

    TempMainReceipt receipt = TempMainReceipt(
      createdAt: createdAt,
      shopId: shopId,
      staffId: staffId,
      staffName: staffName,
      paymentMethod: paymentMethod,
      bank: bank,
      cashAlt: cashAlt,
      isInvoice: salesCartItem.isInvoice,
      customerName: customerName,
      customerUuid: customerUuid,
      uuid: uuid,
      generalDiscount: currentCart().discount,
      fixedDiscount: currentCart().fixedDiscount,
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

    final receiptId = receiptRes!.id;
    final receiptUuid = receiptRes.uuid;
    print(receiptId);
    print(receiptUuid);

    // Step 2: Create product sale records
    final productSaleRecords =
        salesCartItem.cartItems.map((cartItem) {
          final product = cartItem.item;
          print('Sales Record about to be Created');
          return TempProductSaleRecord(
            customPriceSet: cartItem.setCustomPrice,
            createdAt: createdAt,
            productId: product.id ?? 0,
            productUuid: product.uuid,
            productName: product.name,
            shopId: product.shopId,
            staffId: staffId,
            // customerId: customerId,
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
            uuid: cartItem.salesRecordId ?? uuidGen(),
            isProductManaged: cartItem.item.isManaged,
            setTotalPrice: cartItem.setTotalPrice,
          );
        }).toList();

    if (context.mounted) {
      print('Creating Record Sales About to Start');
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
    for (final cartItem in salesCartItem.cartItems) {
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
      // ignore: use_build_context_synchronously
      if (record.addToStock == true &&
          returnData(context, listen: false).productList
              .where(
                (pro) => pro.name == record.productName,
              )
              .isEmpty) {
        final double costPrice =
            (record.costPrice == null ||
                    record.costPrice == 0)
                ? 0
                : record.costPrice!;

        final double sellingPrice =
            record.discount == null
                ? record.revenue / record.quantity
                : (record.originalCost ?? 0) /
                    record.quantity;

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
    // resetPaymentMethod();
    cartQueue.length > 1
        ? deleteCart(cartIndex)
        : clearCart();

    if (context.mounted) {
      returnCustomers(
        context,
        listen: false,
      ).clearSelectedCustomer(context);
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
    currentCart().cartItems.clear();
    currentCart().isInvoice = false;
    currentCart().selectedCustomer = null;
    currentCart().selectedCustomerName = null;
    currentCart().paymentMethod = 0;
    currentCart().discount = null;
    currentCart().fixedDiscount = null;
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

  double calcTotalMain() {
    double tempTotal = 0;
    for (var item in currentCart().cartItems) {
      tempTotal += item.totalCost();
    }
    return tempTotal;
  }

  double calcDiscountMain() {
    if (currentCart().fixedDiscount != null) {
      return currentCart().fixedDiscount ?? 0;
    } else if (currentCart().discount != null) {
      // print(calcTotalMain(items));
      return calcTotalMain() *
          ((currentCart().discount ?? 0) / 100);
    } else {
      double tempTotalDiscount = 0;
      for (var item in currentCart().cartItems) {
        if (item.item.discount != null &&
            item.customPrice == null) {
          double discountPerUnit =
              (item.item.sellingPrice ?? 0) *
              (item.item.discount! / 100);
          tempTotalDiscount +=
              discountPerUnit * item.quantity;
        }
      }
      return tempTotalDiscount;
    }
  }

  double calcFinalTotalMain() {
    return calcTotalMain() - calcDiscountMain();
  }

  bool isSetCustomPrice() {
    return currentCart().setCustomPrice;
  }

  void toggleSetCustomPrice() {
    currentCart().setCustomPrice =
        !currentCart().setCustomPrice;
    notifyListeners();
  }

  void closeCustomPrice() {
    currentCart().setCustomPrice = false;
    notifyListeners();
  }

  //
  //
  //
  //

  bool canAddProductToCart({
    required TempProductClass product,
    required double quantityToAdd,
    required BuildContext context,
  }) {
    double totalInAllCarts = 0;
    for (final cart in cartQueue) {
      for (final cartItem in cart.cartItems) {
        if (cartItem.item.uuid == product.uuid) {
          totalInAllCarts += cartItem.quantity;
        }
      }
    }
    double newTotal = totalInAllCarts + quantityToAdd;
    double availableQty = product.quantity ?? 0;
    if (newTotal > availableQty &&
        returnData(
          context,
          listen: false,
        ).productList.contains(product) &&
        product.isManaged) {
      print(
        'Cannot add — total ($newTotal) exceeds available stock ($availableQty)',
      );
      return false;
    }
    return true;
  }

  // double? calcFixedDiscountPercent() {
  //   return ((currentCart().fixedDiscount ?? 0) /
  //           calcTotalMain()) *
  //       100;
  // }

  String addItemToCart({
    required BuildContext context,
    required TempCartItem newItem,
    required bool isCustomEdit,
  }) {
    if (canAddProductToCart(
      context: context,
      product: newItem.item,
      quantityToAdd: newItem.quantity,
    )) {
      String result = '';
      final index = currentCart().cartItems.indexWhere(
        (item) => item.item.uuid == newItem.item.uuid,
      );
      var items = currentCart().cartItems.where(
        (item) => item.item.uuid == newItem.item.uuid,
      );

      if (isCustomEdit && index != -1) {
        var item = items.first;
        item.item.name = newItem.item.name;
        item.item.sellingPrice = newItem.item.sellingPrice;
        item.item.costPrice = newItem.item.costPrice;
        item.item.setCustomPrice =
            newItem.item.setCustomPrice;
        item.addToStock = newItem.addToStock;
        item.customPrice = newItem.customPrice;
        item.discount =
            currentCart().discount ??
            // calcFixedDiscountPercent() ??
            newItem.discount;
        item.quantity = newItem.quantity;
        item.setCustomPrice = newItem.setCustomPrice;
        item.setTotalPrice = newItem.setTotalPrice;
        notifyListeners();
      } else {
        if (index != -1) {
          // Item exists
          currentCart().cartItems[index].discount =
              currentCart().discount ??
              // calcFixedDiscountPercent() ??
              currentCart().cartItems[index].discount;
          currentCart().cartItems[index].quantity +=
              newItem.quantity;
          result = 'Item Updated Successfully';
        } else {
          newItem.discount =
              currentCart().discount ??
              // calcFixedDiscountPercent() ??
              newItem.discount;
          currentCart().cartItems.add(newItem);
          // print("Main Carts Length: ${cartQueue.length}");
          // print(
          //   "Current Cart Length: ${currentCart().cartItems.length}",
          // );
          // print(
          //   "Current Item Discount: ${newItem.discount ?? 'No Discount'}",
          // );
          result = 'Item Added Successfully';
        }
      }

      notifyListeners();
      return result;
    } else {
      showDialog(
        context: context,
        builder:
            (_) => InfoAlert(
              title: "Quantity Limit Reached",
              message:
                  "Only ${newItem.item.quantity} available in stock.",
              theme: returnTheme(context, listen: false),
            ),
      );
      return "Quantity Limit Exceeded!❌";
    }
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
    currentCart().cartItems.remove(item);
    print("Main Carts Length: ${cartQueue.length}");
    print(
      "Current Cart Length: ${currentCart().cartItems.length}",
    );
    notifyListeners();
  }

  void resetPaymentMethod() {
    currentCart().paymentMethod = 0;
    notifyListeners();
  }

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
    currentCart().paymentMethod = index;
    notifyListeners();
  }

  String returnPaymentMethod() {
    switch (currentCart().paymentMethod) {
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

  //
  //
  //
  //
  //
  //
  //
  //
  //
  //
  //
  //
  //
  //
  //
  // EDIT RECEIPT
  TempCartItem saleRecordToCartItem({
    required TempProductSaleRecord record,
    required TempProductClass product,
  }) {
    double tempRev = 0;
    if (record.customPriceSet) {
      if (record.setTotalPrice != null &&
          record.setTotalPrice == true) {
        tempRev = record.originalCost ?? 0;
      } else {
        tempRev =
            (record.originalCost ?? 0) / record.quantity;
      }
    }
    return TempCartItem(
      item: product,
      quantity: record.quantity,
      discount: 0,
      customPrice: record.customPriceSet ? tempRev : null,
      addToStock: record.addToStock ?? false,
      setCustomPrice: record.customPriceSet,
      setTotalPrice: record.setTotalPrice ?? false,
      salesRecordId: record.uuid,
    );
  }

  List<TempCartItem> convertReceiptToCartItems({
    required TempMainReceipt receipt,
    required List<TempProductSaleRecord> saleRecords,
    required BuildContext context,
  }) {
    List<TempCartItem> cartItems = [];

    for (var record in saleRecords) {
      var product = returnData(context, listen: false)
          .productList
          .where((p) => p.uuid == record.productUuid);

      if (product.isNotEmpty) {
        var newRecord = record.copy();
        if (newRecord.discount != null) {
          newRecord.revenue = newRecord.originalCost!;
          // record.discount = 0;
        }
        final cartItem = saleRecordToCartItem(
          record: newRecord,
          product: product.first,
        );
        cartItems.add(cartItem);
      } else {
        var newRecord = record.copy();
        if (newRecord.discount != null) {
          newRecord.revenue = newRecord.originalCost!;
          // record.discount = 0;
        }
        final double costPrice =
            (record.costPrice == null ||
                    record.costPrice == 0)
                ? 0
                : record.costPrice!;

        final double sellingPrice =
            record.discount == null
                ? record.revenue / record.quantity
                : (record.originalCost ?? 0) /
                    record.quantity;

        TempProductClass productNew = TempProductClass(
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
        final cartItem = saleRecordToCartItem(
          record: newRecord,
          product: productNew,
        );
        cartItems.add(cartItem);
      }
    }

    return cartItems;
  }

  onEditReceipt({
    required TempMainReceipt receipt,
    required BuildContext context,
  }) async {
    // Get all sale records for this receipt
    final saleRecords =
        returnReceiptProvider(context, listen: false)
            .produtRecordSalesMain
            .where((r) => r.receiptUuid == receipt.uuid)
            .toList();

    // Convert them back to cart items
    final cartItems = convertReceiptToCartItems(
      receipt: receipt,
      saleRecords: saleRecords,
      context: context,
    );

    // Set these as the current cart items in your provider/controller
    if (cartQueue
        .where(
          (cart) =>
              cart.receiptUuidEdit != null &&
              cart.receiptUuidEdit == receipt.uuid,
        )
        .isEmpty) {
      cartQueue.add(
        TempCart(
          fixedDiscount: receipt.fixedDiscount,
          createdDate: receipt.createdAt,
          cartItems: cartItems,
          isInvoice: receipt.isInvoice,
          discount: receipt.generalDiscount,
          receiptUuidEdit: receipt.uuid,
          paymentMethod:
              receipt.paymentMethod == 'Cash'
                  ? 0
                  : receipt.paymentMethod == 'Bank'
                  ? 1
                  : 2,
          selectedCustomer: receipt.customerUuid,
          selectedCustomerName: receipt.customerName,
          isReceiptEdit: true,
        ),
      );
      selectCart(cartQueue.indexOf(cartQueue.last));
      notifyListeners();
    } else {
      selectCart(
        cartQueue.indexOf(
          cartQueue
              .where(
                (cart) =>
                    cart.receiptUuidEdit == receipt.uuid,
              )
              .first,
        ),
      );
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return MakeSalesPage(isMain: true);
        },
      ),
    );
  }

  Future<dynamic> cancelReceiptEdit(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return ConfirmationAlert(
          theme: returnTheme(context, listen: false),
          message:
              'You are currently editing this receipt, are you sure you want to cancel this edit?',
          title: 'Cancel Edit?',
          action: () {
            if (currentCart().isReceiptEdit) {
              var recId =
                  returnSalesProvider(
                    context,
                    listen: false,
                  ).currentCart().receiptUuidEdit;
              if (cartQueue.length == 1) {
                addNewCart();
              }

              deleteCart(cartIndex);
              selectCart(0);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return ReceiptPage(
                      receiptUuid: recId!,
                      isMain: true,
                    );
                  },
                ),
              );
            } else {
              Navigator.of(context).pop();
            }
          },
        );
      },
    );
  }
}

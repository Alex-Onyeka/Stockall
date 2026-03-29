import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stockall/classes/checkout_response.dart';
import 'package:stockall/classes/temp_cart/temp_cart.dart';
import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_main_cart/temp_main_cart.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/classes/temp_sub_staff/temp_sub_staff.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/alt_display/alt_display.dart';
import 'package:stockall/pages/sales/make_sales/page1/make_sales_page.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SalesProvider extends ChangeNotifier {
  static final SalesProvider _instance =
      SalesProvider._internal();
  factory SalesProvider() => _instance;
  SalesProvider._internal();
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

  // List<TempCart> cartQueue = [];

  List<TempMainCart> mainCartQueue = [];

  String initCart() {
    try {
      var mainCartId = uuidGen();

      mainCartQueue.add(
        TempMainCart(cartQueue: [], mainCartId: mainCartId),
      );

      mainCartIdCache = mainCartId;

      var cartId = uuidGen();
      mainCartQueue.first.cartQueue.add(
        TempCart(
          departmentName:
              returnDepartmentProvider()
                  .currentDepartment()
                  ?.name,
          departmentUuid:
              returnDepartmentProvider()
                  .currentDepartment()
                  ?.uuid,
          staffId: currentUser().userId,
          staffName:
              "${currentUser().name} ${currentUser().lastName}",
          cartItems: [],
          isInvoice: false,
          id: cartId,
        ),
      );
      cartIdCache = cartId;

      notifyListeners();
      return cartId;
    } catch (e) {
      print('Error Initializing Cart: ${e.toString()}');
      return '';
    }
  }

  bool isSubStaffSelectionMobileOpen = false;

  void toggleSubStaffSelectionMobile(bool value) {
    isSubStaffSelectionMobileOpen = value;
    notifyListeners();
  }

  void selectFistMainCart() {
    selectMainCart(mainCartQueue.first.mainCartId!);
    toggleSubStaffSelectionMobile(false);
    notifyListeners();
  }

  String cartIdCache = '';
  String mainCartIdCache = '';

  TempMainCart currentMainCart() {
    return mainCartQueue.firstWhere(
      (cart) => cart.mainCartId == mainCartIdCache,
    );
  }

  TempSubStaff? selectedSubStaff;
  void selectSubStaff({TempSubStaff? staff}) {
    selectedSubStaff = staff;
    notifyListeners();
  }

  void addSubStaffToMainCart(String mainCartId) {
    mainCartQueue
        .firstWhere((c) => c.mainCartId == mainCartId)
        .subStaff = selectedSubStaff;
    print(
      'Added: ${mainCartQueue.firstWhere((c) => c.mainCartId == mainCartId).subStaff?.staffName}',
    );
    notifyListeners();
  }

  void removeStaffFromMainCart(String mainCartId) {
    mainCartQueue
        .firstWhere((c) => c.mainCartId == mainCartId)
        .subStaff = null;
    print(
      'Removed: ${mainCartQueue.firstWhere((c) => c.mainCartId == mainCartId).subStaff?.staffName}',
    );
    notifyListeners();
  }

  Future<void> addNewMainCart(BuildContext context) async {
    SalesAuthAction().numberOfCartsAction(
      context: context,
      action: () async {
        try {
          var mainCartId = uuidGen();

          mainCartQueue.add(
            TempMainCart(
              cartQueue: [],
              mainCartId: mainCartId,
            ),
          );

          mainCartIdCache = mainCartId;

          var cartId = uuidGen();
          mainCartQueue
              .firstWhere((c) => c.mainCartId == mainCartId)
              .cartQueue
              .add(
                TempCart(
                  departmentName:
                      returnDepartmentProvider()
                          .currentDepartment()
                          ?.name,
                  departmentUuid:
                      returnDepartmentProvider()
                          .currentDepartment()
                          ?.uuid,
                  staffId: currentUser().userId,
                  staffName:
                      "${currentUser().name} ${currentUser().lastName}",
                  cartItems: [],
                  isInvoice: false,
                  id: cartId,
                ),
              );
          cartIdCache = cartId;
          await returnMultiDisplayProvider().createWindow(
            cartId: cartId,
          );

          notifyListeners();
          print(
            "Main Cart Length: ${mainCartQueue.length}",
          );
          print(
            'Cart Queue Length: ${mainCartQueue.firstWhere((c) => c.mainCartId == mainCartId).cartQueue.length}',
          );
        } catch (e) {
          print(
            'Error Creating New Main Cart: ${e.toString()}',
          );
        }

        notifyListeners();
      },
    );
  }

  TempCart currentCart() {
    return currentMainCart().cartQueue.firstWhere(
      (cart) => cart.id == cartIdCache,
    );
  }

  void updateCurrentCartName(String id, String name) {
    var cart = currentMainCart().cartQueue.firstWhere(
      (car) => car.id == id,
    );
    cart.cartName = name.isNotEmpty ? name : null;
    notifyListeners();
  }

  Future<void> addNewCart(
    BuildContext context,
    TempCart tempCart,
  ) async {
    SalesAuthAction().numberOfCartsAction(
      context: context,
      action: () async {
        var newId = uuidGen();
        tempCart.id = newId;
        currentMainCart().cartQueue.add(tempCart);
        cartIdCache = newId;
        await returnMultiDisplayProvider().createWindow(
          cartId: newId,
        );
        print(currentMainCart().cartQueue);
        notifyListeners();
      },
    );
  }

  TempCart getTempCartByCartId(String cartId) {
    var cartItem =
        currentMainCart().cartQueue
            .where((cart) => cart.id == cartId)
            .first;
    return cartItem;
  }

  TempCart getTempCartByIndex(int index) {
    var cartItem = currentMainCart().cartQueue[index];
    return cartItem;
  }

  TempMainCart getTempMainCartByIndex(int index) {
    var mainCartItem = mainCartQueue[index];
    return mainCartItem;
  }

  int getIndexOfMainCartItem(String cartId) {
    var mainCartItem = mainCartQueue.indexWhere(
      (cart) => cart.mainCartId == cartId,
    );
    return mainCartItem;
  }

  int getIndexOfCartItem(String cartId) {
    var cartItem = currentMainCart().cartQueue.indexWhere(
      (cart) => cart.id == cartId,
    );
    return cartItem;
  }

  Future<void> deleteMainCart(String cartId) async {
    if (getIndexOfMainCartItem(cartId) == 0) {
      var newCartId = getTempMainCartByIndex(1).mainCartId!;
      await selectMainCart(newCartId);
    } else {
      var newCartId =
          getTempMainCartByIndex(
            getIndexOfMainCartItem(cartId) - 1,
          ).mainCartId!;
      await selectMainCart(newCartId);
    }
    var id =
        mainCartQueue
            .firstWhere((c) => c.mainCartId == cartId)
            .cartQueue
            .first
            .id;
    mainCartQueue.removeWhere(
      (cart) => cart.mainCartId == cartId,
    );

    await returnMultiDisplayProvider().closeWindow(
      cartId: id!,
    );

    notifyListeners();
  }

  Future<void> deleteCart(String cartId) async {
    if (getIndexOfCartItem(cartId) == 0) {
      var newCartId = getTempCartByIndex(1).id!;
      await selectCart(newCartId);
    } else {
      var newCartId =
          getTempCartByIndex(
            getIndexOfCartItem(cartId) - 1,
          ).id!;
      await selectCart(newCartId);
    }
    currentMainCart().cartQueue.removeWhere(
      (cart) => cart.id == cartId,
    );
    await returnMultiDisplayProvider().closeWindow(
      cartId: cartId,
    );

    notifyListeners();
  }

  Future<void> selectMainCart(String cartId) async {
    try {
      mainCartIdCache = cartId;
      var id =
          mainCartQueue
              .firstWhere((c) => c.mainCartId == cartId)
              .cartQueue
              .first
              .id;
      selectCart(id!);
      notifyListeners();
    } catch (e) {
      print("Error Selecting main Cart: ${e.toString()}");
    }
  }

  Future<void> selectCart(String cartId) async {
    cartIdCache = cartId;
    // if (cartQueue.length > 1) {
    await returnMultiDisplayProvider().selectWindow(
      cartId: cartId,
      cartIndex: (getIndexOfCartItem(cartId) + 1),
    );
    // }
    print(returnMultiDisplayProvider().windows.length);
    notifyListeners();
  }

  Future<void> createWindow() async {
    try {
      returnMultiDisplayProvider().deleteWindow(
        cartIdCache,
      );
      await returnMultiDisplayProvider().createWindow(
        cartId: cartIdCache,
        newCartIndex: (getIndexOfCartItem(cartIdCache) + 1),
      );
    } catch (e) {
      print('An Error Occured: ${e.toString()}');
    }
  }

  List<TempSubStaff> createdStaffs = [];

  final FocusNode scanBarcodeCartPageNode = FocusNode();

  void addListenerScanBarcode() {
    scanBarcodeCartPageNode.addListener(keepBarcodeFocused);
  }

  Timer? _timer;

  void removeListenerScanBarcode() {
    _timer?.cancel(); // prevent duplicates

    _timer = Timer.periodic(
      const Duration(milliseconds: 200),
      (t) {
        if (scanBarcodeCartPageNode.hasFocus) {
          print('Cart Page Node Still Has Listener');
          unfocusScanBarcodeCartPage();
          scanBarcodeCartPageNode.removeListener(
            keepBarcodeFocused,
          );
        } else {
          print('Cart Page Node Listener Cancelled');
          t.cancel(); // cancel this timer instance
          _timer = null; // clear reference
        }
      },
    );
  }

  void requestFocusScanBarcode() {
    scanBarcodeCartPageNode.requestFocus();
  }

  void unfocusScanBarcodeCartPage() {
    scanBarcodeCartPageNode.unfocus();
  }

  void keepBarcodeFocused() {
    if (!scanBarcodeCartPageNode.hasFocus) {
      scanBarcodeCartPageNode.requestFocus();
    }
  }

  void switchInvoiceSale({
    required bool value,
    required BuildContext context,
  }) {
    if (value) {
      SalesAuthAction().invoiceManagementAction(
        context: context,
        action: () {
          currentCart().isInvoice = value;
          notifyListeners();
        },
      );
    } else {
      currentCart().isInvoice = value;
      notifyListeners();
    }
  }

  bool addToStock = false;
  void toggleAddToStock(bool value, BuildContext context) {
    if (value) {
      SalesAuthAction().addItemToStockAfterSaleAction(
        context: context,
        action: () {
          addToStock = value;
          notifyListeners();
        },
      );
    } else {
      addToStock = value;
      notifyListeners();
    }
  }

  // bool useWholeSalePrice = false;
  void toggleWholeSale({
    required BuildContext context,
    required TempCartItem cartItem,
  }) {
    ItemsAuthAction().toggleSetWholeSaleAction(
      context: context,
      action: () {
        cartItem.useWholeSalePrice =
            !cartItem.useWholeSalePrice;
        notifyListeners();
      },
    );
  }

  // void offInvoice() {
  //   currentCart().isInvoice = false;
  //   notifyListeners();
  // }

  // void onInvoice() {
  //   currentCart().isInvoice = true;
  //   notifyListeners();
  // }

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

  double
  calcSalesRecalcFixedDiscountPercentageAmountcordRevenue({
    // required double receiptOriginalCost,
    required double fixedDiscountAmount,
    required double itemCost,
  }) {
    double itemPercent =
        ((fixedDiscountAmount * 100) / calcSubTotal());
    print("Item Percent: $itemPercent");
    double result = ((itemPercent * itemCost) / 100);
    print("Result $result");
    return result;
  }

  void addFixedDiscount(double? discount) {
    currentCart().fixedDiscount = discount;
    currentCart().discount = null;
    // var disc = (((discount ?? 0) / calcSubTotal()) * 100);
    for (var item in currentCart().cartItems) {
      item.discount = null;
      item.fixedDiscount =
          calcSalesRecalcFixedDiscountPercentageAmountcordRevenue(
            fixedDiscountAmount: (discount ?? 0),
            itemCost: item.totalCost(),
          );
      print(
        "General Fixed ${item.item.name}: ${item.fixedDiscount}  ${item.revenue()}",
      );
    }
    print(currentCart().fixedDiscount);
    print(currentCart().discount);
    returnMultiDisplayProvider().updateWindow(
      cartClass: AltCartClass(
        cartId: currentCart().id!,
        currency: returnShopProvider().userShop()!.currency,
        cartItems:
            currentCart().cartItems.reversed.toList(),
        vat:
            returnShopProvider().userShop()!.applyVAT!
                ? vat
                : 0,
        fixedDiscount: currentCart().fixedDiscount,
        percentDiscount: currentCart().discount,
      ),
    );
    notifyListeners();
  }

  void addPercentageDiscount(double? discount) {
    currentCart().discount = discount;
    currentCart().fixedDiscount = null;
    for (var item in currentCart().cartItems) {
      item.discount = discount;
      item.fixedDiscount = null;
      print(
        "${item.item.name}: ${item.discount} ${item.revenue()}",
      );
    }
    returnMultiDisplayProvider().updateWindow(
      cartClass: AltCartClass(
        cartId: currentCart().id!,
        currency: returnShopProvider().userShop()!.currency,
        cartItems:
            currentCart().cartItems.reversed.toList(),
        vat:
            returnShopProvider().userShop()!.applyVAT!
                ? vat
                : 0,
        fixedDiscount: currentCart().fixedDiscount,
        percentDiscount: currentCart().discount,
      ),
    );
    notifyListeners();
  }

  void addAnyDiscount() {
    if (currentCart().discount != null) {
      addPercentageDiscount(currentCart().discount);
    }
    if (currentCart().fixedDiscount != null) {
      addFixedDiscount(currentCart().fixedDiscount);
    }
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

  void toggleSetDiscount(bool value, BuildContext context) {
    if (value) {
      SalesAuthAction().applyDiscountAction(
        context: context,
        action: () {
          currentCart().isSettingDiscountOpen = value;
          print(currentCart().isSettingDiscountOpen);
          notifyListeners();
        },
      );
    } else {
      currentCart().isSettingDiscountOpen = value;
      print(currentCart().isSettingDiscountOpen);
      notifyListeners();
    }
  }

  final SupabaseClient supabase = Supabase.instance.client;
  final ConnectivityProvider connectivity =
      ConnectivityProvider();

  double calcSalesRecordRevenue({
    required double invoceTotalAmount,
    required double receiptPayment,
    required double salesRecodRevenue,
  }) {
    double paymentPercent =
        ((receiptPayment * 100) / invoceTotalAmount);
    double result =
        (paymentPercent * salesRecodRevenue) / 100;
    return result;
  }

  double getTotalMainRevenueInvoice({
    TempInvoice? invoice,
  }) {
    if (invoice != null) {
      var total = ((invoice.bank + invoice.cashAlt));

      return total;
    } else {
      return 0;
    }
  }

  Future<CheckoutResponse?> checkoutMain({
    required BuildContext context,
    required TempCart salesCartItem,
    // required String staffId,
    // required String staffName,
    required int shopId,
    required String paymentMethod,
    required double cashAlt,
    required double bank,
    double? partPayment,
    // int? customerId,
    String? customerUuid,
    String? customerName,
  }) async {
    bool isOnline = await connectivity.isOnline();
    final createdAt =
        currentCart().createdDate?.toUtc() ??
        DateTime.now().toUtc();

    if (currentCart().isInvoice) {
      print('Current Sale is Invoice');
      TempInvoice invoice = TempInvoice(
        departmentName:
            returnDepartmentProvider()
                .currentDepartment()
                ?.name,
        departmentUuidNew:
            returnDepartmentProvider()
                .currentDepartment()
                ?.uuid,
        createdAt: createdAt,
        shopId: shopId,
        staffId: salesCartItem.staffId!, // staffId,
        staffName: salesCartItem.staffName!, // staffName,
        paymentMethod: paymentMethod,
        bank: bank,
        cashAlt: cashAlt,
        customerName: customerName,
        customerUuid: customerUuid,
        uuid: currentCart().invoiceUuidEdit ?? uuidGen(),
        generalDiscount: currentCart().discount,
        fixedDiscount: currentCart().fixedDiscount,
        vat:
            returnShopProvider().userShop()?.applyVAT ==
                    true
                ? vat
                : null,
        originalCost: calcSubTotal(),
        subStaffUuid:
            currentCart().subStaffUuid ??
            currentMainCart().subStaff?.uuid,
      );
      TempInvoice? invoiceRes;
      try {
        if (currentCart().invoiceUuidEdit != null) {
          print(
            'Invoice UUid is not null: ${currentCart().invoiceUuidEdit}',
          );
          try {
            await returnInvoicesProvider().deleteInvoice(
              invoice,
              [],
            );
            await returnEventsLogProvider().createLog(
              returnEventsLogProvider().invoiceAdapter(
                invoice,
                salesCartItem.cartItems
                    .map((item) => item.item.name)
                    .toList(),
                2,
              ),
            );
          } catch (e) {
            print(
              'Error Deleting Invoice: ${e.toString()}',
            );
            return null;
          }
        } else {
          await returnEventsLogProvider().createLog(
            returnEventsLogProvider().invoiceAdapter(
              invoice,
              salesCartItem.cartItems
                  .map((item) => item.item.name)
                  .toList(),
              1,
            ),
          );
          print('Invoice Uuid is null');
        }
        invoiceRes = await returnInvoicesProvider()
            .createInvoices(invoice);
        print('Invoice Created Success');
      } catch (e) {
        print('Error Creating Invoice: ${e.toString()}');
        return null;
      }

      try {
        String? receiptUuid;

        double? partPaymentValue(String meth) {
          if (paymentMethod == meth) {
            return partPayment;
          } else {
            return null;
          }
        }

        if (partPayment != null && partPayment != 0) {
          receiptUuid = uuidGen();

          TempMainReceipt receipt = TempMainReceipt(
            departmentName:
                returnDepartmentProvider()
                    .currentDepartment()
                    ?.name,
            departmentUuidNew:
                returnDepartmentProvider()
                    .currentDepartment()
                    ?.uuid,
            createdAt: createdAt,
            shopId: shopId,
            staffId: salesCartItem.staffId!, // staffId,
            staffName:
                salesCartItem.staffName!, // staffName,
            paymentMethod: paymentMethod,
            bank: partPaymentValue('Bank') ?? bank,
            cashAlt: partPaymentValue('Cash') ?? cashAlt,
            isInvoice: true, //salesCartItem.isInvoice,
            customerName: customerName,
            customerUuid: customerUuid,
            invoiceUuid: invoiceRes?.uuid,
            uuid: receiptUuid,
            generalDiscount: currentCart().discount,
            fixedDiscount: currentCart().fixedDiscount,
            vat:
                returnShopProvider().userShop()?.applyVAT ==
                        true
                    ? vat
                    : null,
            originalCost: calcSubTotal(),
            balance: calcFinalTotal() - partPayment,
            subStaffUuid:
                currentCart().subStaffUuid ??
                currentMainCart().subStaff?.uuid,
          );

          print('Checkout Started');
          await returnReceiptProvider(
            // ignore: use_build_context_synchronously
            context,
            listen: false,
          ).createReceipt(receipt);
          print('Receipt Created');

          await returnEventsLogProvider().createLog(
            returnEventsLogProvider().receiptAdapter(
              receipt,
              salesCartItem.cartItems
                  .map((item) => item.item.name)
                  .toList(),
              1,
            ),
          );

          final productSaleRecords =
              salesCartItem.cartItems.map((cartItem) {
                final product = cartItem.item;

                print(
                  'Sales Record For Receipt about to be Created',
                );

                return TempProductSaleRecord(
                  customPriceSet: cartItem.setCustomPrice,
                  useWholeSalePrice:
                      cartItem.useWholeSalePrice,
                  createdAt: createdAt,
                  productId: product.id ?? 0,
                  productUuid: product.uuid,
                  productName: product.name,
                  shopId: product.shopId,
                  staffId:
                      salesCartItem.staffId!, // staffId,
                  staffName:
                      salesCartItem
                          .staffName!, // staffName,
                  customerUuid: customerUuid,
                  customerName: customerName,
                  recepitId: 0,
                  receiptUuid: receiptUuid,
                  quantity: cartItem.quantity,
                  revenue: calcSalesRecordRevenue(
                    invoceTotalAmount:
                        getTotalMainRevenueInvoice(
                          invoice: invoiceRes,
                        ),
                    receiptPayment: partPayment,
                    salesRecodRevenue: cartItem.revenue(),
                  ),
                  discountedAmount: cartItem.discountCost(),
                  originalCost: cartItem.totalCost(),
                  discount:
                      cartItem.discount ??
                      cartItem.item.discount,
                  fixedDiscount: cartItem.fixedDiscount,
                  costPrice: cartItem.costPrice(),
                  addToStock: cartItem.addToStock,
                  departmentName:
                      cartItem.item.departmentName ??
                      returnDepartmentProvider()
                          .currentDepartment()
                          ?.name,
                  departmentUuid:
                      cartItem.item.departmentUuid ??
                      returnDepartmentProvider()
                          .currentDepartment()
                          ?.uuid,
                  uuid: cartItem.salesRecordId ?? uuidGen(),
                  isProductManaged: cartItem.item.isManaged,
                  setTotalPrice: cartItem.setTotalPrice,
                  unit: cartItem.item.unit,
                  // invoiceUuid: invoiceRes?.uuid,
                );
              }).toList();

          if (context.mounted) {
            print('Creating Record Sales About to Start');
            await returnReceiptProvider(
              context,
              listen: false,
            ).createProductSaleRecord(productSaleRecords);
          }
          print('Sales Record Inserted');
        }

        try {
          // Step 2: Create product sale records
          final productSaleRecords =
              salesCartItem.cartItems.map((cartItem) {
                final product = cartItem.item;

                print('Sales Record about to be Created');

                return TempProductSaleRecord(
                  customPriceSet: cartItem.setCustomPrice,
                  useWholeSalePrice:
                      cartItem.useWholeSalePrice,
                  createdAt: createdAt,
                  productId: product.id ?? 0,
                  productUuid: product.uuid,
                  productName: product.name,
                  shopId: product.shopId,
                  staffId:
                      salesCartItem.staffId!, // staffId,
                  staffName:
                      salesCartItem
                          .staffName!, // staffName,
                  customerUuid: customerUuid,
                  customerName: customerName,
                  recepitId: 0,
                  // receiptUuid: receiptUuid,
                  quantity: cartItem.quantity,
                  revenue: cartItem.revenue(),
                  discountedAmount: cartItem.discountCost(),
                  originalCost: cartItem.totalCost(),
                  discount:
                      cartItem.discount ??
                      cartItem.item.discount,
                  fixedDiscount: cartItem.fixedDiscount,
                  costPrice: cartItem.costPrice(),
                  addToStock: cartItem.addToStock,
                  departmentName:
                      cartItem.item.departmentName ??
                      returnDepartmentProvider()
                          .currentDepartment()
                          ?.name,
                  departmentUuid:
                      cartItem.item.departmentUuid ??
                      returnDepartmentProvider()
                          .currentDepartment()
                          ?.uuid,
                  uuid: cartItem.salesRecordId ?? uuidGen(),
                  isProductManaged: cartItem.item.isManaged,
                  setTotalPrice: cartItem.setTotalPrice,
                  invoiceUuid: invoiceRes?.uuid,
                  unit: cartItem.item.unit,
                );
              }).toList();

          if (context.mounted) {
            print('Creating Record Sales About to Start');
            await returnReceiptProvider(
              context,
              listen: false,
            ).createProductSaleRecord(productSaleRecords);
          }
          print('Sales Record Inserted');

          try {
            // Step 3: Decrement quantity via RPC
            for (final cartItem
                in salesCartItem.cartItems) {
              if (((cartItem.item.quantity ?? 0) > 0) &&
                  cartItem.item.isManaged) {
                if (isOnline) {
                  await supabase.rpc(
                    'decrement_product_quantity_new',
                    params: {
                      'p_product_uuid': cartItem.item.uuid,
                      'p_quantity':
                          cartItem.quantity.toInt(),
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

            try {
              print('Products Decrementation Done');

              // Step 4: Create new product for items with addToStock == true
              for (final record in productSaleRecords) {
                // ignore: use_build_context_synchronously
                if (record.addToStock == true &&
                    // ignore: use_build_context_synchronously
                    returnData()
                        .productList()
                        .where(
                          (pro) =>
                              pro.name ==
                              record.productName,
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

                  final double wholeSalePrice =
                      record.discount == null
                          ? record.revenue / record.quantity
                          : (record.originalCost ?? 0) /
                              record.quantity;

                  TempProductClass
                  product = TempProductClass(
                    groupUnit: 'Others',
                    qttyPerGroup: null,
                    name: record.productName,
                    unit: 'Others',
                    isRefundable: false,
                    costPrice: costPrice,
                    shopId: record.shopId,
                    setCustomPrice: true,
                    isManaged: false,
                    barcode: null,
                    brand: null,
                    categoryUuid: null,
                    color: null,
                    createdAt: DateTime.now(),
                    departmentUuid: record.departmentUuid,
                    departmentName: record.departmentName,
                    discount: null,
                    endDate: null,
                    expiryDate: null,
                    lowQtty: 10,
                    quantity: null,
                    sellingPrice: sellingPrice,
                    wholeSalePrice: wholeSalePrice,
                    size: null,
                    sizeType: null,
                    startDate: null,
                    updatedAt: DateTime.now(),
                    uuid: uuidGen(),
                  );
                  if (context.mounted) {
                    await returnData().createProduct(
                      product,
                      context,
                    );
                  } else {
                    print(
                      'Context Not Mounted to Created New Product',
                    );
                  }
                }
              }
              // Step 5: Reset state
              // resetPaymentMethod();
              currentMainCart().cartQueue.length > 1
                  ? await deleteCart(cartIdCache)
                  : await clearCart();

              if (context.mounted) {
                returnCustomers(
                  context,
                  listen: false,
                ).clearSelectedCustomer(context);
                await returnReceiptProvider(
                  context,
                  listen: false,
                ).loadReceipts(shopId);
                if (context.mounted) {
                  returnNavProvider(
                    context,
                    listen: false,
                  ).navigate(0);
                }
              }
              notifyListeners();
              return CheckoutResponse(
                resUuid: invoiceRes!.uuid!,
                isReceipt: false,
              );
            } catch (e) {
              print('Error Step 4: ${e.toString()}');
              return null;
            }
          } catch (e) {
            print('Error Step 3: ${e.toString()}');
            return null;
          }
        } catch (e) {
          print('Error Step 2: ${e.toString()}');
          return null;
        }
      } catch (e) {
        print('Error Step 1: ${e.toString()}');
        return null;
      }
    } else {
      print('Current Sale is Receipt');
      print("Percent Discount: ${currentCart().discount}");
      print(
        'Fixed Discount: ${currentCart().fixedDiscount}',
      );
      final uuid =
          currentCart().receiptUuidEdit ?? uuidGen();
      TempMainReceipt receipt = TempMainReceipt(
        departmentName:
            returnDepartmentProvider()
                .currentDepartment()
                ?.name,
        departmentUuidNew:
            returnDepartmentProvider()
                .currentDepartment()
                ?.uuid,
        createdAt: createdAt,
        shopId: shopId,
        staffId: salesCartItem.staffId!, // staffId,
        staffName: salesCartItem.staffName!, // staffName,
        paymentMethod: paymentMethod,
        bank: bank,
        cashAlt: cashAlt,
        isInvoice: salesCartItem.isInvoice,
        customerName: customerName,
        customerUuid: customerUuid,
        uuid: uuid,
        generalDiscount: currentCart().discount,
        fixedDiscount: currentCart().fixedDiscount,
        vat:
            returnShopProvider().userShop()?.applyVAT ==
                    true
                ? vat
                : null,
        originalCost: calcSubTotal(),
        balance: null,
        subStaffUuid: currentMainCart().subStaff?.uuid,
      );
      if (currentCart().receiptUuidEdit != null) {
        print(
          'Receipt UUid is not null: ${currentCart().receiptUuidEdit}',
        );
        try {
          await returnReceiptProvider(
            // ignore: use_build_context_synchronously
            context,
            listen: false,
          ).deleteReceipt(receipt, []);
          await returnEventsLogProvider().createLog(
            returnEventsLogProvider().receiptAdapter(
              receipt,
              salesCartItem.cartItems
                  .map((item) => item.item.name)
                  .toList(),
              2,
            ),
          );
        } catch (e) {
          print('Error Deleting Receipt: ${e.toString()}');
          return null;
        }
      } else {
        await returnEventsLogProvider().createLog(
          returnEventsLogProvider().receiptAdapter(
            receipt,
            salesCartItem.cartItems
                .map((item) => item.item.name)
                .toList(),
            1,
          ),
        );
        print('Receipt Uuid is null');
      }

      print('Checkout Started');

      try {
        final receiptRes = await returnReceiptProvider(
          // ignore: use_build_context_synchronously
          context,
          listen: false,
        ).createReceipt(receipt);
        print('Receipt Created');

        final receiptId = receiptRes!.id;
        final receiptUuid = receiptRes.uuid;
        // print(receiptId);
        // print(receiptUuid);

        try {
          // Step 2: Create product sale records
          final productSaleRecords =
              salesCartItem.cartItems.map((cartItem) {
                final product = cartItem.item;

                print('Sales Record about to be Created');

                return TempProductSaleRecord(
                  customPriceSet: cartItem.setCustomPrice,
                  useWholeSalePrice:
                      cartItem.useWholeSalePrice,
                  createdAt: createdAt,
                  productId: product.id ?? 0,
                  productUuid: product.uuid,
                  productName: product.name,
                  shopId: product.shopId,
                  staffId:
                      salesCartItem.staffId!, // staffId,
                  staffName:
                      salesCartItem
                          .staffName!, // staffName,
                  customerUuid: customerUuid,
                  customerName: customerName,
                  recepitId: receiptId ?? 0,
                  receiptUuid: receiptUuid,
                  quantity: cartItem.quantity,
                  revenue: cartItem.revenue(),
                  discountedAmount: cartItem.discountCost(),
                  originalCost: cartItem.totalCost(),
                  discount:
                      cartItem.discount ??
                      cartItem.item.discount,
                  fixedDiscount: cartItem.fixedDiscount,
                  costPrice: cartItem.costPrice(),
                  addToStock: cartItem.addToStock,
                  departmentName:
                      cartItem.item.departmentName ??
                      returnDepartmentProvider()
                          .currentDepartment()
                          ?.name,
                  departmentUuid:
                      cartItem.item.departmentUuid ??
                      returnDepartmentProvider()
                          .currentDepartment()
                          ?.uuid,
                  uuid: cartItem.salesRecordId ?? uuidGen(),
                  isProductManaged: cartItem.item.isManaged,
                  setTotalPrice: cartItem.setTotalPrice,
                  unit: cartItem.item.unit,
                );
              }).toList();

          if (context.mounted) {
            print('Creating Record Sales About to Start');
            await returnReceiptProvider(
              context,
              listen: false,
            ).createProductSaleRecord(productSaleRecords);
          }
          print('Sales Record Inserted');

          try {
            // Step 3: Decrement quantity via RPC
            for (final cartItem
                in salesCartItem.cartItems) {
              if (((cartItem.item.quantity ?? 0) > 0) &&
                  cartItem.item.isManaged) {
                if (isOnline) {
                  await supabase.rpc(
                    'decrement_product_quantity_new',
                    params: {
                      'p_product_uuid': cartItem.item.uuid,
                      'p_quantity':
                          cartItem.quantity.toInt(),
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

            try {
              print('Products Decrementation Done');

              // Step 4: Create new product for items with addToStock == true
              for (final record in productSaleRecords) {
                if (record.addToStock == true &&
                    returnData()
                        .productList()
                        .where(
                          (pro) =>
                              pro.name ==
                              record.productName,
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

                  final double wholeSalePrice =
                      record.discount == null
                          ? record.revenue / record.quantity
                          : (record.originalCost ?? 0) /
                              record.quantity;

                  TempProductClass
                  product = TempProductClass(
                    groupUnit: 'Others',
                    qttyPerGroup: null,
                    name: record.productName,
                    unit: 'Others',
                    isRefundable: false,
                    costPrice: costPrice,
                    shopId: record.shopId,
                    setCustomPrice: true,
                    isManaged: false,
                    barcode: null,
                    brand: null,
                    categoryUuid: null,
                    color: null,
                    createdAt: DateTime.now(),
                    departmentUuid: record.departmentUuid,
                    departmentName: record.departmentName,
                    discount: null,
                    endDate: null,
                    expiryDate: null,
                    lowQtty: 10,
                    quantity: null,
                    sellingPrice: sellingPrice,
                    wholeSalePrice: wholeSalePrice,
                    size: null,
                    sizeType: null,
                    startDate: null,
                    updatedAt: DateTime.now(),
                    uuid: uuidGen(),
                  );
                  if (context.mounted) {
                    await returnData().createProduct(
                      product,
                      context,
                    );
                  } else {
                    print(
                      'Context Not Mounted to Created New Product',
                    );
                  }
                }
              }
              // Step 5: Reset state
              // resetPaymentMethod();
              currentMainCart().cartQueue.length > 1
                  ? await deleteCart(cartIdCache)
                  : await clearCart();

              if (context.mounted) {
                returnCustomers(
                  context,
                  listen: false,
                ).clearSelectedCustomer(context);
                await returnReceiptProvider(
                  context,
                  listen: false,
                ).loadReceipts(shopId);
                if (context.mounted) {
                  returnNavProvider(
                    context,
                    listen: false,
                  ).navigate(0);
                }
              }
              notifyListeners();
              return CheckoutResponse(
                resUuid: receipt.uuid!,
                isReceipt: true,
              );
            } catch (e) {
              print('Error Step 4: ${e.toString()}');
              await returnReceiptProvider(
                // ignore: use_build_context_synchronously
                context,
                listen: false,
              ).deleteReceipt(
                receipt,
                productSaleRecords
                    .map((rec) => rec.productName)
                    .toList(),
              );
              return null;
            }
          } catch (e) {
            print('Error Step 3: ${e.toString()}');
            await returnReceiptProvider(
              // ignore: use_build_context_synchronously
              context,
              listen: false,
            ).deleteReceiptWithoutUpdatingInventory(
              receiptUuid!,
            );
            return null;
          }
        } catch (e) {
          print('Error Step 2: ${e.toString()}');
          await returnReceiptProvider(
            // ignore: use_build_context_synchronously
            context,
            listen: false,
          ).deleteReceipt(receipt, []);
          return null;
        }
      } catch (e) {
        print('Error Step 1: ${e.toString()}');
        return null;
      }
    }
  }

  Future<void> clearCart() async {
    currentCart().cartItems.clear();
    currentCart().isInvoice = false;
    currentCart().selectedCustomer = null;
    currentCart().selectedCustomerName = null;
    currentCart().paymentMethod = 0;
    currentCart().discount = null;
    currentCart().fixedDiscount = null;
    await returnMultiDisplayProvider().updateWindow(
      cartClass: AltCartClass(
        cartId: currentCart().id!,
        currency: returnShopProvider().userShop()!.currency,
        cartItems:
            currentCart().cartItems.reversed.toList(),
        fixedDiscount: currentCart().fixedDiscount,
        percentDiscount: currentCart().fixedDiscount,
        vat:
            returnShopProvider().userShop()!.applyVAT!
                ? vat
                : 0,
      ),
    );
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

  double calcDiscountMain() {
    if (currentCart().fixedDiscount != null) {
      return currentCart().fixedDiscount ?? 0;
    } else if (currentCart().discount != null) {
      return calcSubTotal() *
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

  double calcVatAmount() {
    double tempTotal = 0;
    for (var item in currentCart().cartItems) {
      tempTotal +=
          (item.totalCost() *
              (returnShopProvider().getVat() / 100));
    }
    return tempTotal;
  }

  double calcSubTotal() {
    double tempTotal = 0;
    for (var item in currentCart().cartItems) {
      tempTotal += item.totalCost();
    }
    return tempTotal;
  }

  double calcFinalTotal() {
    return ((calcSubTotal() - calcDiscountMain()) +
        calcVatAmount());
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

  // bool useWholeSalePriceTempEdit = false;

  // bool isSetWholeSalePrice(TempCartItem cartItem) {
  //   return cartItem.useWholeSalePrice;
  // }

  // void toggleSetWholeSalePrice(TempCartItem cartItem) {
  //   currentCart().cartItems.firstWhere((cart) => cart.item)
  //   notifyListeners();
  // }

  // void closeWholeSalePrice() {
  //   currentCart().setWholeSalePrice = false;
  //   notifyListeners();
  // }

  //
  //
  //
  //

  bool canAddProductToCart({
    required TempProductClass product,
    required double quantityToAdd,
  }) {
    double totalInAllCarts = 0;
    for (final cart in currentMainCart().cartQueue) {
      for (final cartItem in cart.cartItems) {
        if (cartItem.item.uuid == product.uuid) {
          totalInAllCarts += cartItem.quantity;
        }
      }
    }
    double newTotal = totalInAllCarts + quantityToAdd;
    double availableQty = product.quantity ?? 0;
    if (newTotal > availableQty &&
        returnData().productList().contains(product) &&
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

  Future<String> addItemToCart({
    required BuildContext context,
    required TempCartItem newItem,
    required bool isCustomEdit,
  }) async {
    if (canAddProductToCart(
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
        item.quantity = newItem.quantity;
        item.setCustomPrice = newItem.setCustomPrice;
        item.setTotalPrice = newItem.setTotalPrice;
        item.item.unit = newItem.item.unit;
        await returnMultiDisplayProvider().updateWindow(
          cartClass: AltCartClass(
            cartId: currentCart().id!,
            currency:
                returnShopProvider().userShop()!.currency,
            cartItems:
                currentCart().cartItems.reversed.toList(),
            fixedDiscount: currentCart().fixedDiscount,
            percentDiscount: currentCart().discount,
            vat:
                returnShopProvider().userShop()!.applyVAT!
                    ? vat
                    : 0,
          ),
        );
        notifyListeners();
      } else {
        if (index != -1) {
          currentCart().cartItems[index].discount;
          currentCart().cartItems[index].quantity +=
              newItem.quantity;
          await returnMultiDisplayProvider().updateWindow(
            cartClass: AltCartClass(
              cartId: currentCart().id!,
              currency:
                  returnShopProvider().userShop()!.currency,
              cartItems:
                  currentCart().cartItems.reversed.toList(),
              fixedDiscount: currentCart().fixedDiscount,
              percentDiscount: currentCart().discount,
              vat:
                  returnShopProvider().userShop()!.applyVAT!
                      ? vat
                      : 0,
            ),
          );
          notifyListeners();
          result = 'Item Updated Successfully';
        } else {
          currentCart().cartItems.add(newItem);
          await returnMultiDisplayProvider().updateWindow(
            cartClass: AltCartClass(
              cartId: currentCart().id!,
              currency:
                  returnShopProvider().userShop()!.currency,
              cartItems:
                  currentCart().cartItems.reversed.toList(),
              fixedDiscount: currentCart().fixedDiscount,
              percentDiscount: currentCart().discount,
              vat:
                  returnShopProvider().userShop()!.applyVAT!
                      ? vat
                      : 0,
            ),
          );
          notifyListeners();
          result = 'Item Added Successfully';
        }
      }
      addAnyDiscount();

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
      return "Quantity Limit Exceeded";
    }
  }

  void editCartItemQuantity({
    required TempCartItem cartItem,
    required double number,
    double? customPrice,
    required bool setTotalPrice,
    required bool setCustomPrice,
  }) async {
    cartItem.quantity = number;
    cartItem.customPrice = customPrice;
    cartItem.setTotalPrice = setTotalPrice;
    cartItem.setCustomPrice = setCustomPrice;
    await returnMultiDisplayProvider().updateWindow(
      cartClass: AltCartClass(
        cartId: currentCart().id!,
        currency: returnShopProvider().userShop()!.currency,
        cartItems:
            currentCart().cartItems.reversed.toList(),
        fixedDiscount: currentCart().fixedDiscount,
        percentDiscount: currentCart().discount,
        vat:
            returnShopProvider().userShop()!.applyVAT!
                ? vat
                : 0,
      ),
    );
    notifyListeners();
  }

  Future<void> removeItemFromCart(
    TempCartItem item,
    BuildContext context,
  ) async {
    currentCart().cartItems.remove(item);
    print(
      "Main Carts Length: ${currentMainCart().cartQueue.length}",
    );
    print(
      "Current Cart Length: ${currentCart().cartItems.length}",
    );
    await returnMultiDisplayProvider().updateWindow(
      cartClass: AltCartClass(
        cartId: currentCart().id!,
        currency: returnShopProvider().userShop()!.currency,
        cartItems:
            currentCart().cartItems.reversed.toList(),
        fixedDiscount: currentCart().fixedDiscount,
        percentDiscount: currentCart().discount,
        vat:
            returnShopProvider().userShop()!.applyVAT!
                ? vat
                : 0,
      ),
    );
    addAnyDiscount();
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

  void changeMethod({
    required int index,
    required BuildContext context,
  }) {
    SalesAuthAction().paymentMethodSelectionAction(
      context: context,
      action: () {
        currentCart().paymentMethod = index;
        notifyListeners();
      },
    );
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
      discount: record.discount,
      fixedDiscount: record.fixedDiscount,
      customPrice: record.customPriceSet ? tempRev : null,
      addToStock: record.addToStock ?? false,
      setCustomPrice: record.customPriceSet,
      setTotalPrice: record.setTotalPrice ?? false,
      salesRecordId: record.uuid,
      useWholeSalePrice: record.useWholeSalePrice ?? false,
    );
  }

  List<TempCartItem> convertReceiptToCartItems({
    required TempMainReceipt receipt,
    required List<TempProductSaleRecord> saleRecords,
    required BuildContext context,
  }) {
    List<TempCartItem> cartItems = [];

    for (var record in saleRecords) {
      var product = returnData().productList().where(
        (p) => p.uuid == record.productUuid,
      );

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

        final double wholeSalePrice =
            record.discount == null
                ? record.revenue / record.quantity
                : (record.originalCost ?? 0) /
                    record.quantity;

        TempProductClass productNew = TempProductClass(
          groupUnit: 'Others',
          qttyPerGroup: null,
          name: record.productName,
          unit: record.unit ?? 'Others',
          isRefundable: false,
          costPrice: costPrice,
          shopId: record.shopId,
          setCustomPrice: true,
          isManaged: false,
          barcode: null,
          brand: null,
          categoryUuid: null,
          color: null,
          createdAt: DateTime.now(),
          departmentUuid: record.departmentUuid,
          departmentName: record.departmentName,
          discount: null,
          endDate: null,
          expiryDate: null,
          lowQtty: 10,
          quantity: null,
          sellingPrice: sellingPrice,
          wholeSalePrice: wholeSalePrice,
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

  Future<void> onEditReceipt({
    required TempMainReceipt receipt,
    required BuildContext context,
  }) async {
    SalesAuthAction().editReceiptAction(
      context: context,
      action: () async {
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

        if (currentMainCart().cartQueue
            .where(
              (cart) =>
                  cart.receiptUuidEdit != null &&
                  cart.receiptUuidEdit == receipt.uuid,
            )
            .isEmpty) {
          var newId = uuidGen();
          var tempCart = TempCart(
            departmentName: receipt.departmentName,
            departmentUuid: receipt.departmentUuidNew,
            subStaffUuid: receipt.subStaffUuid,
            staffId: receipt.staffId,
            staffName: receipt.staffName,
            id: newId,
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
          );
          await addNewCart(context, tempCart);
          await returnMultiDisplayProvider().updateWindow(
            cartClass: AltCartClass(
              cartId: tempCart.id!,
              cartItems:
                  tempCart.cartItems.reversed.toList(),
              fixedDiscount: currentCart().fixedDiscount,
              percentDiscount: currentCart().discount,
              vat: receipt.vat ?? 0,
              currency:
                  returnShopProvider().userShop()!.currency,
            ),
          );
          notifyListeners();
        } else {
          await selectCart(
            currentMainCart().cartQueue
                .where(
                  (cart) =>
                      cart.receiptUuidEdit == receipt.uuid,
                )
                .first
                .id!,
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
      },
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
          action: () async {
            if (currentCart().isReceiptEdit) {
              if (currentMainCart().cartQueue.length == 1) {
                await addNewCart(
                  context,
                  TempCart(
                    departmentName:
                        returnDepartmentProvider()
                            .currentDepartment()
                            ?.name,
                    departmentUuid:
                        returnDepartmentProvider()
                            .currentDepartment()
                            ?.uuid,
                    cartItems: [],
                    isInvoice: false,
                    staffId: currentUser().userId,
                    staffName:
                        "${currentUser().name} ${currentUser().lastName}",
                  ),
                );
              }

              await deleteCart(cartIdCache);
              // await selectCart(cartIndex - 1);
              notifyListeners();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pop();
            }
          },
        );
      },
    );
  }
}

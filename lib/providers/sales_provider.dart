import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stockall/classes/checkout_response.dart';
import 'package:stockall/classes/payment_entry/payment_entry.dart';
import 'package:stockall/classes/temp_cart/temp_cart.dart';
import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_drafts/drafts.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/classes/temp_item_history/item_history_event_class.dart';
import 'package:stockall/classes/temp_main_cart/temp_main_cart.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_orders/order_items.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/classes/temp_product_class/prices_class/product_prices_class.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/classes/temp_sub_staff/temp_sub_staff.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/generate_barcode.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/local_database/cart_func/cart_func.dart';
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

  bool openCategory = false;
  void toggleCategory() {
    openCategory = !openCategory;
    notifyListeners();
  }

  // List<TempCart> cartQueue = [];

  bool checkIfCartExists(String cartId) {
    for (var cart in mainCartQueue) {
      for (var ca in cart.cartQueue) {
        if (ca.id == cartId) {
          return true;
        }
      }
    }
    return false;
  }

  List<TempMainCart> mainCartQueue = [];

  Future<String> fetchMainCart() async {
    try {
      mainCartQueue = CartFunc().getMainCart();
      await mainLocalLog(
        'Main Carts Gotten: ${mainCartQueue.length}',
      );
      if (mainCartQueue.isNotEmpty) {
        if (mainCartIdCache.isEmpty ||
            mainCartQueue
                .where(
                  (mainC) =>
                      mainC.mainCartId == mainCartIdCache,
                )
                .isEmpty) {
          mainCartIdCache = mainCartQueue.first.mainCartId!;
        }
        if (cartIdCache.isEmpty ||
            !checkIfCartExists(cartIdCache)) {
          cartIdCache =
              mainCartQueue.first.cartQueue.first.id!;
        }
        notifyListeners();
        return cartIdCache;
        // }
      } else {
        return await initCart();
      }
    } catch (e) {
      await mainLocalLog(
        'Error Fetching Main Cart: ${e.toString()}',
      );
      // await CartFunc().clearMainCart();
      notifyListeners();
      return await initCart();
    }
  }

  Future<void> deleteAllCarts() async {
    await CartFunc().clearMainCart();
    mainCartQueue.clear();
    mainCartIdCache = '';
    cartIdCache = '';
    notifyListeners();
  }

  Future<String> initCart() async {
    try {
      var mainCartId = uuidGen();
      await mainLocalLog('Main Cart Id: $mainCartId');
      await mainLocalLog(
        'Main Cart Length: ${mainCartQueue.length}',
      );
      await CartFunc().createMainCart(
        TempMainCart(cartQueue: [], mainCartId: mainCartId),
      );
      mainCartIdCache = mainCartId;
      var cartId = uuidGen();
      await mainLocalLog('Normal Cart Id: $cartId');
      await CartFunc().updateMainCart(
        TempMainCart(
          cartQueue: [
            TempCart(
              tempCartItems: null,
              comment: null,
              timeOfDay: null,
              hasPrintedDocket: false,
              subStaffName: null,
              customDate: null,
              departmentName: null,
              departmentUuid: null,
              staffId: currentUser().userId,
              staffName:
                  "${currentUser().name} ${currentUser().lastName}",
              cartItems: [],
              cartItemTypeIndex: 1,
              id: cartId,
              orderUuidEdit: null,
            ),
          ],
          mainCartId: mainCartId,
        ),
      );
      cartIdCache = cartId;
      await mainLocalLog(
        'Normal Cart Id Cached: $cartIdCache',
      );
      fetchMainCart();
      notifyListeners();
      return cartId;
    } catch (e) {
      await mainLocalLog(
        'Error Initializing Cart: ${e.toString()}',
      );
      await CartFunc().clearMainCart();
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

  Future<void> addSubStaffToMainCart(
    String mainCartId,
  ) async {
    var res = mainCartQueue.firstWhere(
      (c) => c.mainCartId == mainCartId,
    );
    res.subStaff = selectedSubStaff;
    await CartFunc().updateMainCart(res);
    await mainLocalLog(
      'Added: ${mainCartQueue.firstWhere((c) => c.mainCartId == mainCartId).subStaff?.staffName}',
    );
    notifyListeners();
  }

  Future<void> removeStaffFromMainCart(
    String mainCartId,
  ) async {
    var res = mainCartQueue.firstWhere(
      (c) => c.mainCartId == mainCartId,
    );
    res.subStaff = null;
    await CartFunc().updateMainCart(res);
    await mainLocalLog(
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

          await CartFunc().createMainCart(
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
                  tempCartItems: null,
                  comment: null,
                  timeOfDay: null,
                  // createdDate: DateTime.now(),
                  hasPrintedDocket: false,
                  subStaffName: null,
                  customDate: null,
                  departmentName: null,
                  departmentUuid: null,
                  staffId: currentUser().userId,
                  staffName:
                      "${currentUser().name} ${currentUser().lastName}",
                  cartItems: [],
                  cartItemTypeIndex: 1,
                  id: cartId,
                  orderUuidEdit: null,
                ),
              );
          await CartFunc().updateMainCart(
            mainCartQueue.firstWhere(
              (c) => c.mainCartId == mainCartId,
            ),
          );
          cartIdCache = cartId;
          await returnMultiDisplayProvider().createWindow(
            cartId: cartId,
          );

          notifyListeners();
          // await mainLocalLog(
          //   "Main Cart Length: ${mainCartQueue.length}",
          // );
          // await mainLocalLog(
          //   'Cart Queue Length: ${mainCartQueue.firstWhere((c) => c.mainCartId == mainCartId).cartQueue.length}',
          // );
        } catch (e) {
          await mainLocalLog(
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

  void updateCurrentCart(TempCart cart) {
    currentCart().cartItems = cart.cartItems;
    currentCart().id = cart.id;
    currentCart().isInvoice = cart.isInvoice;
    currentCart().selectedCustomer = cart.selectedCustomer;
    currentCart().selectedCustomerName =
        cart.selectedCustomerName;
    currentCart().paymentMethod = cart.paymentMethod;
    currentCart().discount = cart.discount;
    currentCart().isReceiptEdit = cart.isReceiptEdit;
    currentCart().receiptUuidEdit = cart.receiptUuidEdit;
    currentCart().invoiceUuidEdit = cart.invoiceUuidEdit;
    currentCart().createdDate = cart.createdDate;
    currentCart().setCustomPrice = cart.setCustomPrice;
    currentCart().fixedDiscount = cart.fixedDiscount;
    currentCart().isSettingDiscountOpen =
        cart.isSettingDiscountOpen;
    currentCart().cartName = cart.cartName;
    currentCart().subStaffUuid = cart.subStaffUuid;
    currentCart().staffName = cart.staffName;
    currentCart().staffId = cart.staffId;
    currentCart().departmentUuid = cart.departmentUuid;
    currentCart().departmentName = cart.departmentName;
    currentCart().customDate = cart.customDate;
    currentCart().hasPrintedDocket = cart.hasPrintedDocket;
    currentCart().subStaffName = cart.subStaffName;
    currentCart().timeOfDay = cart.timeOfDay;
    currentCart().comment = cart.comment;
    currentCart().cartItemTypeIndex =
        cart.cartItemTypeIndex;
    currentCart().orderUuidEdit = cart.orderUuidEdit;
    currentCart().orderUuid = cart.orderUuid;
    currentCart().splitPayments = cart.splitPayments;
    currentCart().draftUuid = cart.draftUuid;
  }

  Future<void> updateCurrentCartItem(
    TempCartItem cartItem,
  ) async {
    List<TempCartItem> temps =
        currentCart().cartItems
            .where((item) => item.uuid == cartItem.uuid)
            .toList();
    if (temps.isNotEmpty) {
      var tempItem = temps.first;
      tempItem.item = cartItem.item;
      tempItem.itemUuid = cartItem.itemUuid;
      tempItem.quantity = cartItem.quantity;
      tempItem.discount = cartItem.discount;
      tempItem.fixedDiscount = cartItem.fixedDiscount;
      tempItem.customPrice = cartItem.customPrice;
      tempItem.setCustomPrice = cartItem.setCustomPrice;
      tempItem.addToStock = cartItem.addToStock;
      tempItem.setTotalPrice = cartItem.setTotalPrice;
      tempItem.useWholeSalePrice =
          cartItem.useWholeSalePrice;
      tempItem.salesRecordId = cartItem.salesRecordId;
      tempItem.useGroupQuantity = cartItem.useGroupQuantity;
      tempItem.qttyPerGroup = cartItem.qttyPerGroup;
      tempItem.isVoid = cartItem.isVoid;
      tempItem.uuid = cartItem.uuid;
      tempItem.remainingQuantity =
          cartItem.remainingQuantity;
      tempItem.unitUuid = cartItem.unitUuid;
      tempItem.remainingBalance = cartItem.remainingBalance;
      tempItem.priceUuid = cartItem.priceUuid;
      tempItem.widthDimension = cartItem.widthDimension;
      tempItem.heightDimension = cartItem.heightDimension;
    } else {
      await mainLocalLog('Couldn\'t Find Cart Item');
    }
  }

  Future<void> updateCurrentCartName(
    String id,
    String name,
  ) async {
    var cart = currentMainCart().cartQueue.firstWhere(
      (car) => car.id == id,
    );
    cart.cartName = name.isNotEmpty ? name : null;
    await CartFunc().updateMainCart(currentMainCart());
    notifyListeners();
  }

  Future<void> updateCurrentCartIsPrintedDocket() async {
    var cart = currentMainCart().cartQueue.firstWhere(
      (car) => car.id == currentCart().id,
    );
    cart.hasPrintedDocket = true;
    await CartFunc().updateMainCart(currentMainCart());
    notifyListeners();
  }

  Future<void> updateReceiptCreatedDate({
    DateTime? createdDate,
  }) async {
    var cart = currentMainCart().cartQueue.firstWhere(
      (car) => car.id == currentCart().id,
    );
    if (createdDate != null) {
      cart.customDate = DateTime(
        createdDate.year,
        createdDate.month,
        createdDate.day,
      );
    } else {
      cart.customDate = null;
    }
    await CartFunc().updateMainCart(currentMainCart());
    notifyListeners();
  }

  Future<void> updateReceiptCreatedTime(
  // String id,
  {TimeOfDay? timeOfDay}) async {
    var cart = currentMainCart().cartQueue.firstWhere(
      (car) => car.id == currentCart().id,
    );
    if (timeOfDay != null) {
      cart.timeOfDay = TimeOfDay(
        hour: timeOfDay.hour,
        minute: timeOfDay.minute,
      );
    } else {
      cart.timeOfDay = null;
    }
    await CartFunc().updateMainCart(currentMainCart());
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
        await CartFunc().updateMainCart(currentMainCart());
        await returnMultiDisplayProvider().createWindow(
          cartId: newId,
        );
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

  bool canDeleteMainCart({required TempMainCart cartMain}) {
    if (returnShopProvider().userShop()?.trackCart ==
        true) {
      for (var cart in cartMain.cartQueue) {
        if (cart.cartItems.isNotEmpty) {
          return false;
        }
      }
      return true;
    } else {
      return true;
    }
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
    await CartFunc().deleteMainCart(cartId);

    await returnMultiDisplayProvider().closeWindow(
      cartId: id!,
    );

    notifyListeners();
  }

  // Void lines are only a record of removed items, so they never block.
  ({TempMainCart mainCart, TempCart cart})?
  firstNonEmptyCart() {
    for (var mainCart in mainCartQueue) {
      for (var cart in mainCart.cartQueue) {
        if (cart.getCartItems().isNotEmpty) {
          return (mainCart: mainCart, cart: cart);
        }
      }
    }
    return null;
  }

  bool isEmptyCart() => firstNonEmptyCart() == null;

  String mainCartLabel(TempMainCart mainCart) {
    return mainCart.cartName() ??
        'Default ${mainCartQueue.indexOf(mainCart) + 1}';
  }

  Future<void> jumpToCart({
    required String mainCartId,
    required String cartId,
  }) async {
    mainCartIdCache = mainCartId;
    await selectCart(cartId);
  }

  Future<void> deleteCart({
    required String cartId,
    required BuildContext context,
  }) async {
    if (currentMainCart().cartQueue.length > 1) {
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
      await CartFunc().updateMainCart(currentMainCart());
      await returnMultiDisplayProvider().closeWindow(
        cartId: cartId,
      );

      notifyListeners();
    } else {
      // await CartFunc().updateMainCart(currentMainCart());
      currentMainCart().cartQueue.removeWhere(
        (cart) => cart.id == cartId,
      );
      await addNewCart(
        context,
        TempCart(
          tempCartItems: null,
          comment: null,
          timeOfDay: null,
          // createdDate: DateTime.now(),
          hasPrintedDocket: false,
          subStaffName: null,
          customDate: null,
          departmentName: null,
          departmentUuid: null,
          staffId: currentUser().userId,
          staffName:
              "${currentUser().name} ${currentUser().lastName}",
          cartItems: [],
          cartItemTypeIndex: 1,
          id: uuidGen(),
          orderUuidEdit: null,
        ),
      );
      try {
        await returnMultiDisplayProvider().closeWindow(
          cartId: cartId,
        );
        await mainLocalLog('🙌🙌🙌💕😢Window Closed');
      } catch (e) {
        await mainLocalLog(
          '❌❌❌❌❌😂Error Closing Window: ${e.toString()}',
        );
      }
    }
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
      await selectCart(id!);
      notifyListeners();
    } catch (e) {
      await mainLocalLog(
        "Error Selecting main Cart: ${e.toString()}",
      );
    }
  }

  Future<void> selectCart(String cartId) async {
    cartIdCache = cartId;
    var cartClass = AltCartClass(
      manageCustomerReward:
          returnShopProvider()
              .userShop()!
              .manageCustomerReward ??
          false,
      cashBack:
          returnShopProvider()
              .userShop()!
              .customerPercentageReward,
      cartId: currentCart().id!,
      cartItems:
          currentCart().getCartItemsAll().reversed.toList(),
      fixedDiscount: currentCart().fixedDiscount,
      percentDiscount: currentCart().discount,
      vat:
          returnShopProvider().userShop()?.applyVAT == true
              ? vat
              : 0,
      currency: returnShopProvider().userShop()!.currency,
    );
    // if (cartQueue.length > 1) {
    await returnMultiDisplayProvider().selectWindow(
      cartId: cartId,
      cartClass: cartClass,
      cartIndex: (getIndexOfCartItem(cartId) + 1),
    );
    notifyListeners();
    // if (currentCart().receiptUuidEdit == null) {
    //   currentCart().departmentUuid =
    //       returnDepartmentProvider()
    //           .currentDepartment()
    //           ?.uuid;
    //   currentCart().departmentName =
    //       returnDepartmentProvider()
    //           .currentDepartment()
    //           ?.name;
    // }
    // }
    await mainLocalLog(
      returnMultiDisplayProvider().windows.length
          .toString(),
    );
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
      await mainLocalLog(
        'An Error Occured: ${e.toString()}',
      );
    }
  }

  List<TempSubStaff> createdStaffs = [];

  final FocusNode scanBarcodeCartPageNode = FocusNode();

  // void addListenerScanBarcode() {
  //   scanBarcodeCartPageNode.addListener(keepBarcodeFocused);
  // }

  // Timer? _timer;

  // void removeListenerScanBarcode() {
  //   _timer?.cancel(); // prevent duplicates

  //   _timer = Timer.periodic(
  //     const Duration(milliseconds: 200),
  //     (t) {
  //       if (scanBarcodeCartPageNode.hasFocus) {
  //         await mainLocalLog('Cart Page Node Still Has Listener');
  //         unfocusScanBarcodeCartPage();
  //         scanBarcodeCartPageNode.removeListener(
  //           keepBarcodeFocused,
  //         );
  //       } else {
  //         await mainLocalLog('Cart Page Node Listener Cancelled');
  //         t.cancel(); // cancel this timer instance
  //         _timer = null; // clear reference
  //       }
  //     },
  //   );
  // }

  void requestFocusScanBarcode() {
    scanBarcodeCartPageNode.requestFocus();
  }

  // Orders (3) and Drafts (4) don't consume stock.
  bool isStockFreeCartType(int? cartItemTypeIndex) {
    return cartItemTypeIndex == 3 || cartItemTypeIndex == 4;
  }

  TempProductClass? getStockConflictForCartSwitch() {
    final Map<String, CartItemConflictClass> cartItems = {};

    final currentCartType = currentCart().cartItemTypeIndex;

    for (final mainCart in mainCartQueue) {
      for (final cart in mainCart.cartQueue) {
        if (isStockFreeCartType(currentCartType) &&
            isStockFreeCartType(cart.cartItemTypeIndex) &&
            cart != currentCart()) {
          continue;
        }

        if (!isStockFreeCartType(currentCartType) &&
            isStockFreeCartType(cart.cartItemTypeIndex)) {
          continue;
        }

        for (final cartItem in cart.getCartItems()) {
          final itemUuid =
              cartItem.itemUuid ?? cartItem.item.uuid;

          if (itemUuid == null) {
            continue;
          }

          final quantity = cartItem.getRealQuantity();

          final existing = cartItems[itemUuid];

          cartItems[itemUuid] = CartItemConflictClass(
            uuid: itemUuid,
            quantity: (existing?.quantity ?? 0) + quantity,
            isExpired:
                existing?.isExpired ??
                cartItem.item.isExpiredReal(),
          );
        }
      }
    }

    for (final conflict in cartItems.values) {
      final product =
          returnData().productListMain
              .where((item) => item.uuid == conflict.uuid)
              .firstOrNull;

      // Custom item — no stock restriction.
      if (product == null) {
        continue;
      }

      // Unmanaged product — no stock restriction.
      if (!product.isManaged) {
        continue;
      }

      final availableQuantity =
          product.getActualQuantity() ?? 0;

      if (conflict.quantity > availableQuantity) {
        final existsInCurrentCart = currentCart()
            .getCartItems()
            .any(
              (item) =>
                  (item.itemUuid ?? item.item.uuid) ==
                  product.uuid,
            );

        if (existsInCurrentCart) {
          return product;
        }
      }

      // Expired item
      if (conflict.isExpired) {
        final existsInCurrentCart = currentCart()
            .getCartItems()
            .any(
              (item) =>
                  (item.itemUuid ?? item.item.uuid) ==
                  product.uuid,
            );

        if (existsInCurrentCart) {
          return product;
        }
      }
    }

    return null;
  }

  void switchInvoiceSale({
    required int value,
    required BuildContext context,
  }) {
    if (value == 4 && !currentCart().canUseDraft()) {
      return;
    }

    if (isStockFreeCartType(
          currentCart().cartItemTypeIndex,
        ) &&
        (value == 1 || value == 2)) {
      final conflict = getStockConflictForCartSwitch();

      if (conflict != null) {
        if (conflict.isExpiredReal()) {
          showDialog(
            context: context,
            builder: (errorContext) {
              return InfoAlert(
                theme: returnTheme(context, listen: false),
                message:
                    'Product: [ ${conflict.name} ] is Expired '
                    'Please Remove This Item From Cart Or Proceed to '
                    'Turn off Is-Managed for this item '
                    'before switching Sale Type.',
                title: 'Item Expired',
              );
            },
          );
        } else {
          showDialog(
            context: context,
            builder: (errorContext) {
              return InfoAlert(
                theme: returnTheme(context, listen: false),
                message:
                    'Product: [ ${conflict.name} ] has a quantity '
                    'that exceeds the available stock. '
                    'Please reduce the quantity or remove this item '
                    'before switching Sale Type.',
                title: 'Insufficient Stock',
              );
            },
          );
        }

        return;
      }
    }

    void performAction() {
      currentCart().cartItemTypeIndex = value;
      CartFunc().updateMainCart(currentMainCart());
      notifyListeners();
    }

    if (value == 2) {
      SalesAuthAction().invoiceManagementAction(
        context: context,
        action: performAction,
      );
    } else if (value == 3) {
      SalesAuthAction().manageOrdersAction(
        context: context,
        action: performAction,
      );
    } else {
      performAction();
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

  void toggleGroupQuantity({
    required BuildContext context,
    required TempCartItem cartItem,
  }) {
    ItemsAuthAction().toggleSetWholeSaleAction(
      context: context,
      action: () async {
        cartItem.useGroupQuantity =
            !(cartItem.useGroupQuantity ?? false);
        await CartFunc().updateMainCart(currentMainCart());
        notifyListeners();
      },
    );
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

  double
  calcSalesRecalcFixedDiscountPercentageAmountcordRevenue({
    // required double receiptOriginalCost,
    required double fixedDiscountAmount,
    required double itemCost,
  }) {
    double itemPercent =
        ((fixedDiscountAmount * 100) / calcSubTotal());
    mainLocalLog("Item Percent: $itemPercent");
    double result = ((itemPercent * itemCost) / 100);
    mainLocalLog("Result $result");
    return result;
  }

  void addFixedDiscount(double? discount) {
    currentCart().fixedDiscount = discount;
    currentCart().discount = null;
    // var disc = (((discount ?? 0) / calcSubTotal()) * 100);
    for (var item in currentCart().getCartItems()) {
      item.discount = null;
      item.fixedDiscount =
          calcSalesRecalcFixedDiscountPercentageAmountcordRevenue(
            fixedDiscountAmount: (discount ?? 0),
            itemCost: item.totalCost(),
          );
      // await mainLocalLog(
      //   "General Fixed ${item.item.name}: ${item.fixedDiscount}  ${item.revenue()}",
      // );
    }
    //  mainLocalLog(currentCart().fixedDiscount);
    //  mainLocalLog(currentCart().discount);
    CartFunc().updateMainCart(currentMainCart());
    returnMultiDisplayProvider().updateWindow(
      cartClass: AltCartClass(
        manageCustomerReward:
            returnShopProvider()
                .userShop()!
                .manageCustomerReward ??
            false,
        cashBack:
            returnShopProvider()
                .userShop()!
                .customerPercentageReward,
        cartId: currentCart().id!,
        currency: returnShopProvider().userShop()!.currency,
        cartItems:
            currentCart()
                .getCartItemsAll()
                .reversed
                .toList(),
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
    for (var item in currentCart().getCartItems()) {
      item.discount = discount;
      item.fixedDiscount = null;
      // await mainLocalLog(
      //   "${item.item.name}: ${item.discount} ${item.revenue()}",
      // );
    }
    CartFunc().updateMainCart(currentMainCart());
    returnMultiDisplayProvider().updateWindow(
      cartClass: AltCartClass(
        manageCustomerReward:
            returnShopProvider()
                .userShop()!
                .manageCustomerReward ??
            false,
        cashBack:
            returnShopProvider()
                .userShop()!
                .customerPercentageReward,
        cartId: currentCart().id!,
        currency: returnShopProvider().userShop()!.currency,
        cartItems:
            currentCart()
                .getCartItemsAll()
                .reversed
                .toList(),
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
    CartFunc().updateMainCart(currentMainCart());
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
          mainLocalLog(
            currentCart().isSettingDiscountOpen.toString(),
          );
          notifyListeners();
        },
      );
    } else {
      currentCart().isSettingDiscountOpen = value;
      mainLocalLog(
        currentCart().isSettingDiscountOpen.toString(),
      );
      notifyListeners();
    }
    CartFunc().updateMainCart(currentMainCart());
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

  String staffName() {
    if (currentCart().invoiceUuidEdit != null) {
      return currentCart().staffName ??
          "${currentUser().name} ${currentUser().lastName}";
    } else {
      return "${currentUser().name} ${currentUser().lastName}";
    }
  }

  String staffUuid() {
    if (currentCart().invoiceUuidEdit != null) {
      return currentCart().staffId ??
          currentUser().userId ??
          'Not Set';
    } else {
      return currentUser().userId ?? 'Not Set';
    }
  }

  String? customerName() {
    return currentCart().selectedCustomerName;
  }

  String? customerUuid() {
    return currentCart().selectedCustomer;
  }

  String? departmentName() {
    if (currentCart().invoiceUuidEdit != null) {
      return currentCart().departmentName ??
          returnDepartmentProvider()
              .currentDepartment()
              ?.name;
    } else {
      return returnDepartmentProvider()
          .currentDepartment()
          ?.name;
    }
  }

  String? departmentUuid() {
    if (currentCart().invoiceUuidEdit != null) {
      return currentCart().departmentUuid ??
          returnDepartmentProvider()
              .currentDepartment()
              ?.uuid;
    } else {
      return returnDepartmentProvider()
          .currentDepartment()
          ?.uuid;
    }
  }

  // One sale line per cart line. The same list is saved to
  // product_sales and to the receipt's or invoice's items.
  List<TempProductSaleRecord> buildSaleRecords({
    required List<TempCartItem> cartItems,
    required DateTime createdAt,
    required int shopId,
    required String staffId,
    required String staffName,
    required String? customerUuid,
    required String? customerName,
    required String? departmentName,
    required String? departmentUuid,
    int receiptId = 0,
    String? receiptUuid,
    String? invoiceUuid,
  }) {
    return cartItems.map((cartItem) {
      final product = cartItem.getItem();
      return TempProductSaleRecord(
        heightDimension: cartItem.heightDimension,
        quantityType: cartItem.quantityType,
        widthDimension: cartItem.widthDimension,
        priceUuid: cartItem.priceUuid,
        pricesList: cartItem.getPriceListFinal(),
        unitUuid: cartItem.unitUuid,
        unitsList: cartItem.getUnitListFinal(),
        isVoid: cartItem.isVoid ?? false,
        qttyPerGroup: cartItem.qttyPerGroup,
        useGroupQuantity: cartItem.useGroupQuantity,
        customPriceSet: cartItem.setCustomPrice,
        useWholeSalePrice: cartItem.useWholeSalePrice,
        createdAt: createdAt,
        productId: product?.id ?? 0,
        productUuid: product?.uuid,
        productName: product?.name ?? 'Item Name',
        shopId: product?.shopId ?? shopId,
        staffId: staffId,
        staffName: staffName,
        customerUuid: customerUuid,
        customerName: customerName,
        recepitId: receiptId,
        receiptUuid: receiptUuid,
        quantity: cartItem.quantity,
        revenue: cartItem.revenue(),
        discountedAmount: cartItem.discountCost(),
        originalCost: cartItem.totalCost(),
        discount:
            cartItem.discount ??
            cartItem.getItem()?.discount,
        fixedDiscount: cartItem.fixedDiscount,
        costPrice: cartItem.costPrice(),
        addToStock: cartItem.addToStock,
        departmentName: departmentName,
        departmentUuid: departmentUuid,
        uuid: cartItem.uuid ?? uuidGen(),
        isProductManaged: cartItem.getItem()?.isManaged,
        setTotalPrice: cartItem.setTotalPrice,
        invoiceUuid: invoiceUuid,
        unit: cartItem.getUnit(),
      );
    }).toList();
  }

  Future<CheckoutResponse?> checkoutMain({
    required BuildContext context,
    required TempCart salesCartItem,
    required int shopId,
    required List<PaymentEntry> payments,
    double? partPayment,
  }) async {
    // Drafts are saved with saveDraft(), never checked out.
    if (currentCart().cartItemTypeIndex == 4) {
      return null;
    }

    final createdAt = currentCart().returnDate();
    final breakdown = PaymentBreakdown(payments);

    if (currentCart().cartItemTypeIndex == 1) {
      final paymentError = validatePayments(payments);
      if (paymentError != null) {
        await mainLocalLog(
          'Checkout Blocked, Invalid Payments: $paymentError',
        );
        return null;
      }
      final uuid =
          currentCart().receiptUuidEdit ??
          currentCart().id ??
          uuidGen();
      await mainLocalLog('🌹🌹 Created Date: $createdAt');
      TempMainReceipt receipt = TempMainReceipt(
        tempItems: null,
        salesTypeIndex: 1,
        orderUuid: salesCartItem.orderUuid,
        comment: currentCart().comment,
        subStaffName:
            currentCart().subStaffName ??
            currentMainCart().subStaff?.staffName,
        departmentName: departmentName(),
        departmentUuidNew: departmentUuid(),
        createdAt: createdAt,
        shopId: shopId,
        staffId: staffUuid(), // staffId,
        staffName: staffName(), // staffName,
        paymentMethod: breakdown.label,
        customerAccount: breakdown.account,
        bank: breakdown.bank,
        cashAlt: breakdown.cash,
        isInvoice: salesCartItem.cartItemTypeIndex == 2,
        customerName: customerName(),
        customerUuid: customerUuid(),
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
        cartName: currentCart().cartName,
      );
      // Built before the receipt is saved so the same lines are
      // stored in receipt.items and in product_sales.
      final productSaleRecords = buildSaleRecords(
        cartItems: salesCartItem.getCartItemsAll(),
        createdAt: createdAt,
        shopId: shopId,
        staffId: staffUuid(), // staffId,
        staffName: staffName(), // staffName,
        customerUuid: customerUuid(),
        customerName: customerName(),
        departmentName: departmentName(),
        departmentUuid: departmentUuid(),
        receiptId: receipt.id ?? 0,
        receiptUuid: receipt.uuid,
      );
      receipt.items = productSaleRecords;
      if (currentCart().receiptUuidEdit != null) {
        final tempProductSaleRecords = buildSaleRecords(
          cartItems:
              salesCartItem.tempCartItems?.toList() ?? [],
          createdAt: createdAt,
          shopId: shopId,
          staffId: staffUuid(), // staffId,
          staffName: staffName(), // staffName,
          customerUuid: customerUuid(),
          customerName: customerName(),
          departmentName: departmentName(),
          departmentUuid: departmentUuid(),
          receiptId: receipt.id ?? 0,
          receiptUuid: receipt.uuid,
        );
        receipt.tempItems = tempProductSaleRecords;
        await mainLocalLog(
          'Receipt UUid is not null: ${currentCart().receiptUuidEdit}',
        );
        try {
          await returnReceiptProvider(
            context,
            listen: false,
          ).deleteReceipt(receipt, []);
          await returnEventsLogProvider().createLog(
            returnEventsLogProvider().receiptAdapter(
              receipt,
              salesCartItem
                  .getCartItems()
                  .map(
                    (item) =>
                        item.getItem()?.name ?? 'Item Name',
                  )
                  .toList(),
              2,
            ),
          );
        } catch (e) {
          await mainLocalLog(
            'Error Deleting Receipt: ${e.toString()}',
          );
          return null;
        }
      } else {
        await returnEventsLogProvider().createLog(
          returnEventsLogProvider().receiptAdapter(
            receipt,
            salesCartItem
                .getCartItems()
                .map(
                  (item) =>
                      item.getItem()?.name ?? 'Item Name',
                )
                .toList(),
            1,
          ),
        );
        await mainLocalLog('Receipt Uuid is null');
      }

      await mainLocalLog('Checkout Started');

      try {
        receipt.tempItems = null;
        await returnReceiptProviderSingle().createReceipt(
          receipt,
        );
        await mainLocalLog('Receipt Created');

        try {
          // Step 2: Create product sale records
          for (final record in productSaleRecords) {
            mainLocalLog(
              'Sales Record about to be Created: ${record.productName}',
            );
          }

          // if (context.mounted) {
          //   await mainLocalLog(
          //     'Creating Record Sales About to Start: ${productSaleRecords.length}',
          //   );
          //   await returnReceiptProvider(
          //     context,
          //     listen: false,
          //   ).createProductSaleRecord(
          //     records: productSaleRecords,
          //     isPartPayment: false,
          //   );
          // }
          await mainLocalLog('Sales Record Inserted');

          try {
            for (final cartItem
                in salesCartItem.getCartItems()) {
              TempProductClass? mainItem;
              var products = returnData().productListMain
                  .where(
                    (item) =>
                        item.uuid == cartItem.item.uuid,
                  );
              if (products.isNotEmpty) {
                mainItem = products.first.copyWith();
              } else {
                mainItem = cartItem.item.copyWith();
              }
              if (((mainItem.getActualQuantity() ?? 0) >
                      0) &&
                  (cartItem.getItem()?.isManaged ??
                      false)) {
                // Stock math is in area for 2D items; store the
                // result back as a sheet count.
                mainItem.quantity = mainItem
                    .quantityAfterRemoving(
                      cartItem.getRealQuantity(),
                    );
                ItemHistory itemHistory = ItemHistory(
                  event: ItemHistoryEventClass.sold,
                  isManaged: cartItem.item.isManaged,
                  source:
                      ItemHistoryEventClass.receiptSource,
                  unit: cartItem.getSelectedUnit().name,
                  primaryUnit:
                      cartItem.getPrimaryUnit().name,
                  shopId: shopId,
                  desc:
                      '${cartItem.quantity} ${cartItem.getSelectedUnit().name} of This Item was Sold. Receipt Id: #${returnOnlyDigits(receipt.uuid ?? '')}',
                  isIncreased: false,

                  title: 'Item Sold In Receipt',
                  quantityChange: -cartItem.quantity,
                  newValue: formatLargeNumberDouble(
                    cartItem
                        .getPrimaryUnit()
                        .getQuantityEquivDivided(
                          index: 1,
                          newQuantity:
                              mainItem
                                  .getActualQuantity() ??
                              0,
                          product: mainItem,
                        ),
                  ),
                  oldValue: formatLargeNumberDouble(
                    (cartItem
                        .getPrimaryUnit()
                        .getQuantityEquivDivided(
                          index: 1,
                          product: mainItem,
                          newQuantity:
                              (mainItem
                                      .getActualQuantity() ??
                                  0) +
                              cartItem.getRealQuantity(),
                        )),
                  ),
                );
                await returnData().updateProduct(
                  itemHistory:
                      returnData()
                              .productList()
                              .where(
                                (pro) =>
                                    pro.name ==
                                    cartItem
                                        .getItem()
                                        ?.name,
                              )
                              .isEmpty
                          ? null
                          : itemHistory,
                  includeQuantity: false,
                  product: mainItem,
                  isQuantityUpdate: true,
                  quantityChange:
                      cartItem.getRealQuantity() /
                      mainItem.dimensionArea(),
                  isMultipleUpdate: true,
                  isIncrement: false,
                );
              } else {
                if (returnData()
                    .productList()
                    .where(
                      (pro) =>
                          pro.name ==
                          cartItem.getItem()?.name,
                    )
                    .isNotEmpty) {
                  ItemHistory itemHistory = ItemHistory(
                    event: ItemHistoryEventClass.sold,
                    isManaged: cartItem.item.isManaged,
                    source:
                        ItemHistoryEventClass.receiptSource,
                    unit: cartItem.getSelectedUnit().name,
                    primaryUnit:
                        cartItem.getPrimaryUnit().name,
                    desc:
                        '${cartItem.quantity} ${cartItem.getSelectedUnit().name} of This Item was Sold, but Not Deducted Because Item is Not Managed. Receipt Id: #${returnOnlyDigits(receipt.uuid ?? '')}',
                    shopId: shopId,
                    isIncreased: false,
                    oldValue: formatLargeNumberDouble(
                      mainItem
                          .getPrimaryUnit()
                          .getQuantityEquivDivided(
                            index: 1,
                            newQuantity:
                                (mainItem
                                        .getActualQuantity() ??
                                    0),
                          ),
                    ),
                    title:
                        'Item Sold In Receipt (Unmanaged)',
                    quantityChange: 0,
                    newValue: formatLargeNumberDouble(
                      mainItem
                          .getPrimaryUnit()
                          .getQuantityEquivDivided(
                            index: 1,
                            newQuantity:
                                (mainItem
                                        .getActualQuantity() ??
                                    0),
                          ),
                    ),
                  );
                  itemHistory.itemName = mainItem.name;
                  itemHistory.itemUuid = mainItem.uuid;
                  await returnItemHistoryProvider()
                      .createItemHistory(itemHistory);
                }
              }
            }

            try {
              await mainLocalLog(
                'Products Decrementation Done',
              );

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

                  var productUuid =
                      record.productUuid ?? uuidGen();

                  TempProductClass
                  product = TempProductClass(
                    heightDimension: record.heightDimension,
                    quantityType: record.quantityType,
                    widthDimension: record.widthDimension,
                    pricesList: [
                      ProductPricesClass(
                        uuid: uuidGen(),
                        staffUuid: currentUser().userId,
                        createdAt: createdAt,
                        staffName: currentUser().name,
                        priceValue: 0,
                        name: 'Price',
                        isPrimary: true,
                        itemUuid: productUuid,
                        priceType: 1,
                      ),
                    ],
                    unitsList: [
                      ProductUnitsClass(
                        uuid: uuidGen(),
                        staffUuid: currentUser().userId,
                        createdAt: createdAt,
                        staffName: currentUser().name,
                        conversion: 1,
                        name: 'Unit(s)',
                        isPrimary: true,
                        productUuid: productUuid,
                      ),
                    ],
                    useGroupUnit: false,
                    categories: [],
                    storageUuid: null,
                    groupUnit: 'Group(s)',
                    qttyPerGroup: null,
                    name: record.productName,
                    unit: 'Unit(s)',
                    isRefundable: false,
                    costPrice: costPrice,
                    shopId: record.shopId,
                    setCustomPrice: true,
                    isManaged: false,
                    barcode: null,
                    brand: null,
                    // categoryUuid: null,
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
                    uuid: productUuid,
                  );
                  if (context.mounted) {
                    ItemHistory itemHistory = ItemHistory(
                      event:
                          ItemHistoryEventClass.itemCreated,
                      isManaged: false,
                      source:
                          ItemHistoryEventClass
                              .receiptSource,
                      shopId: shopId,
                      title: 'Item Created',
                      quantityChange: 0,
                      newValue: '0',
                      desc: 'Item Created Now',
                      isIncreased: true,
                      oldValue: '0',
                    );
                    await returnData().createProduct(
                      isMultiple: true,
                      itemHistory: itemHistory,
                      product: product,
                    );
                  } else {
                    await mainLocalLog(
                      'Context Not Mounted to Created New Product',
                    );
                  }
                }
              }
              // Step 5: Reset state
              // resetPaymentMethod();
              try {
                await deleteCart(
                  cartId: cartIdCache,
                  context: context,
                );
              } catch (e) {
                await mainLocalLog(
                  "Error Deleting Cart Inside Checkout Function: ${e.toString()}",
                );
              }

              if (context.mounted) {
                returnCustomers(
                  context,
                  listen: false,
                ).clearSelectedCustomer(context);
                await returnReceiptProvider(
                  context,
                  listen: false,
                ).loadReceiptsOffline(shopId);
                if (context.mounted) {
                  returnNavProvider(
                    context,
                    listen: false,
                  ).navigate(0);
                }
              }
              returnData().syncData();
              notifyListeners();
              return CheckoutResponse(receipt: receipt);
            } catch (e) {
              await mainLocalLog(
                'Error Step 4: ${e.toString()}',
              );
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
            await mainLocalLog(
              'Error Step 3: ${e.toString()}',
            );
            await returnReceiptProvider(
              // ignore: use_build_context_synchronously
              context,
              listen: false,
            ).deleteReceiptWithoutUpdatingInventory(
              receipt: receipt,
            );
            return null;
          }
        } catch (e) {
          await mainLocalLog(
            'Error Step 2: ${e.toString()}',
          );
          await returnReceiptProvider(
            // ignore: use_build_context_synchronously
            context,
            listen: false,
          ).deleteReceipt(receipt, []);
          return null;
        }
      } catch (e) {
        await mainLocalLog('Error Step 1: ${e.toString()}');
        return null;
      }
    } else if (currentCart().cartItemTypeIndex == 2) {
      await mainLocalLog('Current Sale is Invoice');
      TempInvoice invoice = TempInvoice(
        tempItems: null,
        comment: currentCart().comment,
        subStaffName:
            currentCart().subStaffName ??
            currentMainCart().subStaff?.staffName,
        departmentName: departmentName(),
        departmentUuidNew: departmentUuid(),
        createdAt: createdAt,
        shopId: shopId,
        staffId: staffUuid(),
        staffName: staffName(),
        paymentMethod: breakdown.label,
        bank: breakdown.bank,
        cashAlt: breakdown.cash,
        customerName: customerName(),
        customerUuid: customerUuid(),
        uuid:
            currentCart().invoiceUuidEdit ??
            currentCart().id ??
            uuidGen(),
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
        cartName:
            currentCart().cartName ??
            'Cart ${currentMainCart().cartQueue.length + 1}',
      );
      TempInvoice? invoiceRes;
      List<TempProductSaleRecord> invoiceSaleRecords = [];
      try {
        // Built before the invoice is saved so the same lines are
        // stored in invoice.items and in product_sales.
        invoiceSaleRecords = buildSaleRecords(
          cartItems: salesCartItem.getCartItemsAll(),
          createdAt: createdAt,
          shopId: shopId,
          staffId: staffUuid(), // staffId,
          staffName: staffName(), // staffName,
          customerUuid: customerUuid(),
          customerName: customerName(),
          departmentName: departmentName(),
          departmentUuid: departmentUuid(),
          invoiceUuid: invoice.uuid,
        );

        invoice.items = invoiceSaleRecords;

        if (currentCart().invoiceUuidEdit != null) {
          final tempProductSaleRecords = buildSaleRecords(
            cartItems:
                salesCartItem.tempCartItems?.toList() ?? [],
            createdAt: createdAt,
            shopId: shopId,
            staffId: staffUuid(), // staffId,
            staffName: staffName(), // staffName,
            customerUuid: customerUuid(),
            customerName: customerName(),
            departmentName: departmentName(),
            departmentUuid: departmentUuid(),
            invoiceUuid: invoice.uuid,
          );
          invoice.tempItems = tempProductSaleRecords;
          await mainLocalLog(
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
                salesCartItem
                    .getCartItems()
                    .map(
                      (item) =>
                          item.getItem()?.name ??
                          'Item Name',
                    )
                    .toList(),
                2,
              ),
            );
          } catch (e) {
            await mainLocalLog(
              'Error Deleting Invoice: ${e.toString()}',
            );
            return null;
          }
        } else {
          await returnEventsLogProvider().createLog(
            returnEventsLogProvider().invoiceAdapter(
              invoice,
              salesCartItem
                  .getCartItems()
                  .map(
                    (item) =>
                        item.getItem()?.name ?? 'Item Name',
                  )
                  .toList(),
              1,
            ),
          );
          await mainLocalLog('Invoice Uuid is null');
        }
        invoice.tempItems = null;

        invoiceRes = await returnInvoicesProvider()
            .createInvoices(invoice);
        await mainLocalLog('Invoice Created Success');
      } catch (e) {
        await mainLocalLog(
          'Error Creating Invoice: ${e.toString()}',
        );
        return null;
      }

      try {
        String? receiptUuid;

        if (partPayment != null && partPayment != 0) {
          final productSaleRecords =
              salesCartItem.getCartItemsAll().map((
                cartItem,
              ) {
                final product = cartItem.getItem();
                return TempProductSaleRecord(
                  heightDimension: cartItem.heightDimension,
                  quantityType: cartItem.quantityType,
                  widthDimension: cartItem.widthDimension,
                  priceUuid: cartItem.priceUuid,
                  pricesList: cartItem.getPriceListFinal(),
                  unitUuid: cartItem.unitUuid,
                  unitsList: cartItem.getUnitListFinal(),
                  isVoid: cartItem.isVoid ?? false,
                  qttyPerGroup: cartItem.qttyPerGroup,
                  useGroupQuantity:
                      cartItem.useGroupQuantity,
                  customPriceSet: cartItem.setCustomPrice,
                  useWholeSalePrice:
                      cartItem.useWholeSalePrice,
                  createdAt: createdAt,
                  productId: product?.id ?? 0,
                  productUuid: product?.uuid,
                  productName: product?.name ?? 'Item Name',
                  shopId: product?.shopId ?? shopId,
                  staffId: staffUuid(), // staffId,
                  staffName: staffName(), // staffName,
                  customerUuid: customerUuid(),
                  customerName: customerName(),
                  recepitId: 0,
                  receiptUuid: receiptUuid,
                  quantity: cartItem.quantity,
                  revenue: cartItem.revenue(),
                  discountedAmount: cartItem.discountCost(),
                  originalCost: cartItem.totalCost(),
                  discount:
                      cartItem.discount ??
                      cartItem.getItem()?.discount,
                  fixedDiscount: cartItem.fixedDiscount,
                  costPrice: cartItem.costPrice(),
                  addToStock: cartItem.addToStock,
                  departmentName: departmentName(),
                  departmentUuid: departmentUuid(),
                  uuid: uuidGen(),
                  isProductManaged:
                      cartItem.getItem()?.isManaged,
                  setTotalPrice: cartItem.setTotalPrice,
                  unit: cartItem.getUnit(),
                  // invoiceUuid: invoiceRes?.uuid,
                );
              }).toList();

          await returnInvoicesProvider().makeInvoicePayment(
            bankAmount: breakdown.bank,
            cashAmount: breakdown.cash,
            customerAmount: 0,
            invoice: invoice,
            salesRecords: productSaleRecords,
            currentPayment: partPayment,
          );
        }

        try {
          // Step 2: Create product sale records
          final productSaleRecords = invoiceSaleRecords;
          for (final record in productSaleRecords) {
            mainLocalLog(
              'Sales Record about to be Created: ${record.productName}',
            );
          }

          // if (context.mounted) {
          //   await mainLocalLog(
          //     'Creating Record Sales About to Start',
          //   );
          //   // await returnReceiptProvider(
          //   //   context,
          //   //   listen: false,
          //   // ).createProductSaleRecord(
          //   //   records: productSaleRecords,
          //   //   isPartPayment: false,
          //   // );
          // }
          await mainLocalLog('Sales Record Inserted');

          try {
            // Step 3: Decrement quantity via RPC
            for (final cartItem
                in salesCartItem.getCartItems()) {
              TempProductClass? mainItem;
              var products = returnData().productListMain
                  .where(
                    (item) =>
                        item.uuid == cartItem.item.uuid,
                  );
              if (products.isNotEmpty) {
                mainItem = products.first.copyWith();
              } else {
                mainItem = cartItem.item.copyWith();
              }
              if (((mainItem.getActualQuantity() ?? 0) >
                      0) &&
                  (cartItem.getItem()?.isManaged ??
                      false)) {
                // Stock math is in area for 2D items; store the
                // result back as a sheet count.
                mainItem.quantity = mainItem
                    .quantityAfterRemoving(
                      cartItem.getRealQuantity(),
                    );
                ItemHistory itemHistory = ItemHistory(
                  event: ItemHistoryEventClass.sold,
                  isManaged: cartItem.item.isManaged,
                  source:
                      ItemHistoryEventClass.invoiceSource,
                  unit: cartItem.getSelectedUnit().name,
                  primaryUnit:
                      cartItem.getPrimaryUnit().name,
                  shopId: shopId,
                  desc:
                      '${cartItem.quantity} ${cartItem.getSelectedUnit().name} of This Item was Sold on Credit. Invoice Id: #${returnOnlyDigits(invoice.uuid ?? '')}',
                  isIncreased: false,

                  title: 'Item Sold On Credit',
                  quantityChange: -cartItem.quantity,
                  newValue: formatLargeNumberDouble(
                    cartItem
                        .getPrimaryUnit()
                        .getQuantityEquivDivided(
                          index: 1,
                          newQuantity:
                              mainItem
                                  .getActualQuantity() ??
                              0,
                          product: mainItem,
                        ),
                  ),
                  oldValue: formatLargeNumberDouble(
                    (cartItem
                        .getPrimaryUnit()
                        .getQuantityEquivDivided(
                          index: 1,
                          product: mainItem,
                          newQuantity:
                              (mainItem
                                      .getActualQuantity() ??
                                  0) +
                              cartItem.getRealQuantity(),
                        )),
                  ),
                );
                await returnData().updateProduct(
                  itemHistory:
                      returnData()
                              .productList()
                              .where(
                                (pro) =>
                                    pro.name ==
                                    cartItem
                                        .getItem()
                                        ?.name,
                              )
                              .isEmpty
                          ? null
                          : itemHistory,
                  includeQuantity: false,
                  product: mainItem,
                  isQuantityUpdate: true,
                  quantityChange:
                      cartItem.getRealQuantity() /
                      mainItem.dimensionArea(),
                  isMultipleUpdate: true,
                  isIncrement: false,
                );
              } else {
                if (returnData()
                    .productList()
                    .where(
                      (pro) =>
                          pro.name ==
                          cartItem.getItem()?.name,
                    )
                    .isNotEmpty) {
                  ItemHistory itemHistory = ItemHistory(
                    event: ItemHistoryEventClass.sold,
                    isManaged: cartItem.item.isManaged,
                    source:
                        ItemHistoryEventClass.invoiceSource,
                    unit: cartItem.getSelectedUnit().name,
                    primaryUnit:
                        cartItem.getPrimaryUnit().name,
                    desc:
                        '${cartItem.quantity} ${cartItem.getSelectedUnit().name} of This Item was Sold On Credit, but Not Deducted Because Item is Not Managed. Receipt Id: #${returnOnlyDigits(invoice.uuid ?? '')}',
                    shopId: shopId,
                    isIncreased: false,
                    oldValue: formatLargeNumberDouble(
                      mainItem
                          .getPrimaryUnit()
                          .getQuantityEquivDivided(
                            index: 1,
                            newQuantity:
                                (mainItem
                                        .getActualQuantity() ??
                                    0),
                          ),
                    ),
                    title:
                        'Item Sold On Credit (Unmanaged)',
                    quantityChange: 0,
                    newValue: formatLargeNumberDouble(
                      mainItem
                          .getPrimaryUnit()
                          .getQuantityEquivDivided(
                            index: 1,
                            newQuantity:
                                (mainItem
                                        .getActualQuantity() ??
                                    0),
                          ),
                    ),
                  );
                  itemHistory.itemName = mainItem.name;
                  itemHistory.itemUuid = mainItem.uuid;
                  await returnItemHistoryProvider()
                      .createItemHistory(itemHistory);
                }
              }
            }

            try {
              await mainLocalLog(
                'Products Decrementation Done',
              );

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
                  var productUuid =
                      record.productUuid ?? uuidGen();

                  TempProductClass
                  product = TempProductClass(
                    heightDimension: record.heightDimension,
                    quantityType: record.quantityType,
                    widthDimension: record.widthDimension,
                    pricesList: [
                      ProductPricesClass(
                        uuid: uuidGen(),
                        staffUuid: currentUser().userId,
                        createdAt: createdAt,
                        staffName: currentUser().name,
                        priceValue: 0,
                        name: 'Price',
                        isPrimary: true,
                        itemUuid: productUuid,
                        priceType: 1,
                      ),
                    ],
                    unitsList: [
                      ProductUnitsClass(
                        uuid: uuidGen(),
                        staffUuid: currentUser().userId,
                        createdAt: createdAt,
                        staffName: currentUser().name,
                        conversion: 1,
                        name: 'Unit(s)',
                        isPrimary: true,
                        productUuid: productUuid,
                      ),
                    ],
                    useGroupUnit: false,
                    categories: [],
                    storageUuid: null,
                    groupUnit: 'Group(s)',
                    qttyPerGroup: null,
                    name: record.productName,
                    unit: 'Unit(s)',
                    isRefundable: false,
                    costPrice: costPrice,
                    shopId: record.shopId,
                    setCustomPrice: true,
                    isManaged: false,
                    barcode: null,
                    brand: null,
                    // categoryUuid: null,
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
                    uuid: productUuid,
                  );
                  if (context.mounted) {
                    ItemHistory itemHistory = ItemHistory(
                      event:
                          ItemHistoryEventClass.itemCreated,
                      isManaged: false,
                      source:
                          ItemHistoryEventClass
                              .invoiceSource,
                      shopId: shopId,
                      title: 'Item Created',
                      quantityChange: 0,
                      newValue: '0',
                      desc: 'Item Created Now',
                      isIncreased: true,
                      oldValue: '0',
                    );
                    await returnData().createProduct(
                      isMultiple: true,
                      itemHistory: itemHistory,
                      product: product,
                    );
                  } else {
                    await mainLocalLog(
                      'Context Not Mounted to Created New Product',
                    );
                  }
                }
              }
              // Step 5: Reset state
              // resetPaymentMethod();
              try {
                await deleteCart(
                  cartId: cartIdCache,
                  context: context,
                );
              } catch (e) {
                await mainLocalLog(
                  "Error Deleting Cart Inside Checkout Function: ${e.toString()}",
                );
              }

              if (context.mounted) {
                returnCustomers(
                  context,
                  listen: false,
                ).clearSelectedCustomer(context);
                await returnReceiptProvider(
                  context,
                  listen: false,
                ).loadReceiptsOffline(shopId);
                if (context.mounted) {
                  returnNavProvider(
                    context,
                    listen: false,
                  ).navigate(0);
                }
              }
              notifyListeners();
              returnData().syncData();
              return CheckoutResponse(invoice: invoiceRes);
            } catch (e) {
              await mainLocalLog(
                'Error Step 4: ${e.toString()}',
              );
              return null;
            }
          } catch (e) {
            await mainLocalLog(
              'Error Step 3: ${e.toString()}',
            );
            return null;
          }
        } catch (e) {
          await mainLocalLog(
            'Error Step 2: ${e.toString()}',
          );
          return null;
        }
      } catch (e) {
        await mainLocalLog('Error Step 1: ${e.toString()}');
        return null;
      }
    } else {
      await mainLocalLog('Order Creation Begin');
      final uuid =
          currentCart().orderUuidEdit ??
          currentCart().id ??
          uuidGen();
      await mainLocalLog('🌹🌹 Created Date: $createdAt');
      Orders order = Orders(
        barcode: null,
        orderItems: [],
        updatedAt: DateTime.now(),
        comment: currentCart().comment,
        subStaffName:
            currentCart().subStaffName ??
            currentMainCart().subStaff?.staffName,
        departmentName: departmentName(),
        departmentUuid: departmentUuid(),
        createdAt: createdAt,
        shopId: shopId,
        staffId: staffUuid(), // staffId,
        staffName: staffName(), // staffName,
        customerName: customerName(),
        customerId: customerUuid(),
        uuid: uuid,
        generalDiscount: currentCart().discount,
        fixedDiscount: currentCart().fixedDiscount,
        vat:
            returnShopProvider().userShop()?.applyVAT ==
                    true
                ? vat
                : null,
        originalCost: calcSubTotal(),
        balance: calcFinalTotal(),
        subStaffUuid: currentMainCart().subStaff?.uuid,
        cartName: currentCart().cartName,
        total: calcFinalTotal(),
      );
      final orderItems =
          salesCartItem.getCartItemsAll().map((cartItem) {
            final product = cartItem.getItem();

            mainLocalLog(
              'Sales Record about to be Created: ${cartItem.getItem()?.name}',
            );

            return OrderItems(
              heightDimension: cartItem.heightDimension,
              quantityType: cartItem.quantityType,
              widthDimension: cartItem.widthDimension,
              priceUuid: cartItem.priceUuid,
              pricesList: cartItem.getPriceListFinal(),
              unitUuid: cartItem.unitUuid,
              unitsList: cartItem.getUnitListFinal(),
              originalUseGroupQuantity:
                  cartItem.getItem()?.useGroupUnit ?? false,
              remainingQuantity: cartItem.quantity,
              qttyPerGroup: cartItem.qttyPerGroup,
              useGroupQuantity: cartItem.useGroupQuantity,
              tempUseGroupQuantity:
                  cartItem.useGroupQuantity,
              customPriceSet: cartItem.setCustomPrice,
              useWholeSalePrice: cartItem.useWholeSalePrice,
              createdAt: createdAt,
              productUuid: product?.uuid ?? '',
              productName: product?.name ?? 'Item Name',
              staffId: staffUuid(), // staffId,
              staffName: staffName(), // staffName,
              customerUuid: customerUuid(),
              customerName: customerName(),
              quantity: cartItem.quantity,
              revenue:
                  (cartItem.revenue() /
                      cartItem.getRealQuantity()),
              discountedAmount: cartItem.discountCost(),
              originalCost:
                  (cartItem.totalCost() /
                      cartItem.getRealQuantity()),
              discount:
                  cartItem.discount ??
                  cartItem.getItem()?.discount,
              fixedDiscount: cartItem.fixedDiscount,
              costPrice:
                  cartItem.costPrice() == null
                      ? null
                      : ((cartItem.costPrice() ?? 0) /
                          cartItem.getRealQuantity()),
              addToStock: cartItem.addToStock,
              departmentName: departmentName(),
              departmentUuid: departmentUuid(),
              uuid: cartItem.uuid ?? uuidGen(),
              isProductManaged:
                  cartItem.getItem()?.isManaged,
              setTotalPrice: cartItem.setTotalPrice,
              unit: cartItem.getItem()?.unit ?? 'Unit(s)',
              groupUnit:
                  cartItem.getItem()?.groupUnit ??
                  'Group(s)',
              orderId: order.uuid!,
            );
          }).toList();
      order.orderItems = orderItems;
      if (currentCart().orderUuidEdit != null) {
        await mainLocalLog(
          'Order UUid is not null: ${currentCart().orderUuidEdit}',
        );
        try {
          await returnOrdersProvider().deleteOrder(
            order,
            [],
          );
        } catch (e) {
          await mainLocalLog(
            'Error Deleting Order: ${e.toString()}',
          );
          return null;
        }
      } else {
        await mainLocalLog('Order Uuid is null');
      }

      await mainLocalLog('Order Checkout Started');

      try {
        // Step 2: Create product sale records

        try {
          //
          //
          //
          //

          await returnOrdersProvider().createOrder(order);
          await mainLocalLog('Order Created');

          //
          //
          //
          //
          try {
            for (final cartItem
                in salesCartItem.getCartItems()) {
              TempProductClass? mainItem;
              var products = returnData().productListMain
                  .where(
                    (item) =>
                        item.uuid == cartItem.item.uuid,
                  );
              if (products.isNotEmpty) {
                mainItem = products.first.copyWith();
              } else {
                mainItem = cartItem.item.copyWith();
              }
              ItemHistory itemHistory = ItemHistory(
                event: ItemHistoryEventClass.sold,
                isManaged: cartItem.item.isManaged,
                source: ItemHistoryEventClass.orderSource,
                unit: cartItem.getSelectedUnit().name,
                primaryUnit: cartItem.getPrimaryUnit().name,
                desc:
                    '${cartItem.quantity} ${cartItem.getSelectedUnit().name} of This Item was Ordered for, but Not Deducted. Order Id: #${returnOnlyDigits(order.uuid ?? '')}',
                shopId: shopId,
                isIncreased: false,
                title: 'Order Created',
                quantityChange: 0,
                newValue: formatLargeNumberDouble(
                  cartItem
                      .getPrimaryUnit()
                      .getQuantityEquivDivided(
                        index: 1,
                        newQuantity:
                            (cartItem
                                    .getItem()!
                                    .getActualQuantity() ??
                                0),
                        product: mainItem,
                      ),
                ),
                oldValue: formatLargeNumberDouble(
                  (cartItem
                      .getPrimaryUnit()
                      .getQuantityEquivDivided(
                        index: 1,
                        product: mainItem,
                        newQuantity:
                            (cartItem
                                    .getItem()!
                                    .getActualQuantity() ??
                                0),
                      )),
                ),
              );
              itemHistory.itemName =
                  cartItem.getItem()!.name;
              itemHistory.itemUuid =
                  cartItem.getItem()!.uuid;
              await returnItemHistoryProvider()
                  .createItemHistory(itemHistory);
            }

            try {
              // Step 4: Create new product for items with addToStock == true
              for (final record in orderItems) {
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
                      (record.originalCost ?? 0);

                  final double wholeSalePrice =
                      record.revenue;

                  var productUuid = record.productUuid;

                  TempProductClass
                  product = TempProductClass(
                    heightDimension: record.heightDimension,
                    quantityType: record.quantityType,
                    widthDimension: record.widthDimension,
                    pricesList: [
                      ProductPricesClass(
                        uuid: uuidGen(),
                        staffUuid: currentUser().userId,
                        createdAt: createdAt,
                        staffName: currentUser().name,
                        priceValue: 0,
                        name: 'Price',
                        isPrimary: true,
                        itemUuid: productUuid,
                        priceType: 1,
                      ),
                    ],
                    unitsList: [
                      ProductUnitsClass(
                        uuid: uuidGen(),
                        staffUuid: currentUser().userId,
                        createdAt: createdAt,
                        staffName: currentUser().name,
                        conversion: 1,
                        name: 'Unit(s)',
                        isPrimary: true,
                        productUuid: productUuid,
                      ),
                    ],
                    useGroupUnit: false,
                    categories: [],
                    storageUuid: null,
                    groupUnit: 'Group(s)',
                    qttyPerGroup: null,
                    name: record.productName,
                    unit: 'Unit(s)',
                    isRefundable: false,
                    costPrice: costPrice,
                    shopId: shopId,
                    setCustomPrice: true,
                    isManaged: false,
                    barcode: null,
                    brand: null,
                    // categoryUuid: null,
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
                    uuid: productUuid,
                  );
                  if (context.mounted) {
                    ItemHistory itemHistory = ItemHistory(
                      event:
                          ItemHistoryEventClass.itemCreated,
                      isManaged: false,
                      source:
                          ItemHistoryEventClass.orderSource,
                      shopId: shopId,
                      title: 'Item Created',
                      quantityChange: 0,
                      newValue: '0',
                      desc: 'Item Created Now',
                      isIncreased: true,
                      oldValue: '0',
                    );
                    await returnData().createProduct(
                      isMultiple: true,
                      itemHistory: itemHistory,
                      product: product,
                    );
                  } else {
                    await mainLocalLog(
                      'Context Not Mounted to Created New Product',
                    );
                  }
                }
              }
              // Step 5: Reset state
              // resetPaymentMethod();
              try {
                await deleteCart(
                  cartId: cartIdCache,
                  context: context,
                );
              } catch (e) {
                await mainLocalLog(
                  "Error Deleting Cart Inside Checkout Function: ${e.toString()}",
                );
              }

              if (context.mounted) {
                returnCustomers(
                  context,
                  listen: false,
                ).clearSelectedCustomer(context);
                await returnOrdersProvider()
                    .loadOrdersOffline(shopId);
                if (context.mounted) {
                  returnNavProvider(
                    context,
                    listen: false,
                  ).navigate(0);
                }
              }
              returnData().syncData();
              notifyListeners();
              return CheckoutResponse(order: order);
            } catch (e) {
              await mainLocalLog(
                'Error Step 4: ${e.toString()}',
              );
              await returnOrdersProvider().deleteOrder(
                order,
                [],
              );
              return null;
            }
          } catch (e) {
            await mainLocalLog(
              'Error Step 3: ${e.toString()}',
            );
            await returnOrdersProvider().deleteOrder(
              order,
              [],
            );
            return null;
          }
        } catch (e) {
          await mainLocalLog(
            'Error Step 2: ${e.toString()}',
          );
          await returnOrdersProvider().deleteOrder(
            order,
            [],
          );
          return null;
        }
      } catch (e) {
        await mainLocalLog('Error Step 1: ${e.toString()}');
        return null;
      }
    }
  }

  // Future<void> deleteCart

  // Saves the current Draft cart (new or continued) and
  // empties the cart. Returns false if nothing was saved.
  Future<bool> saveDraft() async {
    if (currentCart().cartItemTypeIndex != 4 ||
        !currentCart().canUseDraft() ||
        currentCart().getCartItemsAll().isEmpty) {
      return false;
    }

    final uuid = currentCart().draftUuid ?? uuidGen();
    final existing =
        returnDraftsProvider().drafts
            .where((draft) => draft.uuid == uuid)
            .firstOrNull;

    Drafts draft = Drafts(
      uuid: uuid,
      createdAt: existing?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      shopId: shopId(),
      staffId: existing?.staffId ?? staffUuid(),
      staffName: existing?.staffName ?? staffName(),
      subStaffUuid:
          currentMainCart().subStaff?.uuid ??
          currentCart().subStaffUuid,
      subStaffName:
          currentCart().subStaffName ??
          currentMainCart().subStaff?.staffName,
      customerUuid: customerUuid(),
      customerName: customerName(),
      departmentUuid: departmentUuid(),
      departmentName: departmentName(),
      cartName: currentCart().cartName ?? 'Draft',
      comment: currentCart().comment,
      generalDiscount: currentCart().discount,
      fixedDiscount: currentCart().fixedDiscount,
      total: calcFinalTotal(),
      draftItems: returnDraftsProvider()
          .cartItemsToDraftItems(
            cartItems: currentCart().getCartItemsAll(),
            draftId: uuid,
          ),
    );

    if (existing != null) {
      final res = await returnDraftsProvider().updateDraft(
        draft: draft,
      );
      if (res == 0) {
        return false;
      }
    } else {
      final res = await returnDraftsProvider().createDraft(
        draft,
      );
      if (res == null) {
        return false;
      }
    }

    await mainLocalLog('Draft Saved: $uuid');
    await clearCart();
    return true;
  }

  Future<void> clearCart() async {
    currentCart().cartItems.clear();
    currentCart().cartItemTypeIndex = 1;
    currentCart().draftUuid = null;
    currentCart().selectedCustomer = null;
    currentCart().selectedCustomerName = null;
    currentCart().paymentMethod = 0;
    currentCart().splitPayments = null;
    currentCart().discount = null;
    currentCart().fixedDiscount = null;
    currentCart().customDate = null;
    currentCart().timeOfDay = null;
    await returnMultiDisplayProvider().updateWindow(
      cartClass: AltCartClass(
        manageCustomerReward:
            returnShopProvider()
                .userShop()!
                .manageCustomerReward ??
            false,
        cashBack:
            returnShopProvider()
                .userShop()!
                .customerPercentageReward,
        cartId: currentCart().id!,
        currency: returnShopProvider().userShop()!.currency,
        cartItems: [],
        fixedDiscount: currentCart().fixedDiscount,
        percentDiscount: currentCart().fixedDiscount,
        vat:
            returnShopProvider().userShop()!.applyVAT!
                ? vat
                : 0,
      ),
    );
    await CartFunc().updateMainCart(currentMainCart());
    await mainLocalLog('Cart Cleared');

    notifyListeners();
  }

  double discountCheck(TempProductClass product) {
    double tempValue = 0;
    if (product.discount == null || product.discount == 0) {
      tempValue = product.getPrimaryPrice().priceValue;
    } else {
      tempValue =
          product.getPrimaryPrice().priceValue -
          (product.getPrimaryPrice().priceValue *
              (product.discount! / 100));
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
      for (var item in currentCart().getCartItems()) {
        if (item.getItem()?.discount != null &&
            item.customPrice == null) {
          double discountPerUnit =
              (item
                      .getItem()
                      ?.getPrimaryPrice()
                      .priceValue ??
                  0) *
              ((item.getItem()?.discount ?? 1) / 100);
          tempTotalDiscount +=
              discountPerUnit * item.quantity;
        }
      }
      return tempTotalDiscount;
    }
  }

  double calcCashBackReward() {
    return calcFinalTotal() *
        ((returnShopProvider()
                    .userShop()
                    ?.customerPercentageReward ??
                0) /
            100);
  }

  // Null when no customer is selected. When editing a receipt for the same
  // customer, its old account debit is added back because saving the edit
  // reverses that debit first.
  double? availableAccountBalance() {
    List<TempCustomersClass> customers =
        returnCustomersSingle().customers
            .where(
              (item) =>
                  item.uuid ==
                  currentCart().selectedCustomer,
            )
            .toList();
    if (customers.isEmpty) {
      return null;
    }
    double balance = customers.first.getBalance();
    if (currentCart().isReceiptEdit &&
        currentCart().receiptUuidEdit != null) {
      var editedReceipts =
          returnReceiptProviderSingle().receipts
              .where(
                (rec) =>
                    rec.uuid ==
                        currentCart().receiptUuidEdit &&
                    rec.customerUuid ==
                        currentCart().selectedCustomer,
              )
              .toList();
      if (editedReceipts.isNotEmpty) {
        balance +=
            editedReceipts.first.customerAccount ?? 0;
      }
    }
    return balance;
  }

  bool isBalanceSufficient() {
    var balance = availableAccountBalance();
    if (balance != null) {
      return balance >= calcFinalTotal();
    } else {
      return false;
    }
  }

  // Customer account payments are restricted to Real Sales for now.
  bool canUseAccount() {
    return currentCart().cartItemTypeIndex == 1 &&
        GeneralSettingsAuthAction()
                .manageCustomersAccountAndPoints(
                  context: null,
                ) ==
            true &&
        returnShopProvider()
                .userShop()
                ?.manageCustomerAccount ==
            true &&
        currentCart().selectedCustomer != null &&
        authorization(
          authorized:
              Authorizations()
                  .makeSalesFromCustomersAccount,
        );
  }

  // Builds the payment entries for checkout from the selected option.
  // The split amounts are only read when Split is selected.
  List<PaymentEntry> resolvePayments({
    required double cash,
    required double bank,
    required double account,
  }) {
    double total = calcFinalTotal();
    switch (currentCart().paymentMethod) {
      case 1:
        return [
          PaymentEntry(
            method: PaymentMethods.bank,
            amount: total,
          ),
        ];
      case 2:
        return PaymentBreakdown.fromAmounts(
          cash: cash,
          bank: bank,
          account: canUseAccount() ? account : 0,
        ).compact;
      case 3:
        return [
          PaymentEntry(
            method: PaymentMethods.account,
            amount: total,
          ),
        ];
      default:
        return [
          PaymentEntry(
            method: PaymentMethods.cash,
            amount: total,
          ),
        ];
    }
  }

  // Null when valid, otherwise a user-facing message.
  String? validatePayments(List<PaymentEntry> payments) {
    var breakdown = PaymentBreakdown(payments);
    if (breakdown.account > 0 && !canUseAccount()) {
      return 'Customer Account payments are only available for Real Sales with a selected customer.';
    }
    if (currentCart().paymentMethod == 3 &&
        !isBalanceSufficient()) {
      return 'This Customers Balance is not enough to make this Purchase. Top up the balance, or pay the remainder with Cash or Bank.';
    }
    return breakdown.validate(
      total: calcFinalTotal(),
      accountBalance: availableAccountBalance(),
    );
  }

  Future<void> setSplitPayments(
    List<PaymentEntry>? payments,
  ) async {
    currentCart().splitPayments = payments;
    await CartFunc().updateMainCart(currentMainCart());
    notifyListeners();
  }

  // Insufficient balance shortcut: use the whole available balance and pay
  // the rest with [method] (cash or bank) as a split payment.
  Future<List<PaymentEntry>> splitRemainderWith(
    String method,
  ) async {
    double total = calcFinalTotal();
    double balance = availableAccountBalance() ?? 0;
    double accountPart = balance < 0 ? 0 : balance;
    if (accountPart > total) {
      accountPart = total;
    }
    var payments = [
      PaymentEntry(
        method: PaymentMethods.account,
        amount: accountPart,
      ),
      PaymentEntry(
        method: method,
        amount: total - accountPart,
      ),
    ];
    currentCart().paymentMethod = 2;
    await setSplitPayments(payments);
    return payments;
  }

  double calcVatAmount() {
    double tempTotal = 0;
    for (var item in currentCart().getCartItems()) {
      tempTotal +=
          (item.totalCost() *
              (returnShopProvider().getVat() / 100));
    }
    return tempTotal;
  }

  double calcSubTotal() {
    double tempTotal = 0;
    for (var item in currentCart().getCartItems()) {
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
    CartFunc().updateMainCart(currentMainCart());
    notifyListeners();
  }

  void setComment({required String? comment}) {
    if (comment == null) {
      currentCart().comment = comment;
    } else {
      if (comment.isEmpty) {
        currentCart().comment = null;
      } else {
        currentCart().comment = comment;
      }
    }
    CartFunc().updateMainCart(currentMainCart());
    mainLocalLog('Comment Updated: $comment');
    notifyListeners();
  }

  void closeCustomPrice() {
    currentCart().setCustomPrice = false;
    CartFunc().updateMainCart(currentMainCart());
    notifyListeners();
  }

  // void notifyListenersLocal() {
  //   notifyListeners();
  // }

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

  // double totalInAllCarts({
  //   required TempCartItem newCartItem,
  // }) {
  //   double totalInAllCarts = 0;
  //   for (var mainCart in mainCartQueue) {
  //     for (final cart in mainCart.cartQueue.where(
  //       (item) => item.cartItemTypeIndex != 3,
  //     )) {
  //       for (final cartItem in cart.getCartItems().where(
  //         (item) => item != newCartItem,
  //       )) {
  //         if ((cartItem.itemUuid ?? cartItem.item.uuid) ==
  //             (newCartItem.itemUuid ??
  //                 newCartItem.item.uuid)) {
  //           if (newCartItem.useGroupQuantity == true) {
  //             totalInAllCarts += cartItem.getRealQuantity();
  //           } else {
  //             totalInAllCarts += cartItem.quantity;
  //           }
  //         }
  //       }
  //     }
  //   }
  //   return totalInAllCarts;
  // }

  double totalInAllCarts({
    required TempCartItem newCartItem,
    required bool isEdit,
  }) {
    double totalInAllCarts = 0;

    final itemUuid =
        newCartItem.itemUuid ?? newCartItem.item.uuid;

    for (var mainCart in mainCartQueue) {
      for (final cart in mainCart.cartQueue.where(
        (item) =>
            !isStockFreeCartType(item.cartItemTypeIndex),
      )) {
        for (final cartItem in cart.getCartItems()) {
          final cartItemUuid =
              cartItem.itemUuid ?? cartItem.item.uuid;

          // During edit, ignore only the line being edited, so
          // other lines of the same item (e.g. other 2D sizes)
          // still count. Lines without a uuid fall back to
          // skipping by item.
          if (isEdit &&
              (newCartItem.uuid != null
                  ? cartItem.uuid == newCartItem.uuid
                  : cartItemUuid == itemUuid)) {
            continue;
          }

          // During normal adding, don't count the exact object
          // being added if it already exists somewhere.
          if (!isEdit && cartItem == newCartItem) {
            continue;
          }

          if (cartItemUuid == itemUuid) {
            // if (newCartItem.useGroupQuantity == true) {
            totalInAllCarts += cartItem.getRealQuantity();
            // } else {
            //   totalInAllCarts += cartItem.quantity;
            // }
          }
        }
      }
    }

    return totalInAllCarts;
  }

  double remainingQttyInAllCarts({
    required TempCartItem newCartItem,
    required bool isEdit,
  }) {
    var tempList = returnData().productListMain.where(
      (item) =>
          item.uuid ==
          (newCartItem.itemUuid ?? newCartItem.item.uuid),
    );
    if (tempList.isNotEmpty) {
      return (tempList.first.getActualQuantity() ?? 0) -
          totalInAllCarts(
            newCartItem: newCartItem,
            isEdit: isEdit,
          );
    } else {
      return (newCartItem.getItem()?.getActualQuantity() ??
              0) -
          totalInAllCarts(
            newCartItem: newCartItem,
            isEdit: isEdit,
          );
    }
  }

  double totalItemQuantityInAllCarts({
    required TempProductClass product,
  }) {
    double totalInAllCarts = 0;
    for (var mainCart in mainCartQueue) {
      for (final cart in mainCart.cartQueue.where(
        (item) =>
            !isStockFreeCartType(item.cartItemTypeIndex),
      )) {
        for (final cartItem in cart.getCartItems().where(
          (item) => item.getItem()?.uuid == product.uuid,
        )) {
          totalInAllCarts += cartItem.getRealQuantity();
        }
      }
    }
    return totalInAllCarts;
  }

  double remainingItemQttyInAllCarts({
    required TempProductClass product,
  }) {
    var tempList = returnData().productListMain.where(
      (item) => item.uuid == (product.uuid ?? item.uuid),
    );
    if (tempList.isNotEmpty) {
      return (tempList.first.getActualQuantity() ?? 0) -
          totalItemQuantityInAllCarts(product: product);
    } else {
      return (product.getActualQuantity() ?? 0) -
          totalItemQuantityInAllCarts(product: product);
    }
  }

  // bool canAddProductToCart({
  //   required TempCartItem newCartItem,
  //   required double quantityToAdd,
  //   required bool? useGroupUnit,
  //   // required bool isEdit,
  // }) {
  //   if (currentCart().cartItemTypeIndex == 3) {
  //     return true;
  //   } else {
  //     double quantityToAddCalc() {
  //       if (useGroupUnit ??
  //           newCartItem.useGroupQuantity == true) {
  //         return (quantityToAdd *
  //             (newCartItem.getQttyPerGroup()));
  //       } else {
  //         return quantityToAdd;
  //       }
  //     }

  //     double newTotal =
  //         totalInAllCarts(newCartItem: newCartItem) +
  //         quantityToAddCalc();

  //     double availableQty() {
  //       var tempProducts = returnData().productListMain
  //           .where(
  //             (item) =>
  //                 item.uuid ==
  //                 (newCartItem.itemUuid ??
  //                     newCartItem.item.uuid),
  //           );
  //       if (tempProducts.isNotEmpty) {
  //         var product = tempProducts.first;
  //         return product.quantity ?? 0;
  //       } else {
  //         return newCartItem.getItem()?.quantity ?? 0;
  //       }
  //     }

  //     double remainingQtty =
  //         availableQty() -
  //         totalInAllCarts(newCartItem: newCartItem);
  //     if (newTotal > availableQty() &&
  //         returnData().productList().contains(
  //           newCartItem.getItem(),
  //         ) &&
  //         (newCartItem.getItem()?.isManaged ?? false)) {
  //       mainLocalLog(
  //         'Cannot add — total ($newTotal) exceeds available stock ($remainingQtty) : Avaliable Quantity: ${availableQty()}',
  //       );
  //       return false;
  //     }
  //     return true;
  //   }
  // }

  bool canAddProductToCart({
    required TempCartItem newCartItem,
    required double quantityToAdd,
    // bool? useGroupUnit,
    required bool isEdit,
  }) {
    // This cart type does not have stock restrictions.
    if (isStockFreeCartType(
      currentCart().cartItemTypeIndex,
    )) {
      return true;
    }

    final itemUuid =
        newCartItem.itemUuid ?? newCartItem.item.uuid;

    // Find the actual product in stock.
    final product = returnData().productListMain
        .cast<TempProductClass?>()
        .firstWhere(
          (item) => item?.uuid == itemUuid,
          orElse: () => null,
        );

    // Item doesn't exist in stock → custom item.
    // Custom items have no quantity restriction.
    if (product == null) {
      return true;
    }

    // Product exists but inventory management is disabled.
    // Therefore, quantity doesn't matter.
    if (!product.isManaged) {
      return true;
    }

    if (product.isExpired()) {
      mainLocalLog('Cannot add Expired Item');
      return false;
    }

    // From this point onward, we KNOW:
    // - It is a real stock product.
    // - It is managed.
    // Therefore stock restrictions apply.

    final availableQuantity =
        product.getActualQuantity() ?? 0;

    final currentQuantity = totalInAllCarts(
      newCartItem: newCartItem,
      isEdit: isEdit,
    );

    final quantityToAddInStock = quantityToAdd;

    final newTotal = currentQuantity + quantityToAddInStock;

    if (newTotal > availableQuantity) {
      mainLocalLog(
        'Cannot add — requested total ($newTotal) exceeds '
        'available stock ($availableQuantity).',
      );

      return false;
    }

    return true;
  }

  bool isAddMultipleItemsToCart = false;
  List<TempCartItem> tempCartItems = [];

  void toggleAddMultipleItemsToCart() {
    isAddMultipleItemsToCart = !isAddMultipleItemsToCart;
    tempCartItems.clear();
    notifyListeners();
  }

  // 2D lines added without dimensions (barcode, quick add)
  // are priced at the item's full width × height.
  void applyDefaultDimensions(TempCartItem cartItem) {
    if (cartItem.item.quantityType == 2 &&
        cartItem.widthDimension == null &&
        cartItem.heightDimension == null) {
      cartItem.widthDimension =
          cartItem.item.widthDimension;
      cartItem.heightDimension =
          cartItem.item.heightDimension;
    }
  }

  // Same item, and for 2D items the same width × height.
  bool isSameCartLine(TempCartItem a, TempCartItem b) {
    final sameProduct =
        (a.itemUuid ?? a.item.uuid) ==
        (b.itemUuid ?? b.item.uuid);
    if (!sameProduct) return false;
    if (b.item.quantityType == 2) {
      return a.item.quantityType == 2 &&
          a.widthDimension == b.widthDimension &&
          a.heightDimension == b.heightDimension;
    }
    return true;
  }

  // Existing void line for this line's item (and size, for 2D).
  TempCartItem? findVoidLine(
    TempCart cart,
    TempCartItem line,
  ) {
    for (final voidLine in cart.getCartItemsVoid()) {
      if (isSameCartLine(voidLine, line)) return voidLine;
    }
    return null;
  }

  void addItemToTempCart({required TempCartItem item}) {
    var newItem = item.copyWith();
    applyDefaultDimensions(newItem);
    var items = tempCartItems.where(
      (cartItem) => isSameCartLine(cartItem, newItem),
    );
    if (items.isNotEmpty) {
      tempCartItems.remove(items.first);
      tempCartItems.add(newItem);
    } else {
      tempCartItems.add(newItem);
    }

    notifyListeners();
  }

  void deleteItemFromTempCart({
    required TempCartItem item,
  }) {
    tempCartItems.remove(item);
    notifyListeners();
  }

  void clearTempCartList() {
    tempCartItems.clear();
    notifyListeners();
  }

  Future<void> addMultipleItemsToCart({
    required BuildContext context,
  }) async {
    for (var newItem in tempCartItems) {
      if (canAddProductToCart(
        newCartItem: newItem,
        quantityToAdd: newItem
            .getSelectedUnit()
            .getQuantityEquivMultiplied(
              index: 1,
              newQuantity: newItem.quantity,
              customWidth: newItem.widthDimension,
              customHeight: newItem.heightDimension,
            ),
        isEdit: false,
        // isEdit: false,
        // useGroupUnit: newItem.useGroupQuantity ?? false,
      )) {
        final index = currentCart()
            .getCartItems()
            .indexWhere(
              (item) => isSameCartLine(item, newItem),
            );

        if (index != -1) {
          currentCart().getCartItemsAll()[index].discount;
          currentCart().getCartItemsAll()[index].quantity +=
              newItem.quantity;
        } else {
          currentCart().cartItems.add(newItem);
        }
        addAnyDiscount();
        await returnMultiDisplayProvider().updateWindow(
          cartClass: AltCartClass(
            manageCustomerReward:
                returnShopProvider()
                    .userShop()!
                    .manageCustomerReward ??
                false,
            cashBack:
                returnShopProvider()
                    .userShop()!
                    .customerPercentageReward,
            cartId: currentCart().id!,
            currency:
                returnShopProvider().userShop()!.currency,
            cartItems:
                currentCart()
                    .getCartItemsAll()
                    .reversed
                    .toList(),
            fixedDiscount: currentCart().fixedDiscount,
            percentDiscount: currentCart().discount,
            vat:
                returnShopProvider().userShop()!.applyVAT!
                    ? vat
                    : 0,
          ),
        );
        await CartFunc().updateMainCart(currentMainCart());

        notifyListeners();
      } else {}
    }
  }

  Future<String> addItemToCart({
    required BuildContext context,
    required TempCartItem newItem,
    required bool isCustomEdit,
    // required bool isEdit,
  }) async {
    applyDefaultDimensions(newItem);
    if (canAddProductToCart(
      isEdit: false,
      newCartItem: newItem,
      quantityToAdd: newItem
          .getSelectedUnit()
          .getQuantityEquivMultiplied(
            index: 1,
            newQuantity: newItem.quantity,
            customWidth: newItem.widthDimension,
            customHeight: newItem.heightDimension,
          ),
    )) {
      String result = '';
      var items = currentCart().getCartItems().where((
        item,
      ) {
        final sameProduct =
            (item.itemUuid ?? item.item.uuid) ==
            (newItem.itemUuid ?? newItem.item.uuid);

        if (!sameProduct) return false;

        final is2DItem = newItem.item.quantityType == 2;

        if (is2DItem) {
          return item.item.quantityType == 2 &&
              item.widthDimension ==
                  newItem.widthDimension &&
              item.heightDimension ==
                  newItem.heightDimension;
        }

        return true;
      });

      var voidItem = findVoidLine(currentCart(), newItem);

      if (items.isNotEmpty) {
        var item = items.first;

        if (returnShopProvider().userShop()!.trackCart ==
                true &&
            item.quantity > newItem.quantity) {
          if (voidItem != null) {
            var beanItem = voidItem;
            beanItem.quantity +=
                item.quantity - newItem.quantity;
          } else {
            var deletedItem = newItem.copyWith(
              quantity: item.quantity - newItem.quantity,
              isVoid: true,
              uuid: uuidGen(),
            );
            currentCart().cartItems.add(deletedItem);
          }
        }

        if (isCustomEdit) {
          item.item.name = newItem.item.name;
          item.item.sellingPrice =
              newItem.item.sellingPrice;
          item.item.costPrice = newItem.item.costPrice;
          item.item.setCustomPrice =
              newItem.item.setCustomPrice;
          item.addToStock = newItem.addToStock;
          item.customPrice = newItem.customPrice;
          item.quantity = newItem.quantity;
          item.setCustomPrice = newItem.setCustomPrice;
          item.setTotalPrice = newItem.setTotalPrice;
          item.useWholeSalePrice =
              newItem.useWholeSalePrice;
          item.useGroupQuantity = newItem.useGroupQuantity;
          item.qttyPerGroup = newItem.qttyPerGroup;
          item.item.unit = newItem.item.unit;
        } else {
          item.addToStock = newItem.addToStock;
          item.customPrice = newItem.customPrice;
          item.discount = newItem.discount;
          item.fixedDiscount = newItem.fixedDiscount;
          item.isVoid = newItem.isVoid;
          item.itemUuid = newItem.itemUuid;
          item.quantity = newItem.quantity;
          item.qttyPerGroup = newItem.qttyPerGroup;
          item.salesRecordId = newItem.salesRecordId;
          item.setCustomPrice = newItem.setCustomPrice;
          item.setTotalPrice = newItem.setTotalPrice;
          item.useWholeSalePrice =
              newItem.useWholeSalePrice;
          item.useGroupQuantity = newItem.useGroupQuantity;
          item.uuid = newItem.uuid;
        }
        await returnMultiDisplayProvider().updateWindow(
          cartClass: AltCartClass(
            manageCustomerReward:
                returnShopProvider()
                    .userShop()!
                    .manageCustomerReward ??
                false,
            cartId: currentCart().id!,
            currency:
                returnShopProvider().userShop()!.currency,
            cartItems:
                currentCart()
                    .getCartItemsAll()
                    .reversed
                    .toList(),
            cashBack:
                returnShopProvider()
                    .userShop()!
                    .customerPercentageReward,
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
        currentCart().cartItems.add(newItem);
        await returnMultiDisplayProvider().updateWindow(
          cartClass: AltCartClass(
            manageCustomerReward:
                returnShopProvider()
                    .userShop()!
                    .manageCustomerReward ??
                false,
            cashBack:
                returnShopProvider()
                    .userShop()!
                    .customerPercentageReward,
            cartId: currentCart().id!,
            currency:
                returnShopProvider().userShop()!.currency,
            cartItems:
                currentCart()
                    .getCartItemsAll()
                    .reversed
                    .toList(),
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
        // }
      }
      addAnyDiscount();
      await CartFunc().updateMainCart(currentMainCart());

      notifyListeners();
      return result;
    } else {
      showDialog(
        context: context,
        builder:
            (_) => InfoAlert(
              title: "Quantity Limit Reached",
              message:
                  "Only ${newItem.getItem()?.getActualQuantity() ?? 0} available in stock.",
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
    if (canAddProductToCart(
      isEdit: true,
      newCartItem: cartItem,
      quantityToAdd: cartItem
          .getSelectedUnit()
          .getQuantityEquivMultiplied(
            index: 1,
            newQuantity: number,
            customWidth: cartItem.widthDimension,
            customHeight: cartItem.heightDimension,
          ),
    )) {
      if (returnShopProvider().userShop()!.trackCart ==
              true &&
          cartItem.quantity > number) {
        // The voided quantity is of the line's current size,
        // which this edit may be changing.
        final originalLine =
            currentCart()
                .getCartItems()
                .where((item) => item.uuid == cartItem.uuid)
                .firstOrNull ??
            cartItem;
        var voidItem = findVoidLine(
          currentCart(),
          originalLine,
        );

        if (voidItem != null) {
          var beanItem = voidItem;
          beanItem.quantity += cartItem.quantity - number;
        } else {
          var deletedItem = cartItem.copyWith(
            quantity: cartItem.quantity - number,
            isVoid: true,
            uuid: uuidGen(),
            widthDimension: originalLine.widthDimension,
            heightDimension: originalLine.heightDimension,
          );
          currentCart().cartItems.add(deletedItem);
        }
      }
      cartItem.quantity = number;
      cartItem.customPrice = customPrice;
      cartItem.setTotalPrice = setTotalPrice;
      cartItem.setCustomPrice = setCustomPrice;
      await updateCurrentCartItem(cartItem);
      await returnMultiDisplayProvider().updateWindow(
        cartClass: AltCartClass(
          manageCustomerReward:
              returnShopProvider()
                  .userShop()!
                  .manageCustomerReward ??
              false,
          cashBack:
              returnShopProvider()
                  .userShop()!
                  .customerPercentageReward,
          cartId: currentCart().id!,
          currency:
              returnShopProvider().userShop()!.currency,
          cartItems:
              currentCart()
                  .getCartItemsAll()
                  .reversed
                  .toList(),
          fixedDiscount: currentCart().fixedDiscount,
          percentDiscount: currentCart().discount,
          vat:
              returnShopProvider().userShop()!.applyVAT!
                  ? vat
                  : 0,
        ),
      );

      await CartFunc().updateMainCart(currentMainCart());
      notifyListeners();
    } else {
      await mainLocalLog(
        'Cannot Add to Cart Because Quantity Ti Wa',
      );
    }
  }

  Future<void> removeItemFromCart(
    TempCartItem item,
    BuildContext context,
  ) async {
    if (returnShopProvider().userShop()!.trackCart ==
        true) {
      var newItem = item.copyWith(
        isVoid: true,
        uuid: uuidGen(),
      );
      var voidItem = findVoidLine(currentCart(), item);

      if (voidItem != null) {
        var beanItem = voidItem;
        beanItem.quantity += item.quantity;
      } else {
        currentCart().cartItems.add(newItem);
      }
    }
    currentCart().cartItems.remove(item);
    await returnMultiDisplayProvider().updateWindow(
      cartClass: AltCartClass(
        manageCustomerReward:
            returnShopProvider()
                .userShop()!
                .manageCustomerReward ??
            false,
        cashBack:
            returnShopProvider()
                .userShop()!
                .customerPercentageReward,
        cartId: currentCart().id!,
        currency: returnShopProvider().userShop()!.currency,
        cartItems:
            currentCart()
                .getCartItemsAll()
                .reversed
                .toList(),
        fixedDiscount: currentCart().fixedDiscount,
        percentDiscount: currentCart().discount,
        vat:
            returnShopProvider().userShop()!.applyVAT!
                ? vat
                : 0,
      ),
    );
    addAnyDiscount();
    CartFunc().updateMainCart(currentMainCart());
    notifyListeners();
  }

  Future<void> resetPaymentMethod() async {
    currentCart().paymentMethod = 0;
    currentCart().splitPayments = null;
    await CartFunc().updateMainCart(currentMainCart());
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
      'subText': 'Use Bank to Make Payment',
    },
    {
      'number': 2,
      'method': 'Split Payment',
      'subText': 'Combine Cash, Bank and Customer Account',
    },
    {
      'number': 3,
      'method': 'Customer Account',
      'subText': 'Make Payment From Customer Balace',
    },
  ];

  void changePaymentMethod({
    required int index,
    required BuildContext context,
  }) {
    SalesAuthAction().paymentMethodSelectionAction(
      context: context,
      action: () {
        currentCart().paymentMethod = index;
        CartFunc().updateMainCart(currentMainCart());
        notifyListeners();
      },
    );
  }

  String returnPaymentMethod({int? index}) {
    switch (index ?? currentCart().paymentMethod) {
      case 0:
        return 'Cash';
      case 1:
        return 'Bank';
      case 2:
        return 'Split';
      case 3:
        return 'Account';
      default:
        return 'Cash';
    }
  }

  // Maps a saved receipt back to a checkout option using its amounts, so
  // old receipts and account receipts reopen on the right option.
  int paymentMethodIndexForReceipt(
    TempMainReceipt receipt,
  ) {
    // Invoice / order receipts keep the old mapping; customer account
    // splits are Real Sales only for now.
    if (receipt.invoiceUuid != null ||
        receipt.orderUuid != null) {
      return receipt.paymentMethod == PaymentMethods.cash
          ? 0
          : receipt.paymentMethod == PaymentMethods.bank
          ? 1
          : 2;
    }
    var breakdown = receipt.paymentBreakdown();
    if (breakdown.isSplit) {
      return 2;
    }
    switch (breakdown.label) {
      case PaymentMethods.bank:
        return 1;
      case PaymentMethods.account:
        return 3;
      default:
        return 0;
    }
  }

  Map<String, dynamic> returnPaymentMethodSalesPage(
    int index,
  ) {
    return paymentMethods.firstWhere(
      (item) => item['number'] == index,
      orElse: () {
        return {
          'number': 0,
          'method': 'Pay with Cash',
          'subText': 'Use Cash to Make Payment',
        };
      },
    );
  }

  Map<String, dynamic> selectedPaymentMethod() {
    return paymentMethods.firstWhere(
      (item) =>
          item['number'] == currentCart().paymentMethod,
      orElse: () {
        return {
          'number': 0,
          'method': 'Pay with Cash',
          'subText': 'Use Cash to Make Payment',
        };
      },
    );
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
            (record.originalCost ?? 0) /
            (record.quantity * record.dimensionArea());
      }
    }
    return TempCartItem(
      heightDimension: record.heightDimension,
      quantityType: record.quantityType,
      widthDimension: record.widthDimension,
      priceUuid: record.priceUuid,
      unitUuid: record.unitUuid,
      uuid: record.uuid,
      itemUuid: product.uuid,
      isVoid: record.isVoid ?? false,
      item: product,
      quantity: record.quantity,
      discount: record.discount,
      fixedDiscount: record.fixedDiscount,
      customPrice: record.customPriceSet ? tempRev : null,
      addToStock: record.addToStock ?? false,
      setCustomPrice: record.customPriceSet,
      setTotalPrice: record.setTotalPrice ?? false,
      // salesRecordId: record.uuid,
      useWholeSalePrice: record.useWholeSalePrice ?? false,
      useGroupQuantity: record.useGroupQuantity ?? false,
      qttyPerGroup: record.qttyPerGroup,
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
        var newProduct = product.first.copyWith();
        newProduct.unitsList = record.getUnitListFinal();
        final cartItem = saleRecordToCartItem(
          record: newRecord,
          product: newProduct,
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
          heightDimension: record.heightDimension,
          quantityType: record.quantityType,
          widthDimension: record.widthDimension,
          pricesList: record.getPriceListFinal(),
          unitsList: record.getUnitListFinal(),
          useGroupUnit: false,
          categories: [],
          storageUuid: null,
          groupUnit: 'Group(s)',
          qttyPerGroup: null,
          name: record.productName,
          unit: record.unit ?? 'Unit(s)',
          isRefundable: false,
          costPrice: costPrice,
          shopId: record.shopId,
          setCustomPrice: true,
          isManaged: false,
          barcode: null,
          brand: null,
          // categoryUuid: null,
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
        TempMainReceipt newReceipt = receipt.copyWith();
        // Convert them back to cart items
        final cartItems = convertReceiptToCartItems(
          receipt: newReceipt,
          saleRecords:
              newReceipt
                  .getItems()
                  .map((item) => item.copy())
                  .toList(),
          context: context,
        );

        final tempCartItems = convertReceiptToCartItems(
          receipt: newReceipt,
          saleRecords:
              newReceipt
                  .getItems()
                  .map((item) => item.copy())
                  .toList(),
          context: context,
        );

        if (currentMainCart().cartQueue
            .where(
              (cart) =>
                  cart.receiptUuidEdit != null &&
                  cart.receiptUuidEdit == newReceipt.uuid,
            )
            .isEmpty) {
          var newId = uuidGen();
          var tempCart = TempCart(
            tempCartItems: tempCartItems,
            orderUuidEdit: null,
            comment: newReceipt.comment,
            timeOfDay: null,
            hasPrintedDocket: false,
            subStaffName: newReceipt.subStaffName,
            customDate: null,
            departmentName: newReceipt.departmentName,
            departmentUuid: newReceipt.departmentUuidNew,
            subStaffUuid: newReceipt.subStaffUuid,
            staffId: newReceipt.staffId,
            staffName: newReceipt.staffName,
            id: newId,
            fixedDiscount: newReceipt.fixedDiscount,
            createdDate: newReceipt.createdAt,
            cartItems: cartItems,
            cartItemTypeIndex:
                newReceipt.invoiceUuid != null
                    ? 2
                    : newReceipt.orderUuid != null
                    ? 3
                    : 1,
            discount: newReceipt.generalDiscount,
            receiptUuidEdit: newReceipt.uuid,
            paymentMethod: paymentMethodIndexForReceipt(
              newReceipt,
            ),
            splitPayments:
                newReceipt.invoiceUuid == null &&
                        newReceipt.orderUuid == null &&
                        newReceipt
                            .paymentBreakdown()
                            .isSplit
                    ? newReceipt.payments()
                    : null,
            selectedCustomer: newReceipt.customerUuid,
            selectedCustomerName: newReceipt.customerName,
            isReceiptEdit: true,
          );
          await addNewCart(context, tempCart);
          await returnMultiDisplayProvider().updateWindow(
            cartClass: AltCartClass(
              manageCustomerReward:
                  returnShopProvider()
                      .userShop()!
                      .manageCustomerReward ??
                  false,
              cashBack: newReceipt.getCustomerReward(),
              cartId: tempCart.id!,
              cartItems:
                  tempCart
                      .getCartItemsAll()
                      .reversed
                      .toList(),
              fixedDiscount: currentCart().fixedDiscount,
              percentDiscount: currentCart().discount,
              vat: newReceipt.vat ?? 0,
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
                      cart.receiptUuidEdit ==
                      newReceipt.uuid,
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
                    tempCartItems: null,
                    comment: null,
                    timeOfDay: null,
                    // createdDate: DateTime.now(),
                    hasPrintedDocket: false,
                    subStaffName: null,
                    customDate: null,
                    departmentName: null,
                    departmentUuid: null,
                    cartItems: [],
                    cartItemTypeIndex: 1,
                    staffId: currentUser().userId,
                    staffName:
                        "${currentUser().name} ${currentUser().lastName}",
                    id: uuidGen(),
                    orderUuidEdit: null,
                  ),
                );
              }

              await deleteCart(
                cartId: cartIdCache,
                context: context,
              );
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

class CartItemConflictClass {
  final String uuid;
  final double quantity;
  final bool isExpired;

  CartItemConflictClass({
    required this.uuid,
    required this.quantity,
    required this.isExpired,
  });
}

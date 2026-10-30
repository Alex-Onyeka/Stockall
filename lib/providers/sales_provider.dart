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
import 'package:stockall/components/alert_dialogues/duplicate_cart_item_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/generate_barcode.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/local_database/cart_func/cart_func.dart';
import 'package:stockall/local_database/invoices/invoices_func.dart';
import 'package:stockall/local_database/main_receipt/main_receipt_func.dart';
import 'package:stockall/local_database/product_record_func.dart/product_record_func.dart';
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
    final int index = currentCart().cartItems.indexWhere(
      (item) =>
          (cartItem.uuid != null &&
              item.uuid == cartItem.uuid) ||
          identical(item, cartItem),
    );
    if (index != -1) {
      var tempItem = currentCart().cartItems[index];
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
      tempItem.wastageAmount = cartItem.wastageAmount;
      tempItem.wastageUnitUuid = cartItem.wastageUnitUuid;
      tempItem.isPercentageWastage =
          cartItem.isPercentageWastage;
      tempItem.manageSalesWastage =
          cartItem.manageSalesWastage;
      tempItem.quantityType = cartItem.quantityType;
      currentCart().cartItems[index] = tempItem;
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

  // Orders preserve wastage as estimated wastage so that delivery accounts for it.
  void clearOrderWastage(TempCart cart) {}

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

          final quantity = cartItem.getStockQuantity();

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
    double sub = calcSubTotal();
    if (sub <= 0) return 0;
    double itemPercent =
        ((fixedDiscountAmount * 100) / sub);
    mainLocalLog("Item Percent: $itemPercent");
    double result = ((itemPercent * itemCost) / 100);
    mainLocalLog("Result $result");
    return result;
  }

  void addFixedDiscount(double? discount) {
    if (discount == null || discount <= 0) {
      currentCart().fixedDiscount = null;
      currentCart().discount = null;
      for (var item in currentCart().getCartItems()) {
        item.discount = null;
        item.fixedDiscount = null;
      }
    } else {
      currentCart().fixedDiscount = discount;
      currentCart().discount = null;
      for (var item in currentCart().getCartItems()) {
        item.discount = null;
        item.fixedDiscount =
            calcSalesRecalcFixedDiscountPercentageAmountcordRevenue(
              fixedDiscountAmount: discount,
              itemCost: item.totalCost(),
            );
      }
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

  void addPercentageDiscount(double? discount) {
    if (discount == null || discount <= 0) {
      currentCart().discount = null;
      currentCart().fixedDiscount = null;
      for (var item in currentCart().getCartItems()) {
        item.discount = null;
        item.fixedDiscount = null;
      }
    } else {
      currentCart().discount = discount;
      currentCart().fixedDiscount = null;
      for (var item in currentCart().getCartItems()) {
        item.discount = discount;
        item.fixedDiscount = null;
      }
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
        isPercentageWastage: cartItem.isPercentageWastage,
        wastageAmount: cartItem.wastageAmount,
        wastageUnitUuid: cartItem.wastageUnitUuid,
        manageSalesWastage: cartItem.manageSalesWastage,
        heightDimension: cartItem.heightDimension,
        quantityType: cartItem.quantityType,
        widthDimension: cartItem.widthDimension,
        dimensionUnit: cartItem.item.dimensionUnit,
        dimensionUnitConversion:
            cartItem.item.dimensionUnitConversion,
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

  Future<void> _applyReceiptInventoryUpdate({
    required List<TempCartItem> oldCartItems,
    required List<TempCartItem> newCartItems,
    required String receiptUuid,
    required int shopId,
    required bool isInvoice,
    DateTime? createdAt,
  }) async {
    final allProductUuids = <String>{};
    for (final item in oldCartItems) {
      final u = item.itemUuid ?? item.item.uuid;
      if (u != null && u.isNotEmpty) {
        allProductUuids.add(u);
      }
    }
    for (final item in newCartItems) {
      final u = item.itemUuid ?? item.item.uuid;
      if (u != null && u.isNotEmpty) {
        allProductUuids.add(u);
      }
    }

    final idDigits = returnOnlyDigits(receiptUuid);

    for (final productUuid in allProductUuids) {
      final oldLines =
          oldCartItems
              .where(
                (i) =>
                    (i.itemUuid ?? i.item.uuid) ==
                        productUuid &&
                    i.isVoid != true,
              )
              .toList();
      final newLines =
          newCartItems
              .where(
                (i) =>
                    (i.itemUuid ?? i.item.uuid) ==
                        productUuid &&
                    i.isVoid != true,
              )
              .toList();

      final oldStockQty = oldLines.fold<double>(
        0.0,
        (sum, i) => sum + i.getStockQuantity(),
      );
      final newStockQty = newLines.fold<double>(
        0.0,
        (sum, i) => sum + i.getStockQuantity(),
      );
      final stockDiff = newStockQty - oldStockQty;

      // If no change in quantity, skip: no stock adjustment and no ItemHistory needed!
      if (stockDiff.abs() < 1e-6) {
        continue;
      }

      final refCartItem =
          newLines.isNotEmpty
              ? newLines.first
              : oldLines.first;
      final products = returnData().productListMain.where(
        (item) => item.uuid == productUuid,
      );
      TempProductClass mainItem =
          products.isNotEmpty
              ? products.first.copyWith()
              : refCartItem.item.copyWith();

      final oldDisplayQty = oldLines.fold<double>(
        0.0,
        (sum, i) => sum + i.historyQuantityChange(),
      );
      final newDisplayQty = newLines.fold<double>(
        0.0,
        (sum, i) => sum + i.historyQuantityChange(),
      );
      final displayDiff =
          (newDisplayQty - oldDisplayQty).abs();

      final primaryUnit = refCartItem.getPrimaryUnit();
      final double stockQtyForDisplay = stockDiff.abs();
      final double primaryQtyEquiv = primaryUnit
          .getQuantityEquivDivided(
            index: 1,
            newQuantity: stockQtyForDisplay,
            product: mainItem,
          );
      final unitName = formatHistoryUnit(
        selectedUnit: refCartItem.getSelectedUnit().name,
        primaryUnit: primaryUnit.name,
        primaryQuantity: primaryQtyEquiv,
      );
      final areaPerSheet = mainItem.dimensionArea();

      final isManaged = shouldDeductStock(
        isManaged:
            refCartItem.getItem()?.isManaged ?? false,
        inProductList: products.isNotEmpty,
        stock: mainItem.getActualQuantity() ?? 0,
      );

      final oldActualArea =
          mainItem.getActualQuantity() ?? 0;

      if (stockDiff > 0) {
        // Net SALE / DEDUCTION (more sold in updated receipt/invoice)
        final deductionArea = stockDiff;
        mainItem.quantity = mainItem.quantityAfterRemoving(
          deductionArea,
        );
        final newActualArea =
            mainItem.getActualQuantity() ?? 0;

        if (isManaged) {
          ItemHistory itemHistory = ItemHistory(
            createdAt: createdAt,
            event: ItemHistoryEventClass.sold,
            isManaged: refCartItem.item.isManaged,
            source: ItemHistoryEventClass.productSource,
            destination:
                isInvoice
                    ? ItemHistoryEventClass
                        .invoiceDestination
                    : ItemHistoryEventClass
                        .receiptDestination,
            unit: unitName,
            primaryUnit: primaryUnit.name,
            shopId: shopId,
            desc:
                isInvoice
                    ? '${formatDimension(displayDiff)} "$unitName" of This Item was Sold on Credit due to Invoice Update. Invoice Id: #$idDigits'
                    : '${formatDimension(displayDiff)} $unitName of This Item was Sold due to Receipt Update. Receipt Id: #$idDigits',
            isIncreased: false,
            title:
                isInvoice
                    ? 'Item Sold On Credit (Updated)'
                    : 'Item Sold In Receipt (Updated)',
            quantityChange: -displayDiff,
            newValue: formatLargeNumberDouble(
              primaryUnit.getQuantityEquivDivided(
                index: 1,
                newQuantity: newActualArea,
                product: mainItem,
              ),
            ),
            oldValue: formatLargeNumberDouble(
              primaryUnit.getQuantityEquivDivided(
                index: 1,
                newQuantity: oldActualArea,
                product: mainItem,
              ),
            ),
          );

          await returnData().updateProduct(
            itemHistory:
                products.isEmpty ? null : itemHistory,
            includeQuantity: false,
            product: mainItem,
            isQuantityUpdate: true,
            quantityChange: deductionArea / areaPerSheet,
            isMultipleUpdate: true,
            isIncrement: false,
          );
        } else {
          // Unmanaged item
          if (products.isNotEmpty) {
            ItemHistory itemHistory = ItemHistory(
              createdAt: createdAt,
              event: ItemHistoryEventClass.sold,
              isManaged: refCartItem.item.isManaged,
              source: ItemHistoryEventClass.productSource,
              destination:
                  isInvoice
                      ? ItemHistoryEventClass
                          .invoiceDestination
                      : ItemHistoryEventClass
                          .receiptDestination,
              unit: unitName,
              primaryUnit: primaryUnit.name,
              desc:
                  isInvoice
                      ? '${formatDimension(displayDiff)} "$unitName" of This Item was Sold on Credit, but Not Deducted Because Item is Not Managed (Invoice Updated). Invoice Id: #$idDigits'
                      : '${formatDimension(displayDiff)} $unitName of This Item was Sold, but Not Deducted Because Item is Not Managed (Receipt Updated). Receipt Id: #$idDigits',
              shopId: shopId,
              isIncreased: false,
              oldValue: formatLargeNumberDouble(
                primaryUnit.getQuantityEquivDivided(
                  index: 1,
                  product: mainItem,
                  newQuantity: oldActualArea,
                ),
              ),
              newValue: formatLargeNumberDouble(
                primaryUnit.getQuantityEquivDivided(
                  index: 1,
                  product: mainItem,
                  newQuantity: oldActualArea,
                ),
              ),
              title:
                  isInvoice
                      ? 'Item Sold On Credit (Updated)'
                      : 'Item Sold In Receipt (Updated)',
              quantityChange: 0,
            );
            itemHistory.itemName =
                refCartItem.getItem()?.name;
            itemHistory.itemUuid =
                refCartItem.getItem()?.uuid;
            await returnItemHistoryProvider()
                .createItemHistory(itemHistory);
          }
        }
      } else {
        // Net RETURN / RESTORATION (less sold in updated receipt/invoice)
        final returnArea = stockDiff.abs();
        final restoredArea = oldActualArea + returnArea;
        mainItem.quantity =
            mainItem.quantityType == 2
                ? restoredArea / areaPerSheet
                : restoredArea;
        final newActualArea =
            mainItem.getActualQuantity() ?? 0;

        if (isManaged) {
          ItemHistory itemHistory = ItemHistory(
            createdAt: createdAt,
            event: ItemHistoryEventClass.returnEvent,
            isManaged: refCartItem.item.isManaged,
            source:
                isInvoice
                    ? ItemHistoryEventClass.invoiceSource
                    : 'receipt',
            destination:
                ItemHistoryEventClass.productDestination,
            unit: unitName,
            primaryUnit: primaryUnit.name,
            shopId: shopId,
            desc:
                isInvoice
                    ? '${formatDimension(displayDiff)} "$unitName" of This Item was Returned due to Invoice Update. Invoice Id: #$idDigits'
                    : '${formatDimension(displayDiff)} $unitName of This Item was Returned due to Receipt Update. Receipt Id: #$idDigits',
            isIncreased: true,
            title:
                isInvoice
                    ? 'Item Returned (Invoice Updated)'
                    : 'Item Returned (Receipt Updated)',
            quantityChange: displayDiff,
            newValue: formatLargeNumberDouble(
              primaryUnit.getQuantityEquivDivided(
                index: 1,
                newQuantity: newActualArea,
                product: mainItem,
              ),
            ),
            oldValue: formatLargeNumberDouble(
              primaryUnit.getQuantityEquivDivided(
                index: 1,
                newQuantity: oldActualArea,
                product: mainItem,
              ),
            ),
          );

          await returnData().updateProduct(
            itemHistory:
                products.isEmpty ? null : itemHistory,
            includeQuantity: false,
            product: mainItem,
            isQuantityUpdate: true,
            quantityChange: returnArea / areaPerSheet,
            isMultipleUpdate: true,
            isIncrement: true,
          );
        } else {
          // Unmanaged item
          if (products.isNotEmpty) {
            ItemHistory itemHistory = ItemHistory(
              createdAt: createdAt,
              event: ItemHistoryEventClass.returnEvent,
              isManaged: refCartItem.item.isManaged,
              source:
                  isInvoice
                      ? ItemHistoryEventClass.invoiceSource
                      : 'receipt',
              destination:
                  ItemHistoryEventClass.productDestination,
              unit: unitName,
              primaryUnit: primaryUnit.name,
              desc:
                  isInvoice
                      ? '${formatDimension(displayDiff)} "$unitName" of This Item was Returned, but Not Added Because Item is Not Managed (Invoice Updated). Invoice Id: #$idDigits'
                      : '${formatDimension(displayDiff)} $unitName of This Item was Returned, but Not Added Because Item is Not Managed (Receipt Updated). Receipt Id: #$idDigits',
              shopId: shopId,
              isIncreased: true,
              oldValue: formatLargeNumberDouble(
                primaryUnit.getQuantityEquivDivided(
                  index: 1,
                  product: mainItem,
                  newQuantity: oldActualArea,
                ),
              ),
              newValue: formatLargeNumberDouble(
                primaryUnit.getQuantityEquivDivided(
                  index: 1,
                  product: mainItem,
                  newQuantity: oldActualArea,
                ),
              ),
              title:
                  isInvoice
                      ? 'Item Returned (Invoice Updated)'
                      : 'Item Returned (Receipt Updated)',
              quantityChange: 0,
            );
            itemHistory.itemName =
                refCartItem.getItem()?.name;
            itemHistory.itemUuid =
                refCartItem.getItem()?.uuid;
            await returnItemHistoryProvider()
                .createItemHistory(itemHistory);
          }
        }
      }
    }
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

    // Backstop: the checkout buttons check this first. Nothing has
    // been written yet, so blocking here leaves no partial sale.
    final stockConflict = checkoutStockConflict();
    if (stockConflict != null) {
      await mainLocalLog(
        'Checkout Blocked, Stock Conflict: $stockConflict',
      );
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
      final isReceiptEdit =
          currentCart().receiptUuidEdit != null;
      TempMainReceipt? existingReceipt;
      if (isReceiptEdit) {
        existingReceipt =
            returnReceiptProviderSingle().receipts
                .where(
                  (r) =>
                      r.uuid ==
                      currentCart().receiptUuidEdit,
                )
                .firstOrNull ??
            MainReceiptFunc().getSingleReceipt(
              uuid: currentCart().receiptUuidEdit!,
            );
      }
      final uuid =
          currentCart().receiptUuidEdit ??
          currentCart().id ??
          uuidGen();
      await mainLocalLog('🌹🌹 Created Date: $createdAt');
      TempMainReceipt receipt = TempMainReceipt(
        id: existingReceipt?.id,
        barcode: existingReceipt?.barcode,
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
      if (isReceiptEdit) {
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
          await ProductRecordFunc()
              .deleteRecordsInReceiptWithoutUpdatingInventory(
                receipt: receipt,
              );
          receipt.tempItems = null;
          final updatedRes =
              await returnReceiptProviderSingle()
                  .updateReceipt(receipt);
          if (updatedRes == null) {
            await mainLocalLog('Error Updating Receipt');
            return null;
          }
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
            'Error Updating Receipt: ${e.toString()}',
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
        if (!isReceiptEdit) {
          await returnReceiptProviderSingle().createReceipt(
            receipt,
          );
          await mainLocalLog('Receipt Created');
        } else {
          await mainLocalLog(
            'Receipt Updated (Skipped createReceipt)',
          );
        }

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
            if (isReceiptEdit) {
              var oldCartItems =
                  salesCartItem.tempCartItems?.toList() ??
                  [];
              if (oldCartItems.isEmpty &&
                  existingReceipt != null) {
                oldCartItems = convertReceiptToCartItems(
                  receipt: existingReceipt,
                  saleRecords:
                      existingReceipt
                          .getItems()
                          .map((item) => item.copy())
                          .toList(),
                  context: context,
                );
              }
              await _applyReceiptInventoryUpdate(
                oldCartItems: oldCartItems,
                newCartItems: salesCartItem.getCartItems(),
                receiptUuid: receipt.uuid ?? '',
                shopId: shopId,
                isInvoice: false,
                createdAt: createdAt,
              );
            } else {
              final groupedCartItems =
                  <String, List<TempCartItem>>{};
              for (final cartItem
                  in salesCartItem.getCartItems()) {
                final key =
                    (cartItem.item.uuid != null &&
                            cartItem.item.uuid!.isNotEmpty)
                        ? cartItem.item.uuid!
                        : 'name_${cartItem.item.name}';
                groupedCartItems
                    .putIfAbsent(key, () => [])
                    .add(cartItem);
              }

              for (final lines in groupedCartItems.values) {
                final refCartItem = lines.first;
                final totalStockQuantity = lines
                    .fold<double>(
                      0.0,
                      (sum, i) =>
                          sum + i.getStockQuantity(),
                    );
                final totalDisplayQuantity = lines
                    .fold<double>(
                      0.0,
                      (sum, i) =>
                          sum + i.historyQuantityChange(),
                    );
                final totalWastage = lines.fold<double>(
                  0.0,
                  (sum, i) => sum + i.wastageInSaleUnit(),
                );

                TempProductClass? mainItem;
                var products = returnData().productListMain
                    .where(
                      (item) =>
                          item.uuid ==
                          refCartItem.item.uuid,
                    );
                if (products.isNotEmpty) {
                  mainItem = products.first.copyWith();
                } else {
                  mainItem = refCartItem.item.copyWith();
                }
                if (shouldDeductStock(
                  isManaged:
                      refCartItem.getItem()?.isManaged ??
                      false,
                  inProductList: products.isNotEmpty,
                  stock: mainItem.getActualQuantity() ?? 0,
                )) {
                  // Stock math is in area for 2D items; store the
                  // result back as a sheet count.
                  final oldStockArea =
                      mainItem.getActualQuantity() ?? 0;
                  mainItem.quantity = mainItem
                      .quantityAfterRemoving(
                        totalStockQuantity,
                      );
                  final newStockArea =
                      mainItem.getActualQuantity() ?? 0;
                  final primaryUnit =
                      refCartItem.getPrimaryUnit();
                  final primaryQtyEquiv = primaryUnit
                      .getQuantityEquivDivided(
                        index: 1,
                        newQuantity: totalStockQuantity,
                        product: mainItem,
                      );
                  final historyUnitName = formatHistoryUnit(
                    selectedUnit:
                        refCartItem.getSelectedUnit().name,
                    primaryUnit: primaryUnit.name,
                    primaryQuantity: primaryQtyEquiv,
                  );
                  final primUnitName =
                      primaryUnit.name == 'Others'
                          ? 'Unit(s)'
                          : primaryUnit.name;
                  final wastageText =
                      totalWastage > 1e-9
                          ? ' (including ${formatDimension(totalWastage)} $primUnitName wastage)'
                          : '';
                  ItemHistory itemHistory = ItemHistory(
                    createdAt: createdAt,
                    event: ItemHistoryEventClass.sold,
                    isManaged: refCartItem.item.isManaged,
                    source:
                        ItemHistoryEventClass.productSource,
                    destination:
                        ItemHistoryEventClass
                            .receiptDestination,
                    unit: historyUnitName,
                    primaryUnit: primaryUnit.name,
                    shopId: shopId,
                    desc:
                        '${formatDimension(totalDisplayQuantity)} $historyUnitName$wastageText of This Item was Sold. Receipt Id: #${returnOnlyDigits(receipt.uuid ?? '')}',
                    isIncreased: false,

                    title: 'Item Sold In Receipt',
                    quantityChange: -totalDisplayQuantity,
                    newValue: formatLargeNumberDouble(
                      primaryUnit.getQuantityEquivDivided(
                        index: 1,
                        newQuantity: newStockArea,
                        product: mainItem,
                      ),
                    ),
                    oldValue: formatLargeNumberDouble(
                      primaryUnit.getQuantityEquivDivided(
                        index: 1,
                        product: mainItem,
                        newQuantity: oldStockArea,
                      ),
                    ),
                  );
                  await returnData().updateProduct(
                    itemHistory:
                        products.isEmpty
                            ? null
                            : itemHistory,
                    includeQuantity: false,
                    product: mainItem,
                    isQuantityUpdate: true,
                    quantityChange:
                        totalStockQuantity /
                        mainItem.dimensionArea(),
                    isMultipleUpdate: true,
                    isIncrement: false,
                  );
                } else {
                  if (products.isNotEmpty) {
                    final primaryUnit =
                        refCartItem.getPrimaryUnit();
                    final primaryQtyEquiv = primaryUnit
                        .getQuantityEquivDivided(
                          index: 1,
                          newQuantity: totalStockQuantity,
                          product: mainItem,
                        );
                    final historyUnitName =
                        formatHistoryUnit(
                          selectedUnit:
                              refCartItem
                                  .getSelectedUnit()
                                  .name,
                          primaryUnit: primaryUnit.name,
                          primaryQuantity: primaryQtyEquiv,
                        );
                    final wastageText =
                        totalWastage > 1e-9
                            ? ' (including ${formatDimension(totalWastage)} wastage)'
                            : '';
                    ItemHistory itemHistory = ItemHistory(
                      createdAt: createdAt,
                      event: ItemHistoryEventClass.sold,
                      isManaged: refCartItem.item.isManaged,
                      source:
                          ItemHistoryEventClass
                              .productSource,
                      destination:
                          ItemHistoryEventClass
                              .receiptDestination,
                      unit: historyUnitName,
                      primaryUnit: primaryUnit.name,
                      desc:
                          '${formatDimension(totalDisplayQuantity)} $historyUnitName$wastageText of This Item was Sold, but Not Deducted Because Item is Not Managed. Receipt Id: #${returnOnlyDigits(receipt.uuid ?? '')}',
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
                    manageSalesWastage:
                        record.manageSalesWastage,
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
                      destination:
                          ItemHistoryEventClass
                              .productDestination,
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
              if (!isReceiptEdit) {
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
              }
              return null;
            }
          } catch (e) {
            await mainLocalLog(
              'Error Step 3: ${e.toString()}',
            );
            if (!isReceiptEdit) {
              await returnReceiptProvider(
                // ignore: use_build_context_synchronously
                context,
                listen: false,
              ).deleteReceiptWithoutUpdatingInventory(
                receipt: receipt,
              );
            }
            return null;
          }
        } catch (e) {
          await mainLocalLog(
            'Error Step 2: ${e.toString()}',
          );
          if (!isReceiptEdit) {
            await returnReceiptProvider(
              // ignore: use_build_context_synchronously
              context,
              listen: false,
            ).deleteReceipt(receipt, []);
          }
          return null;
        }
      } catch (e) {
        await mainLocalLog('Error Step 1: ${e.toString()}');
        return null;
      }
    } else if (currentCart().cartItemTypeIndex == 2) {
      await mainLocalLog('Current Sale is Invoice');
      final isInvoiceEdit =
          currentCart().invoiceUuidEdit != null;
      TempInvoice? existingInvoice;
      if (isInvoiceEdit) {
        existingInvoice =
            returnInvoicesProvider().invoicesMain
                .where(
                  (inv) =>
                      inv.uuid ==
                      currentCart().invoiceUuidEdit,
                )
                .firstOrNull ??
            InvoicesFunc()
                .getInvoices()
                .where(
                  (inv) =>
                      inv.uuid ==
                      currentCart().invoiceUuidEdit,
                )
                .firstOrNull;
      }
      TempInvoice invoice = TempInvoice(
        id: existingInvoice?.id,
        barcode: existingInvoice?.barcode,
        tempItems: null,
        comment: currentCart().comment,
        subStaffName:
            currentCart().subStaffName ??
            currentMainCart().subStaff?.staffName,
        departmentName: departmentName(),
        departmentUuidNew: departmentUuid(),
        createdAt:
            currentCart().createdDate != null
                ? createdAt
                : (existingInvoice?.createdAt ?? createdAt),
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
          cartItems: salesCartItem.getCartItems(),
          createdAt: invoice.createdAt,
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

        if (isInvoiceEdit) {
          final tempProductSaleRecords = buildSaleRecords(
            cartItems:
                salesCartItem.tempCartItems?.toList() ?? [],
            createdAt: invoice.createdAt,
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
            await ProductRecordFunc()
                .deleteRecordsInInvoiceWithoutUpdatingInventory(
                  invoice: invoice,
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
              'Error Cleaning Invoice Sale Records: ${e.toString()}',
            );
            return null;
          }
          invoice.tempItems = null;

          final updateStatus =
              await returnInvoicesProvider().updateInvoice(
                invoice: invoice,
              );
          if (updateStatus == 0) {
            await mainLocalLog('Error Updating Invoice');
            return null;
          }
          invoiceRes = invoice;
          await mainLocalLog('Invoice Updated Success');
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
          invoice.tempItems = null;

          invoiceRes = await returnInvoicesProvider()
              .createInvoices(invoice);
          await mainLocalLog('Invoice Created Success');
        }
      } catch (e) {
        await mainLocalLog(
          'Error Creating/Updating Invoice: ${e.toString()}',
        );
        return null;
      }

      try {
        String? receiptUuid;

        if (partPayment != null && partPayment != 0) {
          final productSaleRecords =
              salesCartItem.getCartItems().map((cartItem) {
                final product = cartItem.getItem();
                return TempProductSaleRecord(
                  isPercentageWastage:
                      cartItem.isPercentageWastage,
                  wastageAmount: cartItem.wastageAmount,
                  wastageUnitUuid: cartItem.wastageUnitUuid,
                  manageSalesWastage:
                      cartItem.manageSalesWastage,
                  heightDimension: cartItem.heightDimension,
                  quantityType: cartItem.quantityType,
                  widthDimension: cartItem.widthDimension,
                  dimensionUnit:
                      cartItem.item.dimensionUnit,
                  dimensionUnitConversion:
                      cartItem.item.dimensionUnitConversion,
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

          // `breakdown` holds the cash/bank split for the full invoice
          // total (the payment method fields always sum to it), but only
          // `partPayment` was actually received. Scale the split down so
          // the receipt's recorded payment (and its Total) match the part
          // payment instead of the whole invoice.
          final paymentRatio =
              breakdown.total > 0
                  ? partPayment / breakdown.total
                  : 0.0;
          final scaledBank =
              breakdown.total > 0
                  ? breakdown.bank * paymentRatio
                  : 0.0;
          final scaledCash =
              breakdown.total > 0
                  ? breakdown.cash * paymentRatio
                  : partPayment;

          await returnInvoicesProvider().makeInvoicePayment(
            bankAmount: scaledBank,
            cashAmount: scaledCash,
            customerAmount: 0,
            invoice: invoice,
            salesRecords: productSaleRecords,
            currentPayment: partPayment,
            paymentDate: createdAt,
            paymentMethod: breakdown.label,
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
            if (isInvoiceEdit) {
              var oldCartItems =
                  salesCartItem.tempCartItems?.toList() ??
                  [];
              if (oldCartItems.isEmpty &&
                  existingInvoice != null) {
                oldCartItems = returnInvoicesProvider()
                    .convertInvoiceToCartItems(
                      invoice: existingInvoice,
                      saleRecords:
                          existingInvoice
                              .getItemsNoVoid() ??
                          [],
                      context: context,
                    );
              }
              await _applyReceiptInventoryUpdate(
                oldCartItems: oldCartItems,
                newCartItems: salesCartItem.getCartItems(),
                receiptUuid: invoice.uuid ?? '',
                shopId: shopId,
                isInvoice: true,
                createdAt: createdAt,
              );
            } else {
              final groupedCartItems =
                  <String, List<TempCartItem>>{};
              for (final cartItem
                  in salesCartItem.getCartItems()) {
                final key =
                    (cartItem.item.uuid != null &&
                            cartItem.item.uuid!.isNotEmpty)
                        ? cartItem.item.uuid!
                        : 'name_${cartItem.item.name}';
                groupedCartItems
                    .putIfAbsent(key, () => [])
                    .add(cartItem);
              }

              for (final lines in groupedCartItems.values) {
                final refCartItem = lines.first;
                final totalStockQuantity = lines
                    .fold<double>(
                      0.0,
                      (sum, i) =>
                          sum + i.getStockQuantity(),
                    );
                final totalDisplayQuantity = lines
                    .fold<double>(
                      0.0,
                      (sum, i) =>
                          sum + i.historyQuantityChange(),
                    );
                final totalWastage = lines.fold<double>(
                  0.0,
                  (sum, i) => sum + i.wastageInSaleUnit(),
                );

                TempProductClass? mainItem;
                var products = returnData().productListMain
                    .where(
                      (item) =>
                          item.uuid ==
                          refCartItem.item.uuid,
                    );
                if (products.isNotEmpty) {
                  mainItem = products.first.copyWith();
                } else {
                  mainItem = refCartItem.item.copyWith();
                }
                if (shouldDeductStock(
                  isManaged:
                      refCartItem.getItem()?.isManaged ??
                      false,
                  inProductList: products.isNotEmpty,
                  stock: mainItem.getActualQuantity() ?? 0,
                )) {
                  // Stock math is in area for 2D items; store the
                  // result back as a sheet count.
                  final oldStockArea =
                      mainItem.getActualQuantity() ?? 0;
                  mainItem.quantity = mainItem
                      .quantityAfterRemoving(
                        totalStockQuantity,
                      );
                  final newStockArea =
                      mainItem.getActualQuantity() ?? 0;
                  final primaryUnit =
                      refCartItem.getPrimaryUnit();
                  final primaryQtyEquiv = primaryUnit
                      .getQuantityEquivDivided(
                        index: 1,
                        newQuantity: totalStockQuantity,
                        product: mainItem,
                      );
                  final historyUnitName = formatHistoryUnit(
                    selectedUnit:
                        refCartItem.getSelectedUnit().name,
                    primaryUnit: primaryUnit.name,
                    primaryQuantity: primaryQtyEquiv,
                  );
                  final primUnitName =
                      primaryUnit.name == 'Others'
                          ? 'Unit(s)'
                          : primaryUnit.name;
                  final wastageText =
                      totalWastage > 1e-9
                          ? ' (including ${formatDimension(totalWastage)} $primUnitName wastage)'
                          : '';
                  ItemHistory itemHistory = ItemHistory(
                    createdAt: createdAt,
                    event: ItemHistoryEventClass.sold,
                    isManaged: refCartItem.item.isManaged,
                    source:
                        ItemHistoryEventClass.productSource,
                    destination:
                        ItemHistoryEventClass
                            .invoiceDestination,
                    unit: historyUnitName,
                    primaryUnit: primaryUnit.name,
                    shopId: shopId,
                    desc:
                        '${formatDimension(totalDisplayQuantity)} "$historyUnitName"$wastageText of This Item was Sold on Credit. Invoice Id: #${returnOnlyDigits(invoice.uuid ?? '')}',
                    isIncreased: false,

                    title: 'Item Sold On Credit',
                    quantityChange: -totalDisplayQuantity,
                    newValue: formatLargeNumberDouble(
                      primaryUnit.getQuantityEquivDivided(
                        index: 1,
                        newQuantity: newStockArea,
                        product: mainItem,
                      ),
                    ),
                    oldValue: formatLargeNumberDouble(
                      primaryUnit.getQuantityEquivDivided(
                        index: 1,
                        product: mainItem,
                        newQuantity: oldStockArea,
                      ),
                    ),
                  );
                  await returnData().updateProduct(
                    itemHistory:
                        products.isEmpty
                            ? null
                            : itemHistory,
                    includeQuantity: false,
                    product: mainItem,
                    isQuantityUpdate: true,
                    quantityChange:
                        totalStockQuantity /
                        mainItem.dimensionArea(),
                    isMultipleUpdate: true,
                    isIncrement: false,
                  );
                } else {
                  if (products.isNotEmpty) {
                    final primaryUnit =
                        refCartItem.getPrimaryUnit();
                    final primaryQtyEquiv = primaryUnit
                        .getQuantityEquivDivided(
                          index: 1,
                          newQuantity: totalStockQuantity,
                          product: mainItem,
                        );
                    final historyUnitName =
                        formatHistoryUnit(
                          selectedUnit:
                              refCartItem
                                  .getSelectedUnit()
                                  .name,
                          primaryUnit: primaryUnit.name,
                          primaryQuantity: primaryQtyEquiv,
                        );
                    final wastageText =
                        totalWastage > 1e-9
                            ? ' (including ${formatDimension(totalWastage)} wastage)'
                            : '';
                    ItemHistory itemHistory = ItemHistory(
                      createdAt: createdAt,
                      event: ItemHistoryEventClass.sold,
                      isManaged: refCartItem.item.isManaged,
                      source:
                          ItemHistoryEventClass
                              .productSource,
                      destination:
                          ItemHistoryEventClass
                              .invoiceDestination,
                      unit: historyUnitName,
                      primaryUnit: primaryUnit.name,
                      desc:
                          '${formatDimension(totalDisplayQuantity)} "$historyUnitName"$wastageText of This Item was Sold On Credit, but Not Deducted Because Item is Not Managed. Receipt Id: #${returnOnlyDigits(invoice.uuid ?? '')}',
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
                    manageSalesWastage:
                        record.manageSalesWastage,
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
                      destination:
                          ItemHistoryEventClass
                              .productDestination,
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
              isPercentageWastage:
                  cartItem.isPercentageWastage,
              wastageAmount: cartItem.wastageAmount,
              wastageUnitUuid: cartItem.wastageUnitUuid,
              manageSalesWastage:
                  cartItem.manageSalesWastage,
              heightDimension: cartItem.heightDimension,
              quantityType: cartItem.quantityType,
              widthDimension: cartItem.widthDimension,
              dimensionUnit: cartItem.item.dimensionUnit,
              dimensionUnitConversion:
                  cartItem.item.dimensionUnitConversion,
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
              unit: cartItem.getUnit(),
              groupUnit:
                  cartItem.getItem()?.groupUnit ??
                  'Group(s)',
              orderId: order.uuid!,
            );
          }).toList();
      order.orderItems = orderItems;
      final isOrderEdit =
          currentCart().orderUuidEdit != null;
      if (isOrderEdit) {
        await mainLocalLog(
          'Order UUid is not null: ${currentCart().orderUuidEdit}',
        );
        final updateRes = await returnOrdersProvider()
            .updateOrder(order: order);
        if (updateRes == 0) {
          await mainLocalLog('Error Updating Order');
          return null;
        }
        await mainLocalLog('Order Updated');
      } else {
        await mainLocalLog('Order Uuid is null');
        await returnOrdersProvider().createOrder(order);
        await mainLocalLog('Order Created');
      }

      await mainLocalLog('Order Checkout Started');

      try {
        // Step 2: Create product sale records

        try {
          //
          //
          //
          //
          try {
            final groupedCartItems =
                <String, List<TempCartItem>>{};
            for (final cartItem
                in salesCartItem.getCartItems()) {
              final key =
                  (cartItem.item.uuid != null &&
                          cartItem.item.uuid!.isNotEmpty)
                      ? cartItem.item.uuid!
                      : 'name_${cartItem.item.name}';
              groupedCartItems
                  .putIfAbsent(key, () => [])
                  .add(cartItem);
            }

            for (final lines in groupedCartItems.values) {
              final refCartItem = lines.first;
              final totalDisplayQuantity = lines
                  .fold<double>(
                    0.0,
                    (sum, i) =>
                        sum + i.historyQuantityChange(),
                  );
              final totalStockQuantity = lines.fold<double>(
                0.0,
                (sum, i) => sum + i.getStockQuantity(),
              );
              final totalWastage = lines.fold<double>(
                0.0,
                (sum, i) => sum + i.wastageInSaleUnit(),
              );

              TempProductClass? mainItem;
              var products = returnData().productListMain
                  .where(
                    (item) =>
                        item.uuid == refCartItem.item.uuid,
                  );
              if (products.isNotEmpty) {
                mainItem = products.first.copyWith();
              } else {
                mainItem = refCartItem.item.copyWith();
              }
              final primaryUnit =
                  refCartItem.getPrimaryUnit();
              final primaryQtyEquiv = primaryUnit
                  .getQuantityEquivDivided(
                    index: 1,
                    newQuantity: totalStockQuantity,
                    product: mainItem,
                  );
              final historyUnitName = formatHistoryUnit(
                selectedUnit:
                    refCartItem.getSelectedUnit().name,
                primaryUnit: primaryUnit.name,
                primaryQuantity: primaryQtyEquiv,
              );
              final primUnitName =
                  primaryUnit.name == 'Others'
                      ? 'Unit(s)'
                      : primaryUnit.name;
              final wastageText =
                  totalWastage > 1e-9
                      ? ' (including ${formatDimension(totalWastage)} $primUnitName wastage)'
                      : '';
              ItemHistory itemHistory = ItemHistory(
                event: ItemHistoryEventClass.sold,
                isManaged: refCartItem.item.isManaged,
                source: ItemHistoryEventClass.productSource,
                destination:
                    ItemHistoryEventClass.orderDestination,
                unit: historyUnitName,
                primaryUnit: primaryUnit.name,
                desc:
                    isOrderEdit
                        ? '${formatDimension(totalDisplayQuantity)} "$historyUnitName"$wastageText of This Item was Ordered for (Order Updated), but Not Deducted. Order Id: #${returnOnlyDigits(order.uuid ?? '')}'
                        : '${formatDimension(totalDisplayQuantity)} "$historyUnitName"$wastageText of This Item was Ordered for, but Not Deducted. Order Id: #${returnOnlyDigits(order.uuid ?? '')}',
                shopId: shopId,
                isIncreased: false,
                title:
                    isOrderEdit
                        ? 'Order Updated'
                        : 'Order Created',
                quantityChange: 0,
                newValue: formatLargeNumberDouble(
                  primaryUnit.getQuantityEquivDivided(
                    index: 1,
                    newQuantity:
                        (mainItem.getActualQuantity() ?? 0),
                    product: mainItem,
                  ),
                ),
                oldValue: formatLargeNumberDouble(
                  primaryUnit.getQuantityEquivDivided(
                    index: 1,
                    product: mainItem,
                    newQuantity:
                        (mainItem.getActualQuantity() ?? 0),
                  ),
                ),
              );
              itemHistory.itemName = mainItem.name;
              itemHistory.itemUuid = mainItem.uuid;
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
                    manageSalesWastage:
                        record.manageSalesWastage,
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
                      destination:
                          ItemHistoryEventClass
                              .productDestination,
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
        tempTotalDiscount += item.discountCost();
      }
      return tempTotalDiscount;
    }
  }

  double calcCashBackReward() {
    if (currentCart().cartItemTypeIndex == 2 ||
        currentCart().invoiceUuidEdit != null) {
      return 0.0;
    }
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
      } else {
        var r = MainReceiptFunc().getSingleReceipt(
          uuid: currentCart().receiptUuidEdit!,
        );
        if (r != null &&
            r.customerUuid ==
                currentCart().selectedCustomer) {
          balance += r.customerAccount ?? 0;
        }
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
          ((item.totalCost() - item.discountCost()) *
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
    double total =
        ((calcSubTotal() - calcDiscountMain()) +
            calcVatAmount());
    return total < 0 ? 0.0 : total;
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
            totalInAllCarts += cartItem.getStockQuantity();
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
          totalInAllCarts += cartItem.getStockQuantity();
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

  // Checked right before checkout: stock can change after lines
  // were added (sync, manual edits). Returns a message naming the
  // first managed item whose lines (with wastage) need more than
  // is in stock, or null when the cart can be checked out.
  String? checkoutStockConflict() {
    final cart = currentCart();
    if (isStockFreeCartType(cart.cartItemTypeIndex)) {
      return null;
    }

    // Stock each managed item needs, in base units (area for 2D).
    double quantityByItem(
      Iterable<TempCartItem> lines,
      String itemUuid,
    ) {
      double total = 0;
      for (final line in lines) {
        if (line.isVoid == true) continue;
        if ((line.itemUuid ?? line.item.uuid) != itemUuid)
          continue;
        total += line.getStockQuantity();
      }
      return total;
    }

    final isEdit =
        cart.receiptUuidEdit != null ||
        cart.invoiceUuidEdit != null;
    final checked = <String>{};

    for (final line in cart.getCartItems()) {
      final itemUuid = line.itemUuid ?? line.item.uuid;
      if (itemUuid == null || !checked.add(itemUuid))
        continue;

      final product = returnData().productListMain
          .cast<TempProductClass?>()
          .firstWhere(
            (item) => item?.uuid == itemUuid,
            orElse: () => null,
          );
      if (product == null || !product.isManaged) continue;

      final required = quantityByItem(
        cart.getCartItems(),
        itemUuid,
      );
      // Editing restores the old lines before deducting the new.
      final available =
          (product.getActualQuantity() ?? 0) +
          (isEdit
              ? quantityByItem(
                cart.tempCartItems ?? [],
                itemUuid,
              )
              : 0);

      // Tolerance for float noise when summing several lines.
      if (required > available + 1e-9) {
        final unit = product.getPrimaryUnit();
        String inUnit(double quantity) {
          final value = unit.getQuantityEquivDivided(
            index: 1,
            newQuantity: quantity < 0 ? 0 : quantity,
            product: product,
          );
          return '${formatDimension(value)} ${unit.name}';
        }

        return 'Not enough stock for ${product.name}. This sale '
            'needs ${inUnit(required)} but only '
            '${inUnit(available)} is available. Reduce the '
            'quantity or remove the item before checking out.';
      }
    }
    return null;
  }

  // Checkout deducts managed stock items even when their stock is
  // 0. Items not in the stock list (custom items) keep the old
  // rule of deducting only when they carry stock.
  bool shouldDeductStock({
    required bool isManaged,
    required bool inProductList,
    required double stock,
  }) {
    return isManaged && (inProductList || stock > 0);
  }

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

  // Width/height equal within float noise; both null is equal.
  bool _sameDimension(double? a, double? b) {
    if (a == null || b == null) return a == b;
    return (a - b).abs() < 1e-6;
  }

  // Unit a line is sold in. Lines without a unit use the primary
  // one. Items without stored units get a new default unit (new
  // uuid) on every read, so they have only one unit: ''.
  String _lineUnitKey(TempCartItem line) {
    if (line.item.unitsList?.isNotEmpty != true) return '';
    return line.unitUuid ??
        line.item.unitsList!
            .where((unit) => unit.isPrimary)
            .firstOrNull
            ?.uuid ??
        '';
  }

  // Same item, and for 2D items the same unit, width × height and
  // wastage. Area-unit lines (m²) ignore width × height: their
  // quantity is already area.
  bool isSameCartLine(TempCartItem a, TempCartItem b) {
    final sameProduct =
        (a.itemUuid ?? a.item.uuid) ==
        (b.itemUuid ?? b.item.uuid);
    if (!sameProduct) return false;
    if (b.item.quantityType == 2) {
      if (a.item.quantityType != 2 ||
          _lineUnitKey(a) != _lineUnitKey(b)) {
        return false;
      }
      final unitKey = _lineUnitKey(b);
      final isAreaUnit =
          b.item.unitsList
              ?.where((unit) => unit.uuid == unitKey)
              .firstOrNull
              ?.isAreaUnit ??
          false;
      return (isAreaUnit ||
              (_sameDimension(
                    a.widthDimension,
                    b.widthDimension,
                  ) &&
                  _sameDimension(
                    a.heightDimension,
                    b.heightDimension,
                  ))) &&
          a.wastageAmount == b.wastageAmount &&
          a.wastageUnitUuid == b.wastageUnitUuid &&
          a.isPercentageWastage == b.isPercentageWastage;
    }
    return true;
  }

  // Existing line the sale dialog starts from when adding
  // [product]: the first live line for 1D items (adding replaces
  // it), none for 2D items (each size and unit is its own line,
  // picked in the dialog). Void lines are never reused.
  TempCartItem? existingLineForAdd(
    TempCart cart,
    TempProductClass product,
  ) {
    if (product.quantityType == 2) return null;
    return cart
        .getCartItems()
        .where(
          (item) =>
              (item.itemUuid ?? item.item.uuid) ==
              product.uuid,
        )
        .firstOrNull;
  }

  // Live line an added [line] merges into, or null to add it as
  // a new line.
  TempCartItem? findCartLine(
    TempCart cart,
    TempCartItem line,
  ) {
    return cart
        .getCartItems()
        .where((item) => isSameCartLine(item, line))
        .firstOrNull;
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
        quantityToAdd: newItem.getStockQuantity(),
        isEdit: false,
        // isEdit: false,
        // useGroupUnit: newItem.useGroupQuantity ?? false,
      )) {
        final existing = findCartLine(
          currentCart(),
          newItem,
        );

        if (existing != null) {
          final oldUnit = existing.getSelectedUnit();
          final newUnit = newItem.getSelectedUnit();
          final double oldConversion =
              (oldUnit.conversion <= 0)
                  ? 1.0
                  : oldUnit.conversion;
          final double newConversion =
              (newUnit.conversion <= 0)
                  ? 1.0
                  : newUnit.conversion;
          final double addedQuantity =
              (newItem.quantity * newConversion) /
              oldConversion;
          existing.quantity += addedQuantity;
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

  Future<String> replaceCartItem({
    required TempCartItem existingLine,
    required TempCartItem newItem,
    required bool isCustomEdit,
  }) async {
    var item = existingLine;
    var voidItem = findVoidLine(currentCart(), newItem);

    final newUnit = newItem.getSelectedUnit();
    final double newConversion =
        (newUnit.conversion <= 0)
            ? 1.0
            : newUnit.conversion;

    if (returnShopProvider().userShop()!.trackCart ==
            true &&
        item.getStockQuantity() >
            newItem.getStockQuantity()) {
      final diffStock =
          item.getStockQuantity() -
          newItem.getStockQuantity();
      final diffInNewUnit =
          (newConversion > 0)
              ? diffStock / newConversion
              : diffStock;
      if (voidItem != null) {
        voidItem.quantity += diffInNewUnit;
      } else {
        var deletedItem = newItem.copyWith(
          quantity: diffInNewUnit,
          isVoid: true,
          uuid: uuidGen(),
        );
        currentCart().cartItems.add(deletedItem);
      }
    }

    if (isCustomEdit) {
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
      item.useWholeSalePrice = newItem.useWholeSalePrice;
      item.useGroupQuantity = newItem.useGroupQuantity;
      item.qttyPerGroup = newItem.qttyPerGroup;
      item.item.unit = newItem.item.unit;
      item.unitUuid = newItem.unitUuid;
      item.priceUuid = newItem.priceUuid;
    } else {
      item.item = newItem.item;
      item.itemUuid = newItem.itemUuid ?? newItem.item.uuid;
      item.unitUuid = newItem.unitUuid;
      item.priceUuid = newItem.priceUuid;
      item.quantity = newItem.quantity;
      item.addToStock = newItem.addToStock;
      item.customPrice = newItem.customPrice;
      item.discount = newItem.discount;
      item.fixedDiscount = newItem.fixedDiscount;
      item.isVoid = newItem.isVoid;
      item.qttyPerGroup = newItem.qttyPerGroup;
      item.salesRecordId = newItem.salesRecordId;
      item.setCustomPrice = newItem.setCustomPrice;
      item.setTotalPrice = newItem.setTotalPrice;
      item.useWholeSalePrice = newItem.useWholeSalePrice;
      item.useGroupQuantity = newItem.useGroupQuantity;
      item.wastageAmount = newItem.wastageAmount;
      item.wastageUnitUuid = newItem.wastageUnitUuid;
      item.isPercentageWastage =
          newItem.isPercentageWastage;
      item.manageSalesWastage = newItem.manageSalesWastage;
      item.widthDimension = newItem.widthDimension;
      item.heightDimension = newItem.heightDimension;
      item.quantityType = newItem.quantityType;
    }

    await returnMultiDisplayProvider().updateWindow(
      cartClass: AltCartClass(
        manageCustomerReward:
            returnShopProvider()
                .userShop()!
                .manageCustomerReward ??
            false,
        cartId: currentCart().id!,
        currency: returnShopProvider().userShop()!.currency,
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
    addAnyDiscount();
    await CartFunc().updateMainCart(currentMainCart());
    notifyListeners();
    return 'Item Replaced Successfully';
  }

  Future<String> addToCartItemQuantity({
    required TempCartItem existingLine,
    required double addedQuantityInOldUnit,
  }) async {
    existingLine.quantity += addedQuantityInOldUnit;

    await returnMultiDisplayProvider().updateWindow(
      cartClass: AltCartClass(
        manageCustomerReward:
            returnShopProvider()
                .userShop()!
                .manageCustomerReward ??
            false,
        cartId: currentCart().id!,
        currency: returnShopProvider().userShop()!.currency,
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
    addAnyDiscount();
    await CartFunc().updateMainCart(currentMainCart());
    notifyListeners();
    return 'Quantity Updated Successfully';
  }

  bool isOnlyQuantityDifference(
    TempCartItem a,
    TempCartItem b,
  ) {
    // 1. Unit comparison: match unit UUID if set, or unit name and conversion
    final unitA = a.getSelectedUnit();
    final unitB = b.getSelectedUnit();
    final bool sameUnit =
        (unitA.uuid == unitB.uuid) ||
        (unitA.name.trim().toLowerCase() ==
                unitB.name.trim().toLowerCase() &&
            unitA.conversion == unitB.conversion);
    if (!sameUnit) return false;

    // 2. Price tier comparison: match price UUID if set, or price name, value, and price type
    final priceA = a.getSelectedPrice();
    final priceB = b.getSelectedPrice();
    final bool samePriceTier =
        (a.priceUuid != null &&
            b.priceUuid != null &&
            a.priceUuid == b.priceUuid) ||
        (priceA.name?.trim().toLowerCase() ==
                priceB.name?.trim().toLowerCase() &&
            priceA.priceValue == priceB.priceValue &&
            priceA.priceType == priceB.priceType);
    if (!samePriceTier) return false;

    // 3. Custom price comparison
    final bool aHasCustom =
        (a.setCustomPrice == true) &&
        a.customPrice != null &&
        a.customPrice! > 0;
    final bool bHasCustom =
        (b.setCustomPrice == true) &&
        b.customPrice != null &&
        b.customPrice! > 0;
    if (aHasCustom != bHasCustom) return false;
    if (aHasCustom) {
      if (a.customPrice != b.customPrice) return false;
      if (a.setTotalPrice != b.setTotalPrice) return false;
    }

    // 4. Wholesale price toggle
    if ((a.useWholeSalePrice == true) !=
        (b.useWholeSalePrice == true))
      return false;

    // 5. Discount comparison
    final double discountA = a.discount ?? 0.0;
    final double discountB = b.discount ?? 0.0;
    if (discountA != discountB) return false;

    final double fixedDiscountA = a.fixedDiscount ?? 0.0;
    final double fixedDiscountB = b.fixedDiscount ?? 0.0;
    if (fixedDiscountA != fixedDiscountB) return false;

    // 6. 2D Item attributes (dimensions and wastage)
    if (a.item.quantityType == 2 ||
        b.item.quantityType == 2) {
      if (a.item.quantityType != b.item.quantityType)
        return false;
      if (a.widthDimension != b.widthDimension)
        return false;
      if (a.heightDimension != b.heightDimension)
        return false;
      final double wastageA = a.wastageAmount ?? 0.0;
      final double wastageB = b.wastageAmount ?? 0.0;
      if (wastageA != wastageB) return false;
      if (a.wastageUnitUuid != b.wastageUnitUuid)
        return false;
      if ((a.isPercentageWastage == true) !=
          (b.isPercentageWastage == true)) {
        return false;
      }
    }

    return true;
  }

  Future<String> addItemToCart({
    required BuildContext context,
    required TempCartItem newItem,
    required bool isCustomEdit,
    Future<bool> Function(DuplicateCartItemChoice choice)?
    onBeforeCommitDuplicate,
  }) async {
    applyDefaultDimensions(newItem);
    var existingLine = findCartLine(currentCart(), newItem);

    if (existingLine != null) {
      final oldUnit = existingLine.getSelectedUnit();
      final newUnit = newItem.getSelectedUnit();
      final double oldConversion =
          (oldUnit.conversion <= 0)
              ? 1.0
              : oldUnit.conversion;
      final double newConversion =
          (newUnit.conversion <= 0)
              ? 1.0
              : newUnit.conversion;

      double addedQuantityInOldUnit;
      if (existingLine.item.quantityType == 2) {
        final double newRealQty = newItem.getRealQuantity();
        addedQuantityInOldUnit = oldUnit
            .getQuantityEquivDivided(
              newQuantity: newRealQty,
              index: 1,
              product: existingLine.item,
            );
      } else {
        addedQuantityInOldUnit =
            (newItem.quantity * newConversion) /
            oldConversion;
      }

      final double finalQuantityAfterAdd =
          existingLine.quantity + addedQuantityInOldUnit;

      final bool onlyQuantityDiff =
          isOnlyQuantityDifference(existingLine, newItem);

      DuplicateCartItemChoice choice;

      if (onlyQuantityDiff) {
        // If the only difference is the quantity, directly add to quantity without alert
        choice = DuplicateCartItemChoice.addToQuantity;
      } else {
        // Show Duplicate Cart Item Alert when other properties differ (unit, price, dimensions, etc.)
        final dialogChoice =
            await showDialog<DuplicateCartItemChoice>(
              context: context,
              builder:
                  (_) => DuplicateCartItemAlert(
                    theme: returnTheme(
                      context,
                      listen: false,
                    ),
                    existingItem: existingLine,
                    newItem: newItem,
                    addedQuantityInOldUnit:
                        addedQuantityInOldUnit,
                    finalQuantityAfterAdd:
                        finalQuantityAfterAdd,
                  ),
            );

        if (dialogChoice == null ||
            dialogChoice ==
                DuplicateCartItemChoice.cancel) {
          return '';
        }
        choice = dialogChoice;
      }

      if (choice == DuplicateCartItemChoice.replace) {
        if (!canAddProductToCart(
          isEdit: true,
          newCartItem: existingLine,
          quantityToAdd: newItem.getStockQuantity(),
        )) {
          showDialog(
            context: context,
            builder:
                (_) => InfoAlert(
                  title: "Quantity Limit Reached",
                  message:
                      "Only ${newItem.getItem()?.getActualQuantity() ?? 0} available in stock.",
                  theme: returnTheme(
                    context,
                    listen: false,
                  ),
                ),
          );
          return "Quantity Limit Exceeded";
        }

        if (onBeforeCommitDuplicate != null) {
          final proceed = await onBeforeCommitDuplicate(
            choice,
          );
          if (!proceed) {
            return '';
          }
        }

        return await replaceCartItem(
          existingLine: existingLine,
          newItem: newItem,
          isCustomEdit: isCustomEdit,
        );
      } else if (choice ==
          DuplicateCartItemChoice.addToQuantity) {
        final double totalStockNeeded =
            existingLine.getStockQuantity() +
            newItem.getStockQuantity();

        if (!canAddProductToCart(
          isEdit: true,
          newCartItem: existingLine,
          quantityToAdd: totalStockNeeded,
        )) {
          showDialog(
            context: context,
            builder:
                (_) => InfoAlert(
                  title: "Quantity Limit Reached",
                  message:
                      "Only ${newItem.getItem()?.getActualQuantity() ?? 0} available in stock.",
                  theme: returnTheme(
                    context,
                    listen: false,
                  ),
                ),
          );
          return "Quantity Limit Exceeded";
        }

        if (onBeforeCommitDuplicate != null) {
          final proceed = await onBeforeCommitDuplicate(
            choice,
          );
          if (!proceed) {
            return '';
          }
        }

        return await addToCartItemQuantity(
          existingLine: existingLine,
          addedQuantityInOldUnit: addedQuantityInOldUnit,
        );
      }
      return '';
    } else {
      if (canAddProductToCart(
        isEdit: false,
        newCartItem: newItem,
        quantityToAdd: newItem.getStockQuantity(),
      )) {
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
        addAnyDiscount();
        await CartFunc().updateMainCart(currentMainCart());
        notifyListeners();
        return 'Item Added Successfully';
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
  }

  Future<bool> editCartItemQuantity({
    required TempCartItem cartItem,
    required double number,
    double? customPrice,
    required bool setTotalPrice,
    required bool setCustomPrice,
  }) async {
    final double oldQuantity = cartItem.quantity;
    final double? oldCustomPrice = cartItem.customPrice;
    final bool oldSetTotalPrice = cartItem.setTotalPrice;
    final bool oldSetCustomPrice = cartItem.setCustomPrice;
    cartItem.quantity = number;
    cartItem.customPrice = customPrice;
    cartItem.setTotalPrice = setTotalPrice;
    cartItem.setCustomPrice = setCustomPrice;

    final double quantityToAdd =
        cartItem.getStockQuantity();

    if (canAddProductToCart(
      isEdit: true,
      newCartItem: cartItem,
      quantityToAdd: quantityToAdd,
    )) {
      if (returnShopProvider().userShop()!.trackCart ==
              true &&
          oldQuantity > number) {
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
          beanItem.quantity += oldQuantity - number;
        } else {
          var deletedItem = cartItem.copyWith(
            quantity: oldQuantity - number,
            isVoid: true,
            uuid: uuidGen(),
            widthDimension: originalLine.widthDimension,
            heightDimension: originalLine.heightDimension,
          );
          deletedItem.unitUuid = originalLine.unitUuid;
          deletedItem.wastageAmount =
              originalLine.wastageAmount;
          deletedItem.wastageUnitUuid =
              originalLine.wastageUnitUuid;
          deletedItem.isPercentageWastage =
              originalLine.isPercentageWastage;
          currentCart().cartItems.add(deletedItem);
        }
      }
      addAnyDiscount();
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
      return true;
    } else {
      cartItem.quantity = oldQuantity;
      cartItem.customPrice = oldCustomPrice;
      cartItem.setTotalPrice = oldSetTotalPrice;
      cartItem.setCustomPrice = oldSetCustomPrice;
      await mainLocalLog(
        'Cannot Add to Cart Because Quantity Ti Wa',
      );
      return false;
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
  // The line's price, added back from the receipt line's snapshot
  // if it was removed from the item. Units already come from the
  // snapshot (convertReceiptToCartItems).
  static TempProductClass editLineProduct({
    required TempProductSaleRecord record,
    required TempProductClass product,
    void Function(String message)? onMissing,
  }) {
    return product.withLineSnapshot(
      priceUuid: record.priceUuid,
      snapshotPrices: record.pricesList,
      onMissing:
          onMissing ?? (message) => mainLocalLog(message),
    );
  }

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
        // originalCost was billed on the line's base quantity
        // (area for 2D, after unit conversion) + wastage.
        tempRev =
            (record.originalCost ?? 0) /
            record.getStockQuantity();
      }
    }
    return TempCartItem(
      isPercentageWastage: record.isPercentageWastage,
      // Lines saved before wastage was applied keep none, so
      // they aren't re-priced or re-deducted.
      wastageAmount:
          record.manageSalesWastage == true
              ? record.wastageAmount
              : null,
      wastageUnitUuid:
          record.manageSalesWastage == true
              ? record.wastageUnitUuid
              : null,
      manageSalesWastage: record.manageSalesWastage,
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
      var product = returnData().productListMain.where(
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
        if (record.dimensionUnit != null) {
          newProduct.dimensionUnit = record.dimensionUnit;
        }
        if (record.dimensionUnitConversion != null &&
            record.dimensionUnitConversion! > 0) {
          newProduct.dimensionUnitConversion =
              record.dimensionUnitConversion;
        }
        final cartItem = saleRecordToCartItem(
          record: newRecord,
          product: editLineProduct(
            record: newRecord,
            product: newProduct,
          ),
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
          manageSalesWastage: record.manageSalesWastage,
          heightDimension: record.heightDimension,
          quantityType: record.quantityType,
          widthDimension: record.widthDimension,
          dimensionUnit: record.dimensionUnit,
          dimensionUnitConversion:
              record.dimensionUnitConversion,
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

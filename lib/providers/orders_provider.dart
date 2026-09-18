import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:stockall/classes/checkout_response.dart';
import 'package:stockall/classes/temp_cart/temp_cart.dart';
import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_orders/order_items.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/classes/temp_orders/unsynced/created/created_orders.dart';
import 'package:stockall/classes/temp_orders/unsynced/deleted/deleted_orders.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/generate_barcode.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/local_database/orders_func/orders_func.dart';
import 'package:stockall/local_database/orders_func/unsync_funcs/created/created_orders_func.dart';
import 'package:stockall/local_database/orders_func/unsync_funcs/deleted/deleted_orders_func.dart';
import 'package:stockall/local_database/orders_func/unsync_funcs/updated/updated_orders_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/alt_display/alt_display.dart';
import 'package:stockall/pages/report/general_report/class/general_report_class.dart';
import 'package:stockall/pages/report/invoice_sales_report/platforms/invoice_sales_report_desktop.dart';
import 'package:stockall/pages/sales/make_sales/page1/make_sales_page.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/receipt_page.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// // //

class OrdersProvider extends ChangeNotifier {
  static final OrdersProvider _instance =
      OrdersProvider._internal();
  factory OrdersProvider() => _instance;
  OrdersProvider._internal();
  bool isLoading = false;
  void toggleIsLoading(bool value) {
    isLoading = value;
    mainLocalLog(
      'Order is ${value ? 'Loading on' : 'Loading Off'}',
    );
    notifyListeners();
  }
  //
  //
  //

  final SupabaseClient supabase = Supabase.instance.client;
  final ConnectivityProvider connectivity =
      ConnectivityProvider();
  List<Orders> _orders = [];
  List<Orders> get orders => _orders;

  final String tableName = 'orders';

  void clearOrders() {
    _orders.clear();
    // clearRecords();
    mainLocalLog('Orders Cleared');
    notifyListeners();
  }

  // void clearRecords() {
  //   orderItems.clear();
  // }

  bool isLoaded = false;
  void load(bool value) {
    isLoaded = value;
    mainLocalLog(
      value == true
          ? 'Orders Loaded is now true'
          : 'Orders Loaded is now false',
    );
    notifyListeners();
  }

  // CREATE a new order
  Future<Orders?> createOrder(Orders order) async {
    try {
      await mainLocalLog('Inner Order Creation Started');
      var barcode = returnOnlyDigits(uuidGen());
      order.barcode = barcode;
      await OrdersFunc().createOrder(order);
      await CreatedOrdersFunc().createOrders(
        CreatedOrders(order: order),
      );
      notifyListeners();
      return order;
    } catch (e) {
      await mainLocalLog(
        'Error Creating Order: ${e.toString()}',
      );
      return null;
    }
    // }
  }

  Future<int> updateOrder({required Orders order}) async {
    order.updatedAt = DateTime.now();
    try {
      await OrdersFunc().createOrder(order);
      var containsCreated =
          CreatedOrdersFunc()
              .getOrders()
              .where((exp) => exp.order.uuid == order.uuid)
              .toList();
      if (containsCreated.isEmpty) {
        await UpdatedOrdersFunc().createUpdatedOrder(order);
      } else {
        await CreatedOrdersFunc().createOrders(
          CreatedOrders(order: order),
        );
      }
      notifyListeners();
      await loadOrdersOffline(shopId());
      // syncData();
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error Updating Orders: ${e.toString()}',
      );
      notifyListeners();
      return 0;
    }
  }

  Future<void> loadSingleOrder({
    required String uuid,
  }) async {
    bool isOnline = await connectivity.isOnline();
    try {
      if (isOnline) {
        final data =
            await supabase
                .from(tableName)
                .select()
                .eq('uuid', uuid)
                .maybeSingle();
        if (data == null) {
          await mainLocalLog('Order Not Found');
          return;
        } else {
          Orders tempMainOrder = Orders.fromJson(data);
          Orders? existingOrder =
              orders
                      .where(
                        (rec) =>
                            rec.uuid == tempMainOrder.uuid,
                      )
                      .isNotEmpty
                  ? orders
                      .where(
                        (rec) =>
                            rec.uuid == tempMainOrder.uuid,
                      )
                      .first
                  : null;
          if (existingOrder != null) {
            await mainLocalLog('💖💖👏🥰Order Exists');
            orders.remove(existingOrder);
          }
          orders.add(tempMainOrder);
          orders.sort(
            (a, b) => b.createdAt.compareTo(a.createdAt),
          );
          await mainLocalLog(
            '💖💖👏🥰 Single Order Loaded',
          );
        }
        notifyListeners();
      }
    } catch (e) {
      await mainLocalLog(
        'Error Fetching Single Order: ${e.toString()}',
      );
    }
  }

  // READ all orders for a shop
  Future<List<Orders>> loadOrders(int shopId) async {
    await loadOrdersOffline(shopId);
    bool isOnline = await connectivity.isOnline();
    List<Map<String, dynamic>> tempList = [];
    if (isOnline && OrdersFunc().isSynced()) {
      await OrdersFunc().clearOrders();
      try {
        final data = await supabase
            .from(tableName)
            .select()
            .eq('shop_id', shopId)
            .order('created_at', ascending: false)
            .range(0, 1000);
        tempList.addAll(data);
        await mainLocalLog(
          'Orders Gotten ${tempList.length}',
        );

        if (data.length >= 1000) {
          final data2 = await supabase
              .from(tableName)
              .select()
              .eq('shop_id', shopId)
              .order('created_at', ascending: false)
              .range(1001, 2000);
          tempList.addAll(data2);
          await mainLocalLog(
            'Orders Gotten Second ${tempList.length}',
          );
        }

        _orders =
            (tempList as List)
                .map((json) => Orders.fromJson(json))
                .toList();
        await OrdersFunc().insertAllOrders(_orders);
        await mainLocalLog('Loaded');
        notifyListeners();
      } catch (e) {
        await mainLocalLog(
          'Error Getting Orders: ${e.toString()}',
        );
        return [];
      }
    } else {
      _orders = OrdersFunc().getOrders();
      await mainLocalLog('Offline Orders Gotten');
      notifyListeners();
    }
    notifyListeners();
    return _orders;
  }

  Future<List<Orders>> loadOrdersOffline(int shopId) async {
    _orders = OrdersFunc().getOrders();
    await mainLocalLog('Offline Orders Gotten');
    notifyListeners();
    return _orders;
  }

  DateTime? dateSet;

  void clearDate() {
    dateSet = null;
    rangeStartDate = null;
    rangeEndDate = null;
    notifyListeners();
  }

  void setDate(DateTime date) {
    if (dateSet == null) {
      dateSet = date;
      rangeStartDate = null;
      rangeEndDate = null;
      mainLocalLog('Date set: $date');
    } else {
      dateSet = null;
      mainLocalLog('Date Cleared');
    }
    notifyListeners();
  }

  DateTime? rangeStartDate;
  DateTime? rangeEndDate;

  void setRange(DateTime rangeStart, DateTime endOfrange) {
    rangeStartDate = rangeStart;
    rangeEndDate = endOfrange;
    mainLocalLog(
      'Date Range set: Start: $rangeStart End: $endOfrange ',
    );
    dateSet = null;
    notifyListeners();
  }

  // DELETE a order
  Future<int> deleteOrder(
    Orders order,
    List<String> productNames,
  ) async {
    try {
      await mainLocalLog('Deleting Order Offline');
      await OrdersFunc().deleteOrder(order.uuid!);
      var containsCreated =
          CreatedOrdersFunc()
              .getOrders()
              .where((rec) => rec.order.uuid == order.uuid)
              .toList();
      var containsUpdate = UpdatedOrdersFunc()
          .getOrderIds()
          .where((rec) => rec.order.uuid == order.uuid!);
      if (containsCreated.isNotEmpty) {
        await CreatedOrdersFunc().deleteOrder(order.uuid!);
      } else {
        await DeletedOrdersFunc().createDeletedOrder(
          DeletedOrders(orderUuid: order.uuid!),
        );
      }
      if (containsUpdate.isNotEmpty) {
        await UpdatedOrdersFunc().deleteUpdatedOrder(
          order.uuid!,
        );
      }

      await loadOrdersOffline(
        returnShopProvider().userShop()!.shopId!,
      );

      await mainLocalLog('Totally Finished Deleting Order');
      notifyListeners();
      syncData();
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error Deleting Order: ${e.toString()}',
      );
      return 0;
    }
  }

  //
  //
  //
  //

  Future<void> createOrdersSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      // Prepare batch payload
      if (CreatedOrdersFunc().getOrders().isNotEmpty &&
          isOnline) {
        List<CreatedOrders> tempOrders =
            CreatedOrdersFunc().getOrders().toList();
        List<CreatedOrders> newOrders =
            tempOrders.map((rec) {
              rec.order.createdAt =
                  rec.order.createdAt.toUtc();
              return rec;
            }).toList();
        int count = 0;
        for (var item in newOrders) {
          try {
            // Insert all at once
            await supabase
                .from(tableName)
                .insert(item.order.toJson())
                .select();
            count++;
            await CreatedOrdersFunc().deleteOrder(
              item.order.uuid!,
            );
          } on PostgrestException catch (e) {
            if (e.code == '23505') {
              await CreatedOrdersFunc().deleteOrder(
                item.order.uuid!,
              );
            }
            await mainLocalLog(
              'Error Synchronizing Order ${item.order.total ?? 0}: $e',
            );
          }
        }

        await mainLocalLog(
          '$count items added successfully ✅',
        );
        // await CreatedOrdersFunc().clearOrders();
        await mainLocalLog('Unsynced Orders Cleared');
        await mainLocalLog('Mounted, refreshing Orders ✅');
        await loadOrders(
          returnShopProvider().userShop()!.shopId!,
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Orders Insert failed ❌: $e',
      );
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

  Future<void> deleteOrdersSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      // Prepare batch payload
      if (DeletedOrdersFunc().getOrderIds().isNotEmpty &&
          isOnline) {
        final tempOrders =
            DeletedOrdersFunc().getOrderIds().toList();

        for (var rec in tempOrders) {
          await supabase
              .from(tableName)
              .delete()
              .eq('uuid', rec.orderUuid);
          await DeletedOrdersFunc().deletedDeletedOrders(
            rec.orderUuid,
          );
        }

        await mainLocalLog(
          '${tempOrders.length} Orders Created successfully ✅',
        );
        await DeletedOrdersFunc().clearDeletedOrders();
        await mainLocalLog(
          'Unsynced Deleted Orders Cleared',
        );
        await mainLocalLog('Mounted, refreshing Orders ✅');
        await loadOrders(
          returnShopProvider().userShop()!.shopId!,
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Orders Delete failed ❌: $e',
      );
    }
  }
  //
  //
  //
  //
  //

  Future<void> updateOrdersSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      // Prepare batch payload
      if (UpdatedOrdersFunc().getOrderIds().isNotEmpty &&
          isOnline) {
        final tempOrders =
            UpdatedOrdersFunc().getOrderIds().toList();
        for (var rec in tempOrders) {
          await supabase
              .from(tableName)
              .update(rec.order.toJson())
              .eq('uuid', rec.order.uuid ?? '');
          await UpdatedOrdersFunc().deleteUpdatedOrder(
            rec.order.uuid ?? '',
          );
        }

        await mainLocalLog(
          '${tempOrders.length} items added successfully ✅',
        );
        await UpdatedOrdersFunc().clearUpdatedOrders();
        await mainLocalLog('Unsynced Orders Cleared');
        await mainLocalLog('Mounted, refreshing Orders ✅');
        await loadOrders(
          returnShopProvider().userShop()!.shopId!,
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Orders Update failed ❌: $e',
      );
    }
  }

  //
  //
  //
  //
  //
  //
  //

  Future<void> onEditOrder({
    required Orders order,
    required BuildContext context,
  }) async {
    SalesAuthAction().editReceiptAction(
      context: context,
      action: () async {
        // Convert them back to cart items
        final cartItems = convertOrderToCartItems(
          order: order,
          saleRecords: order.orderItems,
          context: context,
        );

        if (returnSalesProvider()
            .currentMainCart()
            .cartQueue
            .where(
              (cart) =>
                  cart.orderUuidEdit != null &&
                  cart.orderUuidEdit == order.uuid,
            )
            .isEmpty) {
          var newId = uuidGen();
          var tempCart = TempCart(
            comment: order.comment,
            timeOfDay: null,
            hasPrintedDocket: false,
            subStaffName: order.subStaffName,
            customDate: null,
            departmentName: order.departmentName,
            departmentUuid: order.departmentUuid,
            staffId: order.staffId,
            staffName: order.staffName,
            id: newId,
            fixedDiscount: order.fixedDiscount,
            createdDate: order.createdAt,
            cartItems: cartItems,
            cartItemTypeIndex: 3,
            orderUuidEdit: order.uuid,
            discount: order.generalDiscount,
            paymentMethod: 0,
            selectedCustomer: order.customerId,
            selectedCustomerName: order.customerName,
            isReceiptEdit: true,
            subStaffUuid: order.subStaffUuid,
          );
          await returnSalesProvider().addNewCart(
            context,
            tempCart,
          );
          await returnMultiDisplayProvider().updateWindow(
            cartClass: AltCartClass(
              cartId: tempCart.id!,
              cartItems:
                  tempCart.cartItems.reversed.toList(),
              fixedDiscount: order.fixedDiscount,
              percentDiscount: order.generalDiscount,
              vat: order.vat ?? 0,
              currency:
                  returnShopProvider().userShop()!.currency,
            ),
          );
          notifyListeners();
        } else {
          await returnSalesProvider().selectCart(
            returnSalesProvider()
                .currentMainCart()
                .cartQueue
                .where(
                  (cart) =>
                      cart.orderUuidEdit == order.uuid,
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

  // EDIT Order
  TempCartItem saleRecordToCartItem({
    required OrderItems record,
    required TempProductClass product,
  }) {
    double tempRev = 0;
    if (record.customPriceSet) {
      if (record.setTotalPrice != null &&
          record.setTotalPrice == true) {
        tempRev =
            ((record.originalCost ?? 0) *
                record.getActualQuantity());
      } else {
        tempRev = (record.originalCost ?? 0);
      }
    }
    return TempCartItem(
      uuid: record.uuid,
      itemUuid: product.uuid,
      isVoid: false,
      remainingBalance: record.getRemainingBalance(),
      remainingQuantity: record.remainingQuantity,
      item: product,
      quantity: record.quantity,
      discount: record.discount,
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

  List<TempCartItem> convertOrderToCartItems({
    required Orders order,
    required List<OrderItems> saleRecords,
    required BuildContext context,
  }) {
    List<TempCartItem> cartItems = [];

    for (var record in saleRecords) {
      var product = returnData().productList().where(
        (p) => p.uuid == record.productUuid,
      );

      if (product.isNotEmpty) {
        var newRecord = record.copyWith();
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
        var newRecord = record.copyWith();
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
                ? record.getTotalRevenue() / record.quantity
                : (record.originalCost ?? 0) /
                    record.quantity;
        final double wholeSalePrice =
            record.discount == null
                ? record.getTotalRevenue() / record.quantity
                : (record.originalCost ?? 0) /
                    record.quantity;

        TempProductClass productNew = TempProductClass(
          useGroupUnit: false,
          categories: [],
          groupUnit: 'Group(s)',
          storageUuid: null,
          qttyPerGroup: null,
          name: record.productName,
          unit: record.unit ?? 'Unit(s)',
          isRefundable: false,
          costPrice: costPrice,
          shopId: shopId(),
          setCustomPrice: true,
          isManaged: false,
          barcode: null,
          brand: null,
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

  Future<dynamic> cancelOrderEdit(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return ConfirmationAlert(
          theme: returnTheme(context, listen: false),
          message:
              'You are currently editing this order, are you sure you want to cancel this edit?',
          title: 'Cancel Edit?',
          action: () async {
            if (returnSalesProvider()
                .currentCart()
                .isReceiptEdit) {
              if (returnSalesProvider()
                      .currentMainCart()
                      .cartQueue
                      .length ==
                  1) {
                await returnSalesProvider().addNewCart(
                  context,
                  TempCart(
                    comment: null,
                    timeOfDay: null,
                    // createdDate: DateTime.now(),
                    hasPrintedDocket: false,
                    subStaffName: null,
                    customDate: null,
                    departmentName: null,
                    departmentUuid: null,
                    cartItems: [],
                    cartItemTypeIndex: 2,
                    orderUuidEdit: null,
                    staffId: currentUser().userId,
                    staffName:
                        "${currentUser().name} ${currentUser().lastName}",
                    id: uuidGen(),
                  ),
                );
              }

              await returnSalesProvider().deleteCart(
                cartId: returnSalesProvider().cartIdCache,
                context: context,
              );
              // await selectCart(cartIndex - 1);
              notifyListeners();
              if (context.mounted) {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              }
            } else {
              Navigator.of(context).pop();
            }
          },
        );
      },
    );
  }

  //
  //
  //
  //
  //

  double calcSalesRecordRevenue({
    required double invoceTotalAmount,
    required double receiptPayment,
    required double salesRecodRevenue,
  }) {
    double paymentPercent =
        ((receiptPayment * 100) / invoceTotalAmount);
    double result =
        ((paymentPercent * salesRecodRevenue) / 100);
    return result;
  }

  double calcSalesRecordCostPrice({
    required double invoceTotalAmount,
    required double receiptPayment,
    required double salesRecodCostPrice,
  }) {
    double paymentPercent =
        ((receiptPayment * 100) / invoceTotalAmount);
    double result =
        ((paymentPercent * salesRecodCostPrice) / 100);
    return result;
  }

  double calcSalesRecordDiscountedAmount({
    required double invoceTotalAmount,
    required double receiptPayment,
    required double salesRecodDiscountedAmount,
  }) {
    double paymentPercent =
        ((receiptPayment * 100) / invoceTotalAmount);
    double result =
        ((paymentPercent * salesRecodDiscountedAmount) /
            100);
    return result;
  }

  double calcSalesRecordOriginalCost({
    required double invoceTotalAmount,
    required double receiptPayment,
    required double salesRecodOriginalCost,
  }) {
    double paymentPercent =
        ((receiptPayment * 100) / invoceTotalAmount);
    double result =
        ((paymentPercent * salesRecodOriginalCost) / 100);
    return result;
  }
  //

  Future<void> makeOrderItemDelivery({
    required Orders order,
    required BuildContext context,
    required double cashAmount,
    required double bankAmount,
    required double customerAmount,
  }) async {
    try {
      final createdAt = DateTime.now().toUtc();
      TempMainReceipt receipt = TempMainReceipt(
        salesTypeIndex: 3,
        orderUuid: order.uuid,
        comment: returnOrdersActionProvider().comment,
        subStaffName: null,
        createdAt: createdAt,
        shopId: order.shopId,
        staffId: currentUser().userId,
        staffName:
            "${returnUserProviderSingle().currentUserMain!.name} ${returnUserProviderSingle().currentUserMain!.lastName}",
        paymentMethod: returnSalesProvider()
            .returnPaymentMethod(
              index:
                  returnOrdersActionProvider()
                      .paymentOption,
            ),
        bank: bankAmount,
        customerAccount: customerAmount,
        cashAlt: cashAmount,
        isInvoice: true,
        customerName: order.customerName,
        customerUuid: order.customerId,
        departmentName: order.departmentName,
        departmentUuidNew: order.departmentUuid,
        invoiceUuid: null,
        uuid: uuidGen(),
        generalDiscount: null,
        fixedDiscount: null,
        vat: order.vat,
        originalCost: order.originalCost,
        balance:
            (order.getCalculatedRemainingBalance() -
                        returnOrdersActionProvider()
                            .totalOrdersAmount()) <=
                    0
                ? 0
                : order.getCalculatedRemainingBalance() -
                    returnOrdersActionProvider()
                        .totalOrdersAmount(),
        subStaffUuid: null,
        cartName: null,
      );

      await mainLocalLog('Checkout Started');
      var res = await returnReceiptProviderSingle()
          .createReceipt(receipt);
      if (res != null) {
        await mainLocalLog('Receipt Created');

        List<OrderItems> orderItemsTemp =
            returnOrdersActionProvider().orderListItems;

        final productSaleRecords =
            orderItemsTemp.map((record) {
              mainLocalLog(
                'Sales Record about to be Created',
              );
              return TempProductSaleRecord(
                isVoid: false,
                customPriceSet: record.customPriceSet,
                createdAt: createdAt,
                productId: 1,
                productUuid: record.productUuid,
                productName: record.productName,
                shopId: order.shopId,
                staffId: currentUser().userId!,
                staffName:
                    "${returnUserProviderSingle().currentUserMain!.name} ${returnUserProviderSingle().currentUserMain!.lastName}",
                // customerId: customerId,
                customerUuid: order.customerId,
                customerName: order.customerName,
                recepitId: 0,
                receiptUuid: res.uuid,
                quantity: record.quantity,
                revenue: record.getTotalRevenue(),
                costPrice: record.getTotalCostPrice(),
                discountedAmount: null,
                originalCost:
                    record.getTotalOriginalSellingPrice(),
                discount: record.discount,
                fixedDiscount: record.fixedDiscount,
                addToStock: false,
                departmentName:
                    record.departmentName ??
                    returnDepartmentProvider()
                        .currentDepartment()
                        ?.name,
                departmentUuid:
                    record.departmentUuid ??
                    returnDepartmentProvider()
                        .currentDepartment()
                        ?.uuid,
                uuid: uuidGen(),
                isProductManaged: record.isProductManaged,
                setTotalPrice: record.setTotalPrice,
                unit: record.getUnit(),
                useWholeSalePrice: record.useWholeSalePrice,
                useGroupQuantity: record.useGroupQuantity,
                qttyPerGroup: record.qttyPerGroup,
                // orderUuid: order.uuid,
              );
            }).toList();

        await mainLocalLog(
          'Creating Record Sales About to Start',
        );
        await returnReceiptProviderSingle()
            .createProductSaleRecord(
              records: productSaleRecords,
              isPartPayment: false,
            );
        await mainLocalLog('Sales Record Inserted');
        var newOrder = order.copyWith();

        // newOrder.balance =
        //     (newOrder.getCalculatedRemainingBalance()) -
        //     returnOrdersActionProvider()
        //         .totalOrdersAmount();

        // if ((newOrder.getCalculatedRemainingBalance()) <= 0) {
        //   newOrder.balance = 0;
        // }

        for (var item in orderItemsTemp) {
          var itemTemp = newOrder.getOrderItem(
            newItem: item,
          );
          if (itemTemp != null) {
            itemTemp.remainingQuantity =
                (itemTemp.remainingQuantity ?? 0) -
                item.quantity;
            if ((itemTemp.remainingBalance ?? 0) <= 0) {
              itemTemp.remainingBalance = 0;
            }
          }
        }
        await updateOrder(order: newOrder);
        await returnReceiptProviderSingle()
            .loadReceiptsOffline(shopId());
        for (var item in orderItemsTemp) {
          List<TempProductClass> products =
              returnData().productListMain
                  .where(
                    (it) => it.uuid == item.productUuid,
                  )
                  .toList();
          if (products.isNotEmpty) {
            var productTemp = products.first;
            var product = productTemp.copyWith();
            if (((product.quantity ?? 0) > 0) &&
                (item.isProductManaged ?? false)) {
              product.quantity =
                  (product.quantity ?? 0) -
                  item.getActualQuantity();
              ItemHistory itemHistory = ItemHistory(
                shopId: shopId(),
                desc:
                    '${item.getActualQuantity()} Quantity(s) of This Item was Delivered. Receipt Id: #${returnOnlyDigits(receipt.uuid ?? '')}... Order Id: #${returnOnlyDigits(order.uuid ?? '')}',
                isIncreased: false,
                oldValue:
                    ((product.quantity ?? 0) +
                            item.getActualQuantity())
                        .toString(),
                title: 'Order Item Delivered',
                quantityChange: -item.getActualQuantity(),
                newValue: product.quantity.toString(),
              );
              await returnData().updateProduct(
                itemHistory:
                    returnData()
                            .productList()
                            .where(
                              (pro) =>
                                  pro.name == product.name,
                            )
                            .isEmpty
                        ? null
                        : itemHistory,
                includeQuantity: false,
                product: product,
                isQuantityUpdate: true,
                quantityChange: item.getActualQuantity(),
                isMultipleUpdate: true,
                isIncrement: false,
              );
            } else {
              ItemHistory itemHistory = ItemHistory(
                desc:
                    '${item.getActualQuantity()} Quantity(s) of This Item was Delivered, but Not Deducted Because Item is Not Managed. Receipt Id: #${returnOnlyDigits(receipt.uuid ?? '')}... Order Id: #${returnOnlyDigits(order.uuid ?? '')}',
                shopId: shopId(),
                isIncreased: false,
                oldValue:
                    (product.quantity ?? 0).toString(),
                title: 'Order Item Delivered (Unmanaged)',
                quantityChange: 0,
                newValue:
                    (product.quantity ?? 0).toString(),
              );
              itemHistory.itemName = product.name;
              itemHistory.itemUuid = product.uuid;
              await returnItemHistoryProvider()
                  .createItemHistory(itemHistory);
            }
          }
        }
        returnData().syncData();
        await mainLocalLog(
          'Context is Not Mounted So Offline Data Cannot Be Synchronized',
        );
        notifyListeners();
        returnOrdersActionProvider().clearAll();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ReceiptPage(
                response: CheckoutResponse(receipt: res),
                isMain: false,
              );
            },
          ),
        ).then((_) {
          Navigator.of(context).pop();
        });
      } else {
        await mainLocalLog(
          'Failed to Create Receipt From Order',
        );
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (errorContext) {
            return InfoAlert(
              theme: returnTheme(context, listen: false),
              message:
                  'An Error Occoured While Performing This Operation. Please Try again Later.',
              title: 'An Error Occoured',
            );
          },
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Error Converting Delivery Items to Cart Item For Delivery Receipt Creating: ${e.toString()}',
      );
    }
  }

  //
  //
  //
  //
  //

  Future<int> deleteDeliveryReceipt({
    required TempMainReceipt receipt,
    required List<TempProductSaleRecord> records,
    required String? orderUuid,
  }) async {
    try {
      await returnReceiptProviderSingle().deleteReceipt(
        receipt,
        records.map((rec) => rec.productName).toList(),
      );
      if (orderUuid != null) {
        List<Orders> ordersTemp =
            orders
                .where((item) => item.uuid == orderUuid)
                .toList();
        if (ordersTemp.isNotEmpty) {
          var orderTemp = orders.first.copyWith();
          // orderTemp.balance =
          //     (orderTemp.getCalculatedRemainingBalance()) +
          //     receipt.getTotalRevenue();
          // if ((orderTemp.getCalculatedRemainingBalance()) >
          //     (orderTemp.total ?? 0)) {
          //   orderTemp.balance =
          //       (orderTemp.total ?? 0) -
          //       (orderTemp.getTotalPayment());
          // }
          for (var item in records) {
            var orderItems = orderTemp.orderItems.where(
              (it) => it.productUuid == item.productUuid,
            );
            if (orderItems.isNotEmpty) {
              var orderItem = orderItems.first;
              orderItem.remainingQuantity =
                  (orderItem.remainingQuantity ?? 0) +
                  item.quantity;
              if ((orderItem.remainingQuantity ?? 0) >
                  orderItem.quantity) {
                orderItem.remainingQuantity =
                    orderItem.quantity;
              }
            }
          }

          await updateOrder(order: orderTemp);
          syncData();
        }
      }

      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error Deleting Delivery Receipt: ${e.toString()}',
      );
      return 0;
    }
  }

  //
  //
  //
  //
  //

  List<OrderItems> _orderItems = [];
  List<OrderItems> get orderItems => _orderItems;

  List<Orders> departmentOrders() {
    if (returnShopProvider()
            .userShop()
            ?.manageDepartments ==
        true) {
      if (!authorization(
        authorized: Authorizations().viewAllDepartments,
      )) {
        return orders.where((cat) {
          return cat.departmentUuid ==
              returnDepartmentProvider()
                  .currentDepartment()
                  ?.uuid;
        }).toList();
      } else {
        if (returnDepartmentProvider()
                .currentDepartment()
                ?.uuid ==
            null) {
          return orders;
        } else {
          return orders.where((cat) {
            return cat.departmentUuid ==
                returnDepartmentProvider()
                    .currentDepartment()
                    ?.uuid;
            // }
          }).toList();
        }
      }
    } else {
      return orders;
    }
  }

  List<Orders> returnAllOrSetDateOrders() {
    if (dateSet == null &&
        rangeEndDate == null &&
        rangeStartDate == null) {
      return orders;
    } else {
      return returnOrdersByDayOrWeekAll();
    }
  }

  List<Orders> returnUnpaidOrders() {
    return returnOrdersByDayOrWeekAll()
        .where(
          (order) =>
              (order.total ?? 0) ==
              order.getCalculatedRemainingBalance(),
        )
        .toList();
  }

  List<Orders> returnPartiallyPaidOrders() {
    return returnOrdersByDayOrWeekAll()
        .where(
          (order) =>
              order.getCalculatedRemainingBalance() != 0 &&
              (order.total ?? 0) >
                  order.getCalculatedRemainingBalance(),
        )
        .toList();
  }

  List<Orders> returnPaidOrders() {
    return returnOrdersByDayOrWeekAll()
        .where(
          (order) =>
              order.getCalculatedRemainingBalance() == 0,
        )
        .toList();
  }

  int orderPaymentStatusIndex = 0;

  void selectPaymentStatus(int index) {
    orderPaymentStatusIndex = index;
    notifyListeners();
  }

  List<Orders> returnOrdersBasedOnPaymentStatus() {
    if (rangeStartDate != null) {
      return departmentOrders().where((order) {
        final created = order.createdAt.toLocal();
        return !created.isBefore(
              fourAm(rangeStartDate ?? DateTime.now()),
            ) &&
            !created.isAfter(
              fourAmNextDay(rangeEndDate ?? DateTime.now()),
            );
      }).toList();
    }

    if (dateSet != null) {
      return departmentOrders().where((order) {
        final created = order.createdAt.toLocal();
        final inRange =
            !created.isBefore(
              fourAm(dateSet ?? DateTime.now()),
            ) &&
            !created.isAfter(
              fourAmNextDay(dateSet ?? DateTime.now()),
            );

        return inRange;
      }).toList();
    }
    return departmentOrders();
  }

  List<Orders> returnOrdersByDayOrWeekAll() {
    if (orderPaymentStatusIndex == 0) {
      return returnOrdersBasedOnPaymentStatus()
          .where(
            (order) =>
                (order.total ?? 0) ==
                order.getCalculatedRemainingBalance(),
          )
          .toList();
    } else if (orderPaymentStatusIndex == 1) {
      return returnOrdersBasedOnPaymentStatus()
          .where(
            (order) =>
                order.getCalculatedRemainingBalance() == 0,
          )
          .toList();
    } else if (orderPaymentStatusIndex == 2) {
      return returnOrdersBasedOnPaymentStatus()
          .where(
            (order) =>
                order.getCalculatedRemainingBalance() !=
                    0 &&
                (order.total ?? 0) >
                    order.getCalculatedRemainingBalance(),
          )
          .toList();
    } else {
      return returnOrdersBasedOnPaymentStatus().toList();
    }
  }

  double getTotalRevenueForSelectedDayAll({
    String? staffId,
    String? customerId,
    String? subStaffId,
  }) {
    double tempTotalRevenue = 0;

    for (var order
        in (staffId != null
            ? returnOrdersByDayOrWeekAll().where(
              (rec) => rec.staffId == staffId,
            )
            : subStaffId != null
            ? returnOrdersByDayOrWeekAll().where(
              (rec) => rec.subStaffUuid == subStaffId,
            )
            : customerId != null
            ? returnOrdersByDayOrWeekAll().where(
              (rec) => rec.customerId == customerId,
            )
            : returnOrdersByDayOrWeekAll())) {
      tempTotalRevenue +=
          order.getCalculatedRemainingBalance();
    }

    return tempTotalRevenue;
  }
  //
  //
  //
  //

  double getTotalMainRevenueOrder({required Orders order}) {
    var total = ((order.total ?? 0));

    return total;
  }

  double getAmountPaid({required Orders order}) {
    double tempValue = 0;
    List<TempMainReceipt> receiptsTemp =
        returnReceiptProviderSingle().receipts
            .where((rec) => rec.orderUuid == order.uuid)
            .toList();
    for (var val in receiptsTemp) {
      tempValue +=
          (val.bank +
              val.cashAlt +
              (val.customerAccount ?? 0));
    }
    return tempValue;
  }

  // double getBalance({required Orders order}) {
  //   return order.getCalculatedRemainingBalance();
  // }

  double getDiscountAmountForOrder(Orders order) {
    if (order.fixedDiscount != null) {
      return (order.fixedDiscount ?? 0);
    } else if (order.generalDiscount != null) {
      return (getOriginalCostOrder(order) *
          ((order.generalDiscount ?? 0) / 100));
    } else {
      return 0;
    }
  }

  List<OrderItems> returnOrderItemsByDayOrWeek() {
    if (rangeStartDate != null) {
      if (authorization(
        authorized:
            Authorizations().viewAllTransactionRecords,
      )) {
        return orderItems.where((record) {
          final created = record.createdAt.toLocal();
          return !created.isBefore(
                fourAm(rangeStartDate!),
              ) &&
              created.isBefore(
                fourAmNextDay(
                  rangeEndDate ??
                      resolveBusinessDate(DateTime.now()),
                ),
              );
        }).toList();
      } else {
        return orderItems.where((record) {
          final created = record.createdAt.toLocal();
          return !created.isBefore(
                fourAm(rangeStartDate!),
              ) &&
              created.isBefore(
                fourAmNextDay(
                  rangeEndDate ??
                      resolveBusinessDate(DateTime.now()),
                ),
              ) &&
              record.staffId == currentUser().userId;
        }).toList();
      }
    }

    var currentDate = dateSet ?? DateTime.now();
    if (authorization(
      authorized:
          Authorizations().viewAllTransactionRecords,
    )) {
      return orderItems
          .where(
            (record) =>
                !record.createdAt.isBefore(
                  fourAm(currentDate),
                ) &&
                !record.createdAt.isAfter(
                  fourAmNextDay(currentDate),
                ),
          )
          .toList();
    } else {
      return orderItems
          .where(
            (record) =>
                !record.createdAt.isBefore(
                  fourAm(currentDate),
                ) &&
                !record.createdAt.isAfter(
                  fourAmNextDay(currentDate),
                ) &&
                record.staffId == currentUser().userId,
          )
          .toList();
    }
  }

  //
  //
  //

  double getTotalRevenueForSelectedDay() {
    double tempTotalRevenue = 0;

    for (var order in returnOrdersByDayOrWeekAll()) {
      tempTotalRevenue += getTotalMainRevenueOrder(
        order: order,
      );
    }

    return tempTotalRevenue;
  }

  //
  //
  //

  double getVATForOrder(Orders order) {
    return (getOriginalCostOrder(order) *
        ((order.vat ?? 0) / 100));
  }

  double getOriginalCostOrder(Orders order) {
    return order.originalCost ?? 0;
  }

  // double getTotalMainRevenueOrder(Orders order) {
  //   return order.total ?? 0;
  // }

  String unitText({required OrderItems record}) {
    if (record.useGroupQuantity == true) {
      return record.groupUnit ?? 'Group(s)';
    } else {
      return record.unit ?? 'Unit(s)';
    }
  }

  //
  //
  //
  //
  //
  //
  //

  List<StaffGroupOrders> groupOrdersByStaff() {
    final Map<String?, StaffGroupOrders> grouped = {};

    for (final order in returnOrdersByDayOrWeekAll()) {
      final String? staffUuid = order.staffId;

      if (!grouped.containsKey(staffUuid)) {
        grouped[staffUuid] = StaffGroupOrders(
          staffUuid: staffUuid ?? '',
          staffName:
              staffUuid == null
                  ? null
                  : order.staffName ?? '',
          number: 0,
          totalBalance: 0,
          totalOriginalCost: 0,
          totalRevenue: 0,
        );
      }

      final group = grouped[staffUuid]!;

      group.number++;
      group.totalBalance +=
          order.getCalculatedRemainingBalance();
      group.totalOriginalCost += order.originalCost ?? 0;
      group.totalRevenue += (order.total ?? 0);
    }

    var res = grouped.values.toList();
    res.sort(
      (a, b) => ((a.staffName ?? 'Not Set').toLowerCase())
          .compareTo(
            (b.staffName ?? 'Not Set').toLowerCase(),
          ),
    );
    return res;
  }

  List<CustomerGroupOrders> groupOrdersByCustomer() {
    final Map<String?, CustomerGroupOrders> grouped = {};

    for (final order in returnOrdersByDayOrWeekAll()) {
      final String? customerId = order.customerId;

      if (!grouped.containsKey(customerId)) {
        grouped[customerId] = CustomerGroupOrders(
          customerUuid: customerId ?? '',
          customerName:
              customerId == null
                  ? null
                  : order.customerName ?? '',
          number: 0,
          totalBalance: 0,
          totalOriginalCost: 0,
          totalRevenue: 0,
        );
      }

      final group = grouped[customerId]!;

      group.number++;
      group.totalBalance +=
          order.getCalculatedRemainingBalance();
      group.totalOriginalCost += order.originalCost ?? 0;
      group.totalRevenue += (order.total ?? 0);
    }

    var res = grouped.values.toList();
    res.sort(
      (a, b) =>
          ((a.customerName ?? 'Not Set').toLowerCase())
              .compareTo(
                (b.customerName ?? 'Not Set').toLowerCase(),
              ),
    );
    return res;
  }

  List<DepartmentGroupOrders> groupOrdersByDepartment() {
    final Map<String?, DepartmentGroupOrders> grouped = {};

    for (final order in returnOrdersByDayOrWeekAll()) {
      final String? departmentUuid = order.departmentUuid;

      if (!grouped.containsKey(departmentUuid)) {
        grouped[departmentUuid] = DepartmentGroupOrders(
          departmentUuid: departmentUuid ?? '',
          departmentName:
              departmentUuid == null
                  ? null
                  : order.departmentName ?? '',
          number: 0,
          totalBalance: 0,
          totalOriginalCost: 0,
          totalRevenue: 0,
        );
      }

      final group = grouped[departmentUuid]!;

      group.number++;
      group.totalBalance +=
          order.getCalculatedRemainingBalance();
      group.totalOriginalCost += order.originalCost ?? 0;
      group.totalRevenue += (order.total ?? 0);
    }

    var res = grouped.values.toList();
    res.sort(
      (a, b) => ((a.departmentName ?? 'Not Set')
              .toLowerCase())
          .compareTo(
            (b.departmentName ?? 'Not Set').toLowerCase(),
          ),
    );
    return res;
  }

  //
  //
  //
  ////////////  GENERAL REPORT PRINTING  // // // /  /  // // //

  List<GeneralReportSalesSummaryItem>
  returnGeneralReportSalesSummary() {
    final List<OrderItems> records =
        returnOrderItemsByDayOrWeek().toList();

    Map<String, List<OrderItems>> grouped = {};

    for (var item in records) {
      if (returnShopProvider()
              .userShop()
              ?.manageInventoryStorage ==
          true) {
        List<TempProductClass> productList =
            returnData().productListMain
                .where(
                  (pro) => pro.uuid == item.productUuid,
                )
                .toList();
        if (productList.isNotEmpty) {
          TempProductClass product = productList.first;
          if (product.storageUuid != null) {
            final uuid = product.storageUuid ?? '';
            grouped.putIfAbsent(uuid, () => []);
            grouped[uuid]!.add(item);
          } else {
            final uuid = product.uuid ?? '';

            grouped.putIfAbsent(uuid, () => []);
            grouped[uuid]!.add(item);
          }
        } else {
          final uuid = item.productUuid;
          grouped.putIfAbsent(uuid, () => []);
          grouped[uuid]!.add(item);
        }
      } else {
        final uuid = item.productUuid;

        grouped.putIfAbsent(uuid, () {
          return [];
        });
        grouped[uuid]!.add(item);
      }
    }

    List<GeneralReportSalesSummaryItem> result = [];

    grouped.forEach((uuid, items) {
      double totalQtty = items.fold(
        0,
        (sum, e) => sum + e.quantity,
      );

      double totalCost = items.fold(
        0,
        (sum, e) => sum + e.getTotalRevenue(),
      );

      double totalCostPrice = items.fold(
        0,
        (sum, e) => sum + (e.costPrice ?? 0),
      );

      String itemName() {
        List<TempProductClass> products =
            returnData().productListMain
                .where(
                  (pro) =>
                      pro.uuid == items.first.productUuid,
                )
                .toList();
        if (products.isNotEmpty) {
          TempProductClass product = products.first;
          if (returnShopProvider()
                  .userShop()
                  ?.manageInventoryStorage ==
              true) {
            var storageItems =
                returnStorageProductProvider()
                    .storageProductListMain
                    .where(
                      (item) =>
                          item.uuid == product.storageUuid,
                    )
                    .toList();
            if (storageItems.isNotEmpty) {
              return storageItems.first.name;
            } else {
              return product.name;
            }
          } else {
            return product.name;
          }
        } else {
          return items.first.productName;
        }
      }

      result.add(
        GeneralReportSalesSummaryItem(
          costPrice: totalCostPrice,
          itemName: itemName(),
          itemUuid: uuid,
          quantity: totalQtty,
          totalCost: totalCost,
          departmentName:
              items.first.departmentName ??
              'Departmant Not Set',
          departmentUuid:
              items.first.departmentUuid ??
              'Department Not Set',
          staffName: items.first.staffName,
          staffUuid: items.first.staffId,
        ),
      );
    });
    result.sort((a, b) => b.quantity.compareTo(a.quantity));
    return result;
  }

  double getTotalSalesRevenue() {
    return returnOrderItemsByDayOrWeek()
        .toList()
        .map((item) => item.getTotalRevenue())
        .toList()
        .fold(0, (first, second) => first + second);
  }

  //
  //
  //
  //

  List<GeneralReportSalesSummaryItem>
  returnGeneralReportSalesSummaryNoDepartment() {
    final List<OrderItems> records =
        returnOrderItemsByDayOrWeek()
            .where((item) => item.departmentUuid == null)
            .toList();

    Map<String, List<OrderItems>> grouped = {};

    for (var item in records) {
      if (returnShopProvider()
              .userShop()
              ?.manageInventoryStorage ==
          true) {
        List<TempProductClass> productList =
            returnData().productListMain
                .where(
                  (pro) => pro.uuid == item.productUuid,
                )
                .toList();
        if (productList.isNotEmpty) {
          TempProductClass product = productList.first;
          if (product.storageUuid != null) {
            final uuid = product.storageUuid ?? '';
            grouped.putIfAbsent(uuid, () => []);
            grouped[uuid]!.add(item);
          } else {
            final uuid = product.uuid ?? '';

            grouped.putIfAbsent(uuid, () => []);
            grouped[uuid]!.add(item);
          }
        } else {
          final uuid = item.productUuid;

          grouped.putIfAbsent(uuid, () => []);
          grouped[uuid]!.add(item);
        }
      } else {
        final uuid = item.productUuid;

        grouped.putIfAbsent(uuid, () {
          return [];
        });
        grouped[uuid]!.add(item);
      }
    }

    List<GeneralReportSalesSummaryItem> result = [];

    grouped.forEach((uuid, items) {
      double totalQtty = items.fold(
        0,
        (sum, e) => sum + e.quantity,
      );

      double totalCost = items.fold(
        0,
        (sum, e) => sum + e.getTotalRevenue(),
      );

      double totalCostPrice = items.fold(
        0,
        (sum, e) => sum + (e.costPrice ?? 0),
      );

      String itemName() {
        List<TempProductClass> products =
            returnData().productListMain
                .where(
                  (pro) =>
                      pro.uuid == items.first.productUuid,
                )
                .toList();
        if (products.isNotEmpty) {
          TempProductClass product = products.first;
          if (returnShopProvider()
                  .userShop()
                  ?.manageInventoryStorage ==
              true) {
            var storageItems =
                returnStorageProductProvider()
                    .storageProductListMain
                    .where(
                      (item) =>
                          item.uuid == product.storageUuid,
                    )
                    .toList();
            if (storageItems.isNotEmpty) {
              return storageItems.first.name;
            } else {
              return product.name;
            }
          } else {
            return product.name;
          }
        } else {
          return items.first.productName;
        }
      }

      result.add(
        GeneralReportSalesSummaryItem(
          costPrice: totalCostPrice,
          itemName: itemName(),
          itemUuid: uuid,
          quantity: totalQtty,
          totalCost: totalCost,
          departmentName:
              items.first.departmentName ??
              'Departmant Not Set',
          departmentUuid:
              items.first.departmentUuid ??
              'Department Not Set',
          staffName: items.first.staffName,
          staffUuid: items.first.staffId,
        ),
      );
    });
    result.sort((a, b) => b.quantity.compareTo(a.quantity));
    return result;
  }

  //
  //
  //

  List<GeneralReportSalesSummaryItem>
  returnGeneralReportSalesSummaryByDepartment(
    String departmentUuid,
  ) {
    return returnGeneralReportSalesSummary()
        .where(
          (item) => item.departmentUuid == departmentUuid,
        )
        .toList();
  }

  double getTotalSalesRevenueForDepartment({
    required String deptUuid,
  }) {
    return returnOrderItemsByDayOrWeek()
        .where((item) => item.departmentUuid == deptUuid)
        .map((item) => item.getTotalRevenue())
        .toList()
        .fold(0, (first, second) => first + second);
  }

  //
  //
  //

  double getTotalSalesRevenueNoDepartment() {
    return returnOrderItemsByDayOrWeek()
        .where((item) => item.departmentUuid == null)
        .map((item) => item.getTotalRevenue())
        .toList()
        .fold(0, (first, second) => first + second);
  }

  //
  //
  //
  //
  //
  //
  //
  //

  List<GeneralReportSalesSummaryItemStaff>
  returnGeneralReportSalesSummaryByStaff() {
    final List<OrderItems> records =
        returnOrderItemsByDayOrWeek().toList();

    Map<String, List<OrderItems>> grouped = {};

    // STEP 1: Group by staff + product
    for (var item in records) {
      final staffId = item.staffId;
      final productId = item.productUuid;

      final key = '$staffId|$productId';

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(item);
    }

    // STEP 2: Build result
    List<GeneralReportSalesSummaryItemStaff> result = [];

    grouped.forEach((key, items) {
      final first = items.first;

      double totalQuantity = items.fold(
        0,
        (sum, e) => sum + (e.quantity),
      );

      double totalCost = items.fold(
        0,
        (sum, e) => sum + (e.getTotalRevenue()),
      );

      result.add(
        GeneralReportSalesSummaryItemStaff(
          itemName: first.productName,
          itemUuid: first.productUuid,
          staffName: first.staffName,
          staffUuid: first.staffId,
          quantity: totalQuantity,
          totalCost: totalCost,
        ),
      );
    });
    result.sort((a, b) => b.quantity.compareTo(a.quantity));

    return result;
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
  //

  int sortColumnIndex = 0;
  bool sortAscending = true;

  List<DataColumn> _headingTotal({
    required BuildContext context,
  }) {
    return [
      DataColumn2(label: HeadingTextWidget(title: '#Id')),
      DataColumn2(
        size: ColumnSize.L,

        label: HeadingTextWidget(title: 'Staff'),
      ),
      DataColumn2(
        size: ColumnSize.L,

        label: HeadingTextWidget(title: 'Customer'),
      ),
      DataColumn2(label: HeadingTextWidget(title: 'Date')),
      DataColumn2(label: HeadingTextWidget(title: 'Time')),
      DataColumn2(
        size: ColumnSize.S,
        label: HeadingTextWidget(title: 'Discount'),
      ),
      DataColumn2(
        size: ColumnSize.S,
        label: HeadingTextWidget(title: 'VAT'),
      ),
      DataColumn2(
        label: HeadingTextWidget(title: 'Balance'),
      ),
      DataColumn2(
        label: HeadingTextWidget(title: 'Sub-Total'),
      ),
      DataColumn2(
        label: HeadingTextWidget(title: 'Revenue'),
      ),
    ];
  }

  List<DataColumn> _headingStaffs() {
    return [
      DataColumn2(
        size: ColumnSize.L,

        label: HeadingTextWidget(title: 'Staff'),
      ),
      DataColumn2(
        size: ColumnSize.S,
        label: HeadingTextWidget(title: 'Quantity'),
      ),
      DataColumn2(
        size: ColumnSize.M,
        label: HeadingTextWidget(title: 'Balance'),
      ),
      DataColumn2(
        label: HeadingTextWidget(title: 'Sub-Total'),
      ),
      DataColumn2(
        label: HeadingTextWidget(title: 'Revenue'),
      ),
    ];
  }

  List<DataColumn> _headingCustomers() {
    return [
      DataColumn2(
        size: ColumnSize.L,

        label: HeadingTextWidget(title: 'Customer'),
      ),
      DataColumn2(
        size: ColumnSize.S,
        label: HeadingTextWidget(title: 'Quantity'),
      ),
      DataColumn2(
        size: ColumnSize.M,
        label: HeadingTextWidget(title: 'Balance'),
      ),
      DataColumn2(
        label: HeadingTextWidget(title: 'Sub-Total'),
      ),
      DataColumn2(
        label: HeadingTextWidget(title: 'Revenue'),
      ),
    ];
  }

  List<DataColumn> _headingDepartments() {
    return [
      DataColumn2(
        size: ColumnSize.L,
        label: HeadingTextWidget(title: 'Department'),
      ),
      DataColumn2(
        size: ColumnSize.S,
        label: HeadingTextWidget(title: 'Quantity'),
      ),
      DataColumn2(
        size: ColumnSize.M,
        label: HeadingTextWidget(title: 'Balance'),
      ),
      DataColumn2(
        label: HeadingTextWidget(title: 'Sub-Total'),
      ),
      DataColumn2(
        label: HeadingTextWidget(title: 'Revenue'),
      ),
    ];
  }

  double rowTotalTotalBalance() {
    return returnOrdersByDayOrWeekAll()
        .map(
          (item) => (item.getCalculatedRemainingBalance()),
        )
        .toList()
        .fold(0, (p, n) => p + n);
  }

  double rowTotalTotalCostPrice() {
    return returnOrdersByDayOrWeekAll()
        .map((item) => (item.originalCost ?? 0))
        .toList()
        .fold(0, (p, n) => p + n);
  }

  double rowTotalTotalRevenue() {
    return returnOrdersByDayOrWeekAll()
        .map((item) => (item.total ?? 0))
        .toList()
        .fold(0, (p, n) => p + n);
  }

  List<DataRow> _rowTotal({required BuildContext context}) {
    return [
      ...returnOrdersByDayOrWeekAll().toList().map((item) {
        return DataRow2(
          specificRowHeight:
              (item.staffName ?? '').length > 18 ||
                      (item.customerName ?? '').length > 18
                  ? 40
                  : 30,
          cells: [
            DataCell(
              Text(
                "#${item.barcode ?? returnOnlyDigits(item.uuid ?? '')}",
              ),
            ),
            DataCell(Text(item.staffName ?? 'Not Set')),
            DataCell(Text(item.customerName ?? 'Not Set')),
            // DataCell(Text(item.paymentMethod)),
            DataCell(Text(formatDateTime(item.createdAt))),
            DataCell(Text(formatTime(item.createdAt))),
            DataCell(
              Text(
                "${item.generalDiscount != null ? "" : '${shop(context)?.currency}'}${formatLargeNumberDouble(item.fixedDiscount ?? item.generalDiscount ?? 0)}${item.generalDiscount != null ? "%" : ''}",
              ),
            ),
            DataCell(
              Text(
                "${formatLargeNumberDouble(item.vat ?? 0)}%",
              ),
            ),
            DataCell(
              Text(
                formatMoneyBig(
                  amount:
                      item.getCalculatedRemainingBalance(),
                  context: context,
                ),
              ),
            ),
            DataCell(
              Text(
                formatMoneyBig(
                  amount: item.originalCost ?? 0,
                  context: context,
                ),
              ),
            ),
            DataCell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return ReceiptPage(
                        response: CheckoutResponse(
                          order: item,
                        ),
                        isMain: false,
                      );
                    },
                  ),
                );
              },
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                spacing: 5,
                children: [
                  Text(
                    formatMoneyBig(
                      amount: item.total ?? 0,
                      context: context,
                    ),
                  ),
                  Icon(
                    size: 14,
                    color: Colors.grey.shade500,
                    Icons.arrow_forward_ios_rounded,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
      DataRow2(
        specificRowHeight: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          color: Colors.grey.shade300,
        ),
        cells: [
          DataCell(
            Text(style: TextStyle(fontSize: 14), 'TOTAL'),
          ),
          DataCell(Text('')),
          DataCell(Text('')),
          DataCell(Text('')),
          DataCell(Text('')),
          DataCell(Text('')),
          DataCell(Text("")),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatMoneyBig(
                amount: rowTotalTotalBalance(),
                context: context,
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatMoneyBig(
                amount: rowTotalTotalCostPrice(),
                context: context,
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 16),
              formatMoneyBig(
                amount: rowTotalTotalRevenue(),
                context: context,
              ),
            ),
          ),
        ],
      ),
    ];
  }

  rowStaffsTotalQuantity() {
    return groupOrdersByStaff()
        .map((item) => item.number)
        .toList()
        .fold(0, (p, n) => p + n);
  }

  rowStaffsTotalBalance() {
    return groupOrdersByStaff()
        .map((item) => item.totalBalance)
        .toList()
        .fold<double>(0, (p, n) => p + n);
  }

  rowStaffsTotalCostPrice() {
    return groupOrdersByStaff()
        .map((item) => item.totalOriginalCost)
        .toList()
        .fold<double>(0, (p, n) => p + n);
  }

  rowStaffsTotalRevenue() {
    return groupOrdersByStaff()
        .map((item) => item.totalRevenue)
        .toList()
        .fold<double>(0, (p, n) => p + n);
  }

  List<DataRow> _rowStaffs({
    required BuildContext context,
  }) {
    return [
      ...groupOrdersByStaff().map((item) {
        return DataRow2(
          specificRowHeight:
              (item.staffName ?? '').length > 15 ? 40 : 30,
          cells: [
            DataCell(Text(item.staffName ?? 'Not Set')),
            DataCell(
              Text(formatLargeNumberDouble(item.number)),
            ),
            DataCell(
              Text(
                formatMoneyBig(
                  amount: item.totalBalance,
                  context: context,
                ),
              ),
            ),
            DataCell(
              Text(
                formatMoneyBig(
                  amount: item.totalOriginalCost,
                  context: context,
                ),
              ),
            ),
            DataCell(
              Text(
                formatMoneyBig(
                  amount: item.totalRevenue,
                  context: context,
                ),
              ),
            ),
          ],
        );
      }),
      DataRow2(
        specificRowHeight: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          color: Colors.grey.shade300,
        ),
        cells: [
          DataCell(
            Text(style: TextStyle(fontSize: 14), 'TOTAL'),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatLargeNumberDouble(
                rowStaffsTotalQuantity(),
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatMoneyBig(
                amount: rowStaffsTotalBalance(),
                context: context,
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatMoneyBig(
                amount: rowStaffsTotalCostPrice(),
                context: context,
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatMoneyBig(
                amount: rowStaffsTotalRevenue(),
                context: context,
              ),
            ),
          ),
        ],
      ),
    ];
  }

  rowCustomersTotalQuantity() {
    return groupOrdersByCustomer()
        .map((item) => item.number)
        .toList()
        .fold(0, (p, n) => p + n);
  }

  rowCustomersTotalBalance() {
    return groupOrdersByCustomer()
        .map((item) => item.totalBalance)
        .toList()
        .fold<double>(0, (p, n) => p + n);
  }

  rowCustomersTotalCostPrice() {
    return groupOrdersByCustomer()
        .map((item) => item.totalOriginalCost)
        .toList()
        .fold<double>(0, (p, n) => p + n);
  }

  rowCustomersTotalRevenue() {
    return groupOrdersByCustomer()
        .map((item) => item.totalRevenue)
        .toList()
        .fold<double>(0, (p, n) => p + n);
  }

  List<DataRow> _rowCustomers({
    required BuildContext context,
  }) {
    return [
      ...groupOrdersByCustomer().map((item) {
        return DataRow2(
          specificRowHeight:
              (item.customerName ?? '').length > 15
                  ? 40
                  : 30,
          cells: [
            DataCell(Text(item.customerName ?? 'Not Set')),
            DataCell(
              Text(formatLargeNumberDouble(item.number)),
            ),
            DataCell(
              Text(
                formatMoneyBig(
                  amount: item.totalBalance,
                  context: context,
                ),
              ),
            ),
            DataCell(
              Text(
                formatMoneyBig(
                  amount: item.totalOriginalCost,
                  context: context,
                ),
              ),
            ),
            DataCell(
              Text(
                formatMoneyBig(
                  amount: item.totalRevenue,
                  context: context,
                ),
              ),
            ),
          ],
        );
      }),
      DataRow2(
        specificRowHeight: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          color: Colors.grey.shade300,
        ),
        cells: [
          DataCell(
            Text(style: TextStyle(fontSize: 14), 'TOTAL'),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatLargeNumberDouble(
                rowCustomersTotalQuantity(),
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatMoneyBig(
                amount: rowCustomersTotalBalance(),
                context: context,
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatMoneyBig(
                amount: rowCustomersTotalCostPrice(),
                context: context,
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 16),
              formatMoneyBig(
                amount: rowCustomersTotalRevenue(),
                context: context,
              ),
            ),
          ),
        ],
      ),
    ];
  }

  rowDepartmentsTotalQuantity() {
    return groupOrdersByDepartment()
        .map((item) => item.number)
        .toList()
        .fold(0, (p, n) => p + n);
  }

  rowDepartmentsTotalBalance() {
    return groupOrdersByDepartment()
        .map((item) => item.totalBalance)
        .toList()
        .fold<double>(0, (p, n) => p + n);
  }

  rowDepartmentsTotalCostPrice() {
    return groupOrdersByDepartment()
        .map((item) => item.totalOriginalCost)
        .toList()
        .fold<double>(0, (p, n) => p + n);
  }

  rowDepartmentsTotalRevenue() {
    return groupOrdersByDepartment()
        .map((item) => item.totalRevenue)
        .toList()
        .fold<double>(0, (p, n) => p + n);
  }

  List<DataRow> _rowDepartment({
    required BuildContext context,
  }) {
    return [
      ...groupOrdersByDepartment().map((item) {
        return DataRow2(
          specificRowHeight: 30,
          cells: [
            DataCell(
              Text(item.departmentName ?? 'Not Set'),
            ),
            DataCell(
              Text(formatLargeNumberDouble(item.number)),
            ),
            DataCell(
              Text(
                formatMoneyBig(
                  amount: item.totalBalance,
                  context: context,
                ),
              ),
            ),
            DataCell(
              Text(
                formatMoneyBig(
                  amount: item.totalOriginalCost,
                  context: context,
                ),
              ),
            ),
            DataCell(
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                spacing: 5,
                children: [
                  Text(
                    formatMoneyBig(
                      amount: item.totalRevenue,
                      context: context,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
      DataRow2(
        specificRowHeight: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          color: Colors.grey.shade300,
        ),
        cells: [
          DataCell(
            Text(style: TextStyle(fontSize: 14), 'TOTAL'),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatLargeNumberDouble(
                rowDepartmentsTotalQuantity(),
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatMoneyBig(
                amount: rowDepartmentsTotalBalance(),
                context: context,
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 14),
              formatMoneyBig(
                amount: rowDepartmentsTotalCostPrice(),
                context: context,
              ),
            ),
          ),
          DataCell(
            Text(
              style: TextStyle(fontSize: 16),
              formatMoneyBig(
                amount: rowDepartmentsTotalRevenue(),
                context: context,
              ),
            ),
          ),
        ],
      ),
    ];
  }

  List<DataRow> row({
    required int sortIndex,
    required BuildContext context,
  }) {
    if (sortIndex == 1) {
      return _rowTotal(context: context);
    } else if (sortIndex == 2) {
      return _rowStaffs(context: context);
    } else if (sortIndex == 3) {
      return _rowCustomers(context: context);
    } else {
      return _rowDepartment(context: context);
    }
  }

  List<DataColumn> heading({
    required int sortIndex,
    required BuildContext context,
  }) {
    if (sortIndex == 1) {
      return _headingTotal(context: context);
    } else if (sortIndex == 2) {
      return _headingStaffs();
    } else if (sortIndex == 3) {
      return _headingCustomers();
    } else {
      return _headingDepartments();
    }
  }
}

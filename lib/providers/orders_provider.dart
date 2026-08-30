import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:stockall/classes/checkout_response.dart';
import 'package:stockall/classes/temp_orders/order_items.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/classes/temp_orders/unsynced/created/created_orders.dart';
import 'package:stockall/classes/temp_orders/unsynced/deleted/deleted_orders.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/generate_barcode.dart';
import 'package:stockall/local_database/orders_func/orders_func.dart';
import 'package:stockall/local_database/orders_func/unsync_funcs/created/created_orders_func.dart';
import 'package:stockall/local_database/orders_func/unsync_funcs/deleted/deleted_orders_func.dart';
import 'package:stockall/local_database/orders_func/unsync_funcs/updated/updated_orders_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/general_report/class/general_report_class.dart';
import 'package:stockall/pages/report/invoice_sales_report/platforms/invoice_sales_report_desktop.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/receipt_page.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// // //

// // // //

// I WANT TO START WORKING ON THE INVOICE

// ///////

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
          final updateData = {'is_invoice': false};
          await supabase
              .from(tableName)
              .update(updateData)
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

  List<Orders> returnOwnOrdersByDayOrWeek() {
    if (returnShopProvider()
            .userShop()
            ?.manageDepartments ==
        true) {
      if (rangeStartDate != null) {
        return departmentOrders().where((order) {
          final created = order.createdAt.toLocal();
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
        // final currentDate = dateSet ?? DateTime.now();
        final currentDate =
            dateSet ?? resolveBusinessDate(DateTime.now());

        return departmentOrders()
            .where(
              (order) =>
                  !order.createdAt.isBefore(
                    fourAm(currentDate),
                  ) &&
                  order.createdAt.isBefore(
                    fourAmNextDay(currentDate),
                  ),
            )
            .toList();
      }
    } else {
      if (rangeStartDate != null) {
        if (authorization(
          authorized:
              Authorizations().viewAllTransactionRecords,
        )) {
          return orders.where((order) {
            final created = order.createdAt.toLocal();
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
          return orders.where((order) {
            final created = order.createdAt.toLocal();
            return !created.isBefore(
                  fourAm(rangeStartDate!),
                ) &&
                created.isBefore(
                  fourAmNextDay(
                    rangeEndDate ??
                        resolveBusinessDate(DateTime.now()),
                  ),
                ) &&
                order.staffId == currentUser().userId;
          }).toList();
        }
      } else {
        final currentDate = dateSet ?? DateTime.now();

        if (authorization(
          authorized:
              Authorizations().viewAllTransactionRecords,
        )) {
          return orders
              .where(
                (order) =>
                    !order.createdAt.isBefore(
                      fourAm(currentDate),
                    ) &&
                    !order.createdAt.isAfter(
                      fourAmNextDay(currentDate),
                    ),
              )
              .toList();
        } else {
          return orders
              .where(
                (order) =>
                    !order.createdAt.isBefore(
                      fourAm(currentDate),
                    ) &&
                    !order.createdAt.isAfter(
                      fourAmNextDay(currentDate),
                    ) &&
                    order.staffId == currentUser().userId,
              )
              .toList();
        }
      }
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

    for (var order in returnOwnOrdersByDayOrWeek()) {
      tempTotalRevenue += getTotalMainRevenueOrder(order);
    }

    return tempTotalRevenue;
  }

  double getTotalRevenueForSelectedDayAll({
    String? staffId,
    String? customerId,
  }) {
    double tempTotalRevenue = 0;

    for (var order
        in (staffId != null
            ? returnOwnOrdersByDayOrWeek().where(
              (rec) => rec.staffId == staffId,
            )
            : customerId != null
            ? returnOwnOrdersByDayOrWeek().where(
              (rec) => rec.customerId == customerId,
            )
            : returnOwnOrdersByDayOrWeek())) {
      tempTotalRevenue += getTotalMainRevenueOrder(order);
    }

    return tempTotalRevenue;
  }
  //
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

  double getTotalMainRevenueOrder(Orders order) {
    return order.total ?? 0;
  }

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

    for (final order in returnOwnOrdersByDayOrWeek()) {
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
      group.totalBalance += order.balance ?? 0;
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

    for (final order in returnOwnOrdersByDayOrWeek()) {
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
      group.totalBalance += order.balance ?? 0;
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

    for (final order in returnOwnOrdersByDayOrWeek()) {
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
      group.totalBalance += order.balance ?? 0;
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
        (sum, e) => sum + e.revenue,
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
        .map((item) => item.revenue)
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
        (sum, e) => sum + e.revenue,
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
        .map((item) => item.revenue)
        .toList()
        .fold(0, (first, second) => first + second);
  }

  //
  //
  //

  double getTotalSalesRevenueNoDepartment() {
    return returnOrderItemsByDayOrWeek()
        .where((item) => item.departmentUuid == null)
        .map((item) => item.revenue)
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
        (sum, e) => sum + (e.revenue),
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
    return returnOwnOrdersByDayOrWeek()
        .map((item) => (item.balance ?? 0))
        .toList()
        .fold(0, (p, n) => p + n);
  }

  double rowTotalTotalCostPrice() {
    return returnOwnOrdersByDayOrWeek()
        .map((item) => (item.originalCost ?? 0))
        .toList()
        .fold(0, (p, n) => p + n);
  }

  double rowTotalTotalRevenue() {
    return returnOwnOrdersByDayOrWeek()
        .map((item) => (item.total ?? 0))
        .toList()
        .fold(0, (p, n) => p + n);
  }

  List<DataRow> _rowTotal({required BuildContext context}) {
    return [
      ...returnOwnOrdersByDayOrWeek().toList().map((item) {
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
                  amount: item.balance ?? 0,
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

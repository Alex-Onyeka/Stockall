import 'package:flutter/material.dart';
import 'package:stockall/classes/subscription/subscription_class.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/classes/temp_notification/temp_notification.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/app_version_provider.dart';
import 'package:stockall/providers/data_provider.dart';
import 'package:stockall/providers/events_log_provider.dart';
import 'package:stockall/providers/expenses_provider.dart';
import 'package:stockall/providers/invoices_provider.dart';
import 'package:stockall/providers/notifications_provider.dart';
import 'package:stockall/providers/purchase_provider.dart';
import 'package:stockall/providers/receipts_provider.dart';
import 'package:stockall/providers/shop_provider.dart';
import 'package:stockall/providers/subscription_provider.dart';
import 'package:stockall/providers/user_provider.dart';
import 'package:stockall/providers/utility_constant_provider.dart';

class RefreshFunctions {
  late final ShopProvider shopProvider;
  // late final SuggestionsProvider suggestionProvider;
  late final ReceiptsProvider receiptsProvider;
  late final InvoicesProvider invoicesProvider;
  late final NotificationProvider notificationProvider;
  late final ExpensesProvider expensesProvider;
  late final UserProvider userProvider;
  late final DataProvider dataProvider;
  late final AppVersionProvider appVersionP;
  late final UtilityConstantProvider
  utilityConstantProvider;
  late final EventsLogProvider eventLogProvider;
  late final PurchaseProvider purchaseProvider;

  // Keep a reference to context
  final BuildContext context;

  RefreshFunctions(this.context) {
    shopProvider = returnShopProvider();
    // suggestionProvider = returnSuggestionsProvider(context, listen: false);
    receiptsProvider = returnReceiptProviderSingle();
    invoicesProvider = returnInvoicesProvider();
    notificationProvider = returnNotificationProvider(
      context,
      listen: false,
    );
    expensesProvider = returnExpensesProviderSingle();
    userProvider = returnUserProviderSingle();
    appVersionP = returnAppVersionProvider(
      context,
      listen: false,
    );
    utilityConstantProvider =
        returnUtilityConstantProvider();
    dataProvider = returnData();
    eventLogProvider = returnEventsLogProvider();
    purchaseProvider = returnPurchaseProvider();
  }

  Future<bool> checkOnline() async {
    bool isOnline =
        returnConnectivityProvider().isConnected;
    return isOnline;
  }

  int isSynced() {
    return returnData().isSynced();
  }

  bool isSyncing() {
    return returnData().isSyncing;
  }

  // Future<void> loadSuggestions() async {
  //   await suggestionProvider.loadSuggestions(
  //     shopProvider. userShop()!.shopId!,
  //   );
  // }

  bool isFloatOpen = false;
  bool isUpdateLodaingWeb = false;
  bool isUpdateLodaingMobile = false;

  Future<void> getMainReceipts({
    DateTime? startDate,
    DateTime? endDate,
    bool fetchAll = false,
    bool forceRefresh = false,
  }) async {
    await mainLocalLog('Starting to get receipts');
    await receiptsProvider.loadReceipts(
      shopProvider.userShop()!.shopId!,
      startDate: startDate,
      endDate: endDate,
      fetchAll: fetchAll,
      forceRefresh: forceRefresh,
    );
  }

  Future<void> refreshReceipts(
    context, {
    DateTime? startDate,
    DateTime? endDate,
    bool fetchAll = false,
    bool forceRefresh = false,
  }) async {
    var safeContext = context;
    bool isOnline = await checkOnline();
    await appVersionP.getAppVersion(context);
    if (isOnline && isSynced() == 0) {
      showDialog(
        context: context,
        builder: (context) {
          return ConfirmationAlert(
            theme: returnTheme(context, listen: false),
            message:
                'You have unsynced Records, are you sure you want to proceed?',
            title: 'Unsynced Records Detected',
            action: () async {
              Navigator.of(context).pop();
              await returnData().syncData(
                context: safeContext,
              );
              await getMainReceipts(
                startDate: startDate,
                endDate: endDate,
                fetchAll: fetchAll,
                forceRefresh: forceRefresh,
              );
            },
          );
        },
      );
    } else {
      await getMainReceipts(
        startDate: startDate,
        endDate: endDate,
        fetchAll: fetchAll,
        forceRefresh: forceRefresh,
      );
    }
  }
  //
  //
  //
  //
  //

  Future<void> getInvoices({
    DateTime? startDate,
    DateTime? endDate,
    bool fetchAll = false,
    bool forceRefresh = false,
  }) async {
    await mainLocalLog('Starting to get receipts');
    await invoicesProvider.loadInvoices(
      shopProvider.userShop()!.shopId!,
      startDate: startDate,
      endDate: endDate,
      fetchAll: fetchAll,
      forceRefresh: forceRefresh,
    );
  }

  Future<void> refreshInvoices(
    context, {
    DateTime? startDate,
    DateTime? endDate,
    bool fetchAll = false,
    bool forceRefresh = false,
  }) async {
    var safeContext = context;
    bool isOnline = await checkOnline();
    if (isOnline && isSynced() == 0) {
      showDialog(
        context: context,
        builder: (confirmContext) {
          return ConfirmationAlert(
            theme: returnTheme(context, listen: false),
            message:
                'You have unsynced Records, are you sure you want to proceed?',
            title: 'Unsynced Records Detected',
            action: () async {
              Navigator.of(confirmContext).pop();
              await returnData().syncData(
                context: safeContext,
              );
              await getInvoices(
                startDate: startDate,
                endDate: endDate,
                fetchAll: fetchAll,
                forceRefresh: forceRefresh,
              );
            },
          );
        },
      );
    } else {
      await getInvoices(
        startDate: startDate,
        endDate: endDate,
        fetchAll: fetchAll,
        forceRefresh: forceRefresh,
      );
    }
  }
  //
  //
  //
  //
  //

  Future<List<TempShopClass>> getUserShop() async {
    return await shopProvider.getUserShops();
  }

  Future<void> refreshUserShop(context) async {
    var safeContext = context;
    bool isOnline = await checkOnline();
    if (isOnline && isSynced() == 0) {
      showDialog(
        context: context,
        builder: (context) {
          return ConfirmationAlert(
            theme: returnTheme(context, listen: false),
            message:
                'You have unsynced Records, are you sure you want to proceed?',
            title: 'Unsynced Records Detected',
            action: () async {
              Navigator.of(context).pop();
              await returnData().syncData(
                context: safeContext,
              );
              await getUserShop();
            },
          );
        },
      );
    } else {
      await getUserShop();
    }
  }
  //
  //
  //

  //
  //
  //
  //

  Future<List<TempProductClass>> getProducts() async {
    var tempP = await dataProvider.getProducts(
      shopProvider.userShop()!.shopId!,
    );
    return tempP;
  }

  Future<void> refreshProducts(context) async {
    var safeContext = context;
    bool isOnline = await checkOnline();
    if (isOnline && isSynced() == 0) {
      showDialog(
        context: context,
        builder: (context) {
          return ConfirmationAlert(
            theme: returnTheme(context, listen: false),
            message:
                'You have unsynced Records, are you sure you want to proceed?',
            title: 'Unsynced Records Detected',
            action: () async {
              Navigator.of(context).pop();
              await returnData().syncData(
                context: safeContext,
              );
              await getProducts();
            },
          );
        },
      );
    } else {
      await getProducts();
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

  Future<List<TempNotification>>
  fetchNotifications() async {
    var tempGet = await notificationProvider
        .fetchRecentNotifications(
          shopProvider.userShop()!.shopId!,
        );

    return tempGet;
  }

  Future<void> refreshNotifications(context) async {
    var safeContext = context;
    bool isOnline = await checkOnline();
    if (isOnline && isSynced() == 0) {
      showDialog(
        context: context,
        builder: (context) {
          return ConfirmationAlert(
            theme: returnTheme(context, listen: false),
            message:
                'You have unsynced Records, are you sure you want to proceed?',
            title: 'Unsynced Records Detected',
            action: () async {
              Navigator.of(context).pop();
              await returnData().syncData(
                context: safeContext,
              );
              await fetchNotifications();
            },
          );
        },
      );
    } else {
      await fetchNotifications();
    }
  }

  //
  //
  //
  //
  //

  // late Future<List<TempProductSaleRecord>>
  // getProdutRecordsFuture;

  //
  //
  //
  //
  //

  // Future<List<TempProductSaleRecord>>
  // getProductSalesRecord() async {
  //   var tempRecords = await receiptsProvider
  //       .loadProductSalesRecord(
  //         shopProvider.userShop()!.shopId!,
  //       );

  //   return tempRecords
  //       .where(
  //         (beans) =>
  //             beans.shopId ==
  //             shopProvider.userShop()!.shopId!,
  //       )
  //       .toList();
  // }

  Future<void> refreshProductSalesRecord(context) async {
    var safeContext = context;
    bool isOnline = await checkOnline();
    if (isOnline && isSynced() == 0) {
      showDialog(
        context: context,
        builder: (context) {
          return ConfirmationAlert(
            theme: returnTheme(context, listen: false),
            message:
                'You have unsynced Records, are you sure you want to proceed?',
            title: 'Unsynced Records Detected',
            action: () async {
              Navigator.of(context).pop();
              await returnData().syncData(
                context: safeContext,
              );
              // await getProductSalesRecord();
            },
          );
        },
      );
    } else {
      // await getProductSalesRecord();
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

  Future<List<TempExpensesClass>> getExpenses({
    DateTime? startDate,
    DateTime? endDate,
    bool fetchAll = false,
    bool forceRefresh = false,
  }) async {
    var tempExp = await expensesProvider.getExpenses(
      shopProvider.userShop()!.shopId ?? 0,
      startDate: startDate,
      endDate: endDate,
      fetchAll: fetchAll,
      forceRefresh: forceRefresh,
    );

    return tempExp;
  }

  Future<void> getEventLogs() async {
    await eventLogProvider.getEventLogs();
  }

  Future<void> getErrorLogs() async {
    await returnErrorLogProvider().getErrorLogs();
  }

  Future<void> refreshExpenses(
    context, {
    DateTime? startDate,
    DateTime? endDate,
    bool fetchAll = false,
    bool forceRefresh = false,
  }) async {
    var safeContext = context;
    bool isOnline = await checkOnline();
    if (isOnline && isSynced() == 0) {
      showDialog(
        context: context,
        builder: (context) {
          return ConfirmationAlert(
            theme: returnTheme(context, listen: false),
            message:
                'You have unsynced Records, are you sure you want to proceed?',
            title: 'Unsynced Records Detected',
            action: () async {
              Navigator.of(context).pop();
              await returnData().syncData(
                context: safeContext,
              );
              await getExpenses(
                startDate: startDate,
                endDate: endDate,
                fetchAll: fetchAll,
                forceRefresh: forceRefresh,
              );
            },
          );
        },
      );
    } else {
      await getExpenses(
        startDate: startDate,
        endDate: endDate,
        fetchAll: fetchAll,
        forceRefresh: forceRefresh,
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

  Future<List<TempUserClass>> getEmployees() async {
    await shopProvider.getUserShops();
    if (context.mounted) {
      var users = await userProvider.fetchUsersByShop();
      return users;
    } else {
      return [];
    }
  }

  Future<void> refreshEmployees(context) async {
    var safeContext = context;
    bool isOnline = await checkOnline();
    if (isOnline && isSynced() == 0) {
      showDialog(
        context: context,
        builder: (context) {
          return ConfirmationAlert(
            theme: returnTheme(context, listen: false),
            message:
                'You have unsynced Records, are you sure you want to proceed?',
            title: 'Unsynced Records Detected',
            action: () async {
              Navigator.of(context).pop();
              await returnData().syncData(
                context: safeContext,
              );
              await getEmployees();
            },
          );
        },
      );
    } else {
      await getEmployees();
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

  Future<List<TempCustomersClass>> getCustomers() async {
    var customers = await returnCustomers(
      context,
      listen: false,
    ).fetchCustomers(
      returnShopProvider().userShop()!.shopId!,
    );

    return customers;
  }

  Future<void> refreshCustomers(context) async {
    var safeContext = context;
    bool isOnline = await checkOnline();
    if (isOnline && isSynced() == 0) {
      showDialog(
        context: context,
        builder: (context) {
          return ConfirmationAlert(
            theme: returnTheme(context, listen: false),
            message:
                'You have unsynced Records, are you sure you want to proceed?',
            title: 'Unsynced Records Detected',
            action: () async {
              Navigator.of(context).pop();
              await returnData().syncData(
                context: safeContext,
              );
              await getCustomers();
            },
          );
        },
      );
    } else {
      await getCustomers();
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

  Future<SubscriptionClass?> loadSubscription() async {
    return await returnSubcsription(
      context,
      listen: false,
    ).getSubscription(context);
  }

  //
  //
  //

  Future<void> refreshSubscription(context) async {
    var safeContext = context;
    bool isOnline = await checkOnline();
    if (isOnline && isSynced() == 0) {
      showDialog(
        context: context,
        builder: (context) {
          return ConfirmationAlert(
            theme: returnTheme(context, listen: false),
            message:
                'You have unsynced Records, are you sure you want to proceed?',
            title: 'Unsynced Records Detected',
            action: () async {
              Navigator.of(context).pop();
              await returnData().syncData(
                context: safeContext,
              );
              await loadSubscription();
            },
          );
        },
      );
    } else {
      await loadSubscription();
    }
  }

  //
  //
  //

  Future<void> _fetchDashboardOnline(
    BuildContext safeContext,
  ) async {
    if (safeContext.mounted) {
      await returnUserProviderSingle().fetchCurrentUser(
        safeContext,
      );
    }
    await utilityConstantProvider.getUtilityConstants();

    var subs = await loadSubscription();
    await mainLocalLog(
      "Subscription Plan RefreshDashboard: ${subs?.plan}",
    );
    if (safeContext.mounted) {
      dataProvider.setAllowedRange(plan: subs?.plan);
    }

    await returnDepartmentProvider().getDepartments();
    await getProducts();
    if (safeContext.mounted) {
      await getMainReceipts();
    }
    await getInvoices();
    await getExpenses();
    await getCustomers();
    await getEmployees();
    await fetchNotifications();
  }

  Future<void> _fetchDashboardStartup(
    BuildContext safeContext,
  ) async {
    await loadDashboardDataOffline();
    await getUserShop();
    await utilityConstantProvider.getUtilityConstants();
    var subs = await loadSubscription();
    await mainLocalLog(
      "Subscription Plan RefreshDashboard: ${subs?.plan}",
    );
    if (safeContext.mounted) {
      dataProvider.setAllowedRange(plan: subs?.plan);
    }
    await returnDepartmentProvider().getDepartments();
    if (safeContext.mounted) {
      await getMainReceipts();
    }
    await getExpenses();
    if (safeContext.mounted) {
      await returnUserProvider(
        safeContext,
        listen: false,
      ).fetchCurrentUser(safeContext);
    }
    await fetchNotifications();
  }

  Future<void> refreshDashboard(
    BuildContext context, {
    bool isManualRefresh = false,
  }) async {
    if (!isSyncing()) {
      var safeContext = context;
      var navPro = returnNavProvider(
        context,
        listen: false,
      );

      dataProvider.toggleRefreshing(true);

      List<TempShopClass> shop = await getUserShop();
      if (shop.isEmpty) {
        navPro.nullShop(
          logoutAction: () {
            navPro.navPush(context);
          },
        );
      } else {
        bool isOnline =
            returnConnectivityProvider().isConnected;
        if (isSynced() == 0 &&
            context.mounted &&
            isOnline) {
          showDialog(
            context: context,
            builder: (confirmDialog) {
              return ConfirmationAlert(
                theme: returnTheme(context, listen: false),
                message:
                    'You have unsynced Records, are you sure you want to proceed?',
                title: 'Unsynced Records Detected',
                action: () async {
                  Navigator.of(confirmDialog).pop();
                  dataProvider.toggleRefreshing(true);
                  if (safeContext.mounted) {
                    await returnData().syncData(
                      context: safeContext,
                    );
                  }
                  if (isManualRefresh) {
                    await _fetchDashboardOnline(
                      safeContext,
                    );
                  } else {
                    await _fetchDashboardStartup(
                      safeContext,
                    );
                  }
                  dataProvider.toggleRefreshing(false);
                },
              );
            },
          );
        } else {
          if (isManualRefresh) {
            await _fetchDashboardOnline(safeContext);
          } else {
            await _fetchDashboardStartup(safeContext);
          }
        }
      }

      dataProvider.toggleRefreshing(false);
    }
  }

  //
  //
  //

  Future<void> refreshAll(BuildContext context) async {
    if (!isSyncing()) {
      var safeContext = context;
      var navPro = returnNavProvider(
        context,
        listen: false,
      );

      dataProvider.toggleRefreshing(true);

      List<TempShopClass> shop = await getUserShop();
      if (shop.isEmpty) {
        navPro.nullShop(
          logoutAction: () {
            navPro.navPush(context);
          },
        );
      } else {
        bool isOnline =
            returnConnectivityProvider().isConnected;
        if (isSynced() == 0 &&
            context.mounted &&
            isOnline) {
          showDialog(
            context: context,
            builder: (confirmDialog) {
              return ConfirmationAlert(
                theme: returnTheme(context, listen: false),
                message:
                    'You have unsynced Records, are you sure you want to proceed?',
                title: 'Unsynced Records Detected',
                action: () async {
                  Navigator.of(confirmDialog).pop();
                  if (safeContext.mounted) {
                    await returnData().syncData(
                      context: safeContext,
                    );
                  }
                  if (safeContext.mounted) {
                    await returnUserProviderSingle()
                        .fetchCurrentUser(safeContext);
                  }
                  await utilityConstantProvider
                      .getUtilityConstants();

                  var subs = await loadSubscription();
                  await mainLocalLog(
                    "Subscription Plan RefreshAll: ${subs?.plan}",
                  );
                  if (safeContext.mounted) {
                    dataProvider.setAllowedRange(
                      plan: subs?.plan,
                    );
                  }
                  await mainLocalLog(
                    "Allowed Items RefreshAll: ${dataProvider.allowedRangeItems}",
                  );

                  await returnDepartmentProvider()
                      .getDepartments();
                  await getProducts();
                  if (safeContext.mounted) {
                    await getMainReceipts();
                  }
                  await getInvoices();
                  if (shopProvider.userShop()?.bulkSale ==
                      true) {
                    await returnSubStaffProvider()
                        .getSubStaffs();
                  }
                  await getEventLogs();
                  await getErrorLogs();
                  await getExpenses();
                  await getEmployees();
                  await fetchNotifications();
                  await getCustomers();
                  await purchaseProvider.loadPurchases(
                    shopId(),
                  );
                  await returnMaterialsProvider()
                      .getMaterials();
                  await returnProductionItemsProvider()
                      .getProductionItems();
                  await returnProductionRecordsProvider()
                      .getProductionRecords(shopId());
                  await returnOrdersProvider().loadOrders(
                    shopId(),
                  );
                  await returnDraftsProvider().loadDrafts(
                    shopId(),
                  );
                },
              );
            },
          );
        } else {
          await getUserShop();
          await utilityConstantProvider
              .getUtilityConstants();
          var subs = await loadSubscription();
          await mainLocalLog(
            "Subscription Plan RefreshAll: ${subs?.plan}",
          );
          if (safeContext.mounted) {
            dataProvider.setAllowedRange(plan: subs?.plan);
          }
          await mainLocalLog(
            "Allowed Items RefreshAll: ${dataProvider.allowedRangeItems}",
          );
          await returnDepartmentProvider().getDepartments();
          await getProducts();
          if (safeContext.mounted) {
            await getMainReceipts();
          }
          await getInvoices();
          if (shopProvider.userShop()?.bulkSale == true) {
            await returnSubStaffProvider().getSubStaffs();
          }
          await getEventLogs();
          await getErrorLogs();
          await getExpenses();
          await getEmployees();
          if (safeContext.mounted) {
            await returnUserProvider(
              safeContext,
              listen: false,
            ).fetchCurrentUser(safeContext);
          }
          await fetchNotifications();
          await getCustomers();
          await returnDepartmentProvider().getDepartments();
          await purchaseProvider.loadPurchases(shopId());
          await returnProductionItemsProvider()
              .getProductionItems();
          await returnMaterialsProvider().getMaterials();
          await returnProductionRecordsProvider()
              .getProductionRecords(shopId());
          await returnOrdersProvider().loadOrders(shopId());
          await returnDraftsProvider().loadDrafts(shopId());
        }
      }

      dataProvider.toggleRefreshing(false);
    }
  }
}

Future<void> loadAllDataOffline({
  required BuildContext context,
}) async {
  returnUserProviderSingle().fetchCurrentUserOffline();
  await returnUtilityConstantProvider()
      .getUtilityConstantsOffline();
  var subss =
      await SubscriptionProvider().getSubscriptionOffline();
  returnData().setAllowedRange(plan: subss?.plan);
  await returnDepartmentProvider().getDepartmentsOffline();
  await returnReceiptProviderSingle().loadReceiptsOffline(
    shopId(),
  );
  if (returnShopProvider().userShop()?.bulkSale == true) {
    await returnSubStaffProvider().getSubStaffsOffline();
  }
  await returnEventsLogProvider().getEventLogsOffline();
  await returnErrorLogProvider().getErrorLogsOffline();
  await returnExpensesProviderSingle().getExpensesOffline(
    shopId(),
  );
  await returnUserProviderSingle()
      .fetchUsersByShopOffline();

  await NotificationProvider()
      .fetchRecentNotificationsOffline();

  await returnCustomersSingle().fetchCustomersOffline();

  await returnPurchaseProvider().loadPurchasesOffline();

  await returnMaterialsProvider().getMaterialsOffline(
    shopId(),
  );
  await returnProductionItemsProvider()
      .getProductionItemsOffline(shopId());
  await returnProductionRecordsProvider()
      .getProductionRecordsOffline();
  await returnOrdersProvider().loadOrdersOffline(shopId());
  await returnDraftsProvider().loadDraftsOffline(shopId());
}

Future<void> loadDashboardDataOffline() async {
  returnUserProviderSingle().fetchCurrentUserOffline();
  await returnUtilityConstantProvider()
      .getUtilityConstantsOffline();
  var subss =
      await SubscriptionProvider().getSubscriptionOffline();
  returnData().setAllowedRange(plan: subss?.plan);
  await returnDepartmentProvider().getDepartmentsOffline();
  await returnReceiptProviderSingle().loadReceiptsOffline(
    shopId(),
  );
  await returnExpensesProviderSingle().getExpensesOffline(
    shopId(),
  );
  await NotificationProvider()
      .fetchRecentNotificationsOffline();
  await returnInvoicesProvider().loadInvoicesOffline(
    shopId(),
  );
  await returnData().getProductsOffline(shopId());
}

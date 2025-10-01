import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/classes/temp_notification/temp_notification.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/data_provider.dart';
import 'package:stockall/providers/expenses_provider.dart';
import 'package:stockall/providers/notifications_provider.dart';
import 'package:stockall/providers/receipts_provider.dart';
import 'package:stockall/providers/shop_provider.dart';
import 'package:stockall/providers/user_provider.dart';
import 'package:stockall/services/auth_service.dart';

class RefreshFunctions {
  late final ShopProvider shopProvider;
  // late final SuggestionsProvider suggestionProvider;
  late final ReceiptsProvider receiptsProvider;
  late final NotificationProvider notificationProvider;
  late final ExpensesProvider expensesProvider;
  late final UserProvider userProvider;
  late final DataProvider dataProvider;

  // Keep a reference to context
  final BuildContext context;

  RefreshFunctions(this.context) {
    shopProvider = returnShopProvider(
      context,
      listen: false,
    );
    // suggestionProvider = returnSuggestionsProvider(context, listen: false);
    receiptsProvider = returnReceiptProvider(
      context,
      listen: false,
    );
    notificationProvider = returnNotificationProvider(
      context,
      listen: false,
    );
    expensesProvider = returnExpensesProvider(
      context,
      listen: false,
    );
    userProvider = returnUserProvider(
      context,
      listen: false,
    );
    dataProvider = returnData(context, listen: false);
  }

  Future<bool> checkOnline() async {
    bool isOnline =
        await returnConnectivityProvider(
          context,
          listen: false,
        ).isOnline();
    return isOnline;
  }

  int isSynced() {
    return returnData(context, listen: false).isSynced();
  }

  // Future<void> loadSuggestions() async {
  //   await suggestionProvider.loadSuggestions(
  //     shopProvider.userShop!.shopId!,
  //   );
  // }

  bool isFloatOpen = false;
  bool isUpdateLodaingWeb = false;
  bool isUpdateLodaingMobile = false;

  // Future<List<TempMainReceipt>> getMainReceipts(
  //   BuildContext context,
  // ) async {
  //   var tempReceipts = await receiptsProvider.loadReceipts(
  //     shopProvider.userShop!.shopId!,
  //     context,
  //   );
  //   return tempReceipts;
  // }

  //
  //
  //
  //
  //

  Future<void> getMainReceipts(BuildContext context) async {
    print('Starting to get receipts');
    await receiptsProvider.loadReceipts(
      shopProvider.userShop!.shopId!,
      context,
    );
  }

  Future<void> refreshReceipts(context) async {
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
              await returnData(
                context,
                listen: false,
              ).syncData(safeContext);
              await getMainReceipts(safeContext);
            },
          );
        },
      );
    } else {
      await getMainReceipts(safeContext);
    }
  }
  //
  //
  //
  //
  //

  Future getUserShop() async {
    return await shopProvider.getUserShop(
      AuthService().currentUser!,
    );
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
              await returnData(
                context,
                listen: false,
              ).syncData(safeContext);
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
      shopProvider.userShop!.shopId!,
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
              await returnData(
                context,
                listen: false,
              ).syncData(safeContext);
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
          shopProvider.userShop!.shopId!,
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
              await returnData(
                context,
                listen: false,
              ).syncData(safeContext);
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

  Future<List<TempProductSaleRecord>>
  getProductSalesRecord() async {
    var tempRecords = await receiptsProvider
        .loadProductSalesRecord(
          shopProvider.userShop!.shopId!,
        );

    return tempRecords
        .where(
          (beans) =>
              beans.shopId ==
              shopProvider.userShop!.shopId!,
        )
        .toList();
  }

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
              await returnData(
                context,
                listen: false,
              ).syncData(safeContext);
              await getProductSalesRecord();
            },
          );
        },
      );
    } else {
      await getProductSalesRecord();
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

  Future<List<TempExpensesClass>> getExpenses() async {
    var tempExp = await expensesProvider.getExpenses(
      shopProvider.userShop!.shopId ?? 0,
    );

    return tempExp;
  }

  Future<void> refreshExpenses(context) async {
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
              await returnData(
                context,
                listen: false,
              ).syncData(safeContext);
              await getExpenses();
            },
          );
        },
      );
    } else {
      await getExpenses();
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
    var users = await userProvider.fetchUsers();

    return users;
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
              await returnData(
                context,
                listen: false,
              ).syncData(safeContext);
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
      returnShopProvider(
        context,
        listen: false,
      ).userShop!.shopId!,
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
              await returnData(
                context,
                listen: false,
              ).syncData(safeContext);
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

  Future<void> loadSuggestions() async {
    await returnSuggestionProvider(
      context,
      listen: false,
    ).loadSuggestions(
      returnShopProvider(
        context,
        listen: false,
      ).userShop!.shopId!,
    );
  }

  //
  //
  //

  Future<void> refreshSuggestions(context) async {
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
              await returnData(
                context,
                listen: false,
              ).syncData(safeContext);
              await loadSuggestions();
            },
          );
        },
      );
    } else {
      await loadSuggestions();
    }
  }

  //
  //
  //

  Future<void> refreshAll(BuildContext context) async {
    var safeContext = context;
    var navPro = returnNavProvider(context, listen: false);

    TempShopClass? shop = await getUserShop();
    if (shop == null) {
      navPro.nullShop(
        logoutAction: () {
          navPro.navPush(context);
        },
      );
    } else {
      bool isOnline =
          await returnConnectivityProvider(
            context,
            listen: false,
          ).isOnline();
      if (isSynced() == 0 && context.mounted && isOnline) {
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
                await returnData(
                  context,
                  listen: false,
                ).syncData(safeContext);

                // await getProductSalesRecord();
                await getMainReceipts(safeContext);
                await getExpenses();
                await getEmployees();
                await returnUserProvider(
                  context,
                  listen: false,
                ).fetchCurrentUser(safeContext);
                // await getProducts();
                await fetchNotifications();
                await getCustomers();
                await loadSuggestions();
              },
            );
          },
        );
      } else {
        await getUserShop();
        // await getProductSalesRecord();
        await getMainReceipts(safeContext);
        // await getProductSalesRecord();
        await getExpenses();
        await getEmployees();
        await returnUserProvider(
          context,
          listen: false,
        ).fetchCurrentUser(safeContext);
        // await getProducts();
        await fetchNotifications();
        await getCustomers();
        await loadSuggestions();
      }
    }
  }
}

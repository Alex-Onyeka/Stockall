import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/subscription/subscription_class.dart';
import 'package:stockall/classes/temp_cart/temp_cart.dart';
import 'package:stockall/classes/temp_departments_class/department_class.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/local_database/app_logs/app_logs_func.dart';
import 'package:stockall/local_database/main_database.dart';
import 'package:stockall/local_database/visibility_box/visibility_box.dart';
import 'package:stockall/pages/alt_display/alt_display.dart';
import 'package:stockall/pages/authentication/base_page/base_page.dart';
import 'package:stockall/pages/authentication/forgot_password_page/enter_new_password/enter_new_password.dart';
import 'package:stockall/pages/authentication/launch_screen/launch_screen.dart';
import 'package:stockall/pages/authentication/login/login_page.dart';
import 'package:stockall/pages/authentication/splash_screens/splash_screen.dart';
import 'package:stockall/pages/authentication/translations/translation_provider.dart';
import 'package:stockall/pages/profile/delete_account/delete_account.dart';
import 'package:stockall/pages/subscription_page/subscription_page.dart';
import 'package:stockall/providers/app_version_provider.dart';
import 'package:stockall/providers/categories_provider.dart';
import 'package:stockall/providers/comp_provider.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/providers/customer_account_receipts_provider.dart';
import 'package:stockall/providers/customers_provider.dart';
import 'package:stockall/providers/data_provider.dart';
import 'package:stockall/providers/department_provider.dart';
import 'package:stockall/providers/departments_dashboard_provider.dart';
import 'package:stockall/providers/error_log_provider.dart';
import 'package:stockall/providers/events_log_provider.dart';
import 'package:stockall/providers/expenses_provider.dart';
import 'package:stockall/providers/inventory_updates_provider.dart';
import 'package:stockall/providers/invoices_provider.dart';
import 'package:stockall/providers/country_provider.dart';
import 'package:stockall/providers/item_history_provider.dart';
import 'package:stockall/providers/orders_action_provider.dart';
import 'package:stockall/providers/orders_provider.dart';
import 'package:stockall/providers/drafts_provider.dart';
import 'package:stockall/providers/production_folder/material_quantity_update_provider.dart';
import 'package:stockall/providers/production_folder/materials_item_history_provider.dart';
import 'package:stockall/providers/production_folder/materials_provider.dart';
import 'package:stockall/providers/multi_display_provider.dart';
import 'package:stockall/providers/nav_provider.dart';
import 'package:stockall/providers/notifications_provider.dart';
import 'package:stockall/providers/permission_provider.dart';
import 'package:stockall/providers/pos_printer/device_service.dart';
import 'package:stockall/providers/production_folder/materials_usage_action_provider.dart';
import 'package:stockall/providers/production_folder/materials_usage_provider.dart';
import 'package:stockall/providers/production_folder/production_item_history_provider.dart';
import 'package:stockall/providers/production_folder/production_items_provider.dart';
import 'package:stockall/providers/production_folder/production_items_quantity_update_provider.dart';
import 'package:stockall/providers/production_folder/production_record_provider.dart';
import 'package:stockall/providers/production_folder/productions_action_provider.dart';
import 'package:stockall/providers/purchase_action_provider.dart';
import 'package:stockall/providers/printer_settings_provider.dart';
import 'package:stockall/providers/purchase_provider.dart';
import 'package:stockall/providers/quantity_update_provider.dart';
// import 'package:stockall/providers/product_suggestions_provider.dart';
import 'package:stockall/providers/receipts_provider.dart';
import 'package:stockall/providers/report_provider.dart';
import 'package:stockall/providers/sales_provider.dart';
import 'package:stockall/providers/shop_dashboard_provider.dart';
import 'package:stockall/providers/shop_provider.dart';
import 'package:stockall/providers/storage_item_history_provider.dart';
import 'package:stockall/providers/storage_product_provider.dart';
import 'package:stockall/providers/sub_payment_provider.dart';
import 'package:stockall/providers/sub_staff_provider.dart';
import 'package:stockall/providers/subscription_provider.dart';
import 'package:stockall/providers/suppliers_provider.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/providers/user_provider.dart';
import 'package:stockall/providers/utility_constant_provider.dart';
import 'package:stockall/providers/utility_widget_provider.dart';
import 'package:stockall/providers/validate_input_provider.dart';
import 'package:stockall/services/auth_service.dart';
import 'package:stockall/services/navigation_service.dart';
import 'package:stockall/services/payment_result_page.dart/payment_result_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_manager/window_manager.dart';

// Stopwatch stopwatch = Stopwatch();
void main(List<String> args) async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await initMainLog();
    await mainLocalLog('Starting Application');
    if (args.length >= 3) {
      final windowId = int.tryParse(args[1]);
      final argument = args[2];
      // await mainLocalLog(windowId);
      // await mainLocalLog(argument);

      try {
        final decoded = jsonDecode(argument);
        if (decoded['type'] == 'alt') {
          runApp(
            MyAppAlt(
              home: AltDisplay(
                windowId: windowId ?? -1,
                cartId: decoded['cart_id'],
              ),
            ),
          );
        }
      } catch (e) {
        await mainLocalLog('An Error Occoured: $e');
      }
    } else {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarContrastEnforced: true,
          statusBarBrightness: Brightness.light,
        ),
      );
      // Lock to portrait only
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      await MainDatabase().initHive();
      // This device's printer settings, read in the background.
      unawaited(PrinterSettingsProvider().ensureLoaded());
      if (returnShopProvider().isDesktop()) {
        await windowManager.ensureInitialized();
        maxWindow();
        await mainLocalLog("Maximize In Main Dot Dart");
      }
      await DeviceService.init();
      runApp(MyApp(home: BasePage()));
    }
  } catch (e, s) {
    await mainLocalLog(
      'Error Occoured While Initializing Main Dart File: ${e.toString()}',
      error: e,
      stackTrace: s,
    );
  }
}

Timer? timer;

void syncData() {
  returnData().syncData();
}

void maxWindow() {
  if (Platform.isLinux ||
      Platform.isMacOS ||
      Platform.isWindows) {
    timer = Timer.periodic(Duration(seconds: 1), (
      timer,
    ) async {
      var isMax = await windowManager.isMaximized();
      if (!isMax) {
        await windowManager.maximize();
        await mainLocalLog("Maximize In Emp Auth Page");
      } else {
        timer.cancel();
        await mainLocalLog('Timer Cancelled');
      }
    });
  }
}

bool get _isDesktopLogPlatform =>
    !kIsWeb &&
    (Platform.isLinux ||
        Platform.isMacOS ||
        Platform.isWindows);

Future<void> _logIoQueue = Future<void>.value();
Directory? _cachedLogDir;

Future<T> _enqueueLogOp<T>(Future<T> Function() op) {
  final completer = Completer<T>();
  _logIoQueue = _logIoQueue.then((_) async {
    try {
      completer.complete(await op());
    } catch (e, s) {
      completer.completeError(e, s);
    }
  });
  return completer.future;
}

String _joinLogPath(String dirPath, String fileName) {
  final sep = Platform.pathSeparator;
  return dirPath.endsWith(sep)
      ? '$dirPath$fileName'
      : '$dirPath$sep$fileName';
}

Future<Directory> _resolveWritableLogDirectory() async {
  if (_cachedLogDir != null &&
      await _cachedLogDir!.exists()) {
    return _cachedLogDir!;
  }

  final candidates = <Future<Directory> Function()>[
    getApplicationSupportDirectory,
    () async {
      final docs = await getApplicationDocumentsDirectory();
      return Directory(
        _joinLogPath(docs.path, 'StockallLogs'),
      );
    },
    () async => Directory(
      _joinLogPath(
        Directory.systemTemp.path,
        'StockallLogs',
      ),
    ),
  ];

  for (final getDir in candidates) {
    try {
      final dir = await getDir();
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      _cachedLogDir = dir;
      return dir;
    } catch (_) {
      continue;
    }
  }

  final fallback = Directory(
    _joinLogPath(Directory.systemTemp.path, 'StockallLogs'),
  );
  if (!await fallback.exists()) {
    await fallback.create(recursive: true);
  }
  _cachedLogDir = fallback;
  return fallback;
}

Future<File?> _findWindowsFallbackLogFile() async {
  if (!Platform.isWindows) return null;

  final candidates = <String>[];
  final appData = Platform.environment['APPDATA'];
  if (appData != null && appData.isNotEmpty) {
    candidates.add(
      _joinLogPath(
        _joinLogPath(
          _joinLogPath(appData, 'com.stockallsolutions'),
          'stockall',
        ),
        'mainLog.log',
      ),
    );
  }

  final localAppData = Platform.environment['LOCALAPPDATA'];
  if (localAppData != null && localAppData.isNotEmpty) {
    final packagesDir = Directory(
      _joinLogPath(localAppData, 'Packages'),
    );
    try {
      if (await packagesDir.exists()) {
        await for (final entity in packagesDir.list(
          followLinks: false,
        )) {
          if (entity is Directory) {
            final name =
                entity.path
                    .split(Platform.pathSeparator)
                    .last;
            if (name.startsWith(
              'StockallSolutions.Stockall',
            )) {
              candidates.add(
                _joinLogPath(
                  _joinLogPath(
                    _joinLogPath(
                      _joinLogPath(
                        _joinLogPath(
                          entity.path,
                          'LocalCache',
                        ),
                        'Roaming',
                      ),
                      'com.stockallsolutions',
                    ),
                    'stockall',
                  ),
                  'mainLog.log',
                ),
              );
            }
          }
        }
      }
    } catch (_) {}
  }

  candidates.add(
    _joinLogPath(
      _joinLogPath(
        Directory.systemTemp.path,
        'StockallLogs',
      ),
      'mainLog.log',
    ),
  );

  for (final path in candidates) {
    try {
      final file = File(path);
      if (await file.exists()) {
        return file;
      }
    } catch (_) {}
  }
  return null;
}

Future<void> initMainLog() async {
  if (!_isDesktopLogPlatform) return;
  await _enqueueLogOp(() async {
    try {
      final dir = await _resolveWritableLogDirectory();
      final file = File(
        _joinLogPath(dir.path, 'mainLog.log'),
      );

      // Check file size to avoid unbounded growth (5 MB limit)
      if (await file.exists()) {
        try {
          final length = await file.length();
          if (length > 5 * 1024 * 1024) {
            final prevFile = File(
              _joinLogPath(
                dir.path,
                'mainLog_previous.log',
              ),
            );
            if (await prevFile.exists()) {
              await prevFile.delete();
            }
            await file.rename(prevFile.path);
          }
        } catch (_) {}
      }

      final sessionHeader =
          '\n\n========== STOCKALL LOCAL LOG ==========\n'
          'SESSION START: ${DateTime.now().toString().split('.').first}\n'
          'VERSION: $appVersionDesktop\n'
          'PLATFORM: ${Platform.operatingSystem} (${Platform.operatingSystemVersion})\n'
          'STORAGE PATH: ${dir.path}\n'
          '========================================\n\n';

      await file.writeAsString(
        sessionHeader,
        mode: FileMode.append,
      );
    } catch (_) {}
  });
}

Future<String?> getMainLogFilePath() async {
  if (!_isDesktopLogPlatform) return null;
  final dir = await _resolveWritableLogDirectory();
  final primaryPath = _joinLogPath(dir.path, 'mainLog.log');
  if (await File(primaryPath).exists()) {
    return primaryPath;
  }
  final fallback = await _findWindowsFallbackLogFile();
  return fallback?.path ?? primaryPath;
}

Future<String?> getMainLogDirectoryPath() async {
  if (!_isDesktopLogPlatform) return null;
  final filePath = await getMainLogFilePath();
  if (filePath == null) return null;
  return File(filePath).parent.path;
}

Future<String> readMainLogContent({
  int maxLines = 3000,
}) async {
  return AppLogsFunc().readLogsFormatted();
}

Future<void> clearMainLog() async {
  await AppLogsFunc().clearLogs();
  if (!_isDesktopLogPlatform) return;
  await _enqueueLogOp(() async {
    try {
      final path = await getMainLogFilePath();
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.writeAsString(
            '========== STOCKALL LOCAL LOG CLEARED ==========\n'
            'TIME: ${DateTime.now().toString().split('.').first}\n'
            'VERSION: $appVersionDesktop\n'
            '===============================================\n\n',
          );
        }
      }
    } catch (_) {}
  });
}

Future<bool> openLogDirectory() async {
  if (kIsWeb) return false;
  try {
    final dirPath = await getMainLogDirectoryPath();
    if (dirPath == null) return false;
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    if (Platform.isWindows) {
      await Process.run('explorer.exe', [dirPath]);
      return true;
    } else if (Platform.isMacOS) {
      await Process.run('open', [dirPath]);
      return true;
    } else if (Platform.isLinux) {
      await Process.run('xdg-open', [dirPath]);
      return true;
    }
  } catch (e) {
    await mainLocalLog('Failed to open log directory: $e');
  }
  return false;
}

Future<void> mainLocalLog(
  String? message, {
  Object? error,
  StackTrace? stackTrace,
}) async {
  print('Log: ${message ?? 'Not Set'}');
  final buffer =
      StringBuffer()..writeln(
        'Log: [${DateTime.now().toString().split('.').first}] ${message ?? 'Not Set'}',
      );

  if (error != null) {
    buffer.writeln('Error Log: $error');
  }

  if (stackTrace != null) {
    buffer.writeln("Stack Trace Log: $stackTrace");
  }

  await AppLogsFunc().addLog(buffer.toString().trimRight());

  if (!_isDesktopLogPlatform) return;
  await _enqueueLogOp(() async {
    try {
      final dir = await _resolveWritableLogDirectory();
      final file = File(
        _joinLogPath(dir.path, 'mainLog.log'),
      );

      buffer.writeln();

      await file.writeAsString(
        buffer.toString(),
        mode: FileMode.append,
      );
    } catch (_) {}
  });
}

TempUserClass currentUser() {
  return UserProvider().currentUserMain ??
      TempUserClass(
        password: 'password',
        userId: '',
        name: 'name',
        email: 'email',
        role: 'role',
        departmentUuids: [],
        createdAt: DateTime.now(),
        access: [],
      );
}

DepartmentClass? currentDepartment() {
  return returnDepartmentProvider().currentDepartment();
}

SubscriptionClass? currentSubscription({
  BuildContext? context,
}) {
  if (context == null) {
    return SubscriptionProvider().subscription;
  } else {
    return returnSubcsription(context).subscription;
  }
}

TempCart currentCart({BuildContext? context}) {
  if (context == null) {
    return returnSalesProvider().currentCart();
  } else {
    return returnSalesProviderContext(
      context,
    ).currentCart();
  }
}

bool isStoreKeeper() {
  return currentUser().role == 'Store Keeper'
      ? true
      : false;
}

TempUserClass userGeneral(
  BuildContext context, {
  bool listen = true,
}) {
  return returnUserProvider(
        context,
        listen: listen,
      ).currentUserMain ??
      TempUserClass(
        password: 'password',
        name: 'name',
        email: 'email',
        role: 'Owner',
        userId: '',
        createdAt: DateTime.now(),
        authUserId: 'dfsgdhjfh',
        departmentUuids: [],
        access: [],
      );
}

int shopId() {
  var tempId = returnShopProvider().userShop()?.shopId ?? 1;

  return tempId;
}

ReportProvider returnReportProvider(
  BuildContext context, {
  bool listen = true,
}) {
  return Provider.of<ReportProvider>(
    context,
    listen: listen,
  );
}

ExpensesProvider returnExpensesProvider(
  BuildContext context, {
  bool listen = true,
}) {
  return Provider.of<ExpensesProvider>(
    context,
    listen: listen,
  );
}

ExpensesProvider returnExpensesProviderSingle() {
  return ExpensesProvider();
}

AuthService returnAuth(
  BuildContext context, {
  bool listen = true,
}) {
  return Provider.of<AuthService>(context, listen: listen);
}

NotificationProvider returnNotificationProvider(
  BuildContext context, {
  bool listen = true,
}) {
  return Provider.of<NotificationProvider>(
    context,
    listen: listen,
  );
}

ReceiptsProvider returnReceiptProviderSingle() {
  return ReceiptsProvider();
}

ReceiptsProvider returnReceiptProvider(
  BuildContext context, {
  bool listen = true,
}) {
  return Provider.of<ReceiptsProvider>(
    context,
    listen: listen,
  );
}

InvoicesProvider returnInvoicesProvider({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return InvoicesProvider();
  } else {
    return Provider.of<InvoicesProvider>(
      context,
      listen: listen,
    );
  }
}

StorageProductProvider returnStorageProductProvider({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return StorageProductProvider();
  } else {
    return Provider.of<StorageProductProvider>(
      context,
      listen: listen,
    );
  }
}

ShopDashboardProvider returnShopDashboardProvider({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return ShopDashboardProvider();
  } else {
    return Provider.of<ShopDashboardProvider>(
      context,
      listen: listen,
    );
  }
}

DepartmentsDashboardProvider
returnDepartmentsDashboardProvider({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return DepartmentsDashboardProvider();
  } else {
    return Provider.of<DepartmentsDashboardProvider>(
      context,
      listen: listen,
    );
  }
}

CategoriesProvider returnCategoriesProvider({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return CategoriesProvider();
  } else {
    return Provider.of<CategoriesProvider>(
      context,
      listen: listen,
    );
  }
}

SubStaffProvider returnSubStaffProvider({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return SubStaffProvider();
  } else {
    return Provider.of<SubStaffProvider>(
      context,
      listen: listen,
    );
  }
}

InventoryUpdatesProvider returnInventoryUpdatesProvider({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return InventoryUpdatesProvider();
  } else {
    return Provider.of<InventoryUpdatesProvider>(
      context,
      listen: listen,
    );
  }
}

TempShopClass? shop(
  BuildContext context, {
  bool listen = true,
}) {
  return returnShopProvider(
    context: context,
    listen: listen,
  ).userShop();
}

TempShopClass? shopSingle() {
  return returnShopProvider().userShop();
}

UserProvider returnUserProviderSingle() {
  return UserProvider();
}

UserProvider returnUserProvider(
  BuildContext context, {
  bool listen = true,
}) {
  return Provider.of<UserProvider>(context, listen: listen);
}

ShopProvider returnShopProvider({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return ShopProvider();
  } else {
    return Provider.of<ShopProvider>(
      context,
      listen: listen,
    );
  }
}

PrinterSettingsProvider returnPrinterSettingsProvider({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return PrinterSettingsProvider();
  } else {
    return Provider.of<PrinterSettingsProvider>(
      context,
      listen: listen,
    );
  }
}

ValidateInputProvider returnValidate(
  BuildContext context, {
  bool listen = true,
}) {
  return Provider.of<ValidateInputProvider>(
    context,
    listen: listen,
  );
}

ThemeProvider returnTheme(
  BuildContext context, {
  bool listen = true,
}) {
  return Provider.of<ThemeProvider>(
    context,
    listen: listen,
  );
}

DataProvider returnData({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return DataProvider();
  } else {
    return Provider.of<DataProvider>(
      context,
      listen: listen,
    );
  }
}

PermissionProvider returnPermissionProvider({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return PermissionProvider();
  } else {
    return Provider.of<PermissionProvider>(
      context,
      listen: listen,
    );
  }
}

CustomersProvider returnCustomers(
  BuildContext context, {
  bool listen = true,
}) {
  return Provider.of<CustomersProvider>(
    context,
    listen: listen,
  );
}

CustomersProvider returnCustomersSingle() {
  return CustomersProvider();
}

SubscriptionProvider returnSubcsription(
  BuildContext context, {
  bool listen = true,
}) {
  return Provider.of<SubscriptionProvider>(
    context,
    listen: listen,
  );
}

NavProvider returnNavProvider(
  BuildContext context, {
  bool listen = true,
}) {
  return Provider.of<NavProvider>(context, listen: listen);
}

NavProvider returnNavProviderSingle() {
  return NavProvider();
}

CompProvider returnCompProvider(
  BuildContext context, {
  bool listen = true,
}) {
  return Provider.of<CompProvider>(context, listen: listen);
}

SalesProvider returnSalesProvider() {
  return SalesProvider();
}

SalesProvider returnSalesProviderContext(
  BuildContext context, {
  bool listen = true,
}) {
  return Provider.of<SalesProvider>(
    context,
    listen: listen,
  );
}

TranslationProvider returnTranslationProvider(
  BuildContext context, {
  bool listen = true,
}) {
  return Provider.of<TranslationProvider>(
    context,
    listen: listen,
  );
}

ConnectivityProvider returnConnectivityProvider({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return ConnectivityProvider();
  } else {
    return Provider.of<ConnectivityProvider>(
      context,
      listen: listen,
    );
  }
}

SubPaymentProvider returnSubPaymentProvider({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return SubPaymentProvider();
  } else {
    return Provider.of<SubPaymentProvider>(
      context,
      listen: listen,
    );
  }
}

AppVersionProvider returnAppVersionProvider(
  BuildContext context, {
  bool listen = true,
}) {
  return Provider.of<AppVersionProvider>(
    context,
    listen: listen,
  );
}

MultiDisplayProvider returnMultiDisplayProvider() {
  return MultiDisplayProvider();
}

MultiDisplayProvider returnMultiDisplayProviderContext(
  BuildContext context, {
  bool listen = true,
}) {
  return Provider.of<MultiDisplayProvider>(
    context,
    listen: listen,
  );
}

EventsLogProvider returnEventsLogProvider({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return EventsLogProvider();
  } else {
    return Provider.of<EventsLogProvider>(
      context,
      listen: listen,
    );
  }
}

ErrorLogProvider returnErrorLogProvider({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return ErrorLogProvider();
  } else {
    return Provider.of<ErrorLogProvider>(
      context,
      listen: listen,
    );
  }
}

DepartmentProvider returnDepartmentProvider({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return DepartmentProvider();
  } else {
    return Provider.of<DepartmentProvider>(
      context,
      listen: listen,
    );
  }
}

PurchaseProvider returnPurchaseProvider({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return PurchaseProvider();
  } else {
    return Provider.of<PurchaseProvider>(
      context,
      listen: listen,
    );
  }
}

SuppliersProvider returnSuppliersProvider({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return SuppliersProvider();
  } else {
    return Provider.of<SuppliersProvider>(
      context,
      listen: listen,
    );
  }
}

PurchaseActionProvider returnPurchaseActionProvider({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return PurchaseActionProvider();
  } else {
    return Provider.of<PurchaseActionProvider>(
      context,
      listen: listen,
    );
  }
}

// WaybillProvider returnWaybillProvider({
//   BuildContext? context,
// }) {
//   if (context == null) {
//     return WaybillProvider();
//   } else {
//     return Provider.of<WaybillProvider>(context);
//   }
// }

UtilityWidgetProvider returnUtilityWidgetProvider({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return UtilityWidgetProvider();
  } else {
    return Provider.of<UtilityWidgetProvider>(
      context,
      listen: listen,
    );
  }
}

UtilityConstantProvider returnUtilityConstantProvider({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return UtilityConstantProvider();
  } else {
    return Provider.of<UtilityConstantProvider>(
      context,
      listen: listen,
    );
  }
}

CountryProvider returnCountryProvider({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return CountryProvider();
  } else {
    return Provider.of<CountryProvider>(
      context,
      listen: listen,
    );
  }
}

QuantityUpdateProvider returnQuantityUpdateProvider({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return QuantityUpdateProvider();
  } else {
    return Provider.of<QuantityUpdateProvider>(
      context,
      listen: listen,
    );
  }
}

ItemHistoryProvider returnItemHistoryProvider({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return ItemHistoryProvider();
  } else {
    return Provider.of<ItemHistoryProvider>(
      context,
      listen: listen,
    );
  }
}

ProductionItemHistoryProvider
returnProductionItemHistoryProvider({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return ProductionItemHistoryProvider();
  } else {
    return Provider.of<ProductionItemHistoryProvider>(
      context,
      listen: listen,
    );
  }
}

MaterialsItemHistoryProvider
returnMaterialsItemHistoryProvider({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return MaterialsItemHistoryProvider();
  } else {
    return Provider.of<MaterialsItemHistoryProvider>(
      context,
      listen: listen,
    );
  }
}

MaterialsProvider returnMaterialsProvider({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return MaterialsProvider();
  } else {
    return Provider.of<MaterialsProvider>(
      context,
      listen: listen,
    );
  }
}

MaterialQuantityUpdateProvider
returnMaterialsQuantityUpdateProvider({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return MaterialQuantityUpdateProvider();
  } else {
    return Provider.of<MaterialQuantityUpdateProvider>(
      context,
      listen: listen,
    );
  }
}

ProductionItemsProvider returnProductionItemsProvider({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return ProductionItemsProvider();
  } else {
    return Provider.of<ProductionItemsProvider>(
      context,
      listen: listen,
    );
  }
}

ProductionItemsQuantityUpdateProvider
returnProductionItemsQuantityUpdateProvider({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return ProductionItemsQuantityUpdateProvider();
  } else {
    return Provider.of<
      ProductionItemsQuantityUpdateProvider
    >(context, listen: listen);
  }
}

ProductionRecordsProvider returnProductionRecordsProvider({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return ProductionRecordsProvider();
  } else {
    return Provider.of<ProductionRecordsProvider>(
      context,
      listen: listen,
    );
  }
}

ProductionsActionProvider returnProductionsActionProvider({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return ProductionsActionProvider();
  } else {
    return Provider.of<ProductionsActionProvider>(
      context,
      listen: listen,
    );
  }
}

MaterialsUsageProvider returnMaterialsUsageProvider({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return MaterialsUsageProvider();
  } else {
    return Provider.of<MaterialsUsageProvider>(
      context,
      listen: listen,
    );
  }
}

MaterialsUsageActionProvider
returnMaterialsUsageActionProvider({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return MaterialsUsageActionProvider();
  } else {
    return Provider.of<MaterialsUsageActionProvider>(
      context,
      listen: listen,
    );
  }
}

CustomerAccountReceiptsProvider
returnCustomerAccountReceiptsProvider({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return CustomerAccountReceiptsProvider();
  } else {
    return Provider.of<CustomerAccountReceiptsProvider>(
      context,
      listen: listen,
    );
  }
}

OrdersProvider returnOrdersProvider({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return OrdersProvider();
  } else {
    return Provider.of<OrdersProvider>(
      context,
      listen: listen,
    );
  }
}

DraftsProvider returnDraftsProvider({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return DraftsProvider();
  } else {
    return Provider.of<DraftsProvider>(
      context,
      listen: listen,
    );
  }
}

OrdersActionProvider returnOrdersActionProvider({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return OrdersActionProvider();
  } else {
    return Provider.of<OrdersActionProvider>(
      context,
      listen: listen,
    );
  }
}

StorageItemHistoryProvider
returnStorageItemHistoryProvider({
  BuildContext? context,
  bool listen = true,
}) {
  if (context == null) {
    return StorageItemHistoryProvider();
  } else {
    return Provider.of<StorageItemHistoryProvider>(
      context,
      listen: listen,
    );
  }
}

Widget colorWidget(
  Widget widget,
  bool isPrimary,
  BuildContext context,
) {
  return Builder(
    builder: (context) {
      final colors =
          isPrimary
              ? Provider.of<ThemeProvider>(
                context,
              ).lightModeColor.prGradientColors
              : Provider.of<ThemeProvider>(
                context,
              ).lightModeColor.secGradientColors;

      return ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            colors: colors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds);
        },
        blendMode: BlendMode.srcIn,
        child: widget,
      );
    },
  );
}

class MyApp extends StatefulWidget {
  final Widget home;
  const MyApp({super.key, required this.home});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      returnData().syncProductsIncremental();
      returnData().startPeriodicIncrementalSync();
    } else if (state == AppLifecycleState.paused) {
      returnData().stopPeriodicIncrementalSync();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SalesProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CompProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => NavProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => DataProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CustomersProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ValidateInputProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ShopProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ReceiptsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => InvoicesProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => VisibilityBox(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ExpensesProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ReportProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => TranslationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ConnectivityProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SubscriptionProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SubPaymentProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AppVersionProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => MultiDisplayProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => EventsLogProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => DepartmentProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => InventoryUpdatesProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SubStaffProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ShopDashboardProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => PermissionProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoriesProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => DepartmentsDashboardProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => StorageProductProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SuppliersProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => PurchaseProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => PurchaseActionProvider(),
        ),
        // ChangeNotifierProvider(
        //   create: (_) => WaybillProvider(),
        // ),
        ChangeNotifierProvider(
          create: (_) => UtilityWidgetProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UtilityConstantProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CountryProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ErrorLogProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => QuantityUpdateProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ItemHistoryProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductionItemHistoryProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => MaterialsItemHistoryProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => MaterialsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => MaterialQuantityUpdateProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductionItemsProvider(),
        ),
        ChangeNotifierProvider(
          create:
              (_) =>
                  ProductionItemsQuantityUpdateProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductionRecordsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductionsActionProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => MaterialsUsageProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => MaterialsUsageActionProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CustomerAccountReceiptsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrdersProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => DraftsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrdersActionProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => StorageItemHistoryProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => PrinterSettingsProvider(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Stockall Business Dashboard',
        initialRoute: "/",
        routes: {
          '/': (context) => widget.home,
          '/launch': (context) => LaunchScreen(),
          '/login':
              (context) => LoginPage(useDemoLogin: false),
          '/splash': (context) => SplashScreen(),
          '/reset-password':
              (context) => EnterNewPassword(),
          '/subscription': (context) => SubscriptionPage(),
          '/delete-account': (context) => DeleteAccount(),
          '/payment-result':
              (context) => PaymentResultPage(),
          '/subscription-page':
              (context) => SubscriptionPage(),
        },

        debugShowCheckedModeBanner: false,

        theme: ThemeData(
          appBarTheme: AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle(
              systemStatusBarContrastEnforced: true,
            ),
            backgroundColor: Colors.white,
            centerTitle: true,
            elevation: 0,
            toolbarHeight: 80,
          ),

          scaffoldBackgroundColor: Colors.white,

          fontFamily: 'Plus Jakarta Sans',

          primaryColor: const Color.fromRGBO(
            25,
            43,
            117,
            1,
          ),
        ),
      ),
    );
  }
}

class MyAppAlt extends StatelessWidget {
  final Widget home;
  const MyAppAlt({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Stockall Business Dashboard',
        home: home,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          datePickerTheme: DatePickerThemeData(
            backgroundColor: Colors.white,
            cancelButtonStyle: ButtonStyle(
              padding: WidgetStateProperty.all(
                EdgeInsets.all(50),
              ),
            ),
          ),
          appBarTheme: AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle(
              systemStatusBarContrastEnforced: true,
            ),
            backgroundColor: Colors.white,
            centerTitle: true,
            elevation: 0,
            toolbarHeight: 80,
          ),
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Plus Jakarta Sans',
          primaryColor: const Color.fromRGBO(
            25,
            43,
            117,
            1,
          ),
        ),
      ),
    );
  }
}

// Screen harness for the report export widget tests: a Hive current shop,
// an empty item history box, ShopProvider().userShops and a localhost
// Supabase client (as business_day_date_filtering_test.dart does), so a
// report view can load and build its toolbar.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/temp_current_department/temp_current_department.dart';
import 'package:stockall/classes/temp_customer_account_receipts/customer_account_receipts.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_current_shop/temp_current_shop.dart';
import 'package:stockall/classes/temp_inventory_updates/temp_inventory_update_class.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';
import 'package:stockall/local_database/customer_account_receipts/customer_account_receipts_func.dart';
import 'package:stockall/local_database/customers/customer_func.dart';
import 'package:stockall/local_database/department_current/current_department_func.dart';
import 'package:stockall/local_database/inventory_updates/inventory_updates_func.dart';
import 'package:stockall/local_database/invoices/invoices_func.dart';
import 'package:stockall/local_database/item_history/item_histories_func.dart';
import 'package:stockall/local_database/main_receipt/main_receipt_func.dart';
import 'package:stockall/local_database/product_record_func.dart/product_record_func.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/local_database/shop_current/current_shop_func.dart';
import 'package:stockall/local_database/storage_item_history/storage_item_histories_func.dart';
import 'package:stockall/local_database/storage_product/storage_products_func.dart';
import 'package:stockall/providers/categories_provider.dart';
import 'package:stockall/providers/data_provider.dart';
import 'package:stockall/providers/receipts_provider.dart';
import 'package:stockall/providers/shop_provider.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MemoryAsyncStorage extends GotrueAsyncStorage {
  final _items = <String, String>{};

  @override
  Future<String?> getItem({required String key}) async => _items[key];

  @override
  Future<void> setItem({required String key, required String value}) async =>
      _items[key] = value;

  @override
  Future<void> removeItem({required String key}) async => _items.remove(key);
}

Future<void> setUpScreenEnvironment() async {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async => Directory.systemTemp.path,
      );
  try {
    await Supabase.initialize(
      url: 'http://localhost',
      anonKey: 'test-anon-key',
      authOptions: FlutterAuthClientOptions(
        localStorage: const EmptyLocalStorage(),
        pkceAsyncStorage: _MemoryAsyncStorage(),
        detectSessionInUri: false,
        autoRefreshToken: false,
      ),
    );
  } catch (_) {}

  final tempDir = Directory.systemTemp.createTempSync('stockall_report_export');
  Hive.init(tempDir.path);
  if (!Hive.isAdapterRegistered(30)) {
    Hive.registerAdapter(TempCurrentShopAdapter());
  }
  if (!Hive.isAdapterRegistered(97)) {
    Hive.registerAdapter(ItemHistoryAdapter());
  }
  CurrentShopFunc().currentShopBox = await Hive.openBox<TempCurrentShop>(
    'currentShopReportExportTest',
  );
  await CurrentShopFunc().currentShopBox.add(TempCurrentShop(currentShopId: 1));
  // An empty history box, so the history pages load instead of erroring.
  ItemHistoriesFunc().itemHistoryBox = await Hive.openBox<ItemHistory>(
    'itemHistoryReportExportTest',
  );
  // Empty sales boxes, so the receipt / item sales pages load into
  // their empty state (nothing is read, so no adapters are needed).
  MainReceiptFunc().receiptBox = await Hive.openBox<TempMainReceipt>(
    'receiptReportExportTest',
  );
  InvoicesFunc().invoicesBox = await Hive.openBox<TempInvoice>(
    'invoiceReportExportTest',
  );
  ProductsFunc().productBox = await Hive.openBox<TempProductClass>(
    'productReportExportTest',
  );
  CurrentDepartmentFunc().currentDepartmentBox =
      await Hive.openBox<TempCurrentDepartment>('departmentReportExportTest');
  ProductRecordFunc().productRecordBox =
      await Hive.openBox<TempProductSaleRecord>('salesReportExportTest');
  // Empty customer boxes, so the invoice pages' customer load succeeds.
  CustomerFunc().customerBox = await Hive.openBox<TempCustomersClass>(
    'customerReportExportTest',
  );
  CustomerAccountReceiptsFunc().customerAccountReceiptsBox =
      await Hive.openBox<CustomerAccountReceipts>(
        'customerAccountReceiptsReportExportTest',
      );
  // Empty storage boxes, so the storage report pages load.
  StorageProductsFunc().storageProductsBox =
      await Hive.openBox<TempStorageProducts>('storageProductsReportExportTest');
  StorageItemHistoriesFunc().storageItemHistoryBox =
      await Hive.openBox<StorageItemHistory>('storageHistoryReportExportTest');
  InventoryUpdatesFunc().inventoryUpdatesBox =
      await Hive.openBox<TempInventoryUpdateClass>('inventoryUpdatesReportExportTest');
  ShopProvider().userShops = [
    TempShopClass(
      shopId: 1,
      createdAt: DateTime.utc(2026),
      userId: 'owner-1',
      name: 'Shop',
      currency: 'NGN',
      isVerified: true,
      applyVAT: false,
      manageInventoryStorage: false,
      wholeSale: false,
      manageDepartments: false,
      printSalesDocket: false,
      closeSaleTimeString: null,
      trackCart: false,
      accessPin: null,
      manageProductions: false,
      manageProductionsStorage: false,
      manageProductionItems: false,
      customerPercentageReward: 0,
      manageCustomerReward: false,
      manageCustomerAccount: false,
    ),
  ];
}

/// Pumps [screen] at a desktop (1800 wide) or mobile (500 wide) size and
/// lets its first data load finish.
Future<void> pumpReportScreen(
  WidgetTester tester,
  Widget screen, {
  required bool desktop,
}) async {
  tester.view.physicalSize =
      desktop ? const Size(1800, 1000) : const Size(500, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        // Some views read the shop through Provider.of (the singleton).
        ChangeNotifierProvider<ShopProvider>.value(value: ShopProvider()),
        ChangeNotifierProvider<ReceiptsProvider>.value(
          value: ReceiptsProvider(),
        ),
        ChangeNotifierProvider<DataProvider>.value(value: DataProvider()),
        ChangeNotifierProvider<CategoriesProvider>.value(
          value: CategoriesProvider(),
        ),
      ],
      child: MaterialApp(home: screen),
    ),
  );
  // The first frame schedules the data load; let it finish.
  await settleReportScreen(tester);
}

/// A few bounded frames instead of pumpAndSettle: some empty states
/// animate forever, so pumpAndSettle would time out.
/// The loads also do real I/O (the local log), so real time is let pass.
Future<void> settleReportScreen(WidgetTester tester) async {
  await tester.pump();
  for (var i = 0; i < 10; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

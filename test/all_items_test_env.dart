// Test environment for the All Items page and the bulk stock
// adjustment logic: a Hive current shop (shop 1), empty product /
// department / history / storage boxes, ShopProvider().userShops and
// a localhost Supabase client. Same approach as
// report_export_screen_harness.dart, limited to what these tests use.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/temp_current_department/temp_current_department.dart';
import 'package:stockall/classes/temp_current_shop/temp_current_shop.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';
import 'package:stockall/local_database/department_current/current_department_func.dart';
import 'package:stockall/local_database/item_history/item_histories_func.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/local_database/shop_current/current_shop_func.dart';
import 'package:stockall/local_database/storage_product/storage_products_func.dart';
import 'package:stockall/providers/categories_provider.dart';
import 'package:stockall/providers/comp_provider.dart';
import 'package:stockall/providers/data_provider.dart';
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

bool _isSetUp = false;

Future<void> setUpAllItemsEnvironment() async {
  if (_isSetUp) return;
  _isSetUp = true;

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

  final tempDir = Directory.systemTemp.createTempSync('stockall_all_items');
  Hive.init(tempDir.path);
  if (!Hive.isAdapterRegistered(30)) {
    Hive.registerAdapter(TempCurrentShopAdapter());
  }
  CurrentShopFunc().currentShopBox = await Hive.openBox<TempCurrentShop>(
    'currentShopAllItemsTest',
  );
  await CurrentShopFunc().currentShopBox.add(TempCurrentShop(currentShopId: 1));
  // Empty boxes, so the page and providers can read them.
  ProductsFunc().productBox = await Hive.openBox<TempProductClass>(
    'productAllItemsTest',
  );
  CurrentDepartmentFunc().currentDepartmentBox =
      await Hive.openBox<TempCurrentDepartment>('departmentAllItemsTest');
  ItemHistoriesFunc().itemHistoryBox = await Hive.openBox<ItemHistory>(
    'itemHistoryAllItemsTest',
  );
  StorageProductsFunc().storageProductsBox =
      await Hive.openBox<TempStorageProducts>('storageProductsAllItemsTest');

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

/// Pumps [home] at a desktop (1800 wide) or mobile (500 wide) size
/// with the providers the All Items page reads.
Future<void> pumpAllItemsApp(
  WidgetTester tester,
  Widget home, {
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
        ChangeNotifierProvider<CompProvider>(create: (_) => CompProvider()),
        ChangeNotifierProvider<ShopProvider>.value(value: ShopProvider()),
        ChangeNotifierProvider<DataProvider>.value(value: DataProvider()),
        ChangeNotifierProvider<CategoriesProvider>.value(
          value: CategoriesProvider(),
        ),
      ],
      child: MaterialApp(home: home),
    ),
  );
  await settleAllItems(tester);
}

/// A few bounded frames instead of pumpAndSettle (some empty states
/// animate forever), letting real I/O such as the local log finish.
Future<void> settleAllItems(WidgetTester tester) async {
  await tester.pump();
  for (var i = 0; i < 10; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

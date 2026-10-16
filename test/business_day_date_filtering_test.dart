import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_current_shop/temp_current_shop.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/classes/temp_item_history/item_history_event_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_item_history/materials_item_history.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_item_history/production_item_history.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/local_database/shop_current/current_shop_func.dart';
import 'package:stockall/pages/report/item_history_report/class/item_history_report_logic.dart';
import 'package:stockall/pages/report/items_report_main/class/items_report_main_logic.dart';
import 'package:stockall/providers/item_history_provider.dart';
import 'package:stockall/providers/production_folder/materials_item_history_provider.dart';
import 'package:stockall/providers/production_folder/production_item_history_provider.dart';
import 'package:stockall/providers/shop_provider.dart';
import 'package:stockall/providers/storage_item_history_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MemoryAsyncStorage extends GotrueAsyncStorage {
  final _items = <String, String>{};

  @override
  Future<String?> getItem({required String key}) async =>
      _items[key];

  @override
  Future<void> setItem({
    required String key,
    required String value,
  }) async => _items[key] = value;

  @override
  Future<void> removeItem({required String key}) async =>
      _items.remove(key);
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding
        .instance
        .defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel(
            'plugins.flutter.io/path_provider',
          ),
          (MethodCall methodCall) async =>
              Directory.systemTemp.path,
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

    final tempDir = Directory.systemTemp.createTempSync(
      'stockall_bday_test',
    );
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(30)) {
      Hive.registerAdapter(TempCurrentShopAdapter());
    }
    CurrentShopFunc().currentShopBox =
        await Hive.openBox<TempCurrentShop>(
          'currentShopTest',
        );
    await CurrentShopFunc().currentShopBox.add(
      TempCurrentShop(currentShopId: 1),
    );
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
  });

  group('Business-Day Date Filtering Core Calculation Tests', () {
    test(
      'Case A: No custom closing time (default midnight boundaries)',
      () {
        final oct15 = DateTime(2026, 10, 15);
        final oct16 = DateTime(2026, 10, 16);

        // Record at 12:00 AM on Oct 15 -> Belongs to Oct 15
        final r12amUtc = DateTime.utc(
          2026,
          10,
          15,
          0,
          0,
          0,
        );
        final r12amLocal = DateTime(2026, 10, 15, 0, 0, 0);
        expect(
          isDateTimeInBusinessWindow(
            dateTime: r12amUtc,
            dateSet: oct15,
          ),
          isTrue,
        );
        expect(
          isDateTimeInBusinessWindow(
            dateTime: r12amLocal,
            dateSet: oct15,
          ),
          isTrue,
        );

        // Record at 11:00 PM on Oct 15 -> Belongs to Oct 15
        final r11pmUtc = DateTime.utc(
          2026,
          10,
          15,
          23,
          0,
          0,
        );
        final r11pmLocal = DateTime(2026, 10, 15, 23, 0, 0);
        expect(
          isDateTimeInBusinessWindow(
            dateTime: r11pmUtc,
            dateSet: oct15,
          ),
          isTrue,
        );
        expect(
          isDateTimeInBusinessWindow(
            dateTime: r11pmLocal,
            dateSet: oct15,
          ),
          isTrue,
        );
        expect(
          isDateTimeInBusinessWindow(
            dateTime: r11pmUtc,
            dateSet: oct16,
          ),
          isFalse,
        );

        // Record at 11:30 PM on Oct 15 -> Belongs to Oct 15
        final r1130pmUtc = DateTime.utc(
          2026,
          10,
          15,
          23,
          30,
          0,
        );
        final r1130pmLocal = DateTime(
          2026,
          10,
          15,
          23,
          30,
          0,
        );
        expect(
          isDateTimeInBusinessWindow(
            dateTime: r1130pmUtc,
            dateSet: oct15,
          ),
          isTrue,
        );
        expect(
          isDateTimeInBusinessWindow(
            dateTime: r1130pmLocal,
            dateSet: oct15,
          ),
          isTrue,
        );
        expect(
          isDateTimeInBusinessWindow(
            dateTime: r1130pmUtc,
            dateSet: oct16,
          ),
          isFalse,
        );

        // Record at 11:59:59.999 PM on Oct 15 -> Belongs to Oct 15
        final r1159pmUtc = DateTime.utc(
          2026,
          10,
          15,
          23,
          59,
          59,
          999,
        );
        final r1159pmLocal = DateTime(
          2026,
          10,
          15,
          23,
          59,
          59,
          999,
        );
        expect(
          isDateTimeInBusinessWindow(
            dateTime: r1159pmUtc,
            dateSet: oct15,
          ),
          isTrue,
        );
        expect(
          isDateTimeInBusinessWindow(
            dateTime: r1159pmLocal,
            dateSet: oct15,
          ),
          isTrue,
        );
        expect(
          isDateTimeInBusinessWindow(
            dateTime: r1159pmUtc,
            dateSet: oct16,
          ),
          isFalse,
        );

        // Record exactly at next midnight (12:00:00 AM on Oct 16) -> Belongs to Oct 16, NOT Oct 15
        final rNextMidnightUtc = DateTime.utc(
          2026,
          10,
          16,
          0,
          0,
          0,
        );
        final rNextMidnightLocal = DateTime(
          2026,
          10,
          16,
          0,
          0,
          0,
        );
        expect(
          isDateTimeInBusinessWindow(
            dateTime: rNextMidnightUtc,
            dateSet: oct15,
          ),
          isFalse,
        );
        expect(
          isDateTimeInBusinessWindow(
            dateTime: rNextMidnightLocal,
            dateSet: oct15,
          ),
          isFalse,
        );
        expect(
          isDateTimeInBusinessWindow(
            dateTime: rNextMidnightUtc,
            dateSet: oct16,
          ),
          isTrue,
        );
        expect(
          isDateTimeInBusinessWindow(
            dateTime: rNextMidnightLocal,
            dateSet: oct16,
          ),
          isTrue,
        );
      },
    );

    test(
      'Case B: Custom closing time configured at 10:00 PM (22:00)',
      () {
        const closing10pm = TimeOfDay(hour: 22, minute: 0);
        final oct15 = DateTime(2026, 10, 15);
        final oct16 = DateTime(2026, 10, 16);

        // Record immediately before custom closing boundary (21:59:59 on Oct 15)
        // Belongs to preceding business day (Oct 14), not Oct 15
        final beforeBoundary = DateTime.utc(
          2026,
          10,
          15,
          21,
          59,
          59,
        );
        expect(
          isDateTimeInBusinessWindow(
            dateTime: beforeBoundary,
            dateSet: oct15,
            customClosingTime: closing10pm,
          ),
          isFalse,
        );

        // Record at custom closing boundary (22:00:00 on Oct 15)
        // Belongs to the business day opening at 22:00 (Oct 15)
        final atBoundary = DateTime.utc(
          2026,
          10,
          15,
          22,
          0,
          0,
        );
        expect(
          isDateTimeInBusinessWindow(
            dateTime: atBoundary,
            dateSet: oct15,
            customClosingTime: closing10pm,
          ),
          isTrue,
        );

        // Record immediately after custom closing boundary (22:30:00 on Oct 15)
        // Belongs to Oct 15
        final afterBoundary = DateTime.utc(
          2026,
          10,
          15,
          22,
          30,
          0,
        );
        expect(
          isDateTimeInBusinessWindow(
            dateTime: afterBoundary,
            dateSet: oct15,
            customClosingTime: closing10pm,
          ),
          isTrue,
        );

        // Record on Oct 16 before closing boundary (21:59:59 on Oct 16)
        // Belongs to Oct 15 business day
        final beforeNextClosing = DateTime.utc(
          2026,
          10,
          16,
          21,
          59,
          59,
        );
        expect(
          isDateTimeInBusinessWindow(
            dateTime: beforeNextClosing,
            dateSet: oct15,
            customClosingTime: closing10pm,
          ),
          isTrue,
        );
        expect(
          isDateTimeInBusinessWindow(
            dateTime: beforeNextClosing,
            dateSet: oct16,
            customClosingTime: closing10pm,
          ),
          isFalse,
        );

        // Record exactly at next closing boundary (22:00:00 on Oct 16)
        // Belongs to Oct 16 business day
        final atNextClosing = DateTime.utc(
          2026,
          10,
          16,
          22,
          0,
          0,
        );
        expect(
          isDateTimeInBusinessWindow(
            dateTime: atNextClosing,
            dateSet: oct15,
            customClosingTime: closing10pm,
          ),
          isFalse,
        );
        expect(
          isDateTimeInBusinessWindow(
            dateTime: atNextClosing,
            dateSet: oct16,
            customClosingTime: closing10pm,
          ),
          isTrue,
        );
      },
    );

    test(
      'Case B: Custom closing time configured after midnight at 2:00 AM (02:00)',
      () {
        const closing2am = TimeOfDay(hour: 2, minute: 0);
        final oct15 = DateTime(2026, 10, 15);
        final oct16 = DateTime(2026, 10, 16);

        // Record at 01:59:59 on Oct 16 belongs to Oct 15 business day
        final r159am = DateTime.utc(
          2026,
          10,
          16,
          1,
          59,
          59,
        );
        expect(
          isDateTimeInBusinessWindow(
            dateTime: r159am,
            dateSet: oct15,
            customClosingTime: closing2am,
          ),
          isTrue,
        );
        expect(
          isDateTimeInBusinessWindow(
            dateTime: r159am,
            dateSet: oct16,
            customClosingTime: closing2am,
          ),
          isFalse,
        );

        // Record at 02:00:00 on Oct 16 belongs to Oct 16 business day
        final r2am = DateTime.utc(2026, 10, 16, 2, 0, 0);
        expect(
          isDateTimeInBusinessWindow(
            dateTime: r2am,
            dateSet: oct15,
            customClosingTime: closing2am,
          ),
          isFalse,
        );
        expect(
          isDateTimeInBusinessWindow(
            dateTime: r2am,
            dateSet: oct16,
            customClosingTime: closing2am,
          ),
          isTrue,
        );

        // Record at 11:30 PM on Oct 15 belongs to Oct 15 business day
        final r1130pm = DateTime.utc(
          2026,
          10,
          15,
          23,
          30,
          0,
        );
        expect(
          isDateTimeInBusinessWindow(
            dateTime: r1130pm,
            dateSet: oct15,
            customClosingTime: closing2am,
          ),
          isTrue,
        );
        expect(
          isDateTimeInBusinessWindow(
            dateTime: r1130pm,
            dateSet: oct16,
            customClosingTime: closing2am,
          ),
          isFalse,
        );
      },
    );

    test(
      'Date range filtering (single day and multi-day)',
      () {
        final start = DateTime(2026, 10, 10);
        final end = DateTime(2026, 10, 15, 23, 59, 59);

        // Inside range
        final inRange1 = DateTime.utc(
          2026,
          10,
          10,
          0,
          0,
          0,
        );
        final inRange2 = DateTime.utc(
          2026,
          10,
          15,
          23,
          30,
          0,
        );
        expect(
          isDateTimeInBusinessWindow(
            dateTime: inRange1,
            rangeStartDate: start,
            rangeEndDate: end,
          ),
          isTrue,
        );
        expect(
          isDateTimeInBusinessWindow(
            dateTime: inRange2,
            rangeStartDate: start,
            rangeEndDate: end,
          ),
          isTrue,
        );

        // Outside range
        final beforeRange = DateTime.utc(
          2026,
          10,
          9,
          23,
          59,
          59,
        );
        final afterRange = DateTime.utc(
          2026,
          10,
          16,
          0,
          0,
          0,
        );
        expect(
          isDateTimeInBusinessWindow(
            dateTime: beforeRange,
            rangeStartDate: start,
            rangeEndDate: end,
          ),
          isFalse,
        );
        expect(
          isDateTimeInBusinessWindow(
            dateTime: afterRange,
            rangeStartDate: start,
            rangeEndDate: end,
          ),
          isFalse,
        );
      },
    );
  });

  group('All Four History Providers Filtering Tests', () {
    test(
      '1. Main Item History Provider filters UTC and Local records correctly',
      () {
        final provider = ItemHistoryProvider();
        provider.clearDate();

        final h1 = ItemHistory(
          uuid: '1',
          shopId: 1,
          title: 'Morning Oct 15',
          createdAt: DateTime.utc(2026, 10, 15, 9, 0, 0),
          newValue: '10',
          oldValue: '5',
          quantityChange: 5,
          desc: 'test',
          isIncreased: true,
          event: 'sale',
          isManaged: true,
          source: 's',
        );
        final h2 = ItemHistory(
          uuid: '2',
          shopId: 1,
          title: 'Late Night 11:30 PM Oct 15 (UTC)',
          createdAt: DateTime.utc(2026, 10, 15, 23, 30, 0),
          newValue: '15',
          oldValue: '10',
          quantityChange: 5,
          desc: 'test',
          isIncreased: true,
          event: 'sale',
          isManaged: true,
          source: 's',
        );
        final h3 = ItemHistory(
          uuid: '3',
          shopId: 1,
          title: 'Late Night 11:30 PM Oct 15 (Local)',
          createdAt: DateTime(2026, 10, 15, 23, 30, 0),
          newValue: '20',
          oldValue: '15',
          quantityChange: 5,
          desc: 'test',
          isIncreased: true,
          event: 'sale',
          isManaged: true,
          source: 's',
        );
        final h4 = ItemHistory(
          uuid: '4',
          shopId: 1,
          title: 'Oct 16 Record',
          createdAt: DateTime.utc(2026, 10, 16, 10, 0, 0),
          newValue: '25',
          oldValue: '20',
          quantityChange: 5,
          desc: 'test',
          isIncreased: true,
          event: 'sale',
          isManaged: true,
          source: 's',
        );

        provider.itemHistories = [h1, h2, h3, h4];

        // Filter by Oct 15
        provider.setDate(DateTime(2026, 10, 15));
        final resultOct15 = provider.returnItemHistories();
        expect(
          resultOct15.map((h) => h.uuid).toSet(),
          equals({'1', '2', '3'}),
        );
        expect(
          resultOct15.any((h) => h.uuid == '4'),
          isFalse,
        );

        // Filter by Oct 16
        provider.clearDate();
        provider.setDate(DateTime(2026, 10, 16));
        final resultOct16 = provider.returnItemHistories();
        expect(
          resultOct16.map((h) => h.uuid).toSet(),
          equals({'4'}),
        );
        expect(
          resultOct16.any((h) => h.uuid == '2'),
          isFalse,
        );
        expect(
          resultOct16.any((h) => h.uuid == '3'),
          isFalse,
        );
      },
    );

    test(
      '2. Storage Item History Provider filters UTC and Local records correctly',
      () {
        final provider = StorageItemHistoryProvider();
        provider.clearDate();

        final s1 = StorageItemHistory(
          uuid: 's1',
          shopId: 1,
          title: 'Oct 15 11:30 PM (UTC)',
          createdAt: DateTime.utc(2026, 10, 15, 23, 30, 0),
          storageItemNewValue: '10',
          storageItemOldValue: '5',
          quantityChange: 5,
          desc: 'test',
          isIncreased: true,
          event: 'storage_in',
          source: 's',
        );
        final s2 = StorageItemHistory(
          uuid: 's2',
          shopId: 1,
          title: 'Oct 16 9:00 AM (UTC)',
          createdAt: DateTime.utc(2026, 10, 16, 9, 0, 0),
          storageItemNewValue: '15',
          storageItemOldValue: '10',
          quantityChange: 5,
          desc: 'test',
          isIncreased: true,
          event: 'storage_in',
          source: 's',
        );

        provider.storageItemHistories = [s1, s2];

        provider.setDate(DateTime(2026, 10, 15));
        final resOct15 = provider.returnItemHistories();
        expect(
          resOct15.map((s) => s.uuid).toList(),
          equals(['s1']),
        );

        provider.clearDate();
        provider.setDate(DateTime(2026, 10, 16));
        final resOct16 = provider.returnItemHistories();
        expect(
          resOct16.map((s) => s.uuid).toList(),
          equals(['s2']),
        );
      },
    );

    test(
      '3. Materials Item History Provider filters UTC and Local records correctly',
      () {
        final provider = MaterialsItemHistoryProvider();
        provider.clearDate();

        final m1 = MaterialsItemHistory(
          uuid: 'm1',
          shopId: 1,
          title: 'Oct 15 11:30 PM (UTC)',
          createdAt: DateTime.utc(2026, 10, 15, 23, 30, 0),
          newValue: '10',
          oldValue: '5',
          quantityChange: 5,
          desc: 'test',
          isIncreased: true,
          event: 'usage',
          isManaged: true,
          source: 's',
        );
        final m2 = MaterialsItemHistory(
          uuid: 'm2',
          shopId: 1,
          title: 'Oct 16 (UTC)',
          createdAt: DateTime.utc(2026, 10, 16, 8, 0, 0),
          newValue: '15',
          oldValue: '10',
          quantityChange: 5,
          desc: 'test',
          isIncreased: true,
          event: 'usage',
          isManaged: true,
          source: 's',
        );

        provider.materialsItemHistories = [m1, m2];

        provider.setDate(DateTime(2026, 10, 15));
        final resOct15 =
            provider.returnMaterialsItemHistories();
        expect(
          resOct15.map((m) => m.uuid).toList(),
          equals(['m1']),
        );

        provider.clearDate();
        provider.setDate(DateTime(2026, 10, 16));
        final resOct16 =
            provider.returnMaterialsItemHistories();
        expect(
          resOct16.map((m) => m.uuid).toList(),
          equals(['m2']),
        );
      },
    );

    test(
      '4. Production Item History Provider filters UTC and Local records correctly',
      () {
        final provider = ProductionItemHistoryProvider();
        provider.clearDate();

        final p1 = ProductionItemHistory(
          uuid: 'p1',
          shopId: 1,
          title: 'Oct 15 11:30 PM (UTC)',
          createdAt: DateTime.utc(2026, 10, 15, 23, 30, 0),
          newValue: '10',
          oldValue: '5',
          quantityChange: 5,
          desc: 'test',
          isIncreased: true,
          event: 'production',
          isManaged: true,
          source: 's',
        );
        final p2 = ProductionItemHistory(
          uuid: 'p2',
          shopId: 1,
          title: 'Oct 16 (UTC)',
          createdAt: DateTime.utc(2026, 10, 16, 8, 0, 0),
          newValue: '15',
          oldValue: '10',
          quantityChange: 5,
          desc: 'test',
          isIncreased: true,
          event: 'production',
          isManaged: true,
          source: 's',
        );

        provider.productionItemHistories = [p1, p2];

        provider.setDate(DateTime(2026, 10, 15));
        final resOct15 =
            provider.returnProductionItemHistories();
        expect(
          resOct15.map((p) => p.uuid).toList(),
          equals(['p1']),
        );

        provider.clearDate();
        provider.setDate(DateTime(2026, 10, 16));
        final resOct16 =
            provider.returnProductionItemHistories();
        expect(
          resOct16.map((p) => p.uuid).toList(),
          equals(['p2']),
        );
      },
    );

    test(
      '5. Item History Report Filters matches with dateRange',
      () {
        final h = ItemHistory(
          uuid: 'r1',
          shopId: 1,
          title: 'Late Night Oct 15',
          createdAt: DateTime.utc(2026, 10, 15, 23, 30, 0),
          newValue: '10',
          oldValue: '5',
          quantityChange: 5,
          desc: 'test',
          isIncreased: true,
          event: 'sale',
          isManaged: true,
          source: 's',
        );

        final filters =
            ItemHistoryReportFilters()
              ..dateRange = DateTimeRange(
                start: DateTime(2026, 10, 15),
                end: DateTime(2026, 10, 15),
              );

        expect(
          filters.matches(h, departmentsEnabled: false),
          isTrue,
        );

        final filtersNextDay =
            ItemHistoryReportFilters()
              ..dateRange = DateTimeRange(
                start: DateTime(2026, 10, 16),
                end: DateTime(2026, 10, 16),
              );

        expect(
          filtersNextDay.matches(
            h,
            departmentsEnabled: false,
          ),
          isFalse,
        );
      },
    );
  });

  group(
    'Items Report Main Page - Quantity Range Filtering (Task 1)',
    () {
      TempProductClass makeProduct({
        required String uuid,
        required String name,
        required double quantity,
        required bool isManaged,
      }) {
        final unit = ProductUnitsClass(
          uuid: 'unit-$uuid',
          staffUuid: null,
          createdAt: DateTime(2026, 1, 1),
          staffName: null,
          conversion: 1,
          name: 'Pcs',
          isPrimary: true,
          productUuid: uuid,
        );
        return TempProductClass(
          uuid: uuid,
          name: name,
          barcode: '123',
          sellingPrice: 100,
          costPrice: 50,
          quantity: quantity,
          unit: 'Pcs',
          isRefundable: false,
          setCustomPrice: false,
          departmentName: null,
          departmentUuid: null,
          groupUnit: null,
          qttyPerGroup: null,
          wholeSalePrice: null,
          storageUuid: null,
          useGroupUnit: false,
          unitsList: [unit],
          pricesList: [],
          widthDimension: null,
          heightDimension: null,
          manageSalesWastage: false,
          isManaged: isManaged,
          shopId: 1,
          categories: [],
          createdAt: DateTime(2026, 1, 1),
        );
      }

      test('Filters by quantityMin, quantityMax, and range', () {
        final p1 = makeProduct(
          uuid: '1',
          name: 'Item Low',
          quantity: 5,
          isManaged: true,
        );
        final p2 = makeProduct(
          uuid: '2',
          name: 'Item Mid',
          quantity: 50,
          isManaged: true,
        );
        final p3 = makeProduct(
          uuid: '3',
          name: 'Item High',
          quantity: 200,
          isManaged: true,
        );
        final pUnmanaged = makeProduct(
          uuid: '4',
          name: 'Item Unmanaged',
          quantity: 0,
          isManaged: false,
        );

        final r1 = ItemsReportRowBuilder.build(
          product: p1,
          categoryNameByUuid: {},
          businessNow: DateTime(2026, 10, 16),
        );
        final r2 = ItemsReportRowBuilder.build(
          product: p2,
          categoryNameByUuid: {},
          businessNow: DateTime(2026, 10, 16),
        );
        final r3 = ItemsReportRowBuilder.build(
          product: p3,
          categoryNameByUuid: {},
          businessNow: DateTime(2026, 10, 16),
        );
        final rUnmanaged = ItemsReportRowBuilder.build(
          product: pUnmanaged,
          categoryNameByUuid: {},
          businessNow: DateTime(2026, 10, 16),
        );

        final filters = ItemsReportFilters();

        // No quantity filter -> all match
        expect(
          filters.matches(
            r1,
            departmentsEnabled: false,
            costFilterAllowed: true,
          ),
          isTrue,
        );
        expect(
          filters.matches(
            r2,
            departmentsEnabled: false,
            costFilterAllowed: true,
          ),
          isTrue,
        );
        expect(
          filters.matches(
            r3,
            departmentsEnabled: false,
            costFilterAllowed: true,
          ),
          isTrue,
        );
        expect(
          filters.matches(
            rUnmanaged,
            departmentsEnabled: false,
            costFilterAllowed: true,
          ),
          isTrue,
        );

        // quantityMin = 10 -> excludes r1 (5) and rUnmanaged (null), keeps r2 (50) and r3 (200)
        filters.quantityMin = 10;
        expect(
          filters.matches(
            r1,
            departmentsEnabled: false,
            costFilterAllowed: true,
          ),
          isFalse,
        );
        expect(
          filters.matches(
            r2,
            departmentsEnabled: false,
            costFilterAllowed: true,
          ),
          isTrue,
        );
        expect(
          filters.matches(
            r3,
            departmentsEnabled: false,
            costFilterAllowed: true,
          ),
          isTrue,
        );
        expect(
          filters.matches(
            rUnmanaged,
            departmentsEnabled: false,
            costFilterAllowed: true,
          ),
          isFalse,
        );

        // quantityMax = 100 -> keeps r2 (50), excludes r3 (200)
        filters.quantityMax = 100;
        expect(
          filters.matches(
            r1,
            departmentsEnabled: false,
            costFilterAllowed: true,
          ),
          isFalse,
        );
        expect(
          filters.matches(
            r2,
            departmentsEnabled: false,
            costFilterAllowed: true,
          ),
          isTrue,
        );
        expect(
          filters.matches(
            r3,
            departmentsEnabled: false,
            costFilterAllowed: true,
          ),
          isFalse,
        );
        expect(
          filters.matches(
            rUnmanaged,
            departmentsEnabled: false,
            costFilterAllowed: true,
          ),
          isFalse,
        );

        // Active count tracks quantity filter
        expect(filters.activeCount, 1);

        // clearFiltersOnly resets quantityMin and quantityMax
        filters.clearFiltersOnly();
        expect(filters.quantityMin, isNull);
        expect(filters.quantityMax, isNull);
        expect(filters.activeCount, 0);
        expect(
          filters.matches(
            r1,
            departmentsEnabled: false,
            costFilterAllowed: true,
          ),
          isTrue,
        );
      });

      test(
        'StockMovementCalculator handles UTC timestamps correctly',
        () {
          final p = makeProduct(
            uuid: 'p-1',
            name: 'Widget',
            quantity: 30,
            isManaged: true,
          );
          final row = ItemsReportRowBuilder.build(
            product: p,
            categoryNameByUuid: {},
            businessNow: DateTime(2026, 10, 16),
          );

          final h1 = ItemHistory(
            uuid: 'h1',
            shopId: 1,
            itemUuid: 'p-1',
            title: 'Morning Sale',
            createdAt: DateTime.utc(2026, 10, 15, 10, 0, 0),
            oldValue: '50',
            newValue: '40',
            quantityChange: 10,
            desc: 'test',
            isIncreased: false,
            event: ItemHistoryEventClass.sold,
            isManaged: true,
            source: 'receipt',
            primaryUnit: 'Pcs',
          );
          final h2 = ItemHistory(
            uuid: 'h2',
            shopId: 1,
            itemUuid: 'p-1',
            title: 'Late Night 11:30 PM Sale',
            createdAt: DateTime.utc(
              2026,
              10,
              15,
              23,
              30,
              0,
            ),
            oldValue: '40',
            newValue: '30',
            quantityChange: 10,
            desc: 'test',
            isIncreased: false,
            event: ItemHistoryEventClass.sold,
            isManaged: true,
            source: 'receipt',
            primaryUnit: 'Pcs',
          );

          final movement =
              StockMovementCalculator.calculate(
                row: row,
                histories: [h1, h2],
                startCutoff: DateTime(
                  2026,
                  10,
                  15,
                  0,
                  0,
                  0,
                ),
                endCutoff: DateTime(2026, 10, 16, 0, 0, 0),
              );

          expect(movement.opening, 50.0);
          expect(movement.closing, 30.0);
          expect(movement.change, -20.0);
        },
      );
    },
  );
}

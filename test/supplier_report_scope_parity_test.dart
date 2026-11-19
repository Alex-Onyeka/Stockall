import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_current_department/temp_current_department.dart';
import 'package:stockall/classes/temp_departments_class/department_class.dart';
import 'package:stockall/classes/temp_logged_in_user/logged_in_user.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/local_database/department_current/current_department_func.dart';
import 'package:stockall/local_database/logged_in_user/logged_in_user_func.dart';
import 'package:stockall/local_database/main_database.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/supplier_report/supplier_report_table/class/supplier_report_table_logic.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/providers/department_provider.dart';
import 'package:stockall/providers/shop_provider.dart';
import 'package:stockall/providers/suppliers_provider.dart';
import 'package:stockall/providers/user_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supplier_report_fixtures.dart';

// SupplierReportAccess.scope must keep the rule of
// SuppliersProvider.suppliersMain(), read here from the real
// providers (Hive and Supabase set up as in
// purchase_inventory_and_history_test.dart).

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
  const pathProviderChannel = MethodChannel(
    'plugins.flutter.io/path_provider',
  );
  const connectivityChannel = MethodChannel(
    'dev.fluttercommunity.plus/connectivity',
  );
  late Directory tempDir;

  TempShopClass makeShop({required bool manageDepartments}) {
    return TempShopClass(
      shopId: 101,
      createdAt: DateTime.utc(2026, 1, 1),
      userId: 'user-1',
      name: 'Test Shop',
      currency: 'NGN',
      isVerified: true,
      isHeadQuarters: true,
      manageInventoryStorage: false,
      wholeSale: false,
      manageDepartments: manageDepartments,
      printSalesDocket: false,
      closeSaleTimeString: null,
      trackCart: false,
      accessPin: null,
      manageProductions: false,
      manageProductionsStorage: false,
      manageProductionItems: false,
      customerPercentageReward: null,
      manageCustomerReward: false,
      manageCustomerAccount: false,
    );
  }

  DepartmentClass department(String uuid) => DepartmentClass(
    uuid: uuid,
    createdAt: DateTime.utc(2026, 1, 1),
    shopId: 101,
    name: uuid,
  );

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = Directory.systemTemp.createTempSync(
      'stockall_supplier_scope_test_',
    );
    final messenger =
        TestDefaultBinaryMessengerBinding
            .instance
            .defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      pathProviderChannel,
      (call) async => tempDir.path,
    );
    messenger.setMockMethodCallHandler(
      connectivityChannel,
      (call) async => <String>['none'],
    );
    final logFile = File('${tempDir.path}/mainLog.log');
    if (!logFile.existsSync()) {
      logFile.createSync(recursive: true);
    }

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
    await MainDatabase().initHive();
    ConnectivityProvider().isConnected = false;
  });

  tearDownAll(() async {
    await Hive.close();
    final messenger =
        TestDefaultBinaryMessengerBinding
            .instance
            .defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(pathProviderChannel, null);
    messenger.setMockMethodCallHandler(connectivityChannel, null);
    try {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  });

  final suppliers = [
    supplier('shared'),
    supplier('a', departmentId: 'dept-a'),
    supplier('b', departmentId: 'dept-b'),
  ];

  for (final departmentsEnabled in [false, true]) {
    for (final canViewAll in [false, true]) {
      for (final current in [null, 'dept-a']) {
        test('departments $departmentsEnabled, view all '
            '$canViewAll, current $current', () async {
          await LoggedInUserFunc().insertLoggedInUser(
            LoggedInUser(
              loggedInUser: TempUserClass(
                password: 'pw',
                userId: 'staff-1',
                name: 'Staff',
                email: 'staff@stockall.test',
                role: 'Manager',
                // Without View All, a current department means the
                // staff is in it; staff in no department have none.
                departmentUuids: [
                  if (!canViewAll && current != null) current,
                ],
                createdAt: DateTime.utc(2026, 1, 1),
                access: [
                  if (canViewAll)
                    Authorizations().viewAllDepartments,
                ],
              ),
            ),
          );
          await UserProvider().fetchCurrentUserOffline();
          ShopProvider().setShops([
            makeShop(manageDepartments: departmentsEnabled),
          ]);

          await CurrentDepartmentFunc().clearCurrentDepartment();
          // Without View All, no current department only happens
          // when the shop has none (one is picked otherwise).
          DepartmentProvider().departments =
              current == null && !canViewAll
                  ? []
                  : [department('dept-a'), department('dept-b')];
          if (current != null) {
            await CurrentDepartmentFunc().createCurrentDepartment(
              TempCurrentDepartment(currentDepartmentId: current),
            );
          }

          // The setup took effect.
          expect(
            shopSingle()?.manageDepartments,
            departmentsEnabled,
          );
          expect(
            authorization(
              authorized: Authorizations().viewAllDepartments,
            ),
            canViewAll,
          );
          expect(
            returnDepartmentProvider().currentDepartment()?.uuid,
            current,
          );

          SuppliersProvider().suppliers = List.of(suppliers);
          final expected =
              SuppliersProvider()
                  .suppliersMain()
                  .map((s) => s.uuid)
                  .toList();
          final actual =
              SupplierReportAccess.scope(
                suppliers: suppliers,
                departmentsEnabled: departmentsEnabled,
                canViewAllDepartments: canViewAll,
                currentDepartmentUuid: current,
              ).map((s) => s.uuid).toList();
          expect(actual, expected);
        });
      }
    }
  }
}

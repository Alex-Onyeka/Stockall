import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_permission/temp_permission_class.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/classes/temp_shop_logos/temp_shop_logos.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/local_database/category/category_func.dart';
import 'package:stockall/local_database/customer_account_receipts/customer_account_receipts_func.dart';
import 'package:stockall/local_database/department_func/departments_func.dart';
import 'package:stockall/local_database/drafts_func/drafts_func.dart';
import 'package:stockall/local_database/error_log/error_log_func.dart';
import 'package:stockall/local_database/events_log/events_log_func.dart';
import 'package:stockall/local_database/expenses/expense_categories_func.dart';
import 'package:stockall/local_database/hive_adapters_registry.dart';
import 'package:stockall/local_database/inventory_updates/inventory_updates_func.dart';
import 'package:stockall/local_database/item_history/item_histories_func.dart';
import 'package:stockall/local_database/lan/lan_credentials_func.dart';
import 'package:stockall/local_database/lan/lan_server_sessions_func.dart';
import 'package:stockall/local_database/lan/lan_shop_keys_func.dart';
import 'package:stockall/local_database/materials/materials_func.dart';
import 'package:stockall/local_database/materials_item_history/materials_item_histories_func.dart';
import 'package:stockall/local_database/materials_usage/production_materials_usage_func.dart';
import 'package:stockall/local_database/permission/permission_func.dart';
import 'package:stockall/local_database/production_item_history/production_item_histories_func.dart';
import 'package:stockall/local_database/production_items/production_items_func.dart';
import 'package:stockall/local_database/productions/production_records_func.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/local_database/purchases/purchase_func.dart';
import 'package:stockall/local_database/shop/shop_func.dart';
import 'package:stockall/local_database/shop/updated_shop/updated_shop_func.dart';
import 'package:stockall/local_database/shop_logos/created_shop_logo/created_shop_logos_func.dart';
import 'package:stockall/local_database/shop_logos/shop_logos_func.dart';
import 'package:stockall/local_database/storage_item_history/storage_item_histories_func.dart';
import 'package:stockall/local_database/storage_product/storage_products_func.dart';
import 'package:stockall/local_database/sub_staff/sub_staff_func.dart';
import 'package:stockall/local_database/suppliers_func/suppliers_func.dart';
import 'package:stockall/services/lan/lan_access_policy.dart';
import 'package:stockall/services/lan/lan_auth_server.dart';
import 'package:stockall/services/lan/lan_connection.dart';
import 'package:stockall/services/lan/lan_constants.dart';
import 'package:stockall/services/lan/lan_server.dart';
import 'package:stockall/services/lan/lan_tls.dart';
import 'package:stockall/services/lan/lan_user_backfill.dart';
import 'package:stockall/services/lan/rest/hive_rest_engine.dart';
import 'package:stockall/services/lan/rest/lan_logo_storage.dart';
import 'package:stockall/services/lan/rest/lan_table_registry.dart';
import 'package:stockall/services/lan/rest/postgrest_request.dart';
import 'package:stockall/services/lan/rest/postgrest_response.dart';
import 'package:stockall/services/remote/lan_remote.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'helpers/lan_boxes.dart';
import 'helpers/lan_fixtures.dart';
import 'helpers/lan_samples.dart';

final a = Authorizations();

class ProxyStub implements LanProxy {
  final forwarded = <PgRequest>[];

  @override
  Future<PgResponse> forward(
    PgRequest request,
    LanPrincipal principal,
    Set<int> otherShops,
  ) async {
    forwarded.add(request);
    return const PgResponse(200, body: <Object>[]);
  }
}

PgFilter eq(String column, String value) =>
    PgFilter(column, PgFilterOp.eq, value);

/// Every permission any served table's writes accept.
List<String> allWritePermissions() => {
  for (final s in lanSamples())
    for (final op in LanWriteOp.values)
      ...?LanAccessPolicy.writePermissions(s.table, op),
  for (final table in ['shops', 'users', 'notifications'])
    for (final op in LanWriteOp.values)
      ...?LanAccessPolicy.writePermissions(table, op),
}.toList();

const String _logoUrlBase =
    'https://supabase.test/storage/v1/object/public/logos/';

void main() {
  var online = false;
  var membersChanged = 0;
  final savedShops = <TempShopClass>[];
  late ProxyStub proxy;
  late LanLogoStorage logos;
  late HiveRestEngine engine;
  final owner = principal(access: allWritePermissions());

  Matcher pg(int status, String code) => throwsA(
    isA<PgError>()
        .having((e) => e.status, 'status', status)
        .having((e) => e.code, 'code', code),
  );

  Future<PgResponse> call(
    String table,
    PgOp op, {
    Object? body,
    List<PgFilter> filters = const [],
    LanPrincipal? who,
    bool single = false,
    bool returning = false,
  }) {
    return engine.handle(
      PgRequest(
        table: table,
        op: op,
        body: body,
        filters: filters,
        single: single,
        returnRepresentation: returning,
      ),
      who ?? owner,
    );
  }

  List<Map<String, dynamic>> rows(PgResponse r) {
    expect(r.status, 200, reason: '${r.body}');
    return (r.body as List).cast<Map<String, dynamic>>();
  }

  setUpAll(() async {
    Hive.init(Directory.systemTemp.createTempSync('stockall_lan_p4d').path);
    registerAllHiveAdapters();
    for (final init in [
      DraftsFunc().init,
      CustomerAccountReceiptsFunc().init,
      CategoryFunc().init,
      DepartmentsFunc().init,
      SuppliersFunc().init,
      SubStaffFunc().init,
      StorageProductsFunc().init,
      StorageItemHistoriesFunc().init,
      ItemHistoriesFunc().init,
      InventoryUpdatesFunc().init,
      EventsLogFunc().init,
      ErrorLogFunc().init,
      PurchaseFunc().init,
      MaterialsFunc().init,
      ProductionMaterialsUsageFunc().init,
      ProductionItemsFunc().init,
      ProductionItemHistoriesFunc().init,
      MaterialsItemHistoriesFunc().init,
      ProductionRecordsFunc().init,
      ExpenseCategoriesFunc().init,
      ShopFunc().init,
      PermissionFunc().init,
      ShopLogosFunc().init,
      CreatedShopLogosFunc().init,
      ProductsFunc().init,
      LanCredentialsFunc().init,
      LanServerSessionsFunc().init,
      LanShopKeysFunc().init,
    ]) {
      await init();
    }
    await LanUserBackfill().apply(
      7,
      const LanBackfillShop(ownerId: 'owner', employees: ['staff-1', 'staff-2']),
      [
        TempUserClass(
          userId: 'staff-1',
          name: 'Ada',
          email: 'ada@shop.test',
          password: 'right',
          role: 'Manager',
          departmentUuids: const [],
          access: [a.manageShop, a.makeSale],
          pin: '1234',
        ),
        TempUserClass(
          userId: 'staff-2',
          name: 'Bola',
          email: 'bola@shop.test',
          password: 'other',
          role: 'Cashier',
          departmentUuids: const [],
          access: [a.makeSale],
        ),
      ],
      iterations: 1000,
    );
  });

  tearDownAll(() async {
    await engine.dispose();
    await Hive.close();
  });

  setUp(() async {
    for (final s in lanSamples()) {
      for (final name in [s.main, s.created, s.updated, s.deleted]) {
        if (name != null) await lanBoxes[name]!().clear();
      }
    }
    await ShopFunc().shopBox.clear();
    await UpdatedShopFunc().updatedShopBox.clear();
    await ShopLogosFunc().shopLogosBox.clear();
    await CreatedShopLogosFunc().createdShopLogosBox.clear();
    await PermissionFunc().permissionModelBox.clear();
    await ProductsFunc().productBox.clear();
    await ShopFunc().shopBox.put(7, TempShopClass.fromJson(shopSample));
    await ShopFunc().shopBox.put(
      8,
      TempShopClass.fromJson({...shopSample, 'shop_id': 8, 'name': 'Other'}),
    );
    online = false;
    membersChanged = 0;
    savedShops.clear();
    proxy = ProxyStub();
    logos = LanLogoStorage(
      publicUrlOf: (path) => '$_logoUrlBase$path',
      storedLogo: () => ShopLogosFunc().shopLogosBox.get(7),
      queueLogo: (logo) async {
        await CreatedShopLogosFunc().createdShopLogosBox.clear();
        await CreatedShopLogosFunc().createdShopLogosBox.put(7, logo);
        await ShopLogosFunc().shopLogosBox.clear();
        await ShopLogosFunc().shopLogosBox.put(7, logo);
      },
    );
    engine = HiveRestEngine(
      tables: lanTables(
        shopId: () => 7,
        logos: logos,
        staff: () => (id: 'srv', name: 'Server'),
        onShopSaved: savedShops.add,
      ),
      shopId: () => 7,
      manageDepartments: () => false,
      isOnline: () => online,
      proxy: proxy,
      onlineOnlyTables: LanConstants.onlineOnlyTables,
      onlineOnlyRpcs: LanConstants.onlineOnlyRpcs,
      onMembersChanged: () => membersChanged++,
    );
  });

  test('every P4d table: writes go to the app\'s queues, reads find them',
      () async {
    for (final s in lanSamples()) {
      final uuid = s.json['uuid'] as String;
      Box<dynamic> box(String name) => lanBoxes[name]!();

      await call(s.table, PgOp.insert, body: s.json);
      expect(box(s.main).containsKey(uuid), isTrue, reason: s.table);
      expect(box(s.created).containsKey(uuid), isTrue, reason: s.table);
      final read = rows(await call(s.table, PgOp.select, filters: [eq('uuid', uuid)]));
      expect(read.single['uuid'], uuid, reason: s.table);

      final updated = s.updated;
      final deleted = s.deleted;
      if (updated == null || deleted == null) {
        // Histories and logs are only ever inserted.
        await expectLater(
          call(s.table, PgOp.update, body: {'title': 'x'}, filters: [eq('uuid', uuid)]),
          pg(405, 'LAN501'),
        );
        await expectLater(
          call(s.table, PgOp.delete, filters: [eq('uuid', uuid)]),
          pg(405, 'LAN501'),
        );
        continue;
      }

      // Synced: an update is queued as an update.
      await box(s.created).clear();
      const later = '2026-11-05T08:00:00.000Z';
      await call(
        s.table,
        PgOp.update,
        body: {'updated_at': later},
        filters: [eq('uuid', uuid)],
      );
      expect(box(updated).containsKey(uuid), isTrue, reason: s.table);
      expect(box(s.created).isEmpty, isTrue, reason: s.table);
      final after = rows(await call(s.table, PgOp.select, filters: [eq('uuid', uuid)]));
      expect(
        DateTime.parse(after.single['updated_at'] as String).toUtc(),
        DateTime.parse(later),
        reason: s.table,
      );

      await call(s.table, PgOp.delete, filters: [eq('uuid', uuid)]);
      expect(box(s.main).containsKey(uuid), isFalse, reason: s.table);
      expect(box(deleted).containsKey(uuid), isTrue, reason: s.table);
      expect(box(updated).containsKey(uuid), isFalse, reason: s.table);
    }
  });

  test('a material updated while its insert is pending keeps its quantity',
      () async {
    final material = lanSamples().firstWhere(
      (s) => s.table == 'production_materials',
    );
    await call('production_materials', PgOp.insert, body: material.json);
    await call(
      'production_materials',
      PgOp.update,
      body: {'name': 'Flour (fine)'},
      filters: [eq('uuid', 'm-1')],
    );
    final pending = lanBoxes[material.created]!().get('m-1');
    expect((pending as dynamic).includeQuantity, isTrue);
    expect((pending as dynamic).material.name, 'Flour (fine)');
  });

  group('the store\'s shop', () {
    test('this store only, as the client parses it', () async {
      final r = rows(
        await call('shops', PgOp.select, filters: [eq('user_id', 'owner')]),
      );
      expect(r.map((s) => s['shop_id']), [7]);
      expect(TempShopClass.fromJson(r.single).name, 'Ada Stores');
    });

    test('a setting is saved and queued like the app does offline', () async {
      final r = await call(
        'shops',
        PgOp.update,
        body: {'apply_vat': true},
        filters: [eq('shop_id', '7')],
        single: true,
        returning: true,
      );
      expect((r.body as Map)['apply_vat'], isTrue);
      expect(ShopFunc().shopBox.get(7)!.applyVAT, isTrue);
      expect(UpdatedShopFunc().updatedShopBox.get(7)!.shop.applyVAT, isTrue);
      expect(savedShops.single.shopId, 7);
    });

    test('members, owner, new and deleted stores need Supabase', () async {
      final employees = PgRequest(
        table: 'shops',
        op: PgOp.update,
        body: const {
          'employees': ['staff-1'],
        },
        filters: [eq('shop_id', '7')],
      );
      await expectLater(engine.handle(employees, owner), pg(503, 'LAN01'));
      expect(ShopFunc().shopBox.get(7)!.employees, ['staff-1']);

      online = true;
      await engine.handle(employees, owner);
      await call('shops', PgOp.insert, body: {'name': 'New'});
      expect(proxy.forwarded.map((f) => f.op), [PgOp.update, PgOp.insert]);
      expect(membersChanged, 2);
      expect(UpdatedShopFunc().updatedShopBox.isEmpty, isTrue);
    });
  });

  group('users of this store', () {
    test('from the LAN logins: no password, PIN kept', () async {
      final r = rows(
        await call(
          'users',
          PgOp.select,
          filters: [
            const PgFilter('user_id', PgFilterOp.inList, ['staff-1', 'staff-2']),
          ],
        ),
      );
      expect(r.map((u) => u['user_id']), ['staff-1', 'staff-2']);
      expect(r.every((u) => u['password'] == ''), isTrue);
      final ada = TempUserClass.fromJson(r.first);
      expect(ada.pin, '1234');
      expect(ada.access, contains(a.manageShop));
    });

    test('writes need Supabase; anyone may change their own password or '
        'PIN, not their own access', () async {
      final me = principal(access: const []);
      PgRequest update(String userId, Map<String, dynamic> body) => PgRequest(
        table: 'users',
        op: PgOp.update,
        body: body,
        filters: [eq('user_id', userId)],
      );

      await expectLater(
        engine.handle(update('staff-1', {'pin': '9999'}), me),
        pg(503, 'LAN01'),
      );
      online = true;
      await engine.handle(update('staff-1', {'pin': '9999'}), me);
      expect(membersChanged, 1);

      await expectLater(
        engine.handle(
          update('staff-1', {
            'access': [a.manageShop],
          }),
          me,
        ),
        pg(403, 'LAN02'),
      );
      await expectLater(
        engine.handle(update('staff-2', {'pin': '0000'}), me),
        pg(403, 'LAN02'),
      );
      await engine.handle(
        update('staff-2', {'role': 'Manager'}),
        principal(access: [a.updateEmployee]),
      );
      expect(proxy.forwarded, hasLength(2));
    });
  });

  test('permissions: the global catalogue, with permit_number', () async {
    await PermissionFunc().permissionModelBox.put(
      'perm-1',
      PermissionModel.fromJson(permissionSample),
    );
    final r = rows(await call('permissions', PgOp.select));
    expect(PermissionModel.fromJson(r.single).permitNumber, 2);
  });

  test('online-only tables and RPCs: forwarded when online, LAN01 '
      'otherwise; unused tables are unknown', () async {
    await expectLater(
      call('notifications', PgOp.select, filters: [eq('shop_id', '7')]),
      throwsA(
        isA<PgError>()
            .having((e) => e.code, 'code', 'LAN01')
            .having((e) => e.message, 'message', contains('needs the internet')),
      ),
    );
    online = true;
    await call('notifications', PgOp.select, filters: [eq('shop_id', '7')]);
    await call('app_version', PgOp.select, filters: [eq('id', '1')]);
    await engine.handle(
      const PgRequest(
        table: 'mark_all_notifications_viewed',
        op: PgOp.rpc,
        body: {'p_shop_id': 7},
      ),
      owner,
    );
    expect(proxy.forwarded.map((f) => f.table), [
      'notifications',
      'app_version',
      'mark_all_notifications_viewed',
    ]);
    // Writes keep their permission check.
    await expectLater(
      call(
        'notifications',
        PgOp.delete,
        filters: [eq('uuid', 'n1')],
        who: principal(),
      ),
      pg(403, 'LAN02'),
    );
    await expectLater(
      call('product_suggestions', PgOp.select),
      pg(404, 'PGRST205'),
    );
  });

  test('a product with no unit or price gets one fixed default, kept',
      () async {
    final bare = product('p-bare')
      ..unitsList = []
      ..pricesList = null;
    await ProductsFunc().productBox.put('p-bare', bare);

    Future<Map<String, dynamic>> read() async => rows(
      await call('products', PgOp.select, filters: [eq('uuid', 'p-bare')]),
    ).single;
    final first = await read();
    final second = await read();

    final unit = (first['units_list'] as List).single as dynamic;
    final price = (first['prices_list'] as List).single as dynamic;
    expect(unit.uuid, (second['units_list'] as List).single.uuid);
    expect(price.uuid, (second['prices_list'] as List).single.uuid);
    expect(unit.staffName, 'Server');
    expect(price.priceValue, 0);
    await Future<void>.delayed(Duration.zero);
    final stored = ProductsFunc().productBox.get('p-bare')!;
    expect(stored.unitsList!.single.uuid, unit.uuid);
    expect(stored.pricesList!.single.uuid, price.uuid);
  });

  group('logo storage through a real SupabaseClient', () {
    late LanServer server;
    late LanConnection connection;
    late SupabaseClient lan;

    setUp(() async {
      final identity = LanTlsIdentity.generate();
      server = LanServer(
        identity: identity,
        deviceId: 'desk-1',
        serverView: () => {'epoch': 1},
        auth: LanAuthService(shopId: () => 7, shopJson: (_) => null),
        rest: engine,
        storage: logos,
      );
      await server.start(ports: const [0]);
      connection = (await LanConnection.open([
        LanEndpoint('127.0.0.1', server.port!),
      ], pin: identity.fingerprint))!;
      final login = await connection.postJson('/v1/auth/login', {
        'email': 'ada@shop.test',
        'password': 'right',
        'device_id': 'phone-1',
      });
      lan = createLanRemote(
        connection: connection,
        token: login['token'] as String,
        deviceId: 'phone-1',
      );
    });

    tearDown(() async {
      await lan.dispose();
      connection.close();
      await server.stop();
    });

    test('upload, point the shop at it, download, remove the old one',
        () async {
      final bytes = Uint8List.fromList(List.generate(3000, (i) => i % 251));
      const path = 'logos/7-new.png';

      // ShopProvider.uploadLogo, as a LAN client runs it.
      final key = await lan.storage
          .from('logos')
          .uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/png'),
          );
      expect(key, 'logos/$path');
      final publicUrl = lan.storage.from('logos').getPublicUrl(path);
      expect(Uri.parse(publicUrl).host, 'stockall-lan');
      await lan
          .from('shops')
          .update({
            'logo_url': publicUrl,
            'image_height': 30,
            'image_width': 40,
          })
          .eq('shop_id', 7);

      // Queued for the server's uploadShopLogoSync, as offline.
      final queued = CreatedShopLogosFunc().createdShopLogosBox.get(7)!;
      expect(queued.imageName, path);
      expect(base64Decode(queued.logoPath), bytes);
      expect((queued.imageHeight, queued.imageWidth), (30, 40));
      expect(ShopLogosFunc().shopLogosBox.get(7)!.imageName, path);
      final shop = ShopFunc().shopBox.get(7)!;
      expect(shop.logoUrl, shopSample['logo_url']);
      expect(shop.imageHeight, 30);

      expect(await lan.storage.from('logos').download(path), bytes);
      expect(
        await lan.storage.from('logos').remove(['logos/7-old.png']),
        isEmpty,
      );
    });

    test('a LAN logo URL with nothing uploaded is stored as the Supabase URL',
        () async {
      final url = lan.storage.from('logos').getPublicUrl('logos/7-x.png');
      await lan.from('shops').update({'logo_url': url}).eq('shop_id', 7);
      expect(
        ShopFunc().shopBox.get(7)!.logoUrl,
        '${_logoUrlBase}logos/7-x.png',
      );
      expect(CreatedShopLogosFunc().createdShopLogosBox.isEmpty, isTrue);
    });

    test('an upload needs a shop permission', () async {
      await expectLater(
        LanLogoStorage(
          publicUrlOf: (p) => p,
          storedLogo: () => null,
          queueLogo: (TempShopLogos _) async {},
        ).handle(
          LanStorageRequest(
            method: 'POST',
            path: 'object/logos/logos/a.png',
            headers: const {},
            body: Uint8List.fromList([1, 2, 3]),
          ),
          principal(),
        ).then((r) => r.status),
        completion(403),
      );
    });
  });
}

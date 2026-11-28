import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:stockall/classes/temp_customer_account_receipts/unsynced/customer_account_update/customer_account_update.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/unsynced/material_quantity_update/material_quantity_update.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/unsynced/production_item_quantity_update/production_item_quantity_update.dart';
import 'package:stockall/local_database/customer_account_receipts/unsync_funcs/customer_account_updates/customer_account_update_func.dart';
import 'package:stockall/local_database/hive_adapters_registry.dart';
import 'package:stockall/local_database/materials/materials_func.dart';
import 'package:stockall/local_database/materials/unsync_funcs/materials_quantity_update/materials_quantity_update_func.dart';
import 'package:stockall/local_database/production_items/production_items_func.dart';
import 'package:stockall/local_database/production_items/unsync_funcs/production_items_quantity_update/production_items_quantity_update_func.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/providers/customer_account_receipts_provider.dart';
import 'package:stockall/providers/production_folder/material_quantity_update_provider.dart';
import 'package:stockall/providers/production_folder/production_items_quantity_update_provider.dart';
import 'package:stockall/services/remote/remote_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'lan_remote_router_test.dart' show MemoryAsyncStorage;

/// Three delta RPCs send no entry id to Supabase today. Over the LAN the
/// client adds `hiveUuid` so the server can skip a retried entry;
/// what Supabase receives must not change.
void main() {
  final supabaseCalls = <Map<String, dynamic>>[];
  final lanCalls = <Map<String, dynamic>>[];

  MockClient recorder(List<Map<String, dynamic>> into) {
    return MockClient((request) async {
      into.add({
        'path': request.url.path,
        ...jsonDecode(request.body) as Map<String, dynamic>,
      });
      return http.Response('', 204, request: request);
    });
  }

  late SupabaseClient lan;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Hive.init(Directory.systemTemp.createTempSync('stockall_lan_payload').path);
    registerAllHiveAdapters();
    await MaterialsFunc().init();
    await ProductionItemsFunc().init();
    await CustomerAccountUpdateFunc().init();
    await Supabase.initialize(
      url: 'https://supabase.test',
      anonKey: 'test-anon-key',
      httpClient: recorder(supabaseCalls),
      authOptions: FlutterAuthClientOptions(
        localStorage: const EmptyLocalStorage(),
        pkceAsyncStorage: MemoryAsyncStorage(),
        detectSessionInUri: false,
        autoRefreshToken: false,
      ),
    );
    lan = SupabaseClient(
      'https://stockall-lan:1',
      'stockall-lan',
      httpClient: recorder(lanCalls),
      accessToken: () async => 'token',
    );
    ConnectivityProvider().isConnected = true;
  });

  tearDownAll(() async {
    RemoteRouter.useSupabase();
    await lan.dispose();
    await Hive.close();
  });

  Future<void> queueAll() async {
    await MaterialsQuantityUpdateFunc().createMaterialsQuantityUpdate(
      MaterialQuantityUpdate(
        uuid: 'mq1',
        quantity: 2,
        materialUuid: 'm1',
        isIncrement: true,
      ),
    );
    await ProductionItemsQuantityUpdateFunc()
        .createProductionItemsQuantityUpdate(
          ProductionItemQuantityUpdate(
            uuid: 'pq1',
            quantity: 1,
            productionItemUuid: 'pi1',
            isIncrement: false,
          ),
        );
    await CustomerAccountUpdateFunc().createCustomerAccountUpdate(
      CustomerAccountUpdate(
        uuid: 'ca1',
        amount: 5,
        customerUuid: 'c1',
        isIncrement: true,
        isBalance: true,
      ),
    );
  }

  Future<void> syncAll() async {
    await MaterialQuantityUpdateProvider().materialsQuantityUpdateSync();
    await ProductionItemsQuantityUpdateProvider()
        .productionItemsQuantityUpdateSync();
    await CustomerAccountReceiptsProvider().customerAccountUpdateSync();
  }

  Map<String, List<Map<String, dynamic>>> entriesByRpc(
    List<Map<String, dynamic>> calls,
  ) {
    return {
      for (final c in calls)
        (c['path'] as String).split('/').last: [
          for (final u in c['updates'] as List) u as Map<String, dynamic>,
        ],
    };
  }

  test('Supabase gets exactly today\'s payload: no hiveUuid', () async {
    await queueAll();
    await syncAll();

    final sent = entriesByRpc(supabaseCalls);
    expect(sent.keys, {
      'update_materials_quantities',
      'update_production_items_quantities',
      'update_customer_account',
    });
    expect(sent['update_materials_quantities'], [
      {'materialItemUuid': 'm1', 'quantity': 2.0, 'isIncrement': true},
    ]);
    expect(sent['update_production_items_quantities'], [
      {'productionItemUuid': 'pi1', 'quantity': 1.0, 'isIncrement': false},
    ]);
    expect(sent['update_customer_account'], [
      {
        'customerUuid': 'c1',
        'amount': 5.0,
        'isIncrement': true,
        'isBalance': true,
      },
    ]);
    expect(lanCalls, isEmpty);
  });

  test('the LAN server also gets each entry\'s hiveUuid', () async {
    RemoteRouter.debugUseLan(lan);
    addTearDown(RemoteRouter.useSupabase);
    await queueAll();
    await syncAll();

    final sent = entriesByRpc(lanCalls);
    expect(sent['update_materials_quantities']!.single['hiveUuid'], 'mq1');
    expect(
      sent['update_production_items_quantities']!.single['hiveUuid'],
      'pq1',
    );
    expect(sent['update_customer_account']!.single['hiveUuid'], 'ca1');
  });
}

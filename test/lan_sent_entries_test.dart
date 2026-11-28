import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_customers/unsynced/created_customers/created_customers.dart';
import 'package:stockall/classes/temp_product_class/unsynced/created_products/created_products.dart';
import 'package:stockall/classes/temp_product_class/unsynced/quantity_update/quantity_update.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/material_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/unsynced/created_materials/created_material.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/production_item.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/unsynced/created/created_production_item.dart';
import 'package:stockall/classes/temp_customer_account_receipts/unsynced/customer_account_update/customer_account_update.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/unsynced/material_quantity_update/material_quantity_update.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/unsynced/production_item_quantity_update/production_item_quantity_update.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/local_database/customer_account_receipts/unsync_funcs/customer_account_updates/customer_account_update_func.dart';
import 'package:stockall/local_database/customers/unsync_funcs/created/created_customers_func.dart';
import 'package:stockall/local_database/hive_adapters_registry.dart';
import 'package:stockall/local_database/lan/lan_credentials_func.dart';
import 'package:stockall/local_database/lan/lan_server_sessions_func.dart';
import 'package:stockall/local_database/lan/lan_shop_keys_func.dart';
import 'package:stockall/local_database/lan/sent_entries_func.dart';
import 'package:stockall/local_database/materials/unsync_funcs/created_materials/created_materials_func.dart';
import 'package:stockall/local_database/materials/unsync_funcs/materials_quantity_update/materials_quantity_update_func.dart';
import 'package:stockall/local_database/production_items/unsync_funcs/created/created_production_items_func.dart';
import 'package:stockall/local_database/production_items/unsync_funcs/production_items_quantity_update/production_items_quantity_update_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/created_products/created_product_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/quantity_update/quantity_update_func.dart';
import 'package:stockall/providers/customer_account_receipts_provider.dart';
import 'package:stockall/providers/production_folder/material_quantity_update_provider.dart';
import 'package:stockall/providers/production_folder/production_items_quantity_update_provider.dart';
import 'package:stockall/providers/quantity_update_provider.dart';
import 'package:stockall/services/lan/lan_access_policy.dart';
import 'package:stockall/services/lan/lan_auth_server.dart';
import 'package:stockall/services/lan/lan_connection.dart';
import 'package:stockall/services/lan/lan_server.dart';
import 'package:stockall/services/lan/lan_tls.dart';
import 'package:stockall/services/lan/lan_user_backfill.dart';
import 'package:stockall/services/lan/rest/lan_rest_handler.dart';
import 'package:stockall/services/lan/rest/postgrest_request.dart';
import 'package:stockall/services/lan/rest/postgrest_response.dart';
import 'package:stockall/services/remote/lan_remote.dart';
import 'package:stockall/services/remote/remote_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'helpers/lan_fixtures.dart';
import 'helpers/lan_samples.dart';

/// The server's side of `update_materials_quantities`: records each batch
/// and runs [during] while the client waits for the answer.
class DeltaServer implements LanRestHandler {
  final batches = <List<Map<String, dynamic>>>[];
  Future<void> Function()? during;
  bool fail = false;

  @override
  Future<PgResponse> handle(PgRequest request, LanPrincipal principal) async {
    final updates = ((request.body as Map)['updates'] as List)
        .cast<Map<String, dynamic>>();
    batches.add(updates);
    await during?.call();
    if (fail) throw const PgError(503, 'LAN06', 'not held yet');
    return const PgResponse(204);
  }
}

MaterialQuantityUpdate materialDelta(String uuid, double q, {bool up = true}) {
  return MaterialQuantityUpdate(
    uuid: uuid,
    createdAt: DateTime.now(),
    quantity: q,
    materialUuid: 'm1',
    isIncrement: up,
  );
}

void main() {
  late LanTlsIdentity identity;
  final materials = MaterialsQuantityUpdateFunc();
  final items = ProductionItemsQuantityUpdateFunc();

  Map<String, double> queued() => {
    for (final e in materials.getMaterialsQuantitiesUpdate())
      e.uuid!: e.isIncrement ? e.quantity : -e.quantity,
  };

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Real sockets for the LAN server (the binding fakes HTTP with 400s).
    HttpOverrides.global = null;
    // No connectivity plugin under `flutter test`.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(
          const EventChannel('dev.fluttercommunity.plus/connectivity_status'),
          MockStreamHandler.inline(onListen: (_, _) {}),
        );
    identity = LanTlsIdentity.generate();
    Hive.init(Directory.systemTemp.createTempSync('stockall_sent').path);
    registerAllHiveAdapters();
    await CreatedProductFunc().init();
    await QuantityUpdateFunc().init();
    await CreatedMaterialsFunc().init();
    await CreatedProductionItemsFunc().init();
    await CreatedCustomersFunc().init();
    await materials.init();
    await items.init();
    await CustomerAccountUpdateFunc().init();
    await SentEntriesFunc().init();
    await LanCredentialsFunc().init();
    await LanServerSessionsFunc().init();
    await LanShopKeysFunc().init();
    await LanUserBackfill().apply(
      7,
      const LanBackfillShop(ownerId: 'owner', employees: ['cashier']),
      [
        TempUserClass(
          userId: 'cashier',
          name: 'Ada',
          email: 'ada@shop.test',
          password: 'right',
          role: 'Cashier',
          departmentUuids: const [],
          access: const ['Make Sale'],
        ),
      ],
      iterations: 1000,
    );
  });

  setUp(() async {
    await materials.clearMaterialsQuantitiesUpdate();
    await items.clearProductionItemsQuantitiesUpdate();
    await CustomerAccountUpdateFunc().clearQuantitiesUpdate();
    await CreatedProductFunc().createdProductsBox.clear();
    await QuantityUpdateFunc().quantityUpdateBox.clear();
    await CreatedMaterialsFunc().createdMaterialsBox.clear();
    await CreatedProductionItemsFunc().createdProductionItemsBox.clear();
    await CreatedCustomersFunc().createdCustomersBox.clear();
    await SentEntriesFunc().clearSentEntries();
  });

  tearDownAll(() async {
    RemoteRouter.useSupabase();
    await Hive.close();
  });

  test('changes merge into an entry not sent yet, never into a sent one',
      () async {
    await materials.createMaterialsQuantityUpdate(materialDelta('a', 2));
    await materials.createMaterialsQuantityUpdate(materialDelta('b', 3));
    expect(queued(), {'a': 5});

    await SentEntriesFunc().markSent(materials.materialsQuantityUpdateBoxName, [
      'a',
    ]);
    await materials.createMaterialsQuantityUpdate(materialDelta('c', 4));
    await materials.createMaterialsQuantityUpdate(
      materialDelta('d', 1, up: false),
    );
    // A new entry, and later changes merge into that one.
    expect(queued(), {'a': 5, 'c': 3});

    // Production items follow the same rule.
    ProductionItemQuantityUpdate item(String uuid, double q) =>
        ProductionItemQuantityUpdate(
          uuid: uuid,
          createdAt: DateTime.now(),
          quantity: q,
          productionItemUuid: 'i1',
          isIncrement: true,
        );
    await items.createProductionItemsQuantityUpdate(item('x', 1));
    await SentEntriesFunc().markSent(
      items.productionItemsQuantityUpdateBoxName,
      ['x'],
    );
    await items.createProductionItemsQuantityUpdate(item('y', 2));
    expect(
      items.getProductionItemsQuantitiesUpdate().map((e) => (e.uuid, e.quantity)),
      [('x', 1.0), ('y', 2.0)],
    );
  });

  group('the materials sync over the LAN', () {
    late LanServer server;
    late LanConnection connection;
    late SupabaseClient lan;
    late DeltaServer deltas;

    setUp(() async {
      deltas = DeltaServer();
      server = LanServer(
        identity: identity,
        deviceId: 'desk-1',
        serverView: () => {'epoch': 1},
        auth: LanAuthService(shopId: () => 7, shopJson: (_) => null),
        rest: deltas,
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
      RemoteRouter.useLan(lan);
    });

    tearDown(() async {
      RemoteRouter.useSupabase();
      await lan.dispose();
      connection.close();
      await server.stop();
    });

    test('a change made while the batch is in flight gets its own entry '
        'and is still queued after the answer', () async {
      await materials.createMaterialsQuantityUpdate(materialDelta('a', 2));
      deltas.during = () =>
          materials.createMaterialsQuantityUpdate(materialDelta('b', 3));

      await MaterialQuantityUpdateProvider().materialsQuantityUpdateSync();

      expect(deltas.batches.single, [
        {
          'hiveUuid': 'a',
          'materialItemUuid': 'm1',
          'quantity': 2.0,
          'isIncrement': true,
        },
      ]);
      // Before: the in-flight change merged into 'a' (+5) and the whole
      // queue was cleared after the answer, so +3 was lost.
      expect(queued(), {'b': 3});
      expect(
        SentEntriesFunc().isSent(materials.materialsQuantityUpdateBoxName, 'a'),
        isFalse,
      );
    });

    test('customer accounts: a change queued while the batch is out is '
        'kept and sent next time', () async {
      final accounts = CustomerAccountUpdateFunc();
      CustomerAccountUpdate change(String uuid, double amount) =>
          CustomerAccountUpdate(
            uuid: uuid,
            createdAt: DateTime.now(),
            amount: amount,
            customerUuid: 'c1',
            isIncrement: true,
            isBalance: true,
          );
      await accounts.createCustomerAccountUpdate(change('a', 5));
      deltas.during = () => accounts.createCustomerAccountUpdate(change('b', 7));

      await CustomerAccountReceiptsProvider().customerAccountUpdateSync();

      expect(
        deltas.batches.single.map((u) => (u['hiveUuid'], u['amount'])),
        [('a', 5.0)],
      );
      // Before: the whole queue was cleared after the answer, losing 'b'.
      expect(
        accounts.getQuantitiesUpdate().map((u) => (u.uuid, u.amount)),
        [('b', 7.0)],
      );

      deltas.during = null;
      await CustomerAccountReceiptsProvider().customerAccountUpdateSync();
      expect(
        deltas.batches.last.map((u) => (u['hiveUuid'], u['amount'])),
        [('b', 7.0)],
      );
      expect(accounts.getQuantitiesUpdate(), isEmpty);
    });

    test('a delta for an item whose create is still queued here is not '
        'sent; it goes once the create has gone (all four delta queues)',
        () async {
      Map<String, dynamic> sample(String table) =>
          lanSamples().firstWhere((s) => s.table == table).json;
      // Items created on this device and not yet sent.
      await CreatedProductFunc().createdProductsBox.put(
        'p-new',
        CreatedProducts(product: product('p-new'), includeQuantity: true),
      );
      await CreatedMaterialsFunc().createdMaterialsBox.put(
        'm-new',
        CreatedMaterial(
          material: MaterialClass.fromJson({
            ...sample('production_materials'),
            'uuid': 'm-new',
          }),
          includeQuantity: true,
        ),
      );
      await CreatedProductionItemsFunc().createdProductionItemsBox.put(
        'i-new',
        CreatedProductionItem(
          productionItem: ProductionItem.fromJson({
            ...sample('production_items'),
            'uuid': 'i-new',
          }),
          includeQuantity: true,
        ),
      );
      await CreatedCustomersFunc().createdCustomersBox.put(
        'c-new',
        CreatedCustomers(customer: customer('c-new')),
      );
      // One delta for a new item and one for an item already sent, per queue.
      for (final (uuid, item) in [('q-new', 'p-new'), ('q-old', 'p-old')]) {
        await QuantityUpdateFunc().quantityUpdateBox.put(
          uuid,
          QuantityUpdate(
            uuid: uuid,
            createdAt: DateTime.now(),
            quantity: 1,
            productUuid: item,
            isIncrement: false,
            isStorage: false,
          ),
        );
      }
      for (final (uuid, item) in [('mq-new', 'm-new'), ('mq-old', 'm-old')]) {
        await materials.materialsQuantityUpdateBox.put(
          uuid,
          MaterialQuantityUpdate(
            uuid: uuid,
            createdAt: DateTime.now(),
            quantity: 1,
            materialUuid: item,
            isIncrement: true,
          ),
        );
      }
      for (final (uuid, item) in [('iq-new', 'i-new'), ('iq-old', 'i-old')]) {
        await items.productionItemsQuantityUpdateBox.put(
          uuid,
          ProductionItemQuantityUpdate(
            uuid: uuid,
            createdAt: DateTime.now(),
            quantity: 1,
            productionItemUuid: item,
            isIncrement: true,
          ),
        );
      }
      for (final (uuid, item) in [('aq-new', 'c-new'), ('aq-old', 'c-old')]) {
        await CustomerAccountUpdateFunc().createCustomerAccountUpdate(
          CustomerAccountUpdate(
            uuid: uuid,
            createdAt: DateTime.now(),
            amount: 1,
            customerUuid: item,
            isIncrement: true,
            isBalance: true,
          ),
        );
      }

      Future<void> syncAll() async {
        await QuantityUpdateProvider().quantityUpdateSync();
        await MaterialQuantityUpdateProvider().materialsQuantityUpdateSync();
        await ProductionItemsQuantityUpdateProvider()
            .productionItemsQuantityUpdateSync();
        await CustomerAccountReceiptsProvider().customerAccountUpdateSync();
      }

      Set<Object?> left() => {
        ...QuantityUpdateFunc().quantityUpdateBox.keys,
        ...materials.materialsQuantityUpdateBox.keys,
        ...items.productionItemsQuantityUpdateBox.keys,
        ...CustomerAccountUpdateFunc().customerAccountUpdateBox.keys,
      };

      await syncAll();
      expect(
        [for (final b in deltas.batches) b.map((u) => u['hiveUuid']).toList()],
        [
          ['q-old'],
          ['mq-old'],
          ['iq-old'],
          ['aq-old'],
        ],
      );
      expect(left(), {'q-new', 'mq-new', 'iq-new', 'aq-new'});

      // A queue holding only such deltas sends nothing at all.
      deltas.batches.clear();
      await syncAll();
      expect(deltas.batches, isEmpty);

      // The creates have gone (the created queues are emptied by their
      // syncs): the held deltas go now.
      await CreatedProductFunc().createdProductsBox.clear();
      await CreatedMaterialsFunc().createdMaterialsBox.clear();
      await CreatedProductionItemsFunc().createdProductionItemsBox.clear();
      await CreatedCustomersFunc().createdCustomersBox.clear();
      await syncAll();
      expect(
        [for (final b in deltas.batches) b.map((u) => u['hiveUuid']).toList()],
        [
          ['q-new'],
          ['mq-new'],
          ['iq-new'],
          ['aq-new'],
        ],
      );
      expect(left(), isEmpty);
    });

    test('no answer: the sent entry keeps its amount for the retry, which '
        'the server recognises', () async {
      await materials.createMaterialsQuantityUpdate(materialDelta('a', 2));
      deltas.fail = true;
      await MaterialQuantityUpdateProvider().materialsQuantityUpdateSync();
      expect(queued(), {'a': 2});

      // Without the rule this would have become a=+5, and the server
      // (which may have applied +2) would apply +5 on the retry.
      await materials.createMaterialsQuantityUpdate(materialDelta('b', 3));
      expect(queued(), {'a': 2, 'b': 3});

      deltas.fail = false;
      await MaterialQuantityUpdateProvider().materialsQuantityUpdateSync();
      expect(
        deltas.batches.last.map((u) => (u['hiveUuid'], u['quantity'])),
        unorderedEquals([('a', 2.0), ('b', 3.0)]),
      );
      expect(queued(), isEmpty);
      expect(SentEntriesFunc().sentEntriesBox.isEmpty, isTrue);
    });
  });
}

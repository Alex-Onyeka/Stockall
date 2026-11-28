import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/material_class.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/local_database/hive_adapters_registry.dart';
import 'package:stockall/local_database/lan/lan_applied_deltas_func.dart';
import 'package:stockall/local_database/lan/lan_deleted_items_func.dart';
import 'package:stockall/local_database/lan/lan_delta_journal_func.dart';
import 'package:stockall/local_database/materials/materials_func.dart';
import 'package:stockall/local_database/materials/unsync_funcs/materials_quantity_update/materials_quantity_update_func.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/quantity_update/quantity_update_func.dart';
import 'package:stockall/services/lan/lan_access_policy.dart';
import 'package:stockall/services/lan/rest/hive_rest_engine.dart';
import 'package:stockall/services/lan/rest/lan_delta_registry.dart';
import 'package:stockall/services/lan/rest/lan_delta_rpcs.dart';
import 'package:stockall/services/lan/rest/lan_table_registry.dart';
import 'package:stockall/services/lan/rest/postgrest_request.dart';
import 'package:stockall/services/lan/rest/postgrest_response.dart';

import 'helpers/lan_fixtures.dart';

class _Crash implements Exception {}

MaterialClass _material(String uuid, double quantity) => MaterialClass(
  uuid: uuid,
  name: 'Flour',
  unit: 'kg',
  costPrice: 1,
  shopId: 7,
  departmentName: null,
  departmentUuid: null,
  isManaged: true,
  groupUnit: null,
  qttyPerGroup: null,
  categories: const [],
  useGroupUnit: false,
  unitsList: const [],
  quantity: quantity,
);

PgRequest _rpc(String name, List<Map<String, dynamic>> updates) =>
    PgRequest(table: name, op: PgOp.rpc, body: {'updates': updates});

/// Forwards after [gate] completes.
class _SlowProxy implements LanProxy {
  final gate = Completer<void>();
  final forwarded = <PgRequest>[];

  @override
  Future<PgResponse> forward(
    PgRequest request,
    LanPrincipal principal,
    Set<int> otherShops,
  ) async {
    await gate.future;
    forwarded.add(request);
    return const PgResponse(204);
  }
}

void main() {
  setUpAll(() async {
    Hive.init(Directory.systemTemp.createTempSync('stockall_lan_journal').path);
    registerAllHiveAdapters();
    await ProductsFunc().init();
    await QuantityUpdateFunc().init();
    await MaterialsFunc().init();
    await MaterialsQuantityUpdateFunc().init();
    await LanAppliedDeltasFunc().init();
    await LanDeletedItemsFunc().init();
    await LanDeltaJournalFunc().init();
  });

  setUp(() async {
    await ProductsFunc().productBox.clear();
    await QuantityUpdateFunc().quantityUpdateBox.clear();
    await MaterialsFunc().materialBox.clear();
    await MaterialsQuantityUpdateFunc().materialsQuantityUpdateBox.clear();
    await LanAppliedDeltasFunc().appliedDeltasBox.clear();
    await LanDeltaJournalFunc().journalBox.clear();
  });

  tearDownAll(() async {
    await Hive.close();
  });

  /// The server's deltas, stored like the app's, crashing after [crashAt].
  LanDeltaRpcs server({String? crashAt}) => LanDeltaRpcs(
    rpcs: lanDeltaRpcs(shopId: () => 7),
    applied: const HiveAppliedDeltas(),
    journal: const HiveDeltaJournal(),
    afterStep: (step) async {
      if (step == crashAt) throw _Crash();
    },
  );

  group('a crash part way through a delta (D3)', () {
    final sale = _rpc('update_product_quantities', [
      {'hiveUuid': 'q1', 'itemUuid': 'p1', 'quantity': 3, 'isIncrement': false},
    ]);

    for (final step in ['journal', 'item', 'queue', 'applied']) {
      test('after "$step": finished at the next start, applied once and '
          'queued once; the client\'s retry changes nothing', () async {
        await ProductsFunc().productBox.put('p1', product('p1')); // 4

        await expectLater(
          server(crashAt: step).handle(sale),
          throwsA(isA<_Crash>()),
        );
        expect(LanDeltaJournalFunc().journalBox.length, 1);

        // The next start: initHive finishes what the journal holds.
        expect(await recoverLanDeltaJournal(), 1);
        expect(LanDeltaJournalFunc().journalBox.isEmpty, isTrue);
        expect(ProductsFunc().productBox.get('p1')!.quantity, 1);
        expect(QuantityUpdateFunc().quantityUpdateBox.keys, ['q1']);
        expect(
          LanAppliedDeltasFunc().contains('update_product_quantities:q1'),
          isTrue,
        );

        // The client never got an answer, so it sends the batch again.
        final r = await server().handle(sale);
        expect(r.status, 200);
        expect(ProductsFunc().productBox.get('p1')!.quantity, 1);
        expect(QuantityUpdateFunc().quantityUpdateBox.length, 1);
        expect(await recoverLanDeltaJournal(), 0);
      });
    }

    test('a material (whose queue entries get new uuids) is queued once '
        'after the crash, never merged into a second change', () async {
      await MaterialsFunc().materialBox.put('m1', _material('m1', 10));
      final batch = _rpc('update_materials_quantities', [
        {
          'hiveUuid': 'mq1',
          'materialItemUuid': 'm1',
          'quantity': 2,
          'isIncrement': true,
        },
      ]);
      await expectLater(
        server(crashAt: 'queue').handle(batch),
        throwsA(isA<_Crash>()),
      );
      expect(await recoverLanDeltaJournal(), 1);
      await server().handle(batch);

      expect(MaterialsFunc().materialBox.get('m1')!.quantity, 12);
      final queued = MaterialsQuantityUpdateFunc().getMaterialsQuantitiesUpdate();
      expect(queued.single.quantity, 2);
    });

    test('a finished batch leaves nothing in the journal', () async {
      await ProductsFunc().productBox.put('p1', product('p1'));
      await server().handle(sale);
      expect(LanDeltaJournalFunc().journalBox.isEmpty, isTrue);
      expect(await recoverLanDeltaJournal(), 0);
      expect(ProductsFunc().productBox.get('p1')!.quantity, 1);
    });
  });

  group('no network call inside the stock lock (K1)', () {
    test('a slow Supabase lookup doesn\'t hold up a hold or a pull',
        () async {
      final answer = Completer<LanRemoteRow>();
      final deltas = LanDeltaRpcs(
        rpcs: lanDeltaRpcs(
          shopId: () => 7,
          remoteLookup: (_, _) => answer.future,
        ),
        applied: const HiveAppliedDeltas(),
      );
      final batch = deltas.handle(
        _rpc('update_product_quantities', [
          {
            'hiveUuid': 'q9',
            'itemUuid': 'gone',
            'quantity': 1,
            'isIncrement': false,
          },
        ]),
      );
      // Anything else under the lock runs while the lookup waits.
      expect(
        await deltas
            .runExclusive(() async => 'ran')
            .timeout(const Duration(seconds: 2)),
        'ran',
      );
      answer.complete(LanRemoteRow.missing);
      final r = await batch;
      expect(r.status, 200);
      // Supabase has no such row: dropped and marked applied.
      expect(
        LanAppliedDeltasFunc().contains('update_product_quantities:q9'),
        isTrue,
      );
    });

    test('a checkout\'s lookups are made by prepare, before the lock; '
        'inside it nothing is asked', () async {
      var asked = 0;
      final deltas = LanDeltaRpcs(
        rpcs: lanDeltaRpcs(
          shopId: () => 7,
          remoteLookup: (_, uuid) async {
            asked++;
            return LanRemoteRow(LanRemoteAnswer.found, shopId: 8);
          },
        ),
        applied: const HiveAppliedDeltas(),
      );
      final body = {
        'updates': [
          {'hiveUuid': 'q5', 'itemUuid': 'other', 'quantity': 1},
        ],
      };
      await deltas.prepare('update_product_quantities', body);
      expect(asked, 1);
      final done = await deltas.runExclusive(
        () => deltas.applyHoldingLock(
          'update_product_quantities',
          body,
          skipUnknown: true,
        ),
      );
      expect(asked, 1);
      // Another store's item: done, nothing changed here.
      expect(done.done.single.itemUuid, 'other');
      expect(done.changedItems, isEmpty);

      // Without prepare, an item not held here is just not here yet.
      final cold = LanDeltaRpcs(
        rpcs: lanDeltaRpcs(
          shopId: () => 7,
          remoteLookup: (_, _) async {
            asked++;
            return LanRemoteRow.missing;
          },
        ),
        applied: const HiveAppliedDeltas(),
      );
      final unprepared = await cold.runExclusive(
        () => cold.applyHoldingLock(
          'update_product_quantities',
          {
            'updates': [
              {'hiveUuid': 'q6', 'itemUuid': 'other', 'quantity': 1},
            ],
          },
          skipUnknown: true,
        ),
      );
      expect(asked, 1);
      expect(unprepared.notHereYet.single.itemUuid, 'other');
    });

    test('another store\'s product write is forwarded outside the lock',
        () async {
      final proxy = _SlowProxy();
      final deltas = LanDeltaRpcs(
        rpcs: lanDeltaRpcs(shopId: () => 7),
        applied: const HiveAppliedDeltas(),
      );
      final engine = HiveRestEngine(
        tables: lanTables(shopId: () => 7),
        shopId: () => 7,
        manageDepartments: () => false,
        isOnline: () => true,
        proxy: proxy,
        rpcs: deltas,
      );
      final write = engine.handle(
        PgRequest(
          table: 'products',
          op: PgOp.update,
          body: product('t1', shopId: 8).toJson(isIncludeQuantity: false),
          filters: [PgFilter('uuid', PgFilterOp.eq, 't1')],
        ),
        principal(access: [Authorizations().updateProduct]),
      );
      expect(
        await deltas
            .runExclusive(() async => 'ran')
            .timeout(const Duration(seconds: 2)),
        'ran',
      );
      proxy.gate.complete();
      await write;
      expect(proxy.forwarded.single.table, 'products');
      await engine.dispose();
    });
  });
}

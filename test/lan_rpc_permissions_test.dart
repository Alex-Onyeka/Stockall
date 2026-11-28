import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/services/lan/lan_access_policy.dart';
import 'package:stockall/services/lan/lan_constants.dart';
import 'package:stockall/services/lan/rest/hive_rest_engine.dart';
import 'package:stockall/services/lan/rest/lan_delta_registry.dart';
import 'package:stockall/services/lan/rest/lan_delta_rpcs.dart';
import 'package:stockall/services/lan/rest/postgrest_request.dart';
import 'package:stockall/services/lan/rest/postgrest_response.dart';

import 'helpers/lan_fixtures.dart';

class _NoApplied implements LanAppliedDeltas {
  @override
  bool contains(String key) => false;

  @override
  Future<void> add(String key) async {}
}

/// Answers every stock RPC with 204, counting them.
class _Holds implements LanStockRpcs {
  var calls = 0;

  @override
  bool handles(String name) => name.startsWith('lan_');

  @override
  Future<PgResponse> handle(PgRequest request, LanPrincipal principal) async {
    calls++;
    return const PgResponse(204);
  }
}

void main() {
  final a = Authorizations();

  /// For each RPC the app calls: a permission whose screen sends it, and
  /// one that has nothing to do with it.
  final cases = <String, (String allowed, String unrelated)>{
    'update_product_quantities': (a.makeSale, a.addCustomer),
    'update_materials_quantities': (a.updateMaterialQuantity, a.makeSale),
    'update_production_items_quantities': (
      a.updateProductionItemQuantity,
      a.makeSale,
    ),
    'update_customer_account': (a.creditCustomersAccount, a.addProduct),
    LanConstants.stockReserveRpc: (a.makeSale, a.addCustomer),
    LanConstants.stockSyncRpc: (a.updateSale, a.addCustomer),
    LanConstants.stockCheckoutRpc: (a.makeSale, a.addExpense),
  };

  group('each RPC needs one of the permissions whose screen sends it', () {
    for (final MapEntry(key: name, value: (allowed, unrelated))
        in cases.entries) {
      test(name, () {
        expect(
          LanAccessPolicy.canCall(principal(access: [allowed]), name),
          isTrue,
        );
        expect(
          LanAccessPolicy.canCall(principal(access: [unrelated]), name),
          isFalse,
        );
        expect(LanAccessPolicy.canCall(principal(), name), isFalse);
      });
    }

    test('membership alone: releasing a hold, and the two online-only RPCs',
        () {
      for (final name in [
        LanConstants.stockReleaseRpc,
        ...LanConstants.onlineOnlyRpcs,
      ]) {
        expect(LanAccessPolicy.canCall(principal(), name), isTrue, reason: name);
      }
    });

    test('every RPC the server answers is mapped (an unmapped one is '
        'refused)', () {
      for (final name in {
        ...LanConstants.deltaRpcs,
        LanConstants.stockReserveRpc,
        LanConstants.stockSyncRpc,
        LanConstants.stockReleaseRpc,
        ...LanConstants.onlineOnlyRpcs,
      }) {
        expect(LanAccessPolicy.rpcPermissions(name), isNotNull, reason: name);
      }
      expect(LanAccessPolicy.canCall(principal(), 'drop_everything'), isFalse);
    });
  });

  test('the engine refuses with 403 LAN02, logs it, and runs nothing',
      () async {
    final denied = <String>[];
    final holds = _Holds();
    final engine = HiveRestEngine(
      tables: const [],
      shopId: () => 7,
      manageDepartments: () => false,
      isOnline: () => false,
      rpcs: LanDeltaRpcs(
        rpcs: lanDeltaRpcs(shopId: () => 7),
        applied: _NoApplied(),
      ),
      stock: holds,
      onDenied: (what, who) => denied.add('$what ${who.userId}'),
    );
    PgRequest call(String name) =>
        PgRequest(table: name, op: PgOp.rpc, body: const {'updates': []});
    Matcher refused() => throwsA(
      isA<PgError>()
          .having((e) => e.status, 'status', 403)
          .having((e) => e.code, 'code', 'LAN02'),
    );

    final stranger = principal(access: [a.addCustomer]);
    await expectLater(
      engine.handle(call(LanConstants.stockReserveRpc), stranger),
      refused(),
    );
    await expectLater(
      engine.handle(call('update_product_quantities'), stranger),
      refused(),
    );
    expect(holds.calls, 0);
    expect(denied, [
      'rpc lan_stock_reserve staff-1',
      'rpc update_product_quantities staff-1',
    ]);

    // A cashier's hold goes through; anyone may release.
    await engine.handle(
      call(LanConstants.stockReserveRpc),
      principal(access: [a.makeSale]),
    );
    await engine.handle(call(LanConstants.stockReleaseRpc), stranger);
    expect(holds.calls, 2);
  });
}

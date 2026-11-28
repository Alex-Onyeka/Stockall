import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_current_shop/temp_current_shop.dart';
import 'package:stockall/local_database/lan/lan_applied_deltas_func.dart';
import 'package:stockall/local_database/lan/lan_handoffs_func.dart';
import 'package:stockall/local_database/lan/lan_pending_checkouts_func.dart';
import 'package:stockall/local_database/main_database.dart';
import 'package:stockall/local_database/shop_current/current_shop_func.dart';
import 'package:stockall/services/lan/lan_handoffs.dart';
import 'package:stockall/services/lan/lan_unsent.dart';

void main() {
  setUpAll(() async {
    Hive.init(Directory.systemTemp.createTempSync('stockall_lan_unsent').path);
    await LanHandoffsFunc().init();
    await LanPendingCheckoutsFunc().init();
    await LanAppliedDeltasFunc().init();
    await CurrentShopFunc().init();
  });

  setUp(() async {
    await LanHandoffsFunc().clearHandoffs();
    await LanPendingCheckoutsFunc().clearPending();
    await LanAppliedDeltasFunc().appliedDeltasBox.clear();
  });

  tearDownAll(() async {
    await Hive.close();
  });

  group('logout and store switch warn first', () {
    test('nothing unsent: no warning', () {
      expect(lanUnsentMessage(before: 'logging out'), isNull);
    });

    test('a handoff or a pending checkout on this device: warned, with '
        'what is waiting', () async {
      await LanHandoffsFunc().add(
        jsonEncode(
          LanHandoff(
            kind: LanHandoffKind.rest,
            method: 'POST',
            path: 'products',
            query: '',
            headers: const {},
            body: '{}',
            serverDeviceId: 'desk',
            epoch: 1,
            serverTime: null,
            handedAt: DateTime.utc(2026, 11, 20),
          ).toJson(),
        ),
      );
      expect(
        lanUnsentMessage(before: 'logging out'),
        allOf(contains('1 change'), contains('before logging out')),
      );

      await LanPendingCheckoutsFunc().put('cart-1', '{}');
      expect(
        lanUnsentMessage(before: 'switching stores'),
        allOf(
          contains('1 change and 1 checkout'),
          contains('before switching stores'),
        ),
      );
      expect(
        lanUnsentMessage(before: 'x', handoffs: () => 0, checkouts: () => 2),
        contains('2 checkouts'),
      );
    });
  });

  group('the applied-delta record', () {
    test('kept by logout; cleared only when this device serves another '
        'store', () async {
      await LanAppliedDeltasFunc().forShop(7);
      await LanAppliedDeltasFunc().add('update_product_quantities:q1');

      await MainDatabase().clearAllShopData(includeAuthAndShop: true);
      expect(
        LanAppliedDeltasFunc().contains('update_product_quantities:q1'),
        isTrue,
      );

      // The same store again: still there.
      await LanAppliedDeltasFunc().forShop(7);
      expect(
        LanAppliedDeltasFunc().contains('update_product_quantities:q1'),
        isTrue,
      );

      // Another store: dropped.
      await LanAppliedDeltasFunc().forShop(8);
      expect(
        LanAppliedDeltasFunc().contains('update_product_quantities:q1'),
        isFalse,
      );
      expect(
        LanAppliedDeltasFunc().appliedDeltasBox.get(
          LanAppliedDeltasFunc.shopMarker,
        ),
        8,
      );
    });

    test('pruning old entries never drops the store marker', () async {
      await LanAppliedDeltasFunc().forShop(7);
      await LanAppliedDeltasFunc().add('old');
      await LanAppliedDeltasFunc().prune(
        now: DateTime.now().add(const Duration(days: 365)),
      );
      expect(LanAppliedDeltasFunc().contains('old'), isFalse);
      expect(
        LanAppliedDeltasFunc().appliedDeltasBox.get(
          LanAppliedDeltasFunc.shopMarker,
        ),
        7,
      );
    });
  });
  test('a logout that skips the unsent check (password reset, account '
      'deletion) or a deleted store keeps handoffs and pending checkouts; '
      'they wait for their store, unseen by another one', () async {
    addTearDown(() => CurrentShopFunc().clearCurrentShop());
    await CurrentShopFunc().createCurrentShop(
      TempCurrentShop(currentShopId: 7),
    );
    await LanHandoffsFunc().add(
      jsonEncode(
        LanHandoff(
          kind: LanHandoffKind.rest,
          method: 'POST',
          path: 'products',
          query: '',
          headers: const {},
          body: '{}',
          serverDeviceId: 'desk',
          epoch: 1,
          serverTime: null,
          handedAt: DateTime.utc(2026, 11, 20),
          shopId: 7,
        ).toJson(),
      ),
    );
    await LanPendingCheckoutsFunc().put(
      'cart-1',
      jsonEncode({'cart_id': 'cart-1', 'shop_id': 7}),
    );

    await MainDatabase().clearAllShopData(includeAuthAndShop: true);
    await CurrentShopFunc().clearCurrentShop();
    expect(LanHandoffsFunc().entries(), hasLength(1));
    expect(LanPendingCheckoutsFunc().pendingBox.length, 1);

    // Another store signs in: not its changes.
    await CurrentShopFunc().createCurrentShop(
      TempCurrentShop(currentShopId: 8),
    );
    expect(LanHandoffs().all(), isEmpty);
    expect(LanPendingCheckoutsFunc().all(), isEmpty);
    expect(lanUnsentMessage(before: 'logging out'), isNull);

    // Back to the store: they are there, and the warning with them.
    await CurrentShopFunc().createCurrentShop(
      TempCurrentShop(currentShopId: 7),
    );
    expect(LanHandoffs().all().single.$2.shopId, 7);
    expect(LanPendingCheckoutsFunc().all().keys, ['cart-1']);
    expect(lanUnsentMessage(before: 'logging out'), contains('1 change'));
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_item_purchase_record/temp_item_purchase_record.dart';
import 'package:stockall/classes/temp_purchase/purchase_edit_rules.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';

TempPurchase purchase(
  String uuid, {
  List<TempItemPurchaseRecord>? items,
  String? supplierName = 'Acme',
}) {
  return TempPurchase(
    uuid: uuid,
    createdAt: DateTime.utc(2026, 10, 17, 12),
    shopId: 1,
    supplierId: 'sup-a',
    supplierName: supplierName,
    total: 100,
    isCustomPriceSet: false,
    purchasePayments: [],
    updatedAt: DateTime.utc(2026, 10, 18),
    items: items,
  );
}

TempItemPurchaseRecord line(String itemId, double quantity) {
  return TempItemPurchaseRecord(
    createdAt: DateTime.utc(2026, 10, 17, 12),
    shopId: 1,
    staffId: 'staff-a',
    itemId: itemId,
    storageItemId: null,
    purchaseId: 'p1',
    quantity: quantity,
    total: quantity * 10,
    originalPrice: 10,
    customPrice: null,
    isGroup: false,
    qttyPerGroup: null,
    unit: 'piece',
    unitsList: null,
    unitUuid: null,
    uuid: 'line-$itemId-$quantity',
  );
}

MapEntry<String, double> stock(String item, double qty) =>
    MapEntry(item, qty);

void main() {
  group('stockByItem', () {
    test('sums several lines of one item', () {
      expect(
        stockByItem([stock('a', 12), stock('a', 3), stock('b', 1)]),
        {'a': 15, 'b': 1},
      );
    });

    test('is empty for no lines', () {
      expect(stockByItem([]), isEmpty);
    });
  });

  group('purchaseStockDeltas', () {
    test('unchanged purchase moves no stock', () {
      expect(
        purchaseStockDeltas({'a': 10, 'b': 2}, {'a': 10, 'b': 2}),
        isEmpty,
      );
    });

    test('quantity up adds only the difference', () {
      expect(purchaseStockDeltas({'a': 10}, {'a': 14}), {'a': 4});
    });

    test('quantity down removes only the difference', () {
      expect(purchaseStockDeltas({'a': 10}, {'a': 6}), {'a': -4});
    });

    test('removed item takes its whole old quantity out', () {
      expect(
        purchaseStockDeltas({'a': 10, 'b': 5}, {'a': 10}),
        {'b': -5},
      );
    });

    test('added item adds its whole new quantity', () {
      expect(
        purchaseStockDeltas({'a': 10}, {'a': 10, 'c': 7}),
        {'c': 7},
      );
    });

    test('replacing A with B removes A and adds B', () {
      expect(purchaseStockDeltas({'a': 10}, {'b': 3}), {
        'a': -10,
        'b': 3,
      });
    });

    test('two lines of one item are compared as their sum', () {
      // Old: 1 carton of 12 + 3 pieces. New: 15 single pieces.
      final oldStock = stockByItem([stock('a', 12), stock('a', 3)]);
      final newStock = stockByItem([stock('a', 15)]);
      expect(purchaseStockDeltas(oldStock, newStock), isEmpty);
    });

    test('unit change with the same stored total moves no stock', () {
      // 12 pieces became 1 carton of 12: both are 12 stored units.
      expect(purchaseStockDeltas({'a': 12}, {'a': 1 * 12.0}), isEmpty);
    });

    test('float noise within the tolerance is ignored', () {
      expect(
        purchaseStockDeltas({'a': 0.1 + 0.2}, {'a': 0.3}),
        isEmpty,
      );
      expect(purchaseStockDeltas({'a': 1}, {'a': 1 + 1e-7}), isEmpty);
    });

    test('a real small change is kept', () {
      final deltas = purchaseStockDeltas({'a': 1}, {'a': 1.001});
      expect(deltas['a'], closeTo(0.001, 1e-9));
    });
  });

  group('canEditPurchase', () {
    test('false for a legacy purchase with no stored items', () {
      expect(canEditPurchase(purchase('p1')), isFalse);
      expect(canEditPurchase(purchase('p1', items: [])), isFalse);
    });

    test('true when lines are stored', () {
      expect(
        canEditPurchase(purchase('p1', items: [line('a', 2)])),
        isTrue,
      );
    });
  });

  group('purchaseToPush', () {
    test('prefers the current local copy over the queued one', () {
      final queued = purchase('p1', supplierName: 'Old Name');
      final local = purchase('p1', supplierName: 'New Name');
      expect(purchaseToPush(queued, local), same(local));
    });

    test('falls back to the queued copy when there is no local one', () {
      final queued = purchase('p1');
      expect(purchaseToPush(queued, null), same(queued));
    });
  });

  group('shouldPushPurchaseUpdate', () {
    final t = DateTime.utc(2026, 10, 28, 9);

    test('newer local edit is sent', () {
      expect(
        shouldPushPurchaseUpdate(
          localUpdatedAt: t.add(const Duration(minutes: 1)),
          remoteUpdatedAt: t,
        ),
        isTrue,
      );
    });

    test('older local edit loses to a newer remote edit', () {
      expect(
        shouldPushPurchaseUpdate(
          localUpdatedAt: t,
          remoteUpdatedAt: t.add(const Duration(minutes: 1)),
        ),
        isFalse,
      );
    });

    test('a tie is sent (e.g. rename already on the server)', () {
      expect(
        shouldPushPurchaseUpdate(localUpdatedAt: t, remoteUpdatedAt: t),
        isTrue,
      );
    });

    test('no remote timestamp is sent', () {
      expect(
        shouldPushPurchaseUpdate(localUpdatedAt: t, remoteUpdatedAt: null),
        isTrue,
      );
    });

    test('local and UTC times compare by instant', () {
      final local = t.toLocal();
      expect(
        shouldPushPurchaseUpdate(
          localUpdatedAt: local,
          remoteUpdatedAt: t.add(const Duration(seconds: 1)),
        ),
        isFalse,
      );
      expect(
        shouldPushPurchaseUpdate(
          localUpdatedAt: local.add(const Duration(seconds: 1)),
          remoteUpdatedAt: t,
        ),
        isTrue,
      );
    });

    test('a later rename beats an older edit (no +1 day)', () {
      final edit = t;
      final rename = t.add(const Duration(minutes: 5));
      expect(
        shouldPushPurchaseUpdate(
          localUpdatedAt: rename,
          remoteUpdatedAt: edit,
        ),
        isTrue,
      );
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_item_purchase_record/temp_item_purchase_record.dart';
import 'package:stockall/classes/temp_purchase/purchase_payments.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/classes/temp_suppliers/supplier_rules.dart';

import 'purchase_report_fixtures.dart' show pieceUnit;

TempPurchase purchase(
  String uuid, {
  String? supplierId = 'sup-a',
  String? supplierName = 'Acme',
  double total = 100,
}) {
  return TempPurchase(
    uuid: uuid,
    createdAt: DateTime.utc(2026, 10, 17, 12),
    shopId: 1,
    staffId: 'staff-a',
    staffName: 'Ada',
    supplierId: supplierId,
    supplierName: supplierName,
    departmentUuid: 'dept-a',
    departmentName: 'Main',
    total: total,
    isCustomPriceSet: true,
    purchasePayments: [
      PurchasePayments(
        uuid: 'pay-$uuid',
        purchaseId: uuid,
        createdAt: DateTime.utc(2026, 10, 17, 12),
        amount: 40,
        userId: 'staff-a',
        paymentMethod: 'Cash',
        staffName: 'Ada',
      ),
    ],
    updatedAt: DateTime.utc(2026, 10, 18),
    items: [
      TempItemPurchaseRecord(
        uuid: 'line-$uuid',
        createdAt: DateTime.utc(2026, 10, 17, 12),
        shopId: 1,
        staffId: 'staff-a',
        itemId: 'product-a',
        storageItemId: null,
        purchaseId: uuid,
        itemName: 'Rice',
        quantity: 2,
        total: total,
        originalPrice: total,
        customPrice: null,
        isGroup: false,
        qttyPerGroup: null,
        unit: 'piece',
        // A units list, so toJson never looks units up through
        // the user provider (Supabase).
        unitsList: [pieceUnit],
        unitUuid: 'piece',
      ),
    ],
  );
}

void main() {
  group('supplierFieldOrNull', () {
    test('blank is null, as on create', () {
      expect(supplierFieldOrNull(''), isNull);
      expect(supplierFieldOrNull('   '), isNull);
    });

    test('anything else is kept as typed', () {
      expect(supplierFieldOrNull('a'), 'a');
      expect(supplierFieldOrNull(' a '), ' a ');
      expect(supplierFieldOrNull('08012345678'), '08012345678');
    });
  });

  group('delete warning', () {
    final purchases = [
      purchase('p1'),
      purchase('p2'),
      purchase('p3', supplierId: 'sup-b'),
      purchase('p4', supplierId: null, supplierName: null),
    ];

    test('counts only that supplier\'s purchases', () {
      expect(supplierPurchaseCount(purchases, 'sup-a'), 2);
      expect(supplierPurchaseCount(purchases, 'sup-b'), 1);
      expect(supplierPurchaseCount(purchases, 'sup-c'), 0);
      expect(supplierPurchaseCount(const [], 'sup-a'), 0);
    });

    test('none without purchases; singular and plural', () {
      expect(supplierDeleteWarning(0), isNull);
      expect(
        supplierDeleteWarning(1),
        'This supplier has 1 purchase. It will keep the '
        "supplier's name, but the supplier will be removed.",
      );
      expect(
        supplierDeleteWarning(3),
        'This supplier has 3 purchases. They will keep the '
        "supplier's name, but the supplier will be removed.",
      );
    });
  });

  group('purchasesToRename', () {
    final purchases = [
      purchase('old-name', supplierName: 'Acme'),
      purchase('no-name', supplierName: null),
      purchase('same-name', supplierName: 'Acme Ltd'),
      purchase('other', supplierId: 'sup-b', supplierName: 'Acme'),
      purchase('none', supplierId: null, supplierName: 'Acme'),
      purchase('queued-delete', supplierName: 'Acme'),
    ];

    test('the supplier\'s purchases whose name differs', () {
      final selected = purchasesToRename(
        purchases,
        supplierUuid: 'sup-a',
        newName: 'Acme Ltd',
        pendingDeletedUuids: {'queued-delete'},
      );
      expect(selected.map((p) => p.uuid), ['old-name', 'no-name']);
    });

    test('nothing when every name is already right', () {
      expect(
        purchasesToRename(
          [purchase('a', supplierName: 'Acme')],
          supplierUuid: 'sup-a',
          newName: 'Acme',
        ),
        isEmpty,
      );
    });
  });

  group('renamedPurchase', () {
    final now = DateTime.utc(2026, 10, 28, 9, 30);

    test('only supplier_name and updated_at change', () {
      final original = purchase('p1', supplierName: 'Acme');
      final before = original.toJson();
      final renamed = renamedPurchase(original, 'Acme Ltd', now);

      expect(renamed.supplierName, 'Acme Ltd');
      expect(renamed.updatedAt, now);

      final after = renamed.toJson();
      expect(after.keys.toSet(), before.keys.toSet());
      final changed = {
        for (final k in after.keys)
          if ('${after[k]}' != '${before[k]}') k,
      };
      expect(changed, {'supplier_name', 'updated_at'});

      // Same identity, stock lines, payments, total and dates.
      expect(renamed.uuid, original.uuid);
      expect(renamed.supplierId, original.supplierId);
      expect(renamed.total, original.total);
      expect(renamed.createdAt, original.createdAt);
      expect(renamed.isCustomPriceSet, original.isCustomPriceSet);
      expect(renamed.purchasePayments, same(original.purchasePayments));
      expect(renamed.items, same(original.items));
    });

    test('the original is not modified', () {
      final original = purchase('p1', supplierName: 'Acme');
      renamedPurchase(original, 'Acme Ltd', now);
      expect(original.supplierName, 'Acme');
      expect(original.updatedAt, DateTime.utc(2026, 10, 18));
    });
  });
}

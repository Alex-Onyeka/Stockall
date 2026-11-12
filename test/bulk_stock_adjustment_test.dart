import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/providers/shop_provider.dart';
import 'package:stockall/services/stock_adjustment_helper.dart';

import 'all_items_test_env.dart';

ProductUnitsClass unit(
  String uuid,
  String name,
  double conversion, {
  bool isPrimary = false,
  int? dimensionType,
}) {
  return ProductUnitsClass(
    uuid: uuid,
    staffUuid: null,
    createdAt: DateTime.utc(2026),
    staffName: null,
    conversion: conversion,
    name: name,
    isPrimary: isPrimary,
    productUuid: 'product',
    dimensionType: dimensionType,
  );
}

final each = unit('unit-each', 'Each', 1, isPrimary: true);
final caseUnit = unit('unit-case', 'Case', 12);
final sheet = unit(
  'unit-sheet',
  'Sheet',
  1,
  isPrimary: true,
  dimensionType: ProductUnitsClass.sheetUnit,
);
final squareMeter = unit(
  'unit-sqm',
  'Square Meter',
  1,
  dimensionType: ProductUnitsClass.areaUnit,
);

TempProductClass product(
  String uuid, {
  String? name,
  double? quantity = 10,
  List<ProductUnitsClass>? units,
  int quantityType = 1,
  double? width,
  double? height,
  String? storageUuid,
}) {
  final unitList = units ?? [each, caseUnit];
  return TempProductClass(
    uuid: uuid,
    name: name ?? 'Item $uuid',
    unit: unitList.first.name,
    isRefundable: false,
    costPrice: 0,
    shopId: 1,
    setCustomPrice: false,
    departmentName: null,
    departmentUuid: null,
    isManaged: true,
    groupUnit: null,
    qttyPerGroup: null,
    wholeSalePrice: null,
    storageUuid: storageUuid,
    categories: null,
    useGroupUnit: false,
    unitsList: unitList,
    pricesList: null,
    widthDimension: width,
    heightDimension: height,
    quantityType: quantityType,
    manageSalesWastage: false,
    quantity: quantity,
  );
}

// 2 x 3 sheet (area 6), 4 sheets in stock.
TempProductClass sheetItem(String uuid, {double quantity = 4}) => product(
  uuid,
  quantity: quantity,
  units: [sheet, squareMeter],
  quantityType: 2,
  width: 2,
  height: 3,
);

// 2D item without dimensions.
TempProductClass sheetItemNoDimensions(String uuid) => product(
  uuid,
  units: [sheet],
  quantityType: 2,
);

StockAdjustmentCardCheck check(
  TempProductClass item, {
  required String quantity,
  bool isAdd = true,
  String? unitUuid,
  int quantityTypeTemp = 1,
  String width = '',
  String height = '',
}) {
  return validateStockAdjustmentCard(
    product: item,
    input: StockAdjustmentCardInput(
      quantityText: quantity,
      unitUuid: unitUuid,
      isAddToQuantity: isAdd,
      quantityTypeTemp: quantityTypeTemp,
      widthText: width,
      heightText: height,
    ),
  );
}

StockAdjustmentLine line(
  TempProductClass item, {
  required double quantity,
  bool isAdd = true,
  String? unitUuid,
  bool useCustomDimensions = false,
  double? width,
  double? height,
}) {
  return StockAdjustmentLine(
    productUuid: item.uuid!,
    itemName: item.name,
    unitUuid: unitUuid,
    enteredQuantity: quantity,
    isAddToQuantity: isAdd,
    useCustomDimensions: useCustomDimensions,
    customWidth: width,
    customHeight: height,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('card validation', () {
    final item = product('p1');

    test('blank or only commas / spaces is skipped', () {
      expect(check(item, quantity: '').isSkipped, isTrue);
      expect(check(item, quantity: '  ,  ').isSkipped, isTrue);
      expect(check(item, quantity: '', isAdd: false).isSkipped, isTrue);
    });

    test('not a number is invalid', () {
      expect(check(item, quantity: 'abc').error, stockAdjustmentInvalidNumber);
      expect(check(item, quantity: 'Infinity').error, stockAdjustmentInvalidNumber);
    });

    test('negative is rejected in both modes', () {
      expect(check(item, quantity: '-1').error, stockAdjustmentNegative);
      expect(
        check(item, quantity: '-1', isAdd: false).error,
        stockAdjustmentNegative,
      );
    });

    test('Add with 0 is rejected', () {
      expect(check(item, quantity: '0').error, stockAdjustmentAddZero);
    });

    test('Replace with 0 is allowed', () {
      final result = check(item, quantity: '0', isAdd: false);
      expect(result.error, isNull);
      expect(result.line!.enteredQuantity, 0);
      expect(result.line!.isAddToQuantity, isFalse);
    });

    test('commas are accepted and the line carries the card values', () {
      final result = check(
        item,
        quantity: '1,250',
        unitUuid: caseUnit.uuid,
      );
      final l = result.line!;
      expect(l.enteredQuantity, 1250);
      expect(l.productUuid, 'p1');
      expect(l.itemName, item.name);
      expect(l.unitUuid, caseUnit.uuid);
      expect(l.isAddToQuantity, isTrue);
    });
  });

  group('card validation: 2D dimensions', () {
    test('item without dimensions needs width and height', () {
      final item = sheetItemNoDimensions('p1');
      expect(
        check(item, quantity: '2', unitUuid: sheet.uuid).error,
        'Enter positive Width and Height for this item.',
      );
      final ok = check(
        item,
        quantity: '2',
        unitUuid: sheet.uuid,
        width: '2',
        height: '3',
      );
      expect(ok.error, isNull);
      expect(ok.line!.useCustomDimensions, isTrue);
      expect(ok.line!.customWidth, 2);
      expect(ok.line!.customHeight, 3);
    });

    const sheetMessage =
        'Enter positive dimensions no larger than the original slab / sheet.';

    test('dimensions must be positive', () {
      final item = sheetItem('p1');
      expect(
        check(
          item,
          quantity: '1',
          unitUuid: sheet.uuid,
          quantityTypeTemp: 2,
          width: '0',
          height: '1',
        ).error,
        sheetMessage,
      );
    });

    test('dimensions cannot exceed the sheet', () {
      final item = sheetItem('p1');
      expect(
        check(
          item,
          quantity: '1',
          unitUuid: sheet.uuid,
          quantityTypeTemp: 2,
          width: '2.5',
          height: '1',
        ).error,
        sheetMessage,
      );
    });

    test('dimensions within the sheet give a custom-dimension line', () {
      final item = sheetItem('p1');
      final result = check(
        item,
        quantity: '1',
        unitUuid: sheet.uuid,
        quantityTypeTemp: 2,
        width: '2',
        height: '1.5',
      );
      expect(result.error, isNull);
      expect(result.line!.useCustomDimensions, isTrue);
      expect(result.line!.customWidth, 2);
      expect(result.line!.customHeight, 1.5);
    });

    test('"Enter Whole" does not check dimensions', () {
      final result = check(
        sheetItem('p1'),
        quantity: '2',
        unitUuid: sheet.uuid,
        width: '99',
        height: '99',
      );
      expect(result.error, isNull);
      expect(result.line!.useCustomDimensions, isFalse);
      expect(result.line!.customWidth, isNull);
    });

    test('an area unit does not check dimensions', () {
      // 2D item without dimensions that lists the area unit.
      final item = product(
        'p1',
        units: [sheet, squareMeter],
        quantityType: 2,
      );
      final result = check(
        item,
        quantity: '6',
        unitUuid: squareMeter.uuid,
      );
      expect(result.error, isNull);
      expect(result.line!.customWidth, isNull);
    });
  });

  group('review', () {
    test('all blank: nothing entered', () {
      final review = reviewStockAdjustmentCards([
        (
          product: product('p1'),
          input: const StockAdjustmentCardInput(
            quantityText: '',
            unitUuid: null,
            isAddToQuantity: true,
          ),
        ),
        (
          product: product('p2'),
          input: const StockAdjustmentCardInput(
            quantityText: ' ',
            unitUuid: null,
            isAddToQuantity: false,
          ),
        ),
      ]);
      expect(review.lines, isEmpty);
      expect(review.hasErrors, isFalse);
      expect(review.formError, stockAdjustmentNothingEntered);
    });

    test('a no-op is dropped and counts as nothing entered', () {
      final review = reviewStockAdjustmentCards([
        (
          product: product('p1', quantity: 10),
          input: const StockAdjustmentCardInput(
            quantityText: '10',
            unitUuid: null,
            isAddToQuantity: false,
          ),
        ),
      ]);
      expect(review.lines, isEmpty);
      expect(review.formError, stockAdjustmentNothingEntered);
    });

    test('errors are keyed by item; no form error when a card is invalid', () {
      final review = reviewStockAdjustmentCards([
        (
          product: product('p1'),
          input: const StockAdjustmentCardInput(
            quantityText: '-3',
            unitUuid: null,
            isAddToQuantity: true,
          ),
        ),
        (
          product: product('p2'),
          input: const StockAdjustmentCardInput(
            quantityText: '5',
            unitUuid: null,
            isAddToQuantity: true,
          ),
        ),
        (
          product: product('p3'),
          input: const StockAdjustmentCardInput(
            quantityText: '',
            unitUuid: null,
            isAddToQuantity: true,
          ),
        ),
      ]);
      expect(review.errors, {'p1': stockAdjustmentNegative});
      expect(review.lines.map((l) => l.productUuid), ['p2']);
      expect(review.formError, isNull);
    });

    test('set-to-zero counts Replace with 0, not items already at 0', () {
      final review = reviewStockAdjustmentCards([
        (
          product: product('p1', quantity: 10),
          input: const StockAdjustmentCardInput(
            quantityText: '0',
            unitUuid: null,
            isAddToQuantity: false,
          ),
        ),
        (
          product: product('p2', quantity: 0),
          input: const StockAdjustmentCardInput(
            quantityText: '0',
            unitUuid: null,
            isAddToQuantity: false,
          ),
        ),
        (
          product: product('p3', quantity: 4),
          input: const StockAdjustmentCardInput(
            quantityText: '7',
            unitUuid: null,
            isAddToQuantity: false,
          ),
        ),
      ]);
      expect(review.lines.map((l) => l.productUuid), ['p1', 'p3']);
      expect(review.setToZeroCount, 1);
      expect(review.formError, isNull);
    });
  });

  group('launcher split (real isPartOfStorage)', () {
    setUpAll(() async {
      await setUpAllItemsEnvironment();
    });

    void setManageInventoryStorage(bool value) {
      ShopProvider().userShops.first.manageInventoryStorage = value;
    }

    StockAdjustmentSelection split(
      List<TempProductClass> selected, {
      Map<String, TempProductClass> live = const {},
    }) {
      return splitForStockAdjustment(
        selected: selected,
        findLive: (uuid) => live[uuid],
        isLinkedToStorage: (p) => p.isPartOfStorage(),
      );
    }

    test('storage on, every item linked: all linked, alert message', () {
      setManageInventoryStorage(true);
      final result = split([
        product('p1', storageUuid: 's1'),
        product('p2', storageUuid: 's2'),
      ]);
      expect(result.allLinked, isTrue);
      expect(result.adjustable, isEmpty);
      expect(result.linkedToStorage.length, 2);
      expect(
        allLinkedToStorageMessage(result.linkedToStorage.length),
        'All 2 selected items are linked to a storage item. '
        'Their stock can only change through storage transfers. '
        'Transfer from storage instead.',
      );
    });

    test('storage on, some linked: both lists (banner case)', () {
      setManageInventoryStorage(true);
      final result = split([
        product('p1', storageUuid: 's1'),
        product('p2'),
        product('p3'),
      ]);
      expect(result.allLinked, isFalse);
      expect(result.adjustable.map((p) => p.uuid), ['p2', 'p3']);
      expect(result.linkedToStorage.map((p) => p.uuid), ['p1']);
      expect(
        linkedToStorageBannerMessage(1),
        '1 item is linked to storage and will be skipped.',
      );
      expect(
        linkedToStorageBannerMessage(2),
        '2 items are linked to storage and will be skipped.',
      );
    });

    test('storage off: linked items are adjustable', () {
      setManageInventoryStorage(false);
      final result = split([
        product('p1', storageUuid: 's1'),
        product('p2'),
      ]);
      expect(result.allLinked, isFalse);
      expect(result.linkedToStorage, isEmpty);
      expect(result.adjustable.map((p) => p.uuid), ['p1', 'p2']);
    });

    test('uses the live item and keeps an item selected twice once', () {
      setManageInventoryStorage(true);
      final selectedCopy = product('p1');
      final liveCopy = product('p1', storageUuid: 's1');
      final result = split(
        [selectedCopy, product('p1'), product('p2')],
        live: {'p1': liveCopy},
      );
      expect(identical(result.linkedToStorage.single, liveCopy), isTrue);
      expect(result.adjustable.map((p) => p.uuid), ['p2']);
    });

    test('one linked item: singular alert message', () {
      expect(
        allLinkedToStorageMessage(1),
        'The selected item is linked to a storage item. '
        'Its stock can only change through storage transfers. '
        'Transfer from storage instead.',
      );
    });
  });

  group('confirmation message', () {
    test('adjust count only', () {
      expect(
        stockAdjustmentConfirmationMessage(
          adjustCount: 3,
          setToZeroCount: 0,
          skippedLinkedCount: 0,
        ),
        'You are about to adjust stock for 3 items. '
        'Are you sure you want to proceed?',
      );
    });

    test('singular', () {
      expect(
        stockAdjustmentConfirmationMessage(
          adjustCount: 1,
          setToZeroCount: 1,
          skippedLinkedCount: 1,
        ),
        'You are about to adjust stock for 1 item. '
        '1 item will be set to zero. '
        '1 storage-linked item will be skipped. '
        'Are you sure you want to proceed?',
      );
    });

    test('with set-to-zero', () {
      expect(
        stockAdjustmentConfirmationMessage(
          adjustCount: 4,
          setToZeroCount: 2,
          skippedLinkedCount: 0,
        ),
        'You are about to adjust stock for 4 items. '
        '2 items will be set to zero. '
        'Are you sure you want to proceed?',
      );
    });

    test('with skipped linked items', () {
      expect(
        stockAdjustmentConfirmationMessage(
          adjustCount: 2,
          setToZeroCount: 0,
          skippedLinkedCount: 3,
        ),
        'You are about to adjust stock for 2 items. '
        '3 storage-linked items will be skipped. '
        'Are you sure you want to proceed?',
      );
    });

    test('with both', () {
      expect(
        stockAdjustmentConfirmationMessage(
          adjustCount: 5,
          setToZeroCount: 2,
          skippedLinkedCount: 3,
        ),
        'You are about to adjust stock for 5 items. '
        '2 items will be set to zero. '
        '3 storage-linked items will be skipped. '
        'Are you sure you want to proceed?',
      );
    });
  });

  group('result summary', () {
    test('everything adjusted', () {
      final s = stockAdjustmentSummary(
        const StockAdjustmentResult(
          adjusted: ['A', 'B'],
          skipped: [],
          failed: [],
        ),
      );
      expect(s.title, 'Stock Adjusted');
      expect(s.message, 'Adjusted stock for 2 items.');
    });

    test('partial, with failed and skipped lists', () {
      final s = stockAdjustmentSummary(
        const StockAdjustmentResult(
          adjusted: ['A'],
          skipped: ['C: no change'],
          failed: ['B: could not save the new quantity'],
        ),
      );
      expect(s.title, 'Partial Adjustment');
      expect(
        s.message,
        'Adjusted stock for 1 item.'
        '\n\nFailed (1):\nB: could not save the new quantity'
        '\n\nSkipped (1):\nC: no change',
      );
    });

    test('all failed', () {
      final s = stockAdjustmentSummary(
        const StockAdjustmentResult(
          adjusted: [],
          skipped: [],
          failed: ['A: item no longer exists'],
        ),
      );
      expect(s.title, 'Stock Adjustment Failed');
      expect(
        s.message,
        'No item was adjusted.\n\nFailed (1):\nA: item no longer exists',
      );
    });

    test('nothing adjusted, nothing failed', () {
      final s = stockAdjustmentSummary(
        const StockAdjustmentResult(
          adjusted: [],
          skipped: ['A: linked to storage'],
          failed: [],
        ),
      );
      expect(s.title, 'Nothing Adjusted');
    });
  });

  group('execution plan (live recheck)', () {
    StockAdjustmentPlan plan(
      List<StockAdjustmentLine> lines,
      Map<String, TempProductClass> live, {
      Set<String> linked = const {},
    }) {
      return planStockAdjustments(
        lines: lines,
        findLive: (uuid) => live[uuid],
        isLinkedToStorage: (p) => linked.contains(p.uuid),
      );
    }

    test('computes on the live quantity', () {
      final seen = product('p1', quantity: 10);
      final live = product('p1', quantity: 12);
      final l = line(seen, quantity: 5);
      final result = plan([l], {'p1': live});

      expect(result.failed, isEmpty);
      expect(result.skipped, isEmpty);
      final planned = result.toApply.single;
      expect(identical(planned.product, live), isTrue);
      expect(planned.adjustment.oldStockArea, 12);
      expect(planned.adjustment.newStockArea, 17);
      final direct = computeLineAdjustment(live, l);
      expect(planned.adjustment.newStoredQuantity, direct.newStoredQuantity);
      expect(planned.adjustment.rpcQuantityChange, direct.rpcQuantityChange);
    });

    test('keeps the order of the lines', () {
      final a = product('a');
      final b = product('b');
      final c = product('c');
      final result = plan(
        [line(c, quantity: 1), line(a, quantity: 1), line(b, quantity: 1)],
        {'a': a, 'b': b, 'c': c},
      );
      expect(result.toApply.map((p) => p.product.uuid), ['c', 'a', 'b']);
    });

    test('missing item fails, the others still apply', () {
      final a = product('a', name: 'Apple');
      final b = product('b');
      final result = plan(
        [line(a, quantity: 1), line(b, quantity: 1)],
        {'b': b},
      );
      expect(result.failed, ['Apple: item no longer exists']);
      expect(result.toApply.map((p) => p.product.uuid), ['b']);
    });

    test('item now linked to storage is skipped', () {
      final a = product('a', name: 'Apple');
      final result = plan([line(a, quantity: 1)], {'a': a}, linked: {'a'});
      expect(result.skipped, ['Apple: linked to storage']);
      expect(result.toApply, isEmpty);
    });

    test('no change against the live item is skipped', () {
      final a = product('a', name: 'Apple', quantity: 10);
      final result = plan(
        [line(a, quantity: 10, isAdd: false)],
        {'a': a},
      );
      expect(result.skipped, ['Apple: no change']);
    });

    test('the same item twice is applied once', () {
      final a = product('a', name: 'Apple');
      final result = plan(
        [line(a, quantity: 1), line(a, quantity: 2)],
        {'a': a},
      );
      expect(result.toApply.length, 1);
      expect(result.toApply.single.line.enteredQuantity, 1);
      expect(result.skipped, ['Apple: listed more than once']);
    });

    test('a unit that no longer exists fails', () {
      final seen = product('a', name: 'Apple');
      final live = product('a', name: 'Apple', units: [each]);
      final result = plan(
        [line(seen, quantity: 1, unitUuid: caseUnit.uuid)],
        {'a': live},
      );
      expect(result.failed, ['Apple: selected unit no longer exists']);
    });

    test('custom dimensions too big for the live item fail', () {
      final seen = sheetItem('s');
      final live = product(
        's',
        name: seen.name,
        quantity: 4,
        units: [sheet, squareMeter],
        quantityType: 2,
        width: 1,
        height: 1,
      );
      final result = plan(
        [
          line(
            seen,
            quantity: 1,
            unitUuid: sheet.uuid,
            useCustomDimensions: true,
            width: 2,
            height: 1,
          ),
        ],
        {'s': live},
      );
      expect(result.failed, [
        '${seen.name}: Enter positive dimensions no larger than '
            'the original slab / sheet.',
      ]);
    });

    test('whole sheets on an item that lost its dimensions fail', () {
      final seen = sheetItem('s');
      final live = product(
        's',
        name: seen.name,
        units: [sheet, squareMeter],
        quantityType: 2,
      );
      final result = plan(
        [line(seen, quantity: 1, unitUuid: sheet.uuid)],
        {'s': live},
      );
      expect(result.failed, [
        '${seen.name}: Enter positive Width and Height for this item.',
      ]);
    });
  });
}

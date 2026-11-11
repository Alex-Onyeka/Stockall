import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/classes/temp_item_history/item_history_event_class.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/services/stock_adjustment_helper.dart';

const int testShopId = 42;

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
    productUuid: 'product-1',
    dimensionType: dimensionType,
  );
}

TempProductClass product({
  required double? quantity,
  required List<ProductUnitsClass> units,
  int quantityType = 1,
  double? width,
  double? height,
  double? dimensionUnitConversion,
  bool isManaged = true,
}) {
  return TempProductClass(
    uuid: 'product-1',
    name: 'Test Item',
    unit: units.first.name,
    isRefundable: false,
    costPrice: 0,
    shopId: testShopId,
    setCustomPrice: false,
    departmentName: null,
    departmentUuid: null,
    isManaged: isManaged,
    groupUnit: null,
    qttyPerGroup: null,
    wholeSalePrice: null,
    storageUuid: null,
    categories: null,
    useGroupUnit: false,
    unitsList: units,
    pricesList: null,
    widthDimension: width,
    heightDimension: height,
    quantityType: quantityType,
    manageSalesWastage: false,
    dimensionUnitConversion: dimensionUnitConversion,
    quantity: quantity,
  );
}

// 1D item: Each (primary) and Case = 12 Each.
final each = unit('unit-each', 'Each', 1, isPrimary: true);
final caseUnit = unit('unit-case', 'Case', 12);

TempProductClass oneD({double? quantity = 10, bool isManaged = true}) =>
    product(
      quantity: quantity,
      units: [each, caseUnit],
      isManaged: isManaged,
    );

// 2D item with dimensions: 2 x 3 sheet (area 6), Sheet is primary.
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

TempProductClass twoD({double quantity = 4}) => product(
  quantity: quantity,
  units: [sheet, squareMeter],
  quantityType: 2,
  width: 2,
  height: 3,
);

// 2D item without dimensions, Sheet unit only.
TempProductClass twoDNoDimensions({double quantity = 10}) => product(
  quantity: quantity,
  units: [sheet],
  quantityType: 2,
);

QuantityAdjustment compute(
  TempProductClass item, {
  String? unitUuid,
  required double entered,
  required bool isAdd,
  bool useCustomDimensions = false,
  double? width,
  double? height,
}) {
  return computeQuantityAdjustment(
    product: item,
    unitUuid: unitUuid,
    enteredQuantity: entered,
    isAddToQuantity: isAdd,
    useCustomDimensions: useCustomDimensions,
    customWidth: width,
    customHeight: height,
  );
}

ItemHistory history(
  TempProductClass item,
  QuantityAdjustment adjustment, {
  String? unitUuid,
  String? comment,
}) {
  return buildQuantityAdjustmentHistory(
    product: item,
    unitUuid: unitUuid,
    adjustment: adjustment,
    comment: comment,
    shopId: testShopId,
  );
}

void main() {
  group('1D items', () {
    test('Add to quantity increases stock', () {
      final item = oneD();
      final a = compute(item, entered: 5, isAdd: true);

      expect(a.oldStockArea, 10);
      expect(a.newStockArea, 15);
      expect(a.deltaArea, 5);
      expect(a.isIncrement, isTrue);
      expect(a.isNoChange, isFalse);
      expect(a.rpcQuantityChange, 5);
      expect(a.newStoredQuantity, 15);
    });

    test('Replace quantity can reduce stock', () {
      final item = oneD();
      final a = compute(item, entered: 4, isAdd: false);

      expect(a.newStockArea, 4);
      expect(a.deltaArea, 6);
      expect(a.isIncrement, isFalse);
      expect(a.rpcQuantityChange, 6);
      expect(a.newStoredQuantity, 4);
    });

    test('Replace with 0 empties stock', () {
      final a = compute(oneD(), entered: 0, isAdd: false);

      expect(a.newStockArea, 0);
      expect(a.newStoredQuantity, 0);
      expect(a.rpcQuantityChange, 10);
      expect(a.isIncrement, isFalse);
    });

    test('unset quantity is treated as 0', () {
      final a = compute(
        oneD(quantity: null),
        entered: 5,
        isAdd: true,
      );

      expect(a.oldStockArea, 0);
      expect(a.newStockArea, 5);
    });
  });

  group('multiple units (Case = 12)', () {
    test('Add 2 Case adds 24 Each', () {
      final item = oneD();
      final a = compute(
        item,
        unitUuid: caseUnit.uuid,
        entered: 2,
        isAdd: true,
      );

      expect(a.newStockArea, 34);
      expect(a.rpcQuantityChange, 24);
      expect(a.newStoredQuantity, 34);

      final h = history(item, a, unitUuid: caseUnit.uuid);
      expect(h.quantityChange, 2);
      expect(h.unit, 'Case');
      expect(h.primaryUnit, 'Each');
      expect(h.oldValue, formatLargeNumberDouble(10));
      expect(h.newValue, formatLargeNumberDouble(34));
    });

    test('Replace with 1 Case on 30 Each reduces by 1.5 Case', () {
      final item = oneD(quantity: 30);
      final a = compute(
        item,
        unitUuid: caseUnit.uuid,
        entered: 1,
        isAdd: false,
      );

      expect(a.newStockArea, 12);
      expect(a.rpcQuantityChange, 18);

      final h = history(item, a, unitUuid: caseUnit.uuid);
      expect(h.quantityChange, -1.5);
      expect(h.oldValue, formatLargeNumberDouble(30));
      expect(h.newValue, formatLargeNumberDouble(12));
    });
  });

  group('2D items with dimensions (2 x 3 sheet)', () {
    test('area unit: Add 6 square meters adds 1 sheet', () {
      final item = twoD();
      final a = compute(
        item,
        unitUuid: squareMeter.uuid,
        entered: 6,
        isAdd: true,
      );

      expect(a.oldStockArea, 24);
      expect(a.newStockArea, 30);
      expect(a.areaPerSheet, 6);
      expect(a.rpcQuantityChange, 1);
      expect(a.newStoredQuantity, 5);

      final h = history(item, a, unitUuid: squareMeter.uuid);
      expect(h.quantityChange, 6);
      expect(h.unit, 'Square Meter');
      expect(h.primaryUnit, 'Sheet');
      expect(h.oldValue, formatLargeNumberDouble(4));
      expect(h.newValue, formatLargeNumberDouble(5));
    });

    test('area unit: Replace with 12 square meters leaves 2 sheets', () {
      final item = twoD();
      final a = compute(
        item,
        unitUuid: squareMeter.uuid,
        entered: 12,
        isAdd: false,
      );

      expect(a.newStockArea, 12);
      expect(a.isIncrement, isFalse);
      expect(a.rpcQuantityChange, 2);
      expect(a.newStoredQuantity, 2);
      expect(history(item, a, unitUuid: squareMeter.uuid).quantityChange, -12);
    });

    test('whole sheets: Add 2 sheets uses the item dimensions', () {
      final item = twoD();
      final a = compute(
        item,
        unitUuid: sheet.uuid,
        entered: 2,
        isAdd: true,
        // Ignored: whole sheets use the item's own size.
        width: 1,
        height: 1,
      );

      expect(a.newStockArea, 36);
      expect(a.rpcQuantityChange, 2);
      expect(a.newStoredQuantity, 6);
      expect(history(item, a, unitUuid: sheet.uuid).quantityChange, 2);
    });

    test('custom dimensions: Add one 1 x 1.5 piece', () {
      final item = twoD();
      final a = compute(
        item,
        unitUuid: sheet.uuid,
        entered: 1,
        isAdd: true,
        useCustomDimensions: true,
        width: 1,
        height: 1.5,
      );

      expect(a.newStockArea, 25.5);
      expect(a.rpcQuantityChange, 0.25);
      expect(a.newStoredQuantity, 4.25);
      expect(history(item, a, unitUuid: sheet.uuid).quantityChange, 0.25);
    });

    test('dimension unit conversion (cm sheet, m2 area)', () {
      final item = product(
        quantity: 3,
        units: [sheet, squareMeter],
        quantityType: 2,
        width: 100,
        height: 200,
        dimensionUnitConversion: 10000,
      );
      final a = compute(
        item,
        unitUuid: sheet.uuid,
        entered: 1,
        isAdd: true,
      );

      expect(a.areaPerSheet, 2);
      expect(a.oldStockArea, 6);
      expect(a.newStockArea, 8);
      expect(a.rpcQuantityChange, 1);
      expect(a.newStoredQuantity, 4);
    });
  });

  group('2D sheet unit without item dimensions', () {
    test('custom dimensions are required and stock is stored as area', () {
      final item = twoDNoDimensions();
      final a = compute(
        item,
        unitUuid: sheet.uuid,
        entered: 2,
        isAdd: true,
        useCustomDimensions: true,
        width: 2,
        height: 3,
      );

      expect(a.oldStockArea, 10);
      expect(a.newStockArea, 22);
      expect(a.areaPerSheet, 1);
      expect(a.rpcQuantityChange, 12);
      expect(a.newStoredQuantity, 22);
    });

    test(
      'current behaviour: history values are 0 in a sheet unit '
      'when the item has no dimensions',
      () {
        final item = twoDNoDimensions();
        final a = compute(
          item,
          unitUuid: sheet.uuid,
          entered: 2,
          isAdd: true,
          useCustomDimensions: true,
          width: 2,
          height: 3,
        );
        final h = history(item, a, unitUuid: sheet.uuid);

        expect(h.quantityChange, 0);
        expect(h.oldValue, formatLargeNumberDouble(0));
        expect(h.newValue, formatLargeNumberDouble(0));
      },
    );
  });

  group('no-op detection', () {
    test('Replace with the current quantity is a no-op', () {
      expect(
        compute(oneD(), entered: 10, isAdd: false).isNoChange,
        isTrue,
      );
    });

    test('Add 0 is a no-op', () {
      expect(
        compute(oneD(), entered: 0, isAdd: true).isNoChange,
        isTrue,
      );
    });

    test('a difference below 1e-9 is a no-op', () {
      expect(
        compute(oneD(), entered: 10 + 1e-10, isAdd: false).isNoChange,
        isTrue,
      );
    });

    test('a real change is not a no-op', () {
      expect(
        compute(oneD(), entered: 10.001, isAdd: false).isNoChange,
        isFalse,
      );
    });
  });

  group('history fields', () {
    test('increase', () {
      final item = oneD();
      final a = compute(item, entered: 5, isAdd: true);
      final h = history(item, a, comment: 'Stock count');

      expect(h.title, 'Item Quantity Increased');
      expect(h.event, ItemHistoryEventClass.quantityUpdatedIncrease);
      expect(h.source, ItemHistoryEventClass.manualSource);
      expect(h.destination, ItemHistoryEventClass.productDestination);
      expect(h.isIncreased, isTrue);
      expect(h.quantityChange, 5);
      expect(h.oldValue, formatLargeNumberDouble(10));
      expect(h.newValue, formatLargeNumberDouble(15));
      expect(h.unit, 'Each');
      expect(h.primaryUnit, 'Each');
      expect(h.isManaged, isTrue);
      expect(h.desc, 'Stock count');
      expect(h.shopId, testShopId);
    });

    test('decrease', () {
      final item = oneD();
      final a = compute(item, entered: 4, isAdd: false);
      final h = history(item, a);

      expect(h.title, 'Item Quantity Reduced');
      expect(h.event, ItemHistoryEventClass.quantityUpdatedDecrease);
      expect(h.source, ItemHistoryEventClass.productSource);
      expect(h.destination, ItemHistoryEventClass.manualDestination);
      expect(h.isIncreased, isFalse);
      expect(h.quantityChange, -6);
      expect(h.oldValue, formatLargeNumberDouble(10));
      expect(h.newValue, formatLargeNumberDouble(4));
    });

    test('empty or missing comment uses the default text', () {
      final item = oneD();
      final a = compute(item, entered: 5, isAdd: true);

      expect(history(item, a, comment: '').desc, defaultQuantityAdjustmentDesc);
      expect(history(item, a).desc, defaultQuantityAdjustmentDesc);
      expect(defaultQuantityAdjustmentDesc, 'This Item Quantity Was Updated.');
    });

    test('unmanaged items keep isManaged false', () {
      final item = oneD(quantity: null, isManaged: false);
      final a = compute(item, entered: 5, isAdd: true);

      expect(history(item, a).isManaged, isFalse);
    });
  });

  group('drift guard: single edit dialog before and after refactor', () {
    final samples = <String, _DialogInput>{
      '1D add': _DialogInput(oneD(), quantityText: '5', isAdd: true),
      '1D replace': _DialogInput(oneD(), quantityText: '4', isAdd: false),
      '1D replace empty': _DialogInput(oneD(), quantityText: '', isAdd: false),
      '1D add with comment': _DialogInput(
        oneD(),
        quantityText: '1,250',
        isAdd: true,
        comment: 'Recount',
      ),
      'multi-unit add Case': _DialogInput(
        oneD(),
        unitUuid: caseUnit.uuid,
        quantityText: '2',
        isAdd: true,
      ),
      'multi-unit replace Case': _DialogInput(
        oneD(quantity: 30),
        unitUuid: caseUnit.uuid,
        quantityText: '1',
        isAdd: false,
      ),
      'unmanaged, unset quantity': _DialogInput(
        oneD(quantity: null, isManaged: false),
        quantityText: '3',
        isAdd: true,
      ),
      '2D area unit add': _DialogInput(
        twoD(),
        unitUuid: squareMeter.uuid,
        quantityText: '6',
        isAdd: true,
      ),
      '2D area unit replace': _DialogInput(
        twoD(),
        unitUuid: squareMeter.uuid,
        quantityText: '12',
        isAdd: false,
      ),
      '2D whole sheets': _DialogInput(
        twoD(),
        unitUuid: sheet.uuid,
        quantityText: '2',
        isAdd: true,
        quantityTypeTemp: 1,
      ),
      '2D custom dimensions': _DialogInput(
        twoD(),
        unitUuid: sheet.uuid,
        quantityText: '1',
        isAdd: true,
        quantityTypeTemp: 2,
        widthText: '1',
        heightText: '1.5',
      ),
      '2D custom dimensions replace': _DialogInput(
        twoD(),
        unitUuid: sheet.uuid,
        quantityText: '3',
        isAdd: false,
        quantityTypeTemp: 2,
        widthText: '2',
        heightText: '1',
      ),
      '2D no dimensions': _DialogInput(
        twoDNoDimensions(),
        unitUuid: sheet.uuid,
        quantityText: '2',
        isAdd: true,
        widthText: '2',
        heightText: '3',
      ),
    };

    samples.forEach((name, input) {
      test(name, () {
        final legacy = _legacySingleEdit(input);
        final current = _refactoredSingleEdit(input);

        expect(current.isNoChange, legacy.isNoChange);
        if (legacy.isNoChange) return;

        expect(current.isIncrement, legacy.isIncrement);
        expect(current.rpcQuantityChange, legacy.rpcQuantityChange);
        expect(current.storedQuantity, legacy.storedQuantity);
        _expectSameHistory(current.history!, legacy.history!);
      });
    });
  });
}

/// The inputs the "Edit Unit Qtty" dialog state holds.
class _DialogInput {
  final TempProductClass product;
  final String? unitUuid;
  final String quantityText;
  final bool isAdd;
  final int quantityTypeTemp;
  final String widthText;
  final String heightText;
  final String comment;

  _DialogInput(
    this.product, {
    this.unitUuid,
    required this.quantityText,
    required this.isAdd,
    this.quantityTypeTemp = 1,
    this.widthText = '',
    this.heightText = '',
    this.comment = '',
  });
}

class _DialogOutput {
  final bool isNoChange;
  final bool isIncrement;
  final double rpcQuantityChange;
  final double storedQuantity;
  final ItemHistory? history;

  _DialogOutput({
    required this.isNoChange,
    required this.isIncrement,
    required this.rpcQuantityChange,
    required this.storedQuantity,
    required this.history,
  });
}

/// The dialog's call site after the refactor
/// (update_item_quantity.dart).
_DialogOutput _refactoredSingleEdit(_DialogInput input) {
  final enteredQuantity = double.tryParse(
    input.quantityText.replaceAll(',', '').trim(),
  );
  final adjustment = computeQuantityAdjustment(
    product: input.product,
    unitUuid: input.unitUuid,
    enteredQuantity: enteredQuantity ?? 0,
    isAddToQuantity: input.isAdd,
    useCustomDimensions:
        input.quantityTypeTemp == 2 || !input.product.hasDimensions,
    customWidth: double.tryParse(
      input.widthText.replaceAll(',', '').trim(),
    ),
    customHeight: double.tryParse(
      input.heightText.replaceAll(',', '').trim(),
    ),
  );
  if (adjustment.isNoChange) {
    return _DialogOutput(
      isNoChange: true,
      isIncrement: false,
      rpcQuantityChange: 0,
      storedQuantity: 0,
      history: null,
    );
  }
  return _DialogOutput(
    isNoChange: false,
    isIncrement: adjustment.isIncrement,
    rpcQuantityChange: adjustment.rpcQuantityChange,
    storedQuantity: adjustment.newStoredQuantity,
    history: buildQuantityAdjustmentHistory(
      product: input.product,
      unitUuid: input.unitUuid,
      adjustment: adjustment,
      comment: input.comment,
      shopId: testShopId,
    ),
  );
}

/// Frozen copy of the dialog's computation before the refactor
/// (update_item_quantity.dart at commit b940ed4a: quantityInArea,
/// setQuantity, the delta / rpc / stored quantity expressions and
/// the ItemHistory). Only `widget.product`, the controllers and
/// `shopId()` were replaced by [input] fields. Do not "fix" this
/// copy: it is the reference the helper must keep matching.
_DialogOutput _legacySingleEdit(_DialogInput input) {
  final product = input.product;
  final unitUuid = input.unitUuid;
  final isAddToQuantity = input.isAdd;
  final quantityTypeTemp = input.quantityTypeTemp;

  ProductUnitsClass selectedUnit() =>
      product.getProductUnit(unitUuid: unitUuid);

  bool isAreaUnit() =>
      product.quantityType == 2 && selectedUnit().isAreaUnit;

  final itemHasDimensions = product.hasDimensions;

  double quantityInArea(double quantity) {
    final isDimensionalSheet =
        product.quantityType == 2 && !isAreaUnit();
    final useCustomDimensions =
        quantityTypeTemp == 2 || !itemHasDimensions;
    return selectedUnit().getQuantityEquivMultiplied(
      index: 1,
      product: product,
      newQuantity: quantity,
      customWidth:
          isDimensionalSheet
              ? useCustomDimensions
                  ? double.tryParse(
                    input.widthText.replaceAll(',', '').trim(),
                  )
                  : product.widthDimension
              : null,
      customHeight:
          isDimensionalSheet
              ? useCustomDimensions
                  ? double.tryParse(
                    input.heightText.replaceAll(',', '').trim(),
                  )
                  : product.heightDimension
              : null,
    );
  }

  final quantityText = input.quantityText.replaceAll(',', '').trim();
  final enteredQuantity = double.tryParse(quantityText);

  double setQuantity() {
    if (isAddToQuantity) {
      return (product.getActualQuantity() ?? 0) +
          quantityInArea(enteredQuantity ?? 0);
    } else {
      return quantityInArea(enteredQuantity ?? 0);
    }
  }

  final oldStockArea = product.getActualQuantity() ?? 0;
  final newStockArea = setQuantity();
  final deltaArea = (newStockArea - oldStockArea).abs();

  if (deltaArea < 1e-9) {
    return _DialogOutput(
      isNoChange: true,
      isIncrement: false,
      rpcQuantityChange: 0,
      storedQuantity: 0,
      history: null,
    );
  }

  final bool isIncrement = newStockArea >= oldStockArea;
  final double areaPerSheet = product.dimensionArea();
  final double rpcQuantityChange =
      (product.quantityType == 2 &&
              product.hasDimensions &&
              areaPerSheet > 0)
          ? (deltaArea / areaPerSheet)
          : deltaArea;

  ItemHistory itemHistory = ItemHistory(
    primaryUnit: product.getProductUnit().name,
    unit: product.getProductUnit(unitUuid: unitUuid).name,
    shopId: testShopId,
    title: 'Item Quantity ${isIncrement ? "Increased" : 'Reduced'}',
    quantityChange: product
        .getProductUnit(unitUuid: unitUuid)
        .getQuantityEquivDivided(
          index: 1,
          newQuantity: (newStockArea - oldStockArea),
          product: product,
        ),
    event:
        isIncrement
            ? ItemHistoryEventClass.quantityUpdatedIncrease
            : ItemHistoryEventClass.quantityUpdatedDecrease,
    isManaged: product.isManaged,
    source:
        isIncrement
            ? ItemHistoryEventClass.manualSource
            : ItemHistoryEventClass.productSource,
    destination:
        isIncrement
            ? ItemHistoryEventClass.productDestination
            : ItemHistoryEventClass.manualDestination,
    newValue: formatLargeNumberDouble(
      product.getProductUnit().getQuantityEquivDivided(
        index: 1,
        newQuantity: newStockArea,
        product: product,
      ),
    ),
    desc:
        input.comment.isNotEmpty
            ? input.comment
            : 'This Item Quantity Was Updated.',
    isIncreased: isIncrement,
    oldValue: formatLargeNumberDouble(
      product.getProductUnit().getQuantityEquivDivided(
        index: 1,
        newQuantity: oldStockArea,
        product: product,
      ),
    ),
  );

  final storedQuantity =
      product.quantityType == 2
          ? (product.hasDimensions && areaPerSheet > 0
              ? newStockArea / areaPerSheet
              : newStockArea)
          : newStockArea;

  return _DialogOutput(
    isNoChange: false,
    isIncrement: isIncrement,
    rpcQuantityChange: rpcQuantityChange,
    storedQuantity: storedQuantity,
    history: itemHistory,
  );
}

void _expectSameHistory(ItemHistory actual, ItemHistory expected) {
  expect(actual.title, expected.title);
  expect(actual.event, expected.event);
  expect(actual.source, expected.source);
  expect(actual.destination, expected.destination);
  expect(actual.isIncreased, expected.isIncreased);
  expect(actual.quantityChange, expected.quantityChange);
  expect(actual.oldValue, expected.oldValue);
  expect(actual.newValue, expected.newValue);
  expect(actual.unit, expected.unit);
  expect(actual.primaryUnit, expected.primaryUnit);
  expect(actual.isManaged, expected.isManaged);
  expect(actual.desc, expected.desc);
  expect(actual.shopId, expected.shopId);
}

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_storage_product/storage_transfer.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';

ProductUnitsClass unit(
  String uuid, {
  double conversion = 1,
  int? dimensionType,
  bool isPrimary = true,
}) {
  return ProductUnitsClass(
    uuid: uuid,
    staffUuid: null,
    createdAt: DateTime.utc(2026),
    staffName: null,
    conversion: conversion,
    name: uuid,
    isPrimary: isPrimary,
    productUuid: 'storage-1',
    dimensionType: dimensionType,
  );
}

TempStorageProducts storageItem({
  String uuid = 'storage-1',
  double? quantity,
  int? quantityType = 2,
  double? width = 2,
  double? height = 3,
}) {
  return TempStorageProducts(
    uuid: uuid,
    shopId: 1,
    name: 'Glass Store',
    quantity: quantity,
    costPrice: null,
    sellingPrice: null,
    useGroupUnit: false,
    unitsList: [
      unit('sheet', dimensionType: ProductUnitsClass.sheetUnit),
    ],
    quantityType: quantityType,
    widthDimension: width,
    heightDimension: height,
  );
}

TempProductClass salesItem({
  String uuid = 'sales-1',
  double? quantity = 0,
  int quantityType = 2,
  double? width = 1,
  double? height = 2,
  String? storageUuid = 'storage-1',
}) {
  return TempProductClass(
    name: 'Glass $uuid',
    shopId: 1,
    unit: 'Sheet',
    isRefundable: false,
    costPrice: 0,
    setCustomPrice: false,
    departmentName: null,
    departmentUuid: null,
    isManaged: true,
    groupUnit: null,
    qttyPerGroup: null,
    wholeSalePrice: null,
    storageUuid: storageUuid,
    categories: [],
    useGroupUnit: false,
    unitsList: [],
    pricesList: [],
    uuid: uuid,
    quantity: quantity,
    quantityType: quantityType,
    widthDimension: width,
    heightDimension: height,
    manageSalesWastage: false,
  );
}

void main() {
  group('2D storage stock maths', () {
    test('stock is a sheet count; actual quantity is area', () {
      final storage = storageItem(quantity: 10);

      expect(storage.dimensionArea(), 6);
      expect(storage.getActualQuantity(), 60);
      expect(storage.quantityAfterRemoving(6), 9);
    });

    test('missing or zero size counts as 1', () {
      expect(storageItem(width: null).dimensionArea(), 3);
      expect(
        storageItem(width: null, height: null).dimensionArea(),
        1,
      );
      expect(storageItem(width: 0).dimensionArea(), 1);
    });

    test('1D storage is unchanged', () {
      final storage = storageItem(
        quantity: 10,
        quantityType: 1,
      );

      expect(storage.dimensionArea(), 1);
      expect(storage.getActualQuantity(), 10);
      expect(storage.quantityAfterRemoving(4), 6);
      expect(
        storageItem(quantity: 7, quantityType: null)
            .getActualQuantity(),
        7,
      );
    });

    test('actualFromUnit: sheet, area and 1D units', () {
      final storage = storageItem();
      final sheet = unit(
        'sheet',
        dimensionType: ProductUnitsClass.sheetUnit,
      );
      final packOf2 = unit(
        'pack',
        conversion: 2,
        dimensionType: ProductUnitsClass.sheetUnit,
      );
      final squareMetre = unit(
        'm2',
        dimensionType: ProductUnitsClass.areaUnit,
      );
      final dozen = unit('dozen', conversion: 12);

      expect(storage.actualFromUnit(sheet, 3), 18);
      expect(storage.actualFromUnit(packOf2, 1), 12);
      expect(storage.actualFromUnit(squareMetre, 5), 5);
      expect(
        storageItem(quantityType: 1).actualFromUnit(dozen, 2),
        24,
      );
      expect(storage.unitFromActual(sheet, 18), 3);
    });

    test('JSON round-trip keeps type and size', () {
      // Through jsonEncode, as the Supabase client sends it.
      final restored = TempStorageProducts.fromJson(
        jsonDecode(jsonEncode(storageItem(quantity: 4).toJson()))
            as Map<String, dynamic>,
      );

      expect(restored.quantityType, 2);
      expect(restored.widthDimension, 2);
      expect(restored.heightDimension, 3);
      expect(restored.getActualQuantity(), 24);
    });

    test('old JSON without the new columns is 1D', () {
      final legacy = TempStorageProducts.fromJson({
        'uuid': 'old',
        'shop_id': 1,
        'name': 'Old Store',
        'quantity': 5,
      });

      expect(legacy.quantityType, 1);
      expect(legacy.isDimensional(), isFalse);
      expect(legacy.getActualQuantity(), 5);
    });

    test('copyWith keeps type and size', () {
      final copy = storageItem(quantity: 1).copyWith(quantity: 2);

      expect(copy.quantityType, 2);
      expect(copy.widthDimension, 2);
      expect(copy.heightDimension, 3);
    });
  });

  group('transfers', () {
    test('2D to 2D, same sheet size', () {
      final result = computeStorageTransfer(
        mode: StorageTransferMode.stockOut,
        storage: storageItem(quantity: 10),
        sales: salesItem(width: 2, height: 3),
        actualAmount: 6,
      );

      expect(result.storageQuantity, 9);
      expect(result.storageChange, -1);
      expect(result.salesQuantity, 1);
      expect(result.salesChange, 1);
    });

    test('different sheet sizes keep the area on both sides', () {
      final toSmaller = computeStorageTransfer(
        mode: StorageTransferMode.stockOut,
        storage: storageItem(quantity: 10),
        sales: salesItem(width: 1, height: 2),
        actualAmount: 6,
      );
      expect(toSmaller.storageQuantity, 9);
      expect(toSmaller.salesQuantity, 3);
      expect(toSmaller.salesChange, 3);

      final toLarger = computeStorageTransfer(
        mode: StorageTransferMode.stockOut,
        storage: storageItem(quantity: 10),
        sales: salesItem(width: 4, height: 4),
        actualAmount: 6,
      );
      expect(toLarger.salesQuantity, 0.375);
    });

    test('return from sales to storage', () {
      final result = computeStorageTransfer(
        mode: StorageTransferMode.stockIn,
        storage: storageItem(quantity: 9),
        sales: salesItem(quantity: 3, width: 1, height: 2),
        actualAmount: 2,
      );

      expect(result.salesQuantity, 2);
      expect(result.salesChange, -1);
      expect(result.storageQuantity, closeTo(9.3333, 1e-4));
      expect(result.storageChange, closeTo(0.3333, 1e-4));
    });

    test('1D to 1D is plain arithmetic', () {
      final storage = storageItem(
        quantity: 100,
        quantityType: 1,
      );
      final sales = salesItem(quantity: 5, quantityType: 1);

      final out = computeStorageTransfer(
        mode: StorageTransferMode.stockOut,
        storage: storage,
        sales: sales,
        actualAmount: 12,
      );
      expect(out.storageQuantity, 88);
      expect(out.salesQuantity, 17);
      expect(out.salesChange, 12);

      final back = computeStorageTransfer(
        mode: StorageTransferMode.stockIn,
        storage: storage,
        sales: sales,
        actualAmount: 5,
      );
      expect(back.storageQuantity, 105);
      expect(back.salesQuantity, 0);
    });

    test('stock-in without a sales item and update', () {
      final stockIn = computeStorageTransfer(
        mode: StorageTransferMode.stockIn,
        storage: storageItem(quantity: 10),
        actualAmount: 12,
      );
      expect(stockIn.storageQuantity, 12);
      expect(stockIn.salesQuantity, isNull);
      expect(stockIn.salesChange, isNull);

      final update = computeStorageTransfer(
        mode: StorageTransferMode.update,
        storage: storageItem(quantity: 10),
        sales: salesItem(width: 2, height: 3),
        actualAmount: 30,
      );
      expect(update.storageQuantity, 5);
      expect(update.salesQuantity, isNull);
    });
  });

  group('transfer blocking', () {
    test('storageCanManage only matches the same type', () {
      expect(
        storageCanManage(storageItem(), salesItem()),
        isTrue,
      );
      expect(
        storageCanManage(
          storageItem(quantityType: 1),
          salesItem(quantityType: 1),
        ),
        isTrue,
      );
      expect(
        storageCanManage(
          storageItem(quantityType: null),
          salesItem(quantityType: 1),
        ),
        isTrue,
      );
      expect(
        storageCanManage(
          storageItem(quantityType: 1),
          salesItem(quantityType: 2),
        ),
        isFalse,
      );
      expect(
        storageCanManage(
          storageItem(quantityType: 2),
          salesItem(quantityType: 1),
        ),
        isFalse,
      );
    });

    test('mismatched transfers throw in both directions', () {
      for (final mode in [
        StorageTransferMode.stockIn,
        StorageTransferMode.stockOut,
      ]) {
        expect(
          () => computeStorageTransfer(
            mode: mode,
            storage: storageItem(quantityType: 1, quantity: 10),
            sales: salesItem(quantityType: 2, quantity: 5),
            actualAmount: 1,
          ),
          throwsA(isA<StorageTypeMismatch>()),
        );
        expect(
          () => computeStorageTransfer(
            mode: mode,
            storage: storageItem(quantityType: 2, quantity: 10),
            sales: salesItem(quantityType: 1, quantity: 5),
            actualAmount: 1,
          ),
          throwsA(isA<StorageTypeMismatch>()),
        );
      }
    });
  });

  test('Manage Products lists only compatible items', () {
    final storage = storageItem();
    final products = [
      salesItem(uuid: 'unlinked-2d', storageUuid: null),
      salesItem(
        uuid: 'unlinked-1d',
        quantityType: 1,
        storageUuid: null,
      ),
      salesItem(uuid: 'linked-2d'),
      salesItem(uuid: 'linked-mismatch', quantityType: 1),
      salesItem(uuid: 'other-storage', storageUuid: 'storage-2'),
    ];

    final listed = manageableProducts(
      storage: storage,
      products: products,
    ).map((p) => p.uuid);

    expect(listed, ['unlinked-2d', 'linked-2d', 'linked-mismatch']);
  });

  group('changing a storage item type', () {
    test('same type is always allowed', () {
      expect(
        canChangeStorageType(
          storage: storageItem(quantity: 10),
          managedProducts: [salesItem()],
          newQuantityType: 2,
        ),
        isTrue,
      );
    });

    test('blocked while it has stock', () {
      expect(
        canChangeStorageType(
          storage: storageItem(quantity: 10, quantityType: 1),
          managedProducts: [],
          newQuantityType: 2,
        ),
        isFalse,
      );
    });

    test('allowed at 0 stock when all managed items match', () {
      expect(
        canChangeStorageType(
          storage: storageItem(quantity: 0, quantityType: 1),
          managedProducts: [salesItem(), salesItem(uuid: 'b')],
          newQuantityType: 2,
        ),
        isTrue,
      );
      expect(
        canChangeStorageType(
          storage: storageItem(quantity: null, quantityType: 1),
          managedProducts: [],
          newQuantityType: 2,
        ),
        isTrue,
      );
    });

    test('blocked when a managed item has the old type', () {
      expect(
        canChangeStorageType(
          storage: storageItem(quantity: 0, quantityType: 1),
          managedProducts: [
            salesItem(),
            salesItem(uuid: 'b', quantityType: 1),
          ],
          newQuantityType: 2,
        ),
        isFalse,
      );
    });
  });
}

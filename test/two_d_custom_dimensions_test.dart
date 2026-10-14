import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_cart/temp_cart.dart';
import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';
import 'package:stockall/classes/temp_drafts/draft_items.dart';
import 'package:stockall/classes/temp_main_cart/temp_main_cart.dart';
import 'package:stockall/classes/temp_orders/order_items.dart';
import 'package:stockall/classes/temp_product_class/prices_class/product_prices_class.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/providers/data_provider.dart';
import 'package:stockall/providers/invoices_provider.dart';
import 'package:stockall/providers/sales_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MemoryAsyncStorage extends GotrueAsyncStorage {
  final _items = <String, String>{};

  @override
  Future<String?> getItem({required String key}) async =>
      _items[key];

  @override
  Future<void> setItem({
    required String key,
    required String value,
  }) async => _items[key] = value;

  @override
  Future<void> removeItem({required String key}) async =>
      _items.remove(key);
}

// A 4 × 3 sheet item, priced ₦100 per square unit, 10 sheets in
// stock (120 square units).
void main() {
  const productUuid = 'sheet-1';

  final unit = ProductUnitsClass(
    uuid: 'unit-sq',
    staffUuid: null,
    createdAt: DateTime.utc(2026),
    staffName: null,
    conversion: 1,
    name: 'Sq Unit',
    isPrimary: true,
    productUuid: productUuid,
  );

  final areaUnit = ProductUnitsClass(
    uuid: 'unit-area',
    staffUuid: null,
    createdAt: DateTime.utc(2026),
    staffName: null,
    conversion: 1,
    name: 'Square metre',
    isPrimary: true,
    productUuid: productUuid,
    dimensionType: ProductUnitsClass.areaUnit,
  );

  final sheetUnit = ProductUnitsClass(
    uuid: 'unit-sheet',
    staffUuid: null,
    createdAt: DateTime.utc(2026),
    staffName: null,
    conversion: 1,
    name: 'Sheet',
    isPrimary: false,
    productUuid: productUuid,
    dimensionType: ProductUnitsClass.sheetUnit,
  );

  final price = ProductPricesClass(
    uuid: 'price-1',
    staffUuid: null,
    createdAt: DateTime.utc(2026),
    staffName: null,
    priceValue: 100,
    name: 'Price',
    isPrimary: true,
    itemUuid: productUuid,
  );

  TempProductClass buildSheet({double quantity = 10}) {
    return TempProductClass(
      uuid: productUuid,
      name: 'Glass',
      shopId: 1,
      unit: 'Sq Unit',
      isRefundable: false,
      costPrice: 0,
      sellingPrice: 100,
      quantity: quantity,
      setCustomPrice: false,
      departmentName: null,
      departmentUuid: null,
      isManaged: true,
      groupUnit: null,
      qttyPerGroup: null,
      wholeSalePrice: null,
      storageUuid: null,
      categories: [],
      useGroupUnit: false,
      unitsList: [unit],
      pricesList: [price],
      widthDimension: 4,
      heightDimension: 3,
      quantityType: 2,
      manageSalesWastage: true,
    );
  }

  TempCartItem buildLine({
    required double quantity,
    required double? width,
    required double? height,
    String? uuid = 'line-1',
  }) {
    return TempCartItem(
      item: buildSheet(),
      itemUuid: productUuid,
      quantity: quantity,
      discount: null,
      addToStock: false,
      setTotalPrice: false,
      useWholeSalePrice: false,
      useGroupQuantity: false,
      qttyPerGroup: null,
      isVoid: false,
      uuid: uuid,
      unitUuid: unit.uuid,
      priceUuid: price.uuid,
      widthDimension: width,
      heightDimension: height,
      quantityType: 2,
      manageSalesWastage: null,
      isPercentageWastage: null,
      wastageAmount: null,
    );
  }

  TempCartItem buildConfiguredLine({
    required ProductUnitsClass selectedUnit,
    required double quantity,
    double? width,
    double? height,
  }) {
    final product = buildSheet()
      ..unitsList = [areaUnit, sheetUnit];
    return TempCartItem(
      item: product,
      itemUuid: productUuid,
      quantity: quantity,
      discount: null,
      addToStock: false,
      setTotalPrice: false,
      useWholeSalePrice: false,
      useGroupQuantity: false,
      qttyPerGroup: null,
      isVoid: false,
      uuid: 'configured-line',
      unitUuid: selectedUnit.uuid,
      priceUuid: price.uuid,
      widthDimension: width,
      heightDimension: height,
      quantityType: 2,
      manageSalesWastage: null,
      isPercentageWastage: null,
      wastageAmount: null,
    );
  }

  OrderItems buildOrderLine({
    required double quantity,
    required double? width,
    required double? height,
  }) {
    return OrderItems(
      uuid: 'order-line-1',
      orderId: 'order-1',
      productName: 'Glass',
      productUuid: productUuid,
      createdAt: DateTime.utc(2026),
      staffName: 'Staff',
      staffId: 'staff-1',
      costPrice: null,
      customerName: null,
      customerUuid: null,
      departmentName: null,
      departmentUuid: null,
      qttyPerGroup: null,
      quantity: quantity,
      revenue: 100,
      unit: 'Sq Unit',
      useGroupQuantity: false,
      useWholeSalePrice: false,
      groupUnit: null,
      addToStock: false,
      customPriceSet: false,
      discount: null,
      discountedAmount: null,
      fixedDiscount: null,
      isProductManaged: true,
      originalCost: 100,
      setTotalPrice: false,
      remainingQuantity: quantity,
      originalUseGroupQuantity: false,
      tempUseGroupQuantity: false,
      unitsList: [unit],
      unitUuid: unit.uuid,
      pricesList: [price],
      priceUuid: price.uuid,
      widthDimension: width,
      heightDimension: height,
      quantityType: 2,
      manageSalesWastage: null,
      isPercentageWastage: null,
      wastageAmount: null,
    );
  }

  TempCart buildCart(List<TempCartItem> items) {
    return TempCart(
      cartItems: items,
      tempCartItems: null,
      id: 'cart-1',
      staffName: 'Staff',
      staffId: 'staff-1',
      departmentName: null,
      departmentUuid: null,
      customDate: null,
      hasPrintedDocket: false,
      subStaffName: null,
      timeOfDay: null,
      comment: null,
      cartItemTypeIndex: 1,
      orderUuidEdit: null,
    );
  }

  setUpAll(() async {
    // DataProvider and SalesProvider read Supabase.instance when
    // constructed. Dummy client: no session storage, no network.
    TestWidgetsFlutterBinding.ensureInitialized();
    await Supabase.initialize(
      url: 'http://localhost',
      anonKey: 'test-anon-key',
      authOptions: FlutterAuthClientOptions(
        localStorage: const EmptyLocalStorage(),
        pkceAsyncStorage: _MemoryAsyncStorage(),
        detectSessionInUri: false,
        autoRefreshToken: false,
      ),
    );
  });

  setUp(() {
    // getRealQuantity looks the product up in the main list.
    DataProvider().productListMain = [buildSheet()];
    SalesProvider().mainCartQueue = [];
  });

  group('calculation', () {
    test('scales a quantity by custom width × height', () {
      expect(
        unit.getQuantityEquivMultiplied(
          index: 1,
          product: buildSheet(),
          newQuantity: 2,
          customWidth: 2,
          customHeight: 1.5,
        ),
        6,
      );
    });

    test('is unchanged without dimensions or with only one', () {
      for (final dims in [
        [null, null],
        [2.0, null],
        [null, 1.5],
      ]) {
        expect(
          unit.getQuantityEquivMultiplied(
            index: 1,
            product: buildSheet(),
            newQuantity: 2,
            customWidth: dims[0],
            customHeight: dims[1],
          ),
          2,
        );
      }
    });
  });

  group('cart line pricing and stock amount', () {
    test('whole mode: 1 sheet at full 4 × 3 → ₦1,200, 12 area', () {
      final line = buildLine(quantity: 1, width: 4, height: 3);
      expect(line.totalCost(), 1200);
      expect(line.getRealQuantity(), 12);
    });

    test('dimension mode: 2 × 1.5 → ₦300 each, 3 area each', () {
      final one = buildLine(quantity: 1, width: 2, height: 1.5);
      expect(one.totalCost(), 300);
      expect(one.getRealQuantity(), 3);

      final two = buildLine(quantity: 2, width: 2, height: 1.5);
      expect(two.totalCost(), 600);
      expect(two.getRealQuantity(), 6);
    });

    test('area unit quantity converts directly to area and price', () {
      final line = buildConfiguredLine(
        selectedUnit: areaUnit,
        quantity: 4,
      );

      expect(line.getRealQuantity(), 4);
      expect(line.totalCost(), 400);
      expect(
        line.item.quantityAfterRemoving(line.getRealQuantity()),
        closeTo(9.6666667, 0.000001),
      );
      expect(line.widthDimension, isNull);
      expect(line.heightDimension, isNull);
    });

    test('sheet and custom-size units convert to area for pricing', () {
      final wholeSheets = buildConfiguredLine(
        selectedUnit: sheetUnit,
        quantity: 2,
      );
      final customPieces = buildConfiguredLine(
        selectedUnit: sheetUnit,
        quantity: 2,
        width: 2,
        height: 1.5,
      );

      expect(wholeSheets.getRealQuantity(), 24);
      expect(wholeSheets.totalCost(), 2400);
      expect(customPieces.getRealQuantity(), 6);
      expect(customPieces.totalCost(), 600);
    });

    test('legacy line without dimensions prices as before', () {
      final line = buildLine(
        quantity: 3,
        width: null,
        height: null,
      );
      expect(line.totalCost(), 300);
      expect(line.getRealQuantity(), 3);
    });

    test('direct adds (barcode) default to the full sheet', () {
      final line = buildLine(
        quantity: 1,
        width: null,
        height: null,
      );
      SalesProvider().applyDefaultDimensions(line);
      expect(line.widthDimension, 4);
      expect(line.heightDimension, 3);
      expect(line.totalCost(), 1200);
    });

    test('dimensionsLabel is empty without dimensions', () {
      expect(
        buildLine(
          quantity: 1,
          width: null,
          height: null,
        ).dimensionsLabel(),
        '',
      );
      expect(
        buildLine(
          quantity: 1,
          width: 2,
          height: 1.5,
        ).dimensionsLabel(),
        ' (2 x 1.5)',
      );
      expect(
        buildLine(
          quantity: 1,
          width: 4,
          height: 3,
        ).dimensionsLabel(),
        ' (4 x 3)',
      );
    });
  });

  group('stock write-back (sheet count)', () {
    test('checkout: selling 3 area leaves 9.75 sheets', () {
      final product = buildSheet();
      final line = buildLine(quantity: 1, width: 2, height: 1.5);
      // Same expressions as checkoutMain's deduction block.
      expect(
        product.quantityAfterRemoving(line.getRealQuantity()),
        9.75,
      );
      expect(
        line.getRealQuantity() / product.dimensionArea(),
        0.25,
      );
    });

    test('order delivery: 1 whole sheet → 9 sheets, update of 1', () {
      final product = buildSheet();
      final delivered = buildOrderLine(
        quantity: 1,
        width: 4,
        height: 3,
      );
      // Same expressions as makeOrderItemDelivery.
      final quantityChange =
          delivered.getActualQuantityDuringDeliveryCheckout();
      expect(quantityChange, 12);
      expect(product.quantityAfterRemoving(quantityChange), 9);
      expect(quantityChange / product.dimensionArea(), 1);
    });

    test('non-2D items are unchanged', () {
      final product = buildSheet()..quantityType = 1;
      expect(product.dimensionArea(), 1);
      expect(product.quantityAfterRemoving(3), 7);
    });
  });

  group('order lines', () {
    test('totals use the line area and round-trip', () {
      final line = buildOrderLine(
        quantity: 2,
        width: 2,
        height: 1.5,
      );
      expect(line.getActualQuantity(), 6);
      expect(line.getTotalRevenue(), 600);
      expect(line.getQuantityFromPrimaryUnits(6), 2);
      expect(line.dimensionsLabel(), ' (2 x 1.5)');
    });

    test('legacy order line without dimensions is unchanged', () {
      final line = buildOrderLine(
        quantity: 2,
        width: null,
        height: null,
      );
      expect(line.getActualQuantity(), 2);
      expect(line.getTotalRevenue(), 200);
      expect(line.getQuantityFromPrimaryUnits(2), 2);
      expect(line.dimensionsLabel(), '');
    });
  });

  group('totalInAllCarts while editing (two sizes in one cart)', () {
    test('editing one size still counts the other', () {
      final lineA = buildLine(
        quantity: 1,
        width: 2,
        height: 1.5,
        uuid: 'line-a',
      ); // 3 area
      final lineB = buildLine(
        quantity: 1,
        width: 4,
        height: 3,
        uuid: 'line-b',
      ); // 12 area
      SalesProvider().mainCartQueue = [
        TempMainCart(
          cartQueue: [
            buildCart([lineA, lineB]),
          ],
          mainCartId: 'main-1',
        ),
      ];

      expect(
        SalesProvider().totalInAllCarts(
          newCartItem: lineA.copyWith(),
          isEdit: true,
        ),
        12,
      );
      expect(
        SalesProvider().totalInAllCarts(
          newCartItem: lineB.copyWith(),
          isEdit: true,
        ),
        3,
      );
    });

    test('a line without uuid keeps the skip-by-item behavior', () {
      final lineA = buildLine(
        quantity: 1,
        width: 2,
        height: 1.5,
        uuid: 'line-a',
      );
      final lineB = buildLine(
        quantity: 1,
        width: 4,
        height: 3,
        uuid: 'line-b',
      );
      SalesProvider().mainCartQueue = [
        TempMainCart(
          cartQueue: [
            buildCart([lineA, lineB]),
          ],
          mainCartId: 'main-1',
        ),
      ];

      expect(
        SalesProvider().totalInAllCarts(
          newCartItem: lineA.copyWith()..uuid = null,
          isEdit: true,
        ),
        0,
      );
    });
  });

  group('void lines (track cart)', () {
    TempCartItem voidOf(TempCartItem line, String uuid) =>
        line.copyWith(isVoid: true, uuid: uuid);

    test('each 2D size gets its own void line', () {
      final small = buildLine(
        quantity: 1,
        width: 2,
        height: 1.5,
        uuid: 'small',
      );
      final full = buildLine(
        quantity: 1,
        width: 4,
        height: 3,
        uuid: 'full',
      );
      final smallVoid = voidOf(small, 'small-void');
      final cart = buildCart([small, full, smallVoid]);

      // Voiding the 4 × 3 line must not reuse the 2 × 1.5 void.
      expect(SalesProvider().findVoidLine(cart, full), isNull);
      // Voiding more 2 × 1.5 reuses its own void line.
      expect(
        SalesProvider().findVoidLine(cart, small),
        same(smallVoid),
      );
    });

    test('non-2D items still match by item', () {
      final line = buildLine(
        quantity: 1,
        width: null,
        height: null,
        uuid: 'plain',
      )..item.quantityType = 1;
      final lineVoid = voidOf(line, 'plain-void');
      final cart = buildCart([line, lineVoid]);

      expect(
        SalesProvider().findVoidLine(cart, line),
        same(lineVoid),
      );
    });
  });

  group('2D unit price conversion display', () {
    test('calculates correct effective conversion for sheet unit vs area unit', () {
      final sheet = buildSheet()..unitsList = [areaUnit, sheetUnit];
      // sheetUnit has conversion 1, dimensionArea is 12 -> effective conversion is 12
      final double effectiveConversionSheet =
          sheetUnit.conversion * sheet.dimensionArea();
      expect(effectiveConversionSheet, 12.0);

      // Price per m² is 100, so price per sheet is 100 * 12 = 1200
      expect(price.priceValue * effectiveConversionSheet, 1200.0);

      // areaUnit has conversion 1 -> effective conversion is 1
      final double effectiveConversionArea = areaUnit.conversion;
      expect(effectiveConversionArea, 1.0);
      expect(price.priceValue * effectiveConversionArea, 100.0);
    });
  });

  // 2 custom pieces of 2 × 1.5 (6 area) in a sheet unit, so
  // cart lines and sale records convert the same way.
  group('wastage', () {
    TempCartItem wastageLine({
      double? amount,
      bool? isPercentage,
      bool? manageSalesWastage = true,
    }) {
      return buildConfiguredLine(
          selectedUnit: sheetUnit,
          quantity: 2,
          width: 2,
          height: 1.5,
        )
        ..wastageAmount = amount
        ..isPercentageWastage = isPercentage
        ..manageSalesWastage = manageSalesWastage;
    }

    // The record checkout saves for [line].
    TempProductSaleRecord recordOf(
      TempCartItem line, {
      bool? manageSalesWastage = true,
      double? originalCost,
    }) {
      return TempProductSaleRecord(
        createdAt: DateTime.utc(2026),
        productId: 0,
        productUuid: productUuid,
        productName: 'Glass',
        shopId: 1,
        staffId: 'staff-1',
        staffName: 'Staff',
        recepitId: 0,
        quantity: line.quantity,
        revenue: originalCost ?? line.totalCost(),
        discountedAmount: 0,
        originalCost: originalCost ?? line.totalCost(),
        discount: null,
        customPriceSet: line.setCustomPrice,
        setTotalPrice: line.setTotalPrice,
        departmentName: null,
        departmentUuid: null,
        uuid: 'record-1',
        isProductManaged: true,
        useGroupQuantity: false,
        qttyPerGroup: null,
        isVoid: false,
        unitsList: line.getUnitListFinal(),
        unitUuid: line.unitUuid,
        pricesList: line.getPriceListFinal(),
        priceUuid: line.priceUuid,
        widthDimension: line.widthDimension,
        heightDimension: line.heightDimension,
        quantityType: 2,
        manageSalesWastage: manageSalesWastage,
        isPercentageWastage: line.isPercentageWastage,
        wastageAmount: line.wastageAmount,
      );
    }

    test('computeWastageArea: percent, fixed and unset', () {
      expect(
        computeWastageArea(
          baseArea: 6,
          amount: 10,
          isPercentage: true,
        ),
        closeTo(0.6, 1e-9),
      );
      expect(
        computeWastageArea(
          baseArea: 6,
          amount: 1,
          isPercentage: false,
        ),
        1,
      );
      for (final amount in [null, 0.0, -2.0]) {
        expect(
          computeWastageArea(
            baseArea: 6,
            amount: amount,
            isPercentage: false,
          ),
          0,
        );
      }
    });

    test('percent: billed and taken from stock on area + 10%', () {
      final line = wastageLine(amount: 10, isPercentage: true);
      expect(line.getRealQuantity(), 6);
      expect(line.wastageArea(), closeTo(0.6, 1e-9));
      expect(line.getStockQuantity(), closeTo(6.6, 1e-9));
      expect(line.totalCost(), closeTo(660, 1e-9));
    });

    test('fixed: the amount is added once for the line', () {
      final line = wastageLine(amount: 1, isPercentage: false);
      expect(line.getStockQuantity(), 7);
      expect(line.totalCost(), 700);
    });

    test('no wastage leaves price and stock as before', () {
      final line = wastageLine(amount: null);
      expect(line.getStockQuantity(), 6);
      expect(line.totalCost(), 600);
    });

    test('line discount applies to the price with wastage', () {
      final line = wastageLine(amount: 10, isPercentage: true)
        ..discount = 10;
      expect(line.discountCost(), closeTo(66, 1e-9));
    });

    test('cost price counts the wastage used', () {
      final line = wastageLine(amount: 1, isPercentage: false)
        ..item.costPrice = 40;
      expect(line.costPrice(), 280);
    });

    test('custom unit price is billed on area + wastage', () {
      final line = wastageLine(amount: 10, isPercentage: true)
        ..customPrice = 50
        ..setCustomPrice = true;
      expect(line.totalCost(), closeTo(330, 1e-9));
    });

    test('custom total price: wastage only affects stock', () {
      final line = wastageLine(amount: 10, isPercentage: true)
        ..customPrice = 500
        ..setCustomPrice = true
        ..setTotalPrice = true;
      expect(line.totalCost(), 500);
      expect(line.getStockQuantity(), closeTo(6.6, 1e-9));
    });

    test('non-2D lines ignore wastage', () {
      final line = wastageLine(amount: 10, isPercentage: true)
        ..item.quantityType = 1;
      expect(line.wastageArea(), 0);
      expect(line.getStockQuantity(), line.getRealQuantity());
    });

    test('checkout write-back takes area + wastage (sheets)', () {
      final product = buildSheet();
      final line = wastageLine(amount: 10, isPercentage: true);
      // Same expressions as checkoutMain's deduction block.
      expect(
        product.quantityAfterRemoving(line.getStockQuantity()),
        closeTo(9.45, 1e-9),
      );
      expect(
        line.getStockQuantity() / product.dimensionArea(),
        closeTo(0.55, 1e-9),
      );
    });

    test('delete restores exactly what checkout took', () {
      for (final line in [
        wastageLine(amount: 10, isPercentage: true),
        wastageLine(amount: 1, isPercentage: false),
      ]) {
        final record = recordOf(line);
        // Same expression as deleteRecordsInReceipt/Invoice.
        expect(
          record.getActualQuantity() + record.wastageArea(),
          closeTo(line.getStockQuantity(), 1e-9),
        );
      }
    });

    test('legacy record (flag not set) restores area only', () {
      final line = wastageLine(amount: 10, isPercentage: true);
      final record = recordOf(line, manageSalesWastage: null);
      expect(record.wastageArea(), 0);
      expect(
        record.getActualQuantity() + record.wastageArea(),
        6,
      );
    });

    test('cart stock totals count wastage', () {
      final line = wastageLine(amount: 1, isPercentage: false);
      SalesProvider().mainCartQueue = [
        TempMainCart(
          cartQueue: [
            buildCart([line]),
          ],
          mainCartId: 'main-1',
        ),
      ];
      expect(
        SalesProvider().totalItemQuantityInAllCarts(
          product: buildSheet(),
        ),
        7,
      );
      expect(
        SalesProvider().totalInAllCarts(
          newCartItem: wastageLine()..uuid = 'other-line',
          isEdit: false,
        ),
        7,
      );
    });

    test('lines with different wastage are different lines', () {
      final a = wastageLine(amount: 10, isPercentage: true);
      final b = wastageLine(amount: 10, isPercentage: true);
      final c = wastageLine(amount: 1, isPercentage: false);
      expect(SalesProvider().isSameCartLine(a, b), isTrue);
      expect(SalesProvider().isSameCartLine(a, c), isFalse);
    });

    test('re-edit: custom unit price round-trips with wastage', () {
      final line = wastageLine(amount: 10, isPercentage: true)
        ..customPrice = 50
        ..setCustomPrice = true;
      final record = recordOf(line);

      for (final rebuilt in [
        SalesProvider().saleRecordToCartItem(
          record: record,
          product: buildSheet(),
        ),
        InvoicesProvider().saleRecordToCartItem(
          record: record,
          product: buildSheet(),
        ),
      ]) {
        expect(rebuilt.customPrice, closeTo(50, 1e-9));
        expect(rebuilt.wastageAmount, 10);
        expect(rebuilt.totalCost(), closeTo(330, 1e-9));
        expect(rebuilt.getStockQuantity(), closeTo(6.6, 1e-9));
      }
    });

    test('re-edit: legacy record keeps price, drops wastage', () {
      // Saved before wastage was applied: billed on 6 area.
      final line = wastageLine(amount: 10, isPercentage: true)
        ..customPrice = 50
        ..setCustomPrice = true;
      final record = recordOf(
        line,
        manageSalesWastage: null,
        originalCost: 300,
      );

      for (final rebuilt in [
        SalesProvider().saleRecordToCartItem(
          record: record,
          product: buildSheet(),
        ),
        InvoicesProvider().saleRecordToCartItem(
          record: record,
          product: buildSheet(),
        ),
      ]) {
        expect(rebuilt.customPrice, closeTo(50, 1e-9));
        expect(rebuilt.wastageAmount, isNull);
        expect(rebuilt.totalCost(), closeTo(300, 1e-9));
        expect(rebuilt.getStockQuantity(), 6);
      }
    });
  });

  // A 4 × 2 board (8 m²), 1 in stock, ₦5,000 per m², sold in
  // m² (area unit).
  group('wastage reference numbers', () {
    final m2 = ProductUnitsClass(
      uuid: 'unit-m2',
      staffUuid: null,
      createdAt: DateTime.utc(2026),
      staffName: null,
      conversion: 1,
      name: 'm²',
      isPrimary: true,
      productUuid: productUuid,
      dimensionType: ProductUnitsClass.areaUnit,
    );

    final m2Price = ProductPricesClass(
      uuid: 'price-m2',
      staffUuid: null,
      createdAt: DateTime.utc(2026),
      staffName: null,
      priceValue: 5000,
      name: 'Price',
      isPrimary: true,
      itemUuid: productUuid,
    );

    TempProductClass board() {
      return buildSheet(quantity: 1)
        ..widthDimension = 4
        ..heightDimension = 2
        ..unitsList = [m2]
        ..pricesList = [m2Price];
    }

    TempCartItem sale8({double? amount, bool? isPercentage}) {
      return TempCartItem(
        item: board(),
        itemUuid: productUuid,
        quantity: 8,
        discount: null,
        addToStock: false,
        setTotalPrice: false,
        useWholeSalePrice: false,
        useGroupQuantity: false,
        qttyPerGroup: null,
        isVoid: false,
        uuid: 'sale-8',
        unitUuid: m2.uuid,
        priceUuid: m2Price.uuid,
        widthDimension: null,
        heightDimension: null,
        quantityType: 2,
        manageSalesWastage: true,
        isPercentageWastage: isPercentage,
        wastageAmount: amount,
      );
    }

    // canAddProductToCart logs a rejection to mainLog.log, which
    // asks path_provider for the app support directory.
    const pathProvider = MethodChannel(
      'plugins.flutter.io/path_provider',
    );
    late Directory logDir;

    setUpAll(() {
      logDir = Directory.systemTemp.createTempSync('stockall_test_');
      TestDefaultBinaryMessengerBinding
          .instance
          .defaultBinaryMessenger
          .setMockMethodCallHandler(
            pathProvider,
            (call) async => logDir.path,
          );
    });

    tearDownAll(() {
      TestDefaultBinaryMessengerBinding
          .instance
          .defaultBinaryMessenger
          .setMockMethodCallHandler(pathProvider, null);
      logDir.deleteSync(recursive: true);
    });

    setUp(() {
      DataProvider().productListMain = [board()];
      SalesProvider().mainCartQueue = [
        TempMainCart(
          cartQueue: [buildCart([])],
          mainCartId: 'main-1',
        ),
      ];
      SalesProvider().mainCartIdCache = 'main-1';
      SalesProvider().cartIdCache = 'cart-1';
    });

    test('8 m² + 0.5 m² fixed = 8.5 m², ₦42,500', () {
      final line = sale8(amount: 0.5, isPercentage: false);
      expect(line.getRealQuantity(), 8);
      expect(line.getStockQuantity(), 8.5);
      expect(line.totalCost(), 42500);
    });

    test('8 m² + 10% = 8.8 m², ₦44,000', () {
      final line = sale8(amount: 10, isPercentage: true);
      expect(line.getStockQuantity(), closeTo(8.8, 1e-9));
      expect(line.totalCost(), closeTo(44000, 1e-6));
    });

    test('8 m² stock: 8 m² + 0.5 m² wastage is rejected', () {
      final line = sale8(amount: 0.5, isPercentage: false);
      // Same call as the dialog's final check and addItemToCart.
      expect(
        SalesProvider().canAddProductToCart(
          newCartItem: line,
          quantityToAdd: line.getStockQuantity(),
          isEdit: false,
        ),
        isFalse,
      );
    });

    test('8 m² stock: 8 m² with no wastage is accepted', () {
      for (final line in [
        sale8(amount: null),
        sale8(amount: 0, isPercentage: false),
      ]) {
        expect(
          SalesProvider().canAddProductToCart(
            newCartItem: line,
            quantityToAdd: line.getStockQuantity(),
            isEdit: false,
          ),
          isTrue,
        );
      }
    });

    test('rejection message names the wastage shortfall', () {
      final line = sale8(amount: 0.5, isPercentage: false);
      expect(
        wastageStockMessage(
          cutArea: line.getRealQuantity(),
          wastageArea: line.wastageArea(),
          availableArea: SalesProvider().remainingQttyInAllCarts(
            newCartItem: line,
            isEdit: false,
          ),
          unit: 'm²',
        ),
        'Not enough stock after wastage. This sale needs '
        '8.5 m² (8 m² + 0.5 m² wastage), but only 8 m² is '
        'available.',
      );
    });

    // Item 2: checkout re-check.
    void useCart(
      List<TempCartItem> lines, {
      int type = 1,
      List<TempCartItem>? snapshot,
    }) {
      final cart = buildCart(lines)..cartItemTypeIndex = type;
      if (snapshot != null) {
        cart
          ..receiptUuidEdit = 'receipt-1'
          ..tempCartItems = snapshot;
      }
      SalesProvider().mainCartQueue = [
        TempMainCart(cartQueue: [cart], mainCartId: 'main-1'),
      ];
    }

    test('checkout: 8.5 m² needed, 8 m² in stock is blocked', () {
      useCart([sale8(amount: 0.5, isPercentage: false)]);
      expect(
        SalesProvider().checkoutStockConflict(),
        'Not enough stock for Glass. This sale needs 8.5 m² '
        'but only 8 m² is available. Reduce the quantity or '
        'remove the item before checking out.',
      );
    });

    test('checkout: exactly 8 m² goes through', () {
      useCart([sale8(amount: null)]);
      expect(SalesProvider().checkoutStockConflict(), isNull);
    });

    test('checkout: lines of the same item are added up', () {
      useCart([
        sale8(amount: null)..quantity = 4,
        sale8(amount: null)
          ..uuid = 'sale-8b'
          ..quantity = 4.5,
      ]);
      expect(
        SalesProvider().checkoutStockConflict(),
        contains('needs 8.5 m²'),
      );
    });

    test('checkout: 1D managed item with 0 stock is blocked', () {
      final soda = buildSheet(quantity: 0)
        ..uuid = 'soda'
        ..name = 'Soda'
        ..quantityType = 1
        ..widthDimension = null
        ..heightDimension = null;
      DataProvider().productListMain = [soda];
      useCart([
        TempCartItem.forProduct(soda),
      ]);
      expect(
        SalesProvider().checkoutStockConflict(),
        'Not enough stock for Soda. This sale needs 1 Sq Unit '
        'but only 0 Sq Unit is available. Reduce the quantity '
        'or remove the item before checking out.',
      );
    });

    test('checkout edit: the old lines count as available', () {
      // The original sale took all 8 m²; stock is now 0.
      DataProvider().productListMain = [
        board()..quantity = 0,
      ];
      final snapshot = [sale8(amount: null)];

      useCart([sale8(amount: null)], snapshot: snapshot);
      expect(SalesProvider().checkoutStockConflict(), isNull);

      useCart(
        [sale8(amount: 0.5, isPercentage: false)],
        snapshot: snapshot,
      );
      expect(
        SalesProvider().checkoutStockConflict(),
        contains('needs 8.5 m² but only 8 m²'),
      );
    });

    test('checkout: unmanaged items and stock-free carts pass', () {
      final over = sale8(amount: 5, isPercentage: false);

      for (final type in [3, 4]) {
        useCart([over], type: type);
        expect(SalesProvider().checkoutStockConflict(), isNull);
      }

      DataProvider().productListMain = [
        board()..isManaged = false,
      ];
      useCart([over]);
      expect(SalesProvider().checkoutStockConflict(), isNull);
    });

    test('shouldDeductStock: managed stock items deduct at 0', () {
      bool deducts(bool managed, bool listed, double stock) =>
          SalesProvider().shouldDeductStock(
            isManaged: managed,
            inProductList: listed,
            stock: stock,
          );
      expect(deducts(true, true, 0), isTrue);
      expect(deducts(true, true, 5), isTrue);
      // Not in the stock list (custom item): old rule.
      expect(deducts(true, false, 5), isTrue);
      expect(deducts(true, false, 0), isFalse);
      expect(deducts(false, true, 5), isFalse);
    });

    // The same reference numbers with the wastage unit stored
    // (m²), and as older lines without one (amount in area).
    for (final wastageUnit in [m2.uuid, null]) {
      final label = wastageUnit == null ? 'no unit' : 'm² unit';

      test('$label: 8 m² + 0.5 m² = 8.5 m², ₦42,500', () {
        final line = sale8(amount: 0.5, isPercentage: false)
          ..wastageUnitUuid = wastageUnit;
        expect(line.getStockQuantity(), 8.5);
        expect(line.totalCost(), 42500);
      });

      test('$label: 8 m² + 10% = 8.8 m², ₦44,000', () {
        final line = sale8(amount: 10, isPercentage: true)
          ..wastageUnitUuid = wastageUnit;
        expect(line.getStockQuantity(), closeTo(8.8, 1e-9));
        expect(line.totalCost(), closeTo(44000, 1e-6));
      });

      test('$label: 8 m² stock rejects +0.5, accepts +0', () {
        final over = sale8(amount: 0.5, isPercentage: false)
          ..wastageUnitUuid = wastageUnit;
        final exact = sale8(amount: 0, isPercentage: false)
          ..wastageUnitUuid = wastageUnit;
        expect(
          SalesProvider().canAddProductToCart(
            newCartItem: over,
            quantityToAdd: over.getStockQuantity(),
            isEdit: false,
          ),
          isFalse,
        );
        expect(
          SalesProvider().canAddProductToCart(
            newCartItem: exact,
            quantityToAdd: exact.getStockQuantity(),
            isEdit: false,
          ),
          isTrue,
        );
      });
    }
  });

  group('order carts drop wastage', () {
    test('order cart lines lose wastage, other carts keep it', () {
      TempCartItem lineWithWastage() =>
          buildConfiguredLine(
              selectedUnit: sheetUnit,
              quantity: 2,
              width: 2,
              height: 1.5,
            )
            ..wastageAmount = 10
            ..isPercentageWastage = true
            ..manageSalesWastage = true;

      // e.g. onEditOrder rebuilding an order saved with wastage.
      final orderLine = lineWithWastage();
      final orderCart = buildCart([orderLine])
        ..cartItemTypeIndex = 3;
      SalesProvider().clearOrderWastage(orderCart);
      expect(orderLine.wastageAmount, isNull);
      expect(orderLine.getStockQuantity(), 6);
      expect(orderLine.totalCost(), 600);

      final receiptLine = lineWithWastage();
      SalesProvider().clearOrderWastage(
        buildCart([receiptLine]),
      );
      expect(receiptLine.wastageAmount, 10);
      expect(receiptLine.totalCost(), closeTo(660, 1e-9));
    });
  });

  group('follow-ups', () {
    // A 1D item sold per "Each" (primary) or per "Group" of 12,
    // ₦100 each.
    final each = ProductUnitsClass(
      uuid: 'unit-each',
      staffUuid: null,
      createdAt: DateTime.utc(2026),
      staffName: null,
      conversion: 1,
      name: 'Each',
      isPrimary: true,
      productUuid: 'soda',
    );
    final group12 = ProductUnitsClass(
      uuid: 'unit-group',
      staffUuid: null,
      createdAt: DateTime.utc(2026),
      staffName: null,
      conversion: 12,
      name: 'Group',
      isPrimary: false,
      productUuid: 'soda',
    );

    TempProductClass soda() {
      return buildSheet()
        ..uuid = 'soda'
        ..name = 'Soda'
        ..quantityType = 1
        ..widthDimension = null
        ..heightDimension = null
        ..manageSalesWastage = false
        ..unitsList = [each, group12];
    }

    TempCartItem lineOf(
      TempProductClass product, {
      required String unitUuid,
      required double quantity,
      double? width,
      double? height,
    }) {
      return TempCartItem(
        item: product,
        itemUuid: product.uuid,
        quantity: quantity,
        discount: null,
        addToStock: false,
        setTotalPrice: false,
        useWholeSalePrice: false,
        useGroupQuantity: false,
        qttyPerGroup: null,
        isVoid: false,
        uuid: 'line-x',
        unitUuid: unitUuid,
        priceUuid: price.uuid,
        widthDimension: width,
        heightDimension: height,
        quantityType: product.quantityType,
        manageSalesWastage: null,
        isPercentageWastage: null,
        wastageAmount: null,
      );
    }

    // The record checkout saves for [line].
    TempProductSaleRecord recordFor(
      TempCartItem line, {
      double? originalCost,
    }) {
      return TempProductSaleRecord(
        createdAt: DateTime.utc(2026),
        productId: 0,
        productUuid: line.item.uuid,
        productName: line.item.name,
        shopId: 1,
        staffId: 'staff-1',
        staffName: 'Staff',
        recepitId: 0,
        quantity: line.quantity,
        revenue: originalCost ?? line.totalCost(),
        discountedAmount: 0,
        originalCost: originalCost ?? line.totalCost(),
        discount: null,
        customPriceSet: line.customPrice != null,
        setTotalPrice: line.setTotalPrice,
        departmentName: null,
        departmentUuid: null,
        uuid: 'record-x',
        isProductManaged: true,
        useGroupQuantity: false,
        qttyPerGroup: null,
        isVoid: false,
        unitsList: line.getUnitListFinal(),
        unitUuid: line.unitUuid,
        pricesList: line.getPriceListFinal(),
        priceUuid: line.priceUuid,
        widthDimension: line.widthDimension,
        heightDimension: line.heightDimension,
        quantityType: line.item.quantityType,
        manageSalesWastage: line.manageSalesWastage,
        isPercentageWastage: line.isPercentageWastage,
        wastageAmount: line.wastageAmount,
      );
    }

    void useCart(List<TempCartItem> lines) {
      SalesProvider().mainCartQueue = [
        TempMainCart(
          cartQueue: [buildCart(lines)],
          mainCartId: 'main-1',
        ),
      ];
      SalesProvider().mainCartIdCache = 'main-1';
      SalesProvider().cartIdCache = 'cart-1';
    }

    // Item 3.
    group('barcode lines (forProduct)', () {
      test('2D: takes the product\'s type, size and fields', () {
        final product = buildSheet()
          ..discount = 10
          ..qttyPerGroup = 5;
        final line = TempCartItem.forProduct(product);
        expect(line.quantityType, 2);
        expect(line.quantity, 1);
        expect(line.widthDimension, 4);
        expect(line.heightDimension, 3);
        expect(line.manageSalesWastage, isTrue);
        expect(line.wastageAmount, isNull);
        expect(line.unitUuid, unit.uuid);
        expect(line.priceUuid, price.uuid);
        expect(line.discount, 10);
        expect(line.qttyPerGroup, 5);
        expect(line.setCustomPrice, isFalse);
        // Same as a whole sheet added through the dialog.
        final dialogLine = buildLine(
          quantity: 1,
          width: 4,
          height: 3,
        );
        expect(line.totalCost(), dialogLine.totalCost());
        expect(
          line.getStockQuantity(),
          dialogLine.getStockQuantity(),
        );
      });

      test('2D without wastage management sets no flag', () {
        final line = TempCartItem.forProduct(
          buildSheet()..manageSalesWastage = false,
        );
        expect(line.manageSalesWastage, isNull);
      });

      test('1D: no size, no wastage flag', () {
        final line = TempCartItem.forProduct(soda());
        expect(line.quantityType, 1);
        expect(line.widthDimension, isNull);
        expect(line.heightDimension, isNull);
        expect(line.manageSalesWastage, isNull);
        expect(line.unitUuid, each.uuid);
        expect(line.getStockQuantity(), 1);
        expect(line.totalCost(), 100);
      });

      test('1D discountCost is the same as the old barcode line', () {
        final product = soda()..discount = 10;
        // How the barcode paths built the line before.
        final before = TempCartItem(
          isPercentageWastage: null,
          wastageAmount: null,
          manageSalesWastage: null,
          heightDimension: null,
          widthDimension: null,
          quantityType: product.quantityType,
          priceUuid: null,
          unitUuid: null,
          uuid: 'old-line',
          itemUuid: product.uuid,
          isVoid: false,
          qttyPerGroup: null,
          useGroupQuantity: false,
          useWholeSalePrice: false,
          setCustomPrice: false,
          item: product,
          quantity: 1,
          discount: null,
          addToStock: false,
          setTotalPrice: false,
        );
        final after = TempCartItem.forProduct(product);
        expect(before.discountCost(), 10);
        expect(after.discountCost(), before.discountCost());
        expect(after.totalCost(), before.totalCost());
      });
    });

    // Item 4.
    group('2D unit without a dimension type', () {
      test('record restores what the cart deducted', () {
        // `unit` has no dimensionType.
        expect(unit.dimensionType, isNull);
        final line = buildLine(
          quantity: 2,
          width: 2,
          height: 1.5,
        );
        final record = recordFor(line);
        expect(line.getRealQuantity(), 6);
        expect(record.getActualQuantity(), 6);
        expect(
          record.getActualQuantity() + record.wastageArea(),
          line.getStockQuantity(),
        );
      });

      test('legacy 2D record without a size stays per piece', () {
        final line = buildLine(
          quantity: 2,
          width: null,
          height: null,
        );
        expect(line.getRealQuantity(), 2);
        expect(recordFor(line).getActualQuantity(), 2);
      });

      test('1D records are unchanged', () {
        final line = lineOf(
          soda(),
          unitUuid: group12.uuid,
          quantity: 2,
        );
        expect(recordFor(line).getActualQuantity(), 24);
        expect(line.getRealQuantity(), 24);
      });
    });

    // Item 5.
    group('product discount in calcDiscountMain', () {
      test('2D is per area, like discountCost', () {
        final line = buildLine(
          quantity: 2,
          width: 2,
          height: 1.5,
        )..item.discount = 10;
        useCart([line]);
        // ₦600 for 6 area; was 100 × 10% × 2 pieces = 20.
        expect(SalesProvider().calcDiscountMain(), 60);
        expect(line.discountCost(), 60);
      });

      test('1D keeps its per-piece result', () {
        final line = lineOf(
          soda()..discount = 10,
          unitUuid: group12.uuid,
          quantity: 2,
        );
        useCart([line]);
        expect(SalesProvider().calcDiscountMain(), 20);
      });

      test('custom-priced lines are skipped for 2D and 1D', () {
        useCart([
          buildLine(quantity: 2, width: 2, height: 1.5)
            ..item.discount = 10
            ..customPrice = 50,
          lineOf(soda()..discount = 10, unitUuid: each.uuid, quantity: 3)
            ..customPrice = 50,
        ]);
        expect(SalesProvider().calcDiscountMain(), 0);
      });
    });

    // Item 6.
    group('price preview', () {
      final fixedPrice = ProductPricesClass(
        uuid: 'price-fixed',
        staffUuid: null,
        createdAt: DateTime.utc(2026),
        staffName: null,
        priceValue: 100,
        name: 'Fixed',
        isPrimary: true,
        itemUuid: productUuid,
        priceType: 2,
      );

      // Preview from a fresh dialog copy, then the line as added
      // (dialog values set, then applyDefaultDimensions).
      void expectPreviewMatchesAdded(
        TempCartItem base, {
        required double quantity,
        required String unitUuid,
        required ProductPricesClass usedPrice,
        double? width,
        double? height,
        double? customPrice,
        bool setTotalPrice = false,
        double? wastageAmount,
        bool? isPercentageWastage,
        required double expected,
      }) {
        final preview = base.previewWith(
          quantity: quantity,
          unitUuid: unitUuid,
          priceUuid: usedPrice.uuid,
          units: base.item.getUnitsList(),
          prices: [usedPrice],
          width: width,
          height: height,
          customPrice: customPrice,
          setTotalPrice: setTotalPrice,
          wastageAmount: wastageAmount,
          isPercentageWastage: isPercentageWastage,
          wastageUnitUuid: null,
        );

        final added = base.copyWith()
          ..item = base.item.copyWith(pricesList: [usedPrice])
          ..quantity = quantity
          ..unitUuid = unitUuid
          ..priceUuid = usedPrice.uuid
          ..widthDimension = width
          ..heightDimension = height
          ..customPrice = customPrice
          ..setTotalPrice = setTotalPrice
          ..wastageAmount = wastageAmount
          ..isPercentageWastage = isPercentageWastage;
        SalesProvider().applyDefaultDimensions(added);

        expect(preview.totalCost(), expected);
        expect(added.totalCost(), expected);
      }

      test('2D priceType 2 is priced per area, like the cart', () {
        expectPreviewMatchesAdded(
          buildLine(quantity: 1, width: null, height: null),
          quantity: 2,
          unitUuid: unit.uuid,
          usedPrice: fixedPrice,
          width: 2,
          height: 1.5,
          expected: 600, // the old preview showed 2 × 100
        );
      });

      test('2D priceType 1, custom unit, custom total, wastage', () {
        final base = buildLine(quantity: 1, width: null, height: null);
        expectPreviewMatchesAdded(
          base,
          quantity: 2,
          unitUuid: unit.uuid,
          usedPrice: price,
          width: 2,
          height: 1.5,
          expected: 600,
        );
        expectPreviewMatchesAdded(
          base,
          quantity: 2,
          unitUuid: unit.uuid,
          usedPrice: price,
          width: 2,
          height: 1.5,
          customPrice: 50,
          expected: 300,
        );
        expectPreviewMatchesAdded(
          base,
          quantity: 2,
          unitUuid: unit.uuid,
          usedPrice: price,
          width: 2,
          height: 1.5,
          customPrice: 500,
          setTotalPrice: true,
          expected: 500,
        );
        expectPreviewMatchesAdded(
          base,
          quantity: 2,
          unitUuid: unit.uuid,
          usedPrice: price,
          width: 2,
          height: 1.5,
          wastageAmount: 2,
          isPercentageWastage: false,
          expected: 800,
        );
      });

      test('2D area unit without a size uses the item size', () {
        expectPreviewMatchesAdded(
          buildConfiguredLine(selectedUnit: areaUnit, quantity: 1),
          quantity: 4,
          unitUuid: areaUnit.uuid,
          usedPrice: price,
          expected: 400,
        );
      });

      test('1D priceType 1 and 2', () {
        final base = lineOf(soda(), unitUuid: each.uuid, quantity: 1);
        expectPreviewMatchesAdded(
          base,
          quantity: 2,
          unitUuid: group12.uuid,
          usedPrice: price,
          expected: 2400,
        );
        expectPreviewMatchesAdded(
          base,
          quantity: 3,
          unitUuid: each.uuid,
          usedPrice: fixedPrice,
          expected: 300,
        );
      });

      test('previewing does not touch the cart line', () {
        final base = buildLine(quantity: 1, width: 4, height: 3)
          ..customPrice = 70;
        final dialogUnits = base.getUnitListFinal();
        final dialogPrices = base.getPriceListFinal();
        final itemBefore = base.item;
        final unitsBefore = base.item.unitsList;
        final pricesBefore = base.item.pricesList;

        final preview = base.previewWith(
          quantity: 5,
          unitUuid: unit.uuid,
          priceUuid: price.uuid,
          units: dialogUnits,
          prices: dialogPrices,
          width: 2,
          height: 1.5,
          customPrice: null,
          setTotalPrice: true,
          wastageAmount: 3,
          isPercentageWastage: false,
          wastageUnitUuid: null,
        );
        // Change everything reachable from the preview.
        preview.quantity = 99;
        preview.item.name = 'Changed';
        preview.item.unitsList!.first.conversion = 7;
        preview.item.pricesList!.first.priceValue = 1;

        expect(identical(preview.item, base.item), isFalse);
        expect(identical(base.item, itemBefore), isTrue);
        expect(identical(base.item.unitsList, unitsBefore), isTrue);
        expect(identical(base.item.pricesList, pricesBefore), isTrue);
        expect(base.item.name, 'Glass');
        expect(base.item.unitsList!.first.conversion, 1);
        expect(base.item.pricesList!.first.priceValue, 100);
        expect(dialogUnits.first.conversion, 1);
        expect(dialogPrices.first.priceValue, 100);
        expect(base.quantity, 1);
        expect(base.customPrice, 70);
        expect(base.widthDimension, 4);
        expect(base.wastageAmount, isNull);
        expect(base.setTotalPrice, isFalse);
      });
    });

    // Item 7a. Exact equality: the numbers are exact in binary.
    group('re-edit custom unit price (unit conversion)', () {
      void expectRoundTrip(
        TempCartItem line,
        TempProductClass product, {
        required double expectedTotal,
      }) {
        final record = recordFor(line);
        for (final rebuilt in [
          SalesProvider().saleRecordToCartItem(
            record: record,
            product: product,
          ),
          InvoicesProvider().saleRecordToCartItem(
            record: record,
            product: product,
          ),
        ]) {
          expect(rebuilt.customPrice, 50);
          expect(rebuilt.totalCost(), expectedTotal);
          expect(rebuilt.totalCost(), record.originalCost);
        }
      }

      test('1D group unit (×12): ₦50 each stays ₦50', () {
        final product = soda();
        final line = lineOf(
          product,
          unitUuid: group12.uuid,
          quantity: 2,
        )..customPrice = 50;
        expect(line.totalCost(), 1200);
        // The old divisor (2 pieces) gave back ₦600 each.
        expectRoundTrip(line, product, expectedTotal: 1200);
      });

      TempCartItem sheetLine({
        double? amount,
        bool? isPercentage,
      }) {
        return buildConfiguredLine(
            selectedUnit: sheetUnit,
            quantity: 2,
            width: 2,
            height: 1.5,
          )
          ..customPrice = 50
          ..wastageAmount = amount
          ..isPercentageWastage = isPercentage
          ..manageSalesWastage = amount == null ? null : true;
      }

      TempProductClass sheetProduct() =>
          buildSheet()..unitsList = [areaUnit, sheetUnit];

      test('2D sheet unit with fixed wastage', () {
        final line = sheetLine(amount: 2, isPercentage: false);
        expect(line.totalCost(), 400);
        expectRoundTrip(line, sheetProduct(), expectedTotal: 400);
      });

      test('2D sheet unit with percent wastage', () {
        final line = sheetLine(amount: 50, isPercentage: true);
        expect(line.totalCost(), 450);
        expectRoundTrip(line, sheetProduct(), expectedTotal: 450);
      });

      test('2D legacy record: wastage not applied, price kept', () {
        // Saved before wastage applied: billed on 6 area only.
        final line = sheetLine(amount: 2, isPercentage: false);
        final record = recordFor(line, originalCost: 300)
          ..manageSalesWastage = null;
        expect(record.wastageArea(), 0);
        for (final rebuilt in [
          SalesProvider().saleRecordToCartItem(
            record: record,
            product: sheetProduct(),
          ),
          InvoicesProvider().saleRecordToCartItem(
            record: record,
            product: sheetProduct(),
          ),
        ]) {
          expect(rebuilt.customPrice, 50);
          expect(rebuilt.wastageAmount, isNull);
          expect(rebuilt.totalCost(), 300);
        }
      });
    });
  });

  // A 3 × 1 slab (3 m²) sold per Slab, ₦5,000 per m².
  group('wastage units and combined quantity', () {
    final slab = ProductUnitsClass(
      uuid: 'unit-slab',
      staffUuid: null,
      createdAt: DateTime.utc(2026),
      staffName: null,
      conversion: 1,
      name: 'Slab',
      isPrimary: true,
      productUuid: 'marble',
      dimensionType: ProductUnitsClass.sheetUnit,
    );
    final sqm = ProductUnitsClass(
      uuid: 'unit-sqm',
      staffUuid: null,
      createdAt: DateTime.utc(2026),
      staffName: null,
      conversion: 1,
      name: 'm²',
      isPrimary: false,
      productUuid: 'marble',
      dimensionType: ProductUnitsClass.areaUnit,
    );
    final sqmPrice = ProductPricesClass(
      uuid: 'price-sqm',
      staffUuid: null,
      createdAt: DateTime.utc(2026),
      staffName: null,
      priceValue: 5000,
      name: 'Price',
      isPrimary: true,
      itemUuid: 'marble',
    );

    TempProductClass marble() {
      return buildSheet()
        ..uuid = 'marble'
        ..name = 'Marble'
        ..widthDimension = 3
        ..heightDimension = 1
        ..unitsList = [slab, sqm]
        ..pricesList = [sqmPrice];
    }

    TempCartItem slabLine({
      double quantity = 1,
      double width = 3,
      double height = 1,
      double? amount,
      bool? isPercentage = false,
      String? wastageUnit,
    }) {
      return TempCartItem(
        item: marble(),
        itemUuid: 'marble',
        quantity: quantity,
        discount: null,
        addToStock: false,
        setTotalPrice: false,
        useWholeSalePrice: false,
        useGroupQuantity: false,
        qttyPerGroup: null,
        isVoid: false,
        uuid: 'slab-line',
        unitUuid: slab.uuid,
        priceUuid: sqmPrice.uuid,
        widthDimension: width,
        heightDimension: height,
        quantityType: 2,
        manageSalesWastage: amount == null ? null : true,
        isPercentageWastage: isPercentage,
        wastageAmount: amount,
        wastageUnitUuid: wastageUnit,
      );
    }

    // The record checkout saves for [line] (buildSaleRecords).
    TempProductSaleRecord recordOf(TempCartItem line) {
      return TempProductSaleRecord(
        createdAt: DateTime.utc(2026),
        productId: 0,
        productUuid: line.item.uuid,
        productName: line.item.name,
        shopId: 1,
        staffId: 'staff-1',
        staffName: 'Staff',
        recepitId: 0,
        quantity: line.quantity,
        revenue: line.totalCost(),
        discountedAmount: 0,
        originalCost: line.totalCost(),
        discount: null,
        customPriceSet: line.customPrice != null,
        setTotalPrice: line.setTotalPrice,
        departmentName: null,
        departmentUuid: null,
        uuid: 'slab-record',
        isProductManaged: true,
        useGroupQuantity: false,
        qttyPerGroup: null,
        isVoid: false,
        unitsList: line.getUnitListFinal(),
        unitUuid: line.unitUuid,
        pricesList: line.getPriceListFinal(),
        priceUuid: line.priceUuid,
        widthDimension: line.widthDimension,
        heightDimension: line.heightDimension,
        quantityType: line.item.quantityType,
        manageSalesWastage: line.manageSalesWastage,
        isPercentageWastage: line.isPercentageWastage,
        wastageAmount: line.wastageAmount,
        wastageUnitUuid: line.wastageUnitUuid,
      );
    }

    test('1 Slab + 0.3 m² = 3.3 m², shown as 1.1 Slab', () {
      final line = slabLine(amount: 0.3, wastageUnit: sqm.uuid);
      expect(line.getRealQuantity(), 3);
      expect(line.getStockQuantity(), closeTo(3.3, 1e-9));
      expect(line.displayQuantity(), closeTo(1.1, 1e-9));
      expect(line.wastageInSaleUnit(), closeTo(0.1, 1e-9));
      expect(line.wastageNote(), 'incl. 0.1 Slab wastage');
      expect(line.totalCost(), closeTo(16500, 1e-6));
      // Storage keeps them apart.
      expect(line.quantity, 1);
      expect(line.wastageAmount, 0.3);
    });

    test('1 Slab + 0.1 Slab is the same 3.3 m²', () {
      final line = slabLine(amount: 0.1, wastageUnit: slab.uuid);
      expect(line.getStockQuantity(), closeTo(3.3, 1e-9));
      expect(line.displayQuantity(), closeTo(1.1, 1e-9));
      expect(line.totalCost(), closeTo(16500, 1e-6));
    });

    test('a Slab of wastage is the line\'s cut size', () {
      // 1 piece cut at 1 × 1.5: 0.1 Slab is 0.15 m².
      final line = slabLine(
        width: 1,
        height: 1.5,
        amount: 0.1,
        wastageUnit: slab.uuid,
      );
      expect(line.getRealQuantity(), 1.5);
      expect(line.wastageArea(), closeTo(0.15, 1e-9));
      expect(line.displayQuantity(), closeTo(1.1, 1e-9));
    });

    test('no wastage unit (older lines): the amount is area', () {
      final line = slabLine(amount: 0.3, wastageUnit: null);
      expect(line.getStockQuantity(), closeTo(3.3, 1e-9));
      expect(line.displayQuantity(), closeTo(1.1, 1e-9));
    });

    test('percent ignores the unit: 10% of the sale quantity', () {
      for (final unit in [null, slab.uuid, sqm.uuid]) {
        final line = slabLine(
          amount: 10,
          isPercentage: true,
          wastageUnit: unit,
        );
        expect(line.getStockQuantity(), closeTo(3.3, 1e-9));
        expect(line.displayQuantity(), closeTo(1.1, 1e-9));
      }
    });

    test('edit → save → edit keeps 1 + 0.1, never 1.2', () {
      TempCartItem line =
          slabLine(amount: 0.1, wastageUnit: slab.uuid)
            ..customPrice = 5000
            ..setCustomPrice = true;
      for (var round = 0; round < 3; round++) {
        for (final rebuilt in [
          SalesProvider().saleRecordToCartItem(
            record: recordOf(line),
            product: marble(),
          ),
          InvoicesProvider().saleRecordToCartItem(
            record: recordOf(line),
            product: marble(),
          ),
        ]) {
          expect(rebuilt.quantity, 1);
          expect(rebuilt.wastageAmount, 0.1);
          expect(rebuilt.wastageUnitUuid, slab.uuid);
          expect(rebuilt.displayQuantity(), closeTo(1.1, 1e-9));
          expect(rebuilt.customPrice, closeTo(5000, 1e-9));
          expect(rebuilt.totalCost(), closeTo(16500, 1e-6));
        }
        line = SalesProvider().saleRecordToCartItem(
          record: recordOf(line),
          product: marble(),
        );
      }
    });

    test('delete restores 1 + 0.1 = 1.1 Slab (3.3 m²)', () {
      final line = slabLine(amount: 0.1, wastageUnit: slab.uuid);
      final record = recordOf(line);
      // Same expression as deleteRecordsInReceipt/Invoice.
      expect(
        record.getStockQuantity(),
        closeTo(line.getStockQuantity(), 1e-9),
      );
      expect(record.getStockQuantity(), closeTo(3.3, 1e-9));
      expect(
        record.getStockQuantity() / marble().dimensionArea(),
        closeTo(1.1, 1e-9),
      );
      expect(record.displayQuantity(), closeTo(1.1, 1e-9));
      // Item history: same unit as before (Slab), with wastage.
      expect(record.quantityText(), '1.1');
      expect(
        record.historyWastageText(),
        ' (incl. 0.1 wastage)',
      );
    });

    test('older record without a wastage unit stays in area', () {
      final record = recordOf(
        slabLine(amount: 0.3, wastageUnit: null),
      );
      expect(record.wastageUnitUuid, isNull);
      expect(record.getStockQuantity(), closeTo(3.3, 1e-9));
      final rebuilt = SalesProvider().saleRecordToCartItem(
        record: record,
        product: marble(),
      );
      expect(rebuilt.wastageUnitUuid, isNull);
      expect(rebuilt.getStockQuantity(), closeTo(3.3, 1e-9));
    });

    test('per-1 price: custom totals divide by the sale quantity', () {
      final customTotal = recordOf(
        slabLine(amount: 0.1, wastageUnit: slab.uuid)
          ..customPrice = 500
          ..setCustomPrice = true
          ..setTotalPrice = true,
      );
      expect(customTotal.originalCost, 500);
      expect(customTotal.priceQuantity(), 1);
      expect(customTotal.priceBaseQuantity(), 3);

      final priced = recordOf(
        slabLine(amount: 0.1, wastageUnit: slab.uuid),
      );
      expect(priced.priceQuantity(), closeTo(1.1, 1e-9));
      expect(priced.priceBaseQuantity(), closeTo(3.3, 1e-9));
      // ₦5,000 per m², not inflated by the wastage.
      expect(
        priced.originalCost! / priced.priceBaseQuantity(),
        closeTo(5000, 1e-6),
      );
    });

    test('1D lines are unchanged', () {
      final line = buildLine(quantity: 2, width: null, height: null)
        ..item.quantityType = 1
        ..wastageAmount = 0.5
        ..isPercentageWastage = false
        ..wastageUnitUuid = unit.uuid;
      expect(line.displayQuantity(), 2);
      expect(line.wastageNote(), '');
      expect(line.quantityText(), '2.0');
      expect(line.historyWastageText(), '');
      final record = recordOf(line)..quantityType = 1;
      expect(record.displayQuantity(), 2);
      expect(record.priceQuantity(), 2);
      expect(record.wastageNote(), '');
    });

    test('order carts clear the wastage unit too', () {
      final line = slabLine(amount: 0.1, wastageUnit: slab.uuid);
      SalesProvider().clearOrderWastage(
        buildCart([line])..cartItemTypeIndex = 3,
      );
      expect(line.wastageAmount, isNull);
      expect(line.wastageUnitUuid, isNull);
      expect(line.displayQuantity(), 1);
    });

    test('JSON keeps the wastage unit (cart, record, draft)', () {
      final line = slabLine(amount: 0.1, wastageUnit: slab.uuid);
      expect(
        TempCartItem.fromJson(
          jsonDecode(jsonEncode(line.toJson())),
        ).wastageUnitUuid,
        slab.uuid,
      );
      expect(
        TempProductSaleRecord.fromJson(
          jsonDecode(jsonEncode(recordOf(line).toJson())),
        ).wastageUnitUuid,
        slab.uuid,
      );

      final draft = DraftItems(
        uuid: 'draft-line',
        draftId: 'draft-1',
        createdAt: DateTime.utc(2026),
        productUuid: 'marble',
        productName: 'Marble',
        quantity: 1,
        customPrice: null,
        setCustomPrice: false,
        setTotalPrice: false,
        useWholeSalePrice: false,
        addToStock: false,
        discount: null,
        fixedDiscount: null,
        useGroupQuantity: false,
        qttyPerGroup: null,
        isVoid: false,
        unit: 'Slab',
        groupUnit: null,
        unitUuid: slab.uuid,
        unitsList: [slab, sqm],
        priceUuid: sqmPrice.uuid,
        pricesList: [sqmPrice],
        sellingPrice: 5000,
        costPrice: 0,
        isProductManaged: true,
        revenue: 16500,
        widthDimension: 3,
        heightDimension: 1,
        quantityType: 2,
        manageSalesWastage: true,
        isPercentageWastage: false,
        wastageAmount: 0.1,
        wastageUnitUuid: slab.uuid,
      );
      final restored = DraftItems.fromJson(
        jsonDecode(jsonEncode(draft.toJson())),
      );
      expect(restored.wastageUnitUuid, slab.uuid);
      expect(restored.wastageAmount, 0.1);
      expect(restored.quantity, 1);
    });
  });

  group('cart line identity', () {
    // 1 sheet of 4 × 3 in stock (12 area). Sold by the sheet
    // (priced at the line's size) or by the m² (area unit).
    TempProductClass sheetProduct() =>
        buildSheet(quantity: 1)..unitsList = [areaUnit, sheetUnit];

    TempCartItem line2D({
      required String uuid,
      required ProductUnitsClass lineUnit,
      double quantity = 1,
      double? width,
      double? height,
      bool isVoid = false,
    }) {
      return TempCartItem(
        item: sheetProduct(),
        itemUuid: productUuid,
        quantity: quantity,
        discount: null,
        addToStock: false,
        setTotalPrice: false,
        useWholeSalePrice: false,
        useGroupQuantity: false,
        qttyPerGroup: null,
        isVoid: isVoid,
        uuid: uuid,
        unitUuid: lineUnit.uuid,
        priceUuid: price.uuid,
        widthDimension: width,
        heightDimension: height,
        quantityType: 2,
        manageSalesWastage: null,
        isPercentageWastage: null,
        wastageAmount: null,
      );
    }

    TempProductClass plainProduct() => buildSheet()
      ..quantityType = 1
      ..unitsList = [unit, sheetUnit];

    TempCartItem line1D({
      required String uuid,
      String? unitUuid,
      double quantity = 1,
      bool isVoid = false,
    }) {
      return TempCartItem(
        item: plainProduct(),
        itemUuid: productUuid,
        quantity: quantity,
        discount: null,
        addToStock: false,
        setTotalPrice: false,
        useWholeSalePrice: false,
        useGroupQuantity: false,
        qttyPerGroup: null,
        isVoid: isVoid,
        uuid: uuid,
        unitUuid: unitUuid ?? unit.uuid,
        priceUuid: price.uuid,
        widthDimension: null,
        heightDimension: null,
        quantityType: 1,
        manageSalesWastage: null,
        isPercentageWastage: null,
        wastageAmount: null,
      );
    }

    void useCart(List<TempCartItem> lines) {
      SalesProvider().mainCartQueue = [
        TempMainCart(
          cartQueue: [buildCart(lines)],
          mainCartId: 'main-1',
        ),
      ];
      SalesProvider().mainCartIdCache = 'main-1';
      SalesProvider().cartIdCache = 'cart-1';
    }

    // canAddProductToCart logs a rejection to mainLog.log, which
    // asks path_provider for the app support directory.
    const pathProvider = MethodChannel(
      'plugins.flutter.io/path_provider',
    );
    late Directory logDir;

    setUpAll(() {
      logDir = Directory.systemTemp.createTempSync('stockall_test_');
      TestDefaultBinaryMessengerBinding
          .instance
          .defaultBinaryMessenger
          .setMockMethodCallHandler(
            pathProvider,
            (call) async => logDir.path,
          );
    });

    tearDownAll(() {
      TestDefaultBinaryMessengerBinding
          .instance
          .defaultBinaryMessenger
          .setMockMethodCallHandler(pathProvider, null);
      logDir.deleteSync(recursive: true);
    });

    setUp(() {
      DataProvider().productListMain = [sheetProduct()];
      SalesProvider().tempCartItems = [];
    });

    test('2D lines with different sizes are separate lines', () {
      final small = line2D(
        uuid: 'a',
        lineUnit: sheetUnit,
        width: 1,
        height: 2,
      );
      final big = line2D(
        uuid: 'b',
        lineUnit: sheetUnit,
        width: 2,
        height: 2,
      );
      expect(SalesProvider().isSameCartLine(small, big), isFalse);

      SalesProvider().addItemToTempCart(item: small);
      SalesProvider().addItemToTempCart(item: big);
      expect(SalesProvider().tempCartItems.length, 2);

      useCart([small]);
      expect(
        SalesProvider().findCartLine(
          SalesProvider().currentCart(),
          big,
        ),
        isNull,
      );
    });

    test('sizes equal within float noise are the same line', () {
      final a = line2D(
        uuid: 'a',
        lineUnit: sheetUnit,
        width: 0.1 + 0.2,
        height: 2,
      );
      final b = line2D(
        uuid: 'b',
        lineUnit: sheetUnit,
        width: 0.3,
        height: 2,
      );
      expect(a.widthDimension == b.widthDimension, isFalse);
      expect(SalesProvider().isSameCartLine(a, b), isTrue);
    });

    test('a default-size line and an m² line are separate lines', () {
      final whole = line2D(
        uuid: 'whole',
        lineUnit: sheetUnit,
        width: 4,
        height: 3,
      );
      // addItemToCart gives m² lines the item's size too
      // (applyDefaultDimensions); only the unit tells them apart.
      final area = line2D(
        uuid: 'area',
        lineUnit: areaUnit,
        quantity: 3,
        width: 4,
        height: 3,
      );
      expect(SalesProvider().isSameCartLine(whole, area), isFalse);
      expect(SalesProvider().isSameCartLine(area, whole), isFalse);

      useCart([whole]);
      expect(
        SalesProvider().findCartLine(
          SalesProvider().currentCart(),
          area,
        ),
        isNull,
      );
    });

    test('m² lines match whatever size they carry', () {
      final added = line2D(
        uuid: 'added',
        lineUnit: areaUnit,
        width: 4,
        height: 3,
      );
      // Edited into m² in the dialog: no size.
      final edited = line2D(
        uuid: 'edited',
        lineUnit: areaUnit,
        width: null,
        height: null,
      );
      expect(SalesProvider().isSameCartLine(added, edited), isTrue);
      expect(SalesProvider().isSameCartLine(edited, added), isTrue);
    });

    test('a line without a unit counts as the primary unit', () {
      final noUnit = line2D(
        uuid: 'a',
        lineUnit: areaUnit,
        width: 4,
        height: 3,
      )..unitUuid = null;
      final primary = line2D(
        uuid: 'b',
        lineUnit: areaUnit,
        width: 4,
        height: 3,
      );
      final sheet = line2D(
        uuid: 'c',
        lineUnit: sheetUnit,
        width: 4,
        height: 3,
      );
      expect(SalesProvider().isSameCartLine(noUnit, primary), isTrue);
      expect(SalesProvider().isSameCartLine(noUnit, sheet), isFalse);
    });

    test('editing one line leaves the other lines of the item alone', () async {
      final a = line2D(
        uuid: 'a',
        lineUnit: sheetUnit,
        width: 1,
        height: 2,
      );
      final b = line2D(
        uuid: 'b',
        lineUnit: sheetUnit,
        width: 2,
        height: 2,
      );
      final c = line2D(uuid: 'c', lineUnit: areaUnit, quantity: 2);
      useCart([a, b, c]);

      await SalesProvider().updateCurrentCartItem(
        a.copyWith(quantity: 3),
      );
      expect([a.quantity, b.quantity, c.quantity], [3, 1, 2]);

      await SalesProvider().updateCurrentCartItem(
        b.copyWith(quantity: 2, widthDimension: 1.5),
      );
      expect([a.quantity, b.quantity, c.quantity], [3, 2, 2]);
      expect(b.widthDimension, 1.5);
      expect(a.widthDimension, 1);

      await SalesProvider().updateCurrentCartItem(
        c.copyWith(quantity: 4),
      );
      expect([a.quantity, b.quantity, c.quantity], [3, 2, 4]);
    });

    test('a line edited to match another stays a separate line', () async {
      final a = line2D(
        uuid: 'a',
        lineUnit: sheetUnit,
        width: 1,
        height: 2,
      );
      final b = line2D(
        uuid: 'b',
        lineUnit: sheetUnit,
        width: 2,
        height: 2,
      );
      useCart([a, b]);

      await SalesProvider().updateCurrentCartItem(
        a.copyWith(widthDimension: 2),
      );
      final cart = SalesProvider().currentCart();
      expect(cart.getCartItems().length, 2);
      expect(SalesProvider().isSameCartLine(a, b), isTrue);
      // Both still count towards stock: 4 + 4 area.
      expect(
        SalesProvider().totalInAllCarts(
          newCartItem: line2D(uuid: 'new', lineUnit: areaUnit),
          isEdit: false,
        ),
        8,
      );
    });

    test('stock totals add up every line of the item', () {
      final a = line2D(
        uuid: 'a',
        lineUnit: sheetUnit,
        width: 1,
        height: 2,
      ); // 2 area
      final b = line2D(
        uuid: 'b',
        lineUnit: sheetUnit,
        width: 2,
        height: 2,
      ); // 4 area
      final c = line2D(
        uuid: 'c',
        lineUnit: areaUnit,
        quantity: 3,
      ); // 3 area
      useCart([a, b, c]);

      final sp = SalesProvider();
      final newLine = line2D(uuid: 'new', lineUnit: areaUnit);
      expect(
        sp.totalInAllCarts(newCartItem: newLine, isEdit: false),
        9,
      );
      // Editing excludes only the line being edited.
      expect(
        sp.totalInAllCarts(newCartItem: a.copyWith(), isEdit: true),
        7,
      );
      expect(
        sp.totalInAllCarts(newCartItem: b.copyWith(), isEdit: true),
        5,
      );
      expect(
        sp.totalInAllCarts(newCartItem: c.copyWith(), isEdit: true),
        6,
      );

      // 12 area in stock, 9 in the cart.
      expect(
        sp.canAddProductToCart(
          newCartItem: newLine,
          quantityToAdd: 3,
          isEdit: false,
        ),
        isTrue,
      );
      expect(
        sp.canAddProductToCart(
          newCartItem: newLine,
          quantityToAdd: 3.5,
          isEdit: false,
        ),
        isFalse,
      );
      // Editing b (4 area) to 2 × 3 (6 area): 2 + 3 + 6 = 11.
      expect(
        sp.canAddProductToCart(
          newCartItem: b.copyWith(),
          quantityToAdd: 6,
          isEdit: true,
        ),
        isTrue,
      );
      expect(
        sp.canAddProductToCart(
          newCartItem: b.copyWith(),
          quantityToAdd: 8,
          isEdit: true,
        ),
        isFalse,
      );
    });

    test('removing one line leaves the others and their stock', () {
      final a = line2D(
        uuid: 'a',
        lineUnit: sheetUnit,
        width: 1,
        height: 2,
      );
      final b = line2D(
        uuid: 'b',
        lineUnit: sheetUnit,
        width: 2,
        height: 2,
      );
      useCart([a, b]);
      final cart = SalesProvider().currentCart();

      // removeItemFromCart removes the line object itself.
      cart.cartItems.remove(a);
      expect(cart.getCartItems(), [b]);
      expect(
        SalesProvider().totalInAllCarts(
          newCartItem: line2D(uuid: 'new', lineUnit: areaUnit),
          isEdit: false,
        ),
        4,
      );
    });

    test('void lines stay with their own size and unit', () {
      final small = line2D(
        uuid: 'small',
        lineUnit: sheetUnit,
        width: 1,
        height: 2,
      );
      final whole = line2D(
        uuid: 'whole',
        lineUnit: sheetUnit,
        width: 4,
        height: 3,
      );
      final area = line2D(
        uuid: 'area',
        lineUnit: areaUnit,
        width: 4,
        height: 3,
      );
      final wholeVoid = whole.copyWith(isVoid: true, uuid: 'wv');
      final areaVoid = area.copyWith(isVoid: true, uuid: 'av');
      final sp = SalesProvider();

      // Only the sheet void exists: the m² line must not reuse it.
      var cart = buildCart([small, whole, area, wholeVoid]);
      expect(sp.findVoidLine(cart, area), isNull);
      expect(sp.findVoidLine(cart, small), isNull);
      expect(sp.findVoidLine(cart, whole), same(wholeVoid));

      // And the other way round.
      cart = buildCart([small, whole, area, areaVoid]);
      expect(sp.findVoidLine(cart, whole), isNull);
      expect(sp.findVoidLine(cart, area), same(areaVoid));
    });

    test('adding merges into the live line, not one behind a void', () {
      final voidX = line2D(
        uuid: 'x-void',
        lineUnit: sheetUnit,
        width: 1,
        height: 2,
        isVoid: true,
      );
      final y = line2D(
        uuid: 'y',
        lineUnit: sheetUnit,
        width: 2,
        height: 2,
      );
      final x = line2D(
        uuid: 'x',
        lineUnit: sheetUnit,
        width: 1,
        height: 2,
      );
      useCart([voidX, y, x]);

      final added = line2D(
        uuid: 'new',
        lineUnit: sheetUnit,
        width: 1,
        height: 2,
      );
      expect(
        SalesProvider().findCartLine(
          SalesProvider().currentCart(),
          added,
        ),
        same(x),
      );
    });

    group('1D lines are unchanged', () {
      test('same item is one line whatever the unit', () {
        final a = line1D(uuid: 'a');
        final b = line1D(uuid: 'b', unitUuid: sheetUnit.uuid);
        expect(SalesProvider().isSameCartLine(a, b), isTrue);

        SalesProvider().addItemToTempCart(item: a);
        SalesProvider().addItemToTempCart(item: b);
        expect(SalesProvider().tempCartItems.length, 1);
        expect(SalesProvider().tempCartItems.single.uuid, 'b');

        useCart([a]);
        expect(
          SalesProvider().findCartLine(
            SalesProvider().currentCart(),
            b,
          ),
          same(a),
        );
      });

      test('the dialog starts from the live line', () {
        final live = line1D(uuid: 'live', quantity: 4);
        final voided = line1D(
          uuid: 'void',
          quantity: 1,
          isVoid: true,
        );
        // Void line first, as after remove-then-add.
        final cart = buildCart([voided, live]);
        expect(
          SalesProvider().existingLineForAdd(
            cart,
            plainProduct(),
          ),
          same(live),
        );
      });

      test('only a void line: the new line gets its own uuid', () {
        final voided = line1D(uuid: 'void', isVoid: true);
        final cart = buildCart([voided]);
        expect(
          SalesProvider().existingLineForAdd(
            cart,
            plainProduct(),
          ),
          isNull,
        );
      });
    });

    test('2D: the dialog never starts from an existing line', () {
      final cart = buildCart([
        line2D(uuid: 'a', lineUnit: sheetUnit, width: 4, height: 3),
      ]);
      expect(
        SalesProvider().existingLineForAdd(cart, sheetProduct()),
        isNull,
      );
    });
  });
}


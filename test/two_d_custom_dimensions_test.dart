import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_cart/temp_cart.dart';
import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';
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
}


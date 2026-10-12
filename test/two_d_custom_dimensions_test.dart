import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_cart/temp_cart.dart';
import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';
import 'package:stockall/classes/temp_main_cart/temp_main_cart.dart';
import 'package:stockall/classes/temp_orders/order_items.dart';
import 'package:stockall/classes/temp_product_class/prices_class/product_prices_class.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/providers/data_provider.dart';
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
    );
  }

  TempCart buildCart(List<TempCartItem> items) {
    return TempCart(
      cartItems: items,
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
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/temp_cart/temp_cart.dart';
import 'package:stockall/classes/temp_main_cart/temp_main_cart.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/components/alert_dialogues/stock_conflict_alert.dart';
import 'package:stockall/components/lan_stock_banner.dart';
import 'package:stockall/local_database/cart_func/cart_func.dart';
import 'package:stockall/local_database/hive_adapters_registry.dart';
import 'package:stockall/local_database/lan/lan_applied_deltas_func.dart';
import 'package:stockall/local_database/lan/lan_deleted_items_func.dart';
import 'package:stockall/local_database/lan/lan_own_holds_func.dart';
import 'package:stockall/local_database/lan/lan_pending_checkouts_func.dart';
import 'package:stockall/local_database/lan/lan_stock_holds_func.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/quantity_update/quantity_update_func.dart';
import 'package:stockall/providers/data_provider.dart';
import 'package:stockall/providers/sales_provider.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/lan/rest/lan_delta_registry.dart';
import 'package:stockall/services/lan/rest/lan_delta_rpcs.dart';
import 'package:stockall/services/lan/stock/lan_holds.dart';
import 'package:stockall/services/lan/stock/lan_stock_client.dart';
import 'package:stockall/services/lan/stock/lan_stock_service.dart';
import 'package:stockall/services/navigation_service.dart';
import 'package:stockall/services/remote/remote_client.dart';

import 'all_items_test_env.dart';
import 'helpers/lan_carts.dart';
import 'helpers/lan_fixtures.dart';

/// Each cart operation that holds stock, through the real `SalesProvider`, against a
/// real `LanStockService` (this device is "phone"; another till is
/// "other"). The customer display finds no second screen, so its window
/// calls return at once.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sales = SalesProvider();
  final client = LanStockClient();
  late LanStockService server;
  late List<List<LanStockConflict>> conflicts;
  StreamSubscription<List<LanStockConflict>>? sub;

  setUpAll(() async {
    await setUpAllItemsEnvironment();
    registerAllHiveAdapters();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('screen_retriever'),
          (call) async => {'displays': <Object?>[]},
        );
    await CartFunc().init();
    await QuantityUpdateFunc().init();
    await LanAppliedDeltasFunc().init();
    await LanDeletedItemsFunc().init();
    await LanStockHoldsFunc().init();
    await LanPendingCheckoutsFunc().init();
    await LanOwnHoldsFunc().init();
  });

  TempProductClass stocked(String uuid, double quantity) =>
      product(uuid)..quantity = quantity;

  /// Stock on the server and in the product list; [mains] saved as the
  /// device's carts (the first cart of the first selected); a fresh
  /// server and client.
  Future<void> prepare({
    required Map<String, double> stock,
    required List<TempMainCart> mains,
  }) async {
    await sub?.cancel();
    await client.stop();
    client.reset();
    await ProductsFunc().productBox.clear();
    for (final e in stock.entries) {
      await ProductsFunc().productBox.put(e.key, stocked(e.key, e.value));
    }
    DataProvider().productListMain = [
      for (final e in stock.entries) stocked(e.key, e.value),
    ];
    await LanStockHoldsFunc().clearHolds();
    await LanPendingCheckoutsFunc().clearPending();
    await LanOwnHoldsFunc().clearOwnHolds();
    await LanAppliedDeltasFunc().appliedDeltasBox.clear();
    final deltas = LanDeltaRpcs(
      rpcs: lanDeltaRpcs(shopId: () => 7),
      applied: const HiveAppliedDeltas(),
    );
    server = LanStockService(
      exclusive: deltas.runExclusive,
      product: (uuid) => ProductsFunc().productBox.get(uuid),
      applyCheckout:
          (body) => deltas.applyHoldingLock(
            'update_product_quantities',
            body,
            skipUnknown: true,
          ),
      ownDeviceId: () => 'desk',
    )..start();
    await CartFunc().clearMainCart();
    for (final m in mains) {
      await CartFunc().createMainCart(m);
    }
    sales.mainCartQueue = CartFunc().getMainCart();
    sales.mainCartIdCache = mains.first.mainCartId!;
    sales.cartIdCache = mains.first.cartQueue.first.id!;
    sales.tempCartItems = [];
    // As the app's deps, with the server reached over JSON.
    client.deps = LanStockClientDeps(
      link:
          () => LanStockLink(
            call:
                (rpc, params) async =>
                    jsonDecode(
                          jsonEncode(
                            await server.call(
                              rpc,
                              jsonDecode(jsonEncode(params))
                                  as Map<String, dynamic>,
                              device: 'phone',
                            ),
                          ),
                        )
                        as Map<String, dynamic>,
          ),
      route: () => LanRoute.lanUp,
      carts: () => CartFunc().cartBox.values.expand((m) => m.cartQueue),
      held:
          (p) => DataProvider().productListMain.any(
            (x) => x.uuid == p && x.isManaged,
          ),
      queued: () => const {},
      dropQueued: (_) async {},
      cartChanges: () => CartFunc().cartBox.watch(),
      debounce: const Duration(milliseconds: 5),
      pinFor: const Duration(milliseconds: 300),
    );
    client.start();
    conflicts = [];
    sub = client.conflicts.listen(conflicts.add);
  }

  /// The safety net's debounce and its call.
  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 60));

  Future<void> otherHolds(String product, double quantity) => server.reserve(
    device: 'other',
    requests: [LanHoldRequest('o1', product, quantity)],
  );

  TempMainCart main(String id, List<TempCart> carts) =>
      TempMainCart(cartQueue: carts, mainCartId: id);

  Future<BuildContext> host(
    WidgetTester tester, {
    GlobalKey<NavigatorState>? navigator,
  }) async {
    late BuildContext context;
    await tester.pumpWidget(
      ChangeNotifierProvider<ThemeProvider>(
        create: (_) => ThemeProvider(),
        child: MaterialApp(
          navigatorKey: navigator,
          home: Builder(
            builder: (c) {
              context = c;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    return context;
  }

  tearDownAll(() async {
    await sub?.cancel();
    await client.stop();
    client.reset();
  });

  testWidgets('add a line: held before it is saved; refused with the '
      'server\'s amount, then what is left shows as available', (
    tester,
  ) async {
    final context = await host(tester);
    final p1 = stocked('p1', 4);
    await tester.runAsync(() async {
      await prepare(
        stock: {'p1': 4},
        mains: [
          main('m1', [cart('c1', [])]),
        ],
      );
      await otherHolds('p1', 3);

      final refused = await sales.addItemToCart(
        context: context,
        newItem: line(p1, 2),
        isCustomEdit: false,
      );
      expect(refused, 'Quantity Limit Exceeded');
      expect(sales.currentCart().cartItems, isEmpty);
      expect(sales.remainingItemQttyInAllCarts(product: p1), 1);

      final added = await sales.addItemToCart(
        context: context,
        newItem: line(p1, 1),
        isCustomEdit: false,
      );
      expect(added, 'Item Added Successfully');
      await settle();
      expect(server.heldBy('phone', 'c1', 'p1'), 1);
      expect(sales.remainingItemQttyInAllCarts(product: p1), 0);
    });
    await tester.pump();
    expect(find.text('Quantity Limit Reached'), findsOneWidget);
    expect(find.textContaining('Other tills hold the rest'), findsOneWidget);
  });

  testWidgets('add to a line\'s quantity and replace a line: only the cart\'s '
      'new total is held', (tester) async {
    final context = await host(tester);
    final p1 = stocked('p1', 4);
    await tester.runAsync(() async {
      final a = line(p1, 1, uuid: 'a');
      await prepare(
        stock: {'p1': 4},
        mains: [
          main('m1', [
            cart('c1', [a]),
          ]),
        ],
      );
      await client.reconcile();
      expect(server.heldBy('phone', 'c1', 'p1'), 1);
      await otherHolds('p1', 2);

      // Same line, more of it: 3 > 2 left for this cart.
      expect(
        await sales.addItemToCart(
          context: context,
          newItem: line(p1, 2),
          isCustomEdit: false,
        ),
        'Quantity Limit Exceeded',
      );
      expect(a.quantity, 1);
      expect(
        await sales.addItemToCart(
          context: context,
          newItem: line(p1, 1),
          isCustomEdit: false,
        ),
        'Quantity Updated Successfully',
      );
      expect(a.quantity, 2);
      expect(server.heldBy('phone', 'c1', 'p1'), 2);

      // Replace (after the duplicate dialog's choice): the hook first, as
      // addItemToCart runs it, then the replace.
      final smaller = line(p1, 1);
      expect(
        await sales.holdInCart(
          line: a,
          without: a,
          plus: smaller.getStockQuantity(),
        ),
        isTrue,
      );
      await sales.replaceCartItem(
        existingLine: a,
        newItem: smaller,
        isCustomEdit: false,
      );
      await settle();
      expect(server.heldBy('phone', 'c1', 'p1'), 1);
      expect(await sales.holdInCart(line: a, without: a, plus: 3), isFalse);
      expect(server.heldBy('phone', 'c1', 'p1'), 1);
    });
    await tester.pump();
    expect(find.text('Quantity Limit Reached'), findsOneWidget);
  });

  testWidgets('change a quantity: an increase that doesn\'t fit is undone; a '
      'decrease is saved, then lowered on the server', (tester) async {
    await host(tester);
    await tester.runAsync(() async {
      final a = line(stocked('p1', 3), 1, uuid: 'a');
      await prepare(
        stock: {'p1': 3},
        mains: [
          main('m1', [
            cart('c1', [a]),
          ]),
        ],
      );
      await client.reconcile();
      await otherHolds('p1', 1);

      Future<bool> edit(double n) => sales.editCartItemQuantity(
        cartItem: a,
        number: n,
        setTotalPrice: false,
        setCustomPrice: false,
      );

      expect(await edit(3), isFalse);
      expect(a.quantity, 1);
      expect(await edit(2), isTrue);
      expect(server.heldBy('phone', 'c1', 'p1'), 2);
      expect(await edit(1), isTrue);
      await settle();
      expect(server.heldBy('phone', 'c1', 'p1'), 1);
    });
  });

  testWidgets('add many: one batch; what the server can\'t hold is skipped '
      'and listed', (tester) async {
    final context = await host(tester);
    await tester.runAsync(() async {
      await prepare(
        stock: {'p1': 1, 'p2': 5},
        mains: [
          main('m1', [cart('c1', [])]),
        ],
      );
      await otherHolds('p1', 1);
      sales.tempCartItems = [
        line(stocked('p1', 1), 1),
        line(stocked('p2', 5), 2),
      ];
      await sales.addMultipleItemsToCart(context: context);
      await settle();
      expect(sales.currentCart().cartItems.map((l) => l.itemUuid), ['p2']);
      expect(server.heldBy('phone', 'c1', 'p2'), 2);
      expect(server.heldBy('phone', 'c1', 'p1'), 0);
      expect(conflicts.single.single.productUuid, 'p1');
      expect(conflicts.single.single.available, 0);
    });
  });

  testWidgets('remove a line, clear a cart, delete a cart and a main cart: '
      'saved, then released', (tester) async {
    final context = await host(tester);
    await tester.runAsync(() async {
      final p1 = stocked('p1', 9);
      final p2 = stocked('p2', 9);
      final c1Line = line(p2, 1);
      await prepare(
        stock: {'p1': 9, 'p2': 9},
        mains: [
          main('m1', [
            cart('c1', [line(p1, 1), c1Line]),
            cart('c2', [line(p1, 1)]),
          ]),
          main('m2', [
            cart('c3', [line(p2, 1)]),
          ]),
        ],
      );
      await client.reconcile();
      expect(server.totals(), {'p1': 2.0, 'p2': 2.0});

      await sales.removeItemFromCart(c1Line, context);
      await settle();
      expect(server.heldBy('phone', 'c1', 'p2'), 0);

      await sales.clearCart();
      await settle();
      expect(server.heldBy('phone', 'c1', 'p1'), 0);

      await sales.deleteCart(cartId: 'c2', context: context);
      await settle();
      expect(server.heldBy('phone', 'c2', 'p1'), 0);

      await sales.deleteMainCart('m2');
      await settle();
      expect(server.holds, isEmpty);
    });
  });

  testWidgets('switch a draft to a receipt: all lines held at once or no '
      'switch; back to a draft releases them; a loaded draft holds nothing', (
    tester,
  ) async {
    final context = await host(tester);
    await tester.runAsync(() async {
      final p1 = stocked('p1', 2);
      final p2 = stocked('p2', 5);
      await prepare(
        stock: {'p1': 2, 'p2': 5},
        mains: [
          main('m1', [
            cart('c1', [line(p1, 2), line(p2, 1)], type: 4),
          ]),
        ],
      );
      await client.reconcile();
      expect(server.holds, isEmpty);
      await otherHolds('p1', 1);

      sales.switchInvoiceSale(value: 1, context: context);
      await settle();
      expect(sales.currentCart().cartItemTypeIndex, 4);
      expect(server.heldBy('phone', 'c1', 'p2'), 0);

      await server.release(device: 'other');
      // The server's `stock` event.
      client.onStock(server.totals(['p1']));
      sales.switchInvoiceSale(value: 1, context: context);
      await settle();
      expect(sales.currentCart().cartItemTypeIndex, 1);
      expect(server.totals(), {'p1': 2.0, 'p2': 1.0});

      sales.switchInvoiceSale(value: 4, context: context);
      await settle();
      expect(sales.currentCart().cartItemTypeIndex, 4);
      expect(server.holds, isEmpty);
    });
    await tester.pump();
    // The conflict dialog, for this cart: nothing to go to.
    expect(find.text('Insufficient Stock'), findsOneWidget);
    expect(
      find.textContaining('Other tills hold some of the stock this cart'),
      findsOneWidget,
    );
    expect(find.text('Default 1 · Cart 1'), findsOneWidget);
    expect(find.text('2 Unit(s)'), findsOneWidget);
    expect(find.text('1 Unit(s)'), findsOneWidget);
    expect(find.text('Go to Cart'), findsNothing);
  });

  testWidgets('a receipt edit opens holding nothing; adding to it holds the '
      'increase only, and the local check credits its original lines', (
    tester,
  ) async {
    final context = await host(tester);
    await tester.runAsync(() async {
      // 1 in stock; the receipt being edited already took 2.
      final p1 = stocked('p1', 1);
      final original = [line(p1, 2)];
      final edit = cart(
        'e1',
        [line(p1, 2, uuid: 'x')],
        receiptEdit: 'r-1',
        original: original,
      );
      await prepare(
        stock: {'p1': 1},
        mains: [
          main('m1', [edit]),
        ],
      );
      await client.reconcile();
      expect(server.holds, isEmpty);

      // 3 in all: 2 back from the original + the 1 in stock.
      expect(
        await sales.addItemToCart(
          context: context,
          newItem: line(p1, 1),
          isCustomEdit: false,
        ),
        'Quantity Updated Successfully',
      );
      await settle();
      expect(server.heldBy('phone', 'e1', 'p1'), 1);

      // 4 doesn't fit: refused by the local check, before the server.
      expect(
        await sales.addItemToCart(
          context: context,
          newItem: line(p1, 1),
          isCustomEdit: false,
        ),
        'Quantity Limit Exceeded',
      );
      expect(sales.currentCart().cartItems.single.quantity, 3);
    });
    await tester.pump();
    expect(find.text('Quantity Limit Reached'), findsOneWidget);
  });

  test('the local check credits an edit\'s original lines like the '
      'checkout check; another edit cart counts only what it adds', () async {
    final p1 = stocked('p1', 1);
    // Being edited (current): sold 2 before, 2 in the cart now.
    final edit = cart(
      'e1',
      [line(p1, 2, uuid: 'x')],
      receiptEdit: 'r-1',
      original: [line(p1, 2)],
    );
    // Another edit, of a receipt that sold 3: now 4 (adds 1).
    final other = cart(
      'e2',
      [line(p1, 4, uuid: 'y')],
      receiptEdit: 'r-2',
      original: [line(p1, 3)],
    );
    await prepare(
      stock: {'p1': 2},
      mains: [
        main('m1', [edit, other]),
      ],
    );
    final x = edit.cartItems.single;

    bool canAdd(double total) => sales.canAddProductToCart(
      newCartItem: x,
      quantityToAdd: total,
      isEdit: true,
    );

    // 2 in stock − 1 the other edit adds + 2 back = 3 for this line.
    expect(canAdd(3), isTrue);
    expect(canAdd(4), isFalse);
    // A new line in the edit: the cart's 2 lines are credited too.
    expect(
      sales.canAddProductToCart(
        newCartItem: line(p1, 1),
        quantityToAdd: 1,
        isEdit: false,
      ),
      isTrue,
    );
    expect(
      sales.canAddProductToCart(
        newCartItem: line(p1, 2),
        quantityToAdd: 2,
        isEdit: false,
      ),
      isFalse,
    );
    // The checkout check (this cart only) credits the same 2: 3 passes;
    // 5 is more than stock + original.
    x.quantity = 3;
    expect(sales.checkoutStockConflict(), isNull);
    x.quantity = 5;
    expect(sales.checkoutStockConflict(), isNotNull);
    x.quantity = 2;
    expect(sales.remainingQttyInAllCarts(newCartItem: x, isEdit: true), 3);
  });

  test('the product card while editing shows what the cashier can still '
      'add: the on-screen edit gets its original back; another edit '
      'counts only what it adds', () async {
    final p1 = stocked('p1', 2);
    // On screen: sold 2 before, still 2 in the cart.
    final edit = cart(
      'e1',
      [line(p1, 2, uuid: 'x')],
      receiptEdit: 'r-1',
      original: [line(p1, 2)],
    );
    // Another edit, of a receipt that sold 3: now 4 (adds 1).
    final other = cart(
      'e2',
      [line(p1, 4, uuid: 'y')],
      receiptEdit: 'r-2',
      original: [line(p1, 3)],
    );
    await prepare(
      stock: {'p1': 2},
      mains: [
        main('m1', [edit, other]),
      ],
    );

    bool canAddLine(double q) => sales.canAddProductToCart(
      newCartItem: line(p1, q),
      quantityToAdd: q,
      isEdit: false,
    );

    // 2 in stock − 1 the other edit adds: 1 more for this edit.
    expect(sales.remainingItemQttyInAllCarts(product: p1), 1);
    expect(canAddLine(1), isTrue);
    expect(canAddLine(2), isFalse);

    // After adding it, none left, and none can be added.
    edit.cartItems.single.quantity = 3;
    expect(sales.remainingItemQttyInAllCarts(product: p1), 0);
    expect(canAddLine(1), isFalse);

    // The other edit on screen instead: its original 3 back in full;
    // this one (3 for an original 2) adds 1.
    sales.cartIdCache = 'e2';
    expect(sales.remainingItemQttyInAllCarts(product: p1), 0);
    expect(canAddLine(1), isFalse);
    edit.cartItems.single.quantity = 2;
    expect(sales.remainingItemQttyInAllCarts(product: p1), 1);
    expect(canAddLine(1), isTrue);
  });

  testWidgets('a re-sync conflict with no page at hand: the dialog through '
      'the app navigator; Go to Cart jumps to that cart', (tester) async {
    await host(tester, navigator: navigatorKey);
    StockConflictPresenter().start();
    addTearDown(StockConflictPresenter().stop);
    // As on the sales page (Go to Cart then needn't open it).
    LanStockBanner.salesPagesOpen = 1;
    addTearDown(() => LanStockBanner.salesPagesOpen = 0);
    await tester.runAsync(() async {
      final p1 = stocked('p1', 2);
      await prepare(
        stock: {'p1': 2},
        mains: [
          main('m1', [
            cart('c1', []),
            cart('c2', [line(p1, 2)]),
          ]),
        ],
      );
      await otherHolds('p1', 1);
      await client.resync();
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pumpAndSettle();
    expect(find.text('Stock Held by Other Tills'), findsOneWidget);
    expect(find.text('Default 1 · Cart 2'), findsOneWidget);
    // Tapped on the real clock: the jump's work (its cart writes, the
    // stock calls it starts) runs there and is awaited here, so nothing
    // is left inside this test's fake clock for the tests after it.
    await tester.runAsync(() async {
      await tester.tap(find.text('Go to Cart'));
      await client.stop();
      await CartFunc().cartBox.flush();
    });
    await tester.pumpAndSettle();
    expect(sales.cartIdCache, 'c2');
    expect(find.text('Stock Held by Other Tills'), findsNothing);
  });

  group('standalone (no LAN session)', () {
    /// As on a device that never paired: no server to ask, routed straight
    /// to Supabase.
    void standalone() {
      RemoteRouter.useSupabase();
      client.deps = LanStockClientDeps(
        link: () => null,
        route: () => LanRoute.standalone,
        carts: () => CartFunc().cartBox.values.expand((m) => m.cartQueue),
        held:
            (p) => DataProvider().productListMain.any(
              (x) => x.uuid == p && x.isManaged,
            ),
        queued: () => const {},
        dropQueued: (_) async {},
      );
    }

    tearDown(RemoteRouter.useSupabase);

    testWidgets('add many: an item over its stock is skipped silently, as '
        'before LAN sync; on the store\'s network the same skip is listed',
        (tester) async {
      final context = await host(tester);
      await tester.runAsync(() async {
        await prepare(
          stock: {'p1': 1},
          mains: [
            main('m1', [cart('c1', [])]),
          ],
        );
        standalone();
        sales.tempCartItems = [line(stocked('p1', 1), 3)];
        await sales.addMultipleItemsToCart(context: context);
        await settle();
        expect(sales.currentCart().cartItems, isEmpty);
        expect(conflicts, isEmpty);

        // The server can't be reached: the local check's skip is listed.
        RemoteRouter.useNothing();
        await sales.addMultipleItemsToCart(context: context);
        await settle();
        expect(sales.currentCart().cartItems, isEmpty);
        expect(conflicts.single.single.productUuid, 'p1');
      });
    });

    test('an edit is credited its original lines: in full on screen; '
        'another edit counts only what it adds', () async {
      final p1 = stocked('p1', 1);
      final edit = cart(
        'e1',
        [line(p1, 2, uuid: 'x')],
        receiptEdit: 'r-1',
        original: [line(p1, 2)],
      );
      final other = cart(
        'e2',
        [line(p1, 4, uuid: 'y')],
        receiptEdit: 'r-2',
        original: [line(p1, 3)],
      );
      await prepare(
        stock: {'p1': 2},
        mains: [
          main('m1', [edit, other]),
        ],
      );
      standalone();
      final x = edit.cartItems.single;
      expect(sales.reservedElsewhere('p1'), 0);

      // 2 in stock − 1 the other edit adds + 2 back = 3 for this line.
      expect(
        sales.canAddProductToCart(newCartItem: x, quantityToAdd: 3, isEdit: true),
        isTrue,
      );
      expect(
        sales.canAddProductToCart(newCartItem: x, quantityToAdd: 4, isEdit: true),
        isFalse,
      );
      expect(sales.remainingQttyInAllCarts(newCartItem: x, isEdit: true), 3);
      // The product card: on-screen edit fully credited, the other counts 1.
      expect(sales.totalItemQuantityInAllCarts(product: p1), 1);
    });
  });
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/components/lan_stock_banner.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/sales/make_sales/page1/make_sales_page.dart';
import 'package:stockall/providers/sales_provider.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/lan/stock/lan_holds.dart';
import 'package:stockall/services/lan/stock/lan_stock_client.dart';
import 'package:stockall/services/navigation_service.dart';

/// One product a cart couldn't get, as the conflict dialog shows it.
class StockConflictRow {
  const StockConflictRow({
    required this.product,
    required this.cart,
    required this.wanted,
    required this.available,
    this.mainCartId,
    this.cartId,
  });

  final String product;
  final String cart;
  final String wanted;
  final String available;

  /// The cart, when it is still on this device (for "Go to Cart").
  final String? mainCartId;
  final String? cartId;
}

/// Holds the store server couldn't give: after a re-sync,
/// a cart type switch, or items skipped by add many. Lists each product,
/// its cart, what the cart wants and what is available, with "Go to Cart"
/// (the first cart still here, when it isn't the one on screen) and "OK".
/// One widget for every width, laid out like `DuplicateCartItemAlert`.
class StockConflictAlert extends StatelessWidget {
  const StockConflictAlert({
    super.key,
    required this.theme,
    required this.rows,
    this.title = 'Stock Held by Other Tills',
    this.message =
        'Other tills hold some of the stock these carts need. Reduce the '
            'quantities or remove these items before checking out.',
    this.onGoToCart,
  });

  final ThemeProvider theme;
  final List<StockConflictRow> rows;
  final String title;
  final String message;

  /// Null: no "Go to Cart" button.
  final VoidCallback? onGoToCart;

  @override
  Widget build(BuildContext context) {
    final isMobile = screenWidth(context) < mobileScreen;
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      contentPadding: const EdgeInsets.all(15),
      backgroundColor: Colors.white,
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: SizedBox(
          width: 620,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              const SizedBox(height: 5),
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.orange.shade700,
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: theme.mobileTexts.h3.fontSize,
                  fontWeight: theme.mobileTexts.h3.fontWeightBold,
                ),
              ),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: theme.mobileTexts.b2.fontSize,
                  color: Colors.grey.shade700,
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: SingleChildScrollView(
                  child: isMobile ? _cards() : _table(),
                ),
              ),
              const SizedBox(height: 4),
              if (isMobile)
                Column(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (onGoToCart != null) _goToCart(context),
                    _ok(context),
                  ],
                )
              else
                Row(
                  spacing: 10,
                  children: [
                    Expanded(flex: 2, child: _ok(context)),
                    if (onGoToCart != null)
                      Expanded(flex: 3, child: _goToCart(context)),
                  ],
                ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle get _cell => TextStyle(fontSize: theme.mobileTexts.b3.fontSize);

  TextStyle get _head => TextStyle(
    fontSize: theme.mobileTexts.b3.fontSize,
    fontWeight: FontWeight.bold,
    color: Colors.grey.shade700,
  );

  Widget _table() {
    Widget row(List<String> cells, TextStyle style) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text(cells[0], style: style)),
          Expanded(flex: 3, child: Text(cells[1], style: style)),
          Expanded(
            flex: 2,
            child: Text(cells[2], style: style, textAlign: TextAlign.end),
          ),
          Expanded(
            flex: 2,
            child: Text(cells[3], style: style, textAlign: TextAlign.end),
          ),
        ],
      ),
    );
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Container(
            color: Colors.grey.shade100,
            child: row(['Item', 'Cart', 'Wanted', 'Available'], _head),
          ),
          for (final r in rows) ...[
            Divider(height: 1, color: Colors.grey.shade200),
            row([r.product, r.cart, r.wanted, r.available], _cell),
          ],
        ],
      ),
    );
  }

  Widget _cards() => Column(
    spacing: 8,
    children: [
      for (final r in rows)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.orange.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Text(
                r.product,
                style: _cell.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(r.cart, style: _cell.copyWith(color: Colors.grey.shade700)),
              Text(
                'Wanted ${r.wanted} · Available ${r.available}',
                style: _cell,
              ),
            ],
          ),
        ),
    ],
  );

  Widget _button(
    BuildContext context, {
    required String label,
    required Color background,
    required Color text,
    required VoidCallback onTap,
  }) {
    return Ink(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: background,
      ),
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        borderRadius: BorderRadius.circular(5),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: theme.mobileTexts.b3.fontSize,
                fontWeight: FontWeight.bold,
                color: text,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _ok(BuildContext context) => _button(
    context,
    label: 'OK',
    background: Colors.grey.shade200,
    text: Colors.grey.shade800,
    onTap: () => Navigator.of(context).pop(),
  );

  Widget _goToCart(BuildContext context) => _button(
    context,
    label: 'Go to Cart',
    background: theme.lightModeColor.prColor300,
    text: Colors.white,
    onTap: () {
      Navigator.of(context).pop();
      onGoToCart?.call();
    },
  );
}

/// The rows for [conflicts]: product names and amounts in the product's
/// primary unit, carts by their label ("Default 1 · Cart 2"); a cart no
/// longer here is a sale already checked out.
List<StockConflictRow> stockConflictRows(List<LanStockConflict> conflicts) {
  final sales = SalesProvider();
  String amount(TempProductClass? product, double quantity) {
    final q = quantity < 0 ? 0.0 : quantity;
    if (product == null) return formatDimension(q);
    final unit = product.getPrimaryUnit();
    final value = unit.getQuantityEquivDivided(
      index: 1,
      newQuantity: q,
      product: product,
    );
    return '${formatDimension(value)} ${unit.name}';
  }

  return [
    for (final c in conflicts)
      () {
        final product =
            returnData().productListMain
                .where((p) => p.uuid == c.productUuid)
                .firstOrNull;
        String? mainId;
        var cartLabel = 'Checked-out sale';
        for (final main in sales.mainCartQueue) {
          final i = main.cartQueue.indexWhere((cart) => cart.id == c.cartId);
          if (i < 0) continue;
          mainId = main.mainCartId;
          cartLabel = '${sales.mainCartLabel(main)} · Cart ${i + 1}';
          break;
        }
        return StockConflictRow(
          product: product?.name ?? 'Item',
          cart: cartLabel,
          wanted: amount(product, c.wanted),
          available: amount(product, c.available ?? c.held),
          mainCartId: mainId,
          cartId: mainId == null ? null : c.cartId,
        );
      }(),
  ];
}

/// Shows the conflict dialog for [conflicts]. "Go to Cart" jumps to the
/// first of their carts still here that isn't the one on screen, opening
/// the sales page when none is open.
Future<void> showStockConflicts(
  BuildContext context,
  List<LanStockConflict> conflicts, {
  String? title,
  String? message,
}) async {
  if (conflicts.isEmpty) return;
  final rows = stockConflictRows(conflicts);
  final sales = SalesProvider();
  final target =
      rows
          .where((r) => r.cartId != null && r.cartId != sales.cartIdCache)
          .firstOrNull;
  await showDialog<void>(
    context: context,
    builder:
        (_) => StockConflictAlert(
          theme: returnTheme(context, listen: false),
          rows: rows,
          title: title ?? 'Stock Held by Other Tills',
          message:
              message ??
              'Other tills hold some of the stock these carts need. Reduce the '
                  'quantities or remove these items before checking out.',
          onGoToCart:
              target == null
                  ? null
                  : () async {
                    await sales.jumpToCart(
                      mainCartId: target.mainCartId!,
                      cartId: target.cartId!,
                    );
                    if (LanStockBanner.salesPagesOpen > 0) return;
                    final nav = navigatorKey.currentState;
                    await nav?.push(
                      MaterialPageRoute(builder: (_) => MakeSalesPage()),
                    );
                  },
        ),
  );
}

/// Shows the conflicts the stock client reports with no page at hand
/// (re-sync, the safety net, add many) through [navigatorKey], one dialog
/// at a time; conflicts arriving meanwhile come in the next one.
class StockConflictPresenter {
  static final StockConflictPresenter _instance =
      StockConflictPresenter._internal();
  factory StockConflictPresenter() => _instance;
  StockConflictPresenter._internal();

  StreamSubscription<List<LanStockConflict>>? _sub;
  final List<LanStockConflict> _waiting = [];
  bool _showing = false;

  /// Main window only.
  void start() {
    _sub ??= LanStockClient().conflicts.listen((conflicts) {
      _waiting.addAll(conflicts);
      unawaited(_showNext());
    });
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    _waiting.clear();
  }

  Future<void> _showNext() async {
    if (_showing || _waiting.isEmpty) return;
    final context = navigatorKey.currentContext;
    if (context == null) return;
    // The latest per (cart, product).
    final batch =
        {
          for (final c in _waiting) (c.cartId, c.productUuid): c,
        }.values.toList();
    _waiting.clear();
    _showing = true;
    try {
      await showStockConflicts(context, batch);
    } catch (e) {
      await mainLocalLog('Stock conflict dialog failed: $e');
    } finally {
      _showing = false;
    }
    if (_waiting.isNotEmpty) unawaited(_showNext());
  }
}

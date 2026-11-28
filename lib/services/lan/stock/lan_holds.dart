import 'package:stockall/classes/temp_cart/temp_cart.dart';
import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';

/// What the carts of this device need the store server to hold.
/// Pure: no I/O, no providers.

const double lanHoldEps = 1e-9;

/// One cart's hold of one product.
typedef LanHoldKey = ({String cart, String product});

/// Receipt (1) and invoice (2) carts hold stock; orders (3) and drafts (4)
/// don't (as `SalesProvider.isStockFreeCartType`).
bool cartHoldsStock(TempCart cart) =>
    cart.cartItemTypeIndex != 3 && cart.cartItemTypeIndex != 4;

/// A receipt or invoice edit: its original lines ([TempCart.tempCartItems])
/// are already out of stock, so it holds only what it adds.
bool isEditCart(TempCart cart) =>
    cart.receiptUuidEdit != null || cart.invoiceUuidEdit != null;

String? lineProduct(TempCartItem line) {
  final uuid = line.itemUuid ?? line.item.uuid;
  return uuid == null || uuid.isEmpty ? null : uuid;
}

/// Stock [lines] need per product, in stock units
/// (`getStockQuantity()`: area and wastage for 2D items). Void lines need
/// nothing.
Map<String, double> stockByProduct(Iterable<TempCartItem> lines) {
  final out = <String, double>{};
  for (final line in lines) {
    if (line.isVoid == true) continue;
    final product = lineProduct(line);
    if (product == null) continue;
    out[product] = (out[product] ?? 0) + line.getStockQuantity();
  }
  return out;
}

/// What [cart]'s lines need of [product], leaving out [without] (the line
/// a change replaces), plus [plus].
double cartNeedOf(
  TempCart cart,
  String product, {
  TempCartItem? without,
  double plus = 0,
}) {
  var total = plus;
  for (final line in cart.cartItems) {
    if (line.isVoid == true || lineProduct(line) != product) continue;
    if (without != null &&
        (identical(line, without) ||
            (without.uuid != null && line.uuid == without.uuid))) {
      continue;
    }
    total += line.getStockQuantity();
  }
  return total;
}

/// The hold [cart] needs of [product] when its lines need [needed] of it:
/// nothing for a stock-free cart; for an edit, only the increase over the
/// original lines. [holdsStock] overrides the cart's type (a switch to a
/// receipt or invoice, before it is saved).
double cartHoldFor(
  TempCart cart,
  String product,
  double needed, {
  bool? holdsStock,
}) {
  if (!(holdsStock ?? cartHoldsStock(cart))) return 0;
  var hold = needed;
  if (isEditCart(cart)) {
    hold -= stockByProduct(cart.tempCartItems ?? const [])[product] ?? 0;
  }
  return hold > lanHoldEps ? hold : 0;
}

/// Every hold [carts] need, for the products [held] says the server holds
/// (managed stock products; custom and unmanaged items are free).
Map<LanHoldKey, double> cartHolds(
  Iterable<TempCart> carts, {
  required bool Function(String product) held,
}) {
  final out = <LanHoldKey, double>{};
  for (final cart in carts) {
    final id = cart.id;
    if (id == null || id.isEmpty || !cartHoldsStock(cart)) continue;
    for (final e in stockByProduct(cart.cartItems).entries) {
      if (!held(e.key)) continue;
      final hold = cartHoldFor(cart, e.key, e.value);
      if (hold > 0) out[(cart: id, product: e.key)] = hold;
    }
  }
  return out;
}

/// The holds to send so [held] becomes [wanted]: each key whose amount
/// differs, with its new amount (0 releases it).
Map<LanHoldKey, double> holdDiff(
  Map<LanHoldKey, double> wanted,
  Map<LanHoldKey, double> held,
) {
  final out = <LanHoldKey, double>{};
  for (final key in {...wanted.keys, ...held.keys}) {
    final want = wanted[key] ?? 0;
    if ((want - (held[key] ?? 0)).abs() > lanHoldEps) out[key] = want;
  }
  return out;
}

/// How this device reaches its store server's stock holds: over the LAN
/// client's RPCs, or in process on the server itself.
class LanStockLink {
  const LanStockLink({
    required this.call,
    this.inProcess = false,
    this.reservedElsewhere,
  });

  /// One of the `lan_stock_*` / `lan_checkout` RPCs: its JSON answer.
  final Future<Map<String, dynamic>> Function(
    String rpc,
    Map<String, dynamic> params,
  )
  call;

  /// This device is the server: its own till.
  final bool inProcess;

  /// In process: what other devices hold of a product, read directly.
  final double Function(String product)? reservedElsewhere;
}

/// A hold the server couldn't give in full.
class LanStockConflict {
  const LanStockConflict({
    required this.cartId,
    required this.productUuid,
    required this.wanted,
    required this.held,
    this.available,
  });

  factory LanStockConflict.fromJson(Map<String, dynamic> json) =>
      LanStockConflict(
        cartId: json['cart_id'] as String,
        productUuid: json['product_uuid'] as String,
        wanted: (json['wanted'] as num).toDouble(),
        held: (json['held'] as num).toDouble(),
        available: (json['available'] as num?)?.toDouble(),
      );

  final String cartId;
  final String productUuid;
  final double wanted;
  final double held;
  final double? available;

  @override
  String toString() =>
      'LanStockConflict($cartId, $productUuid, wanted $wanted, held $held, '
      'available $available)';
}

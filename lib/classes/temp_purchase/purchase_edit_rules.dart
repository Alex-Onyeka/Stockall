import 'package:stockall/classes/temp_purchase/temp_purchase.dart';

// Pure rules for editing a purchase in place, kept out of the
// providers so they can be tested without Supabase or Hive.

/// Changes this small are float noise, not a stock change.
const double purchaseStockTolerance = 1e-6;

/// Stored quantity per item, summed over [lines] (item uuid to
/// quantity in the item's stored unit).
Map<String, double> stockByItem(
  Iterable<MapEntry<String, double>> lines,
) {
  final stock = <String, double>{};
  for (final line in lines) {
    stock[line.key] = (stock[line.key] ?? 0) + line.value;
  }
  return stock;
}

/// Net stock change per item when a purchase goes from [oldStock]
/// to [newStock]: new minus old. Items removed from the purchase
/// come out negative, items added positive. Items whose change is
/// within [purchaseStockTolerance] are left out.
Map<String, double> purchaseStockDeltas(
  Map<String, double> oldStock,
  Map<String, double> newStock,
) {
  final deltas = <String, double>{};
  for (final key in {...oldStock.keys, ...newStock.keys}) {
    final delta = (newStock[key] ?? 0) - (oldStock[key] ?? 0);
    if (delta.abs() > purchaseStockTolerance) {
      deltas[key] = delta;
    }
  }
  return deltas;
}

/// Only purchases with stored lines can be edited. Older purchases
/// have none, so saving an edit would wipe their lines and leave
/// stock wrong.
bool canEditPurchase(TempPurchase purchase) =>
    purchase.items?.isNotEmpty == true;

/// The copy of a queued purchase update to send: the current local
/// copy when there is one (it holds every later local change),
/// otherwise the copy saved in the queue.
TempPurchase purchaseToPush(
  TempPurchase queued,
  TempPurchase? local,
) => local ?? queued;

/// Whether a queued purchase update should overwrite the server
/// row. It loses only to a strictly newer remote edit; on a tie it
/// is sent, since the server has nothing newer.
bool shouldPushPurchaseUpdate({
  required DateTime localUpdatedAt,
  DateTime? remoteUpdatedAt,
}) =>
    remoteUpdatedAt == null ||
    !localUpdatedAt.toUtc().isBefore(remoteUpdatedAt.toUtc());

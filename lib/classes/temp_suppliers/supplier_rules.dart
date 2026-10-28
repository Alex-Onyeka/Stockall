import 'package:stockall/classes/temp_purchase/temp_purchase.dart';

// Pure rules for editing and deleting suppliers, kept out of the
// providers so they can be tested without Supabase or Hive.

/// A supplier text field as saved: null when left blank (as on
/// create), otherwise the value as typed.
String? supplierFieldOrNull(String value) =>
    value.trim().isEmpty ? null : value;

/// Purchases bought from the supplier [supplierUuid].
int supplierPurchaseCount(
  List<TempPurchase> purchases,
  String supplierUuid,
) =>
    purchases.where((p) => p.supplierId == supplierUuid).length;

/// Shown before the delete confirmation when the supplier has
/// purchases. Null when it has none.
String? supplierDeleteWarning(int purchaseCount) {
  if (purchaseCount <= 0) return null;
  final purchases =
      purchaseCount == 1 ? '1 purchase' : '$purchaseCount purchases';
  final pronoun = purchaseCount == 1 ? 'It' : 'They';
  return 'This supplier has $purchases. $pronoun will keep the '
      "supplier's name, but the supplier will be removed.";
}

/// Purchases of [supplierUuid] whose saved supplier name is not
/// [newName] (none saved included). Purchases queued for deletion
/// are left out.
List<TempPurchase> purchasesToRename(
  List<TempPurchase> purchases, {
  required String supplierUuid,
  required String newName,
  Set<String> pendingDeletedUuids = const {},
}) {
  return purchases
      .where(
        (p) =>
            p.supplierId == supplierUuid &&
            p.supplierName != newName &&
            !pendingDeletedUuids.contains(p.uuid),
      )
      .toList();
}

/// A copy of [purchase] with only the supplier name and updatedAt
/// changed. [purchase] itself is not modified.
TempPurchase renamedPurchase(
  TempPurchase purchase,
  String newName,
  DateTime now,
) => purchase.copyWith(supplierName: newName, updatedAt: now);

import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';

// Storage ↔ sales rules. A 1D storage item only manages 1D sales
// items and a 2D storage item only 2D sales items; transfers
// between different types are blocked.

bool storageCanManage(
  TempStorageProducts storage,
  TempProductClass product,
) {
  return (storage.quantityType == 2) ==
      (product.quantityType == 2);
}

// Sales items listed in Manage Products: unlinked items of the
// same type, plus everything already linked to this storage (so
// an old mismatched link can still be removed).
List<TempProductClass> manageableProducts({
  required TempStorageProducts storage,
  required List<TempProductClass> products,
}) {
  return products
      .where(
        (product) =>
            product.storageUuid == storage.uuid ||
            (product.storageUuid == null &&
                storageCanManage(storage, product)),
      )
      .toList();
}

// The type of a storage item can only change while it holds no
// stock and every sales item it manages already has the new type.
bool canChangeStorageType({
  required TempStorageProducts storage,
  required List<TempProductClass> managedProducts,
  required int newQuantityType,
}) {
  if ((storage.quantityType == 2) == (newQuantityType == 2)) {
    return true;
  }
  if ((storage.quantity ?? 0) != 0) {
    return false;
  }
  return managedProducts.every(
    (product) =>
        (product.quantityType == 2) == (newQuantityType == 2),
  );
}

enum StorageTransferMode { stockIn, stockOut, update }

class StorageTypeMismatch implements Exception {
  final String storageName;
  final String productName;

  StorageTypeMismatch({
    required this.storageName,
    required this.productName,
  });

  @override
  String toString() =>
      'StorageTypeMismatch: $productName and storage item $storageName have different dimension types.';
}

// New stored quantities after a storage transfer. Stored values
// are sheet counts for 2D items; the changes are signed.
class StorageTransferResult {
  final double storageQuantity;
  final double storageChange;
  final double? salesQuantity;
  final double? salesChange;

  const StorageTransferResult({
    required this.storageQuantity,
    required this.storageChange,
    required this.salesQuantity,
    required this.salesChange,
  });
}

// [actualAmount] is in getActualQuantity units (area for 2D
// items): the amount moved, or the new storage total for
// update. Area is kept on both sides and each side converts
// back with its own dimensionArea(), so sheets of different
// sizes stay correct (part sheets allowed).
//   stockIn  with sales: sales → storage (return)
//   stockIn  without sales: added to storage
//   stockOut with sales: storage → sales
StorageTransferResult computeStorageTransfer({
  required StorageTransferMode mode,
  required TempStorageProducts storage,
  TempProductClass? sales,
  required double actualAmount,
}) {
  if (sales != null && !storageCanManage(storage, sales)) {
    throw StorageTypeMismatch(
      storageName: storage.name,
      productName: sales.name,
    );
  }
  final storageActual = storage.getActualQuantity() ?? 0;
  final salesActual = sales?.getActualQuantity() ?? 0;

  double newStorageActual;
  double? newSalesActual;
  switch (mode) {
    case StorageTransferMode.stockIn:
      newStorageActual = storageActual + actualAmount;
      if (sales != null) {
        newSalesActual = salesActual - actualAmount;
      }
      break;
    case StorageTransferMode.stockOut:
      newStorageActual = storageActual - actualAmount;
      if (sales != null) {
        newSalesActual = salesActual + actualAmount;
      }
      break;
    case StorageTransferMode.update:
      newStorageActual = actualAmount;
      break;
  }

  final storageQuantity =
      newStorageActual / storage.dimensionArea();
  final salesQuantity =
      newSalesActual == null
          ? null
          : newSalesActual / sales!.dimensionArea();
  return StorageTransferResult(
    storageQuantity: storageQuantity,
    storageChange: storageQuantity - (storage.quantity ?? 0),
    salesQuantity: salesQuantity,
    salesChange:
        salesQuantity == null
            ? null
            : salesQuantity - (sales!.quantity ?? 0),
  );
}

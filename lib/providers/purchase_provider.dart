import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/classes/temp_item_history/item_history_event_class.dart';
import 'package:stockall/classes/temp_item_purchase_record/temp_item_purchase_record.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_purchase/purchase_edit_rules.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/classes/temp_purchase/unsynced/created_purchases/created_purchases.dart';
import 'package:stockall/classes/temp_purchase/unsynced/deleted_purchase/deleted_purchases.dart';
import 'package:stockall/classes/temp_purchase/unsynced/updated/updated_purchases.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history_event_class.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';
import 'package:stockall/classes/temp_suppliers/supplier_rules.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/generate_barcode.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/local_database/purchases/purchase_func.dart';
import 'package:stockall/local_database/purchases/unsync_funcs/created/created_purchases_func.dart';
import 'package:stockall/local_database/purchases/unsync_funcs/deleted/deleted_purchases_func.dart';
import 'package:stockall/local_database/purchases/unsync_funcs/updated/updated_purchases_func.dart';
import 'package:stockall/local_database/storage_product/storage_products_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PurchaseProvider extends ChangeNotifier {
  static final PurchaseProvider _instance =
      PurchaseProvider._internal();
  factory PurchaseProvider() => _instance;
  PurchaseProvider._internal();
  bool isLoading = false;
  void toggleIsLoading(bool value) {
    isLoading = value;
    mainLocalLog(
      'Purchase is ${value ? 'Loading on' : 'Loading Off'}',
    );
    notifyListeners();
  }
  //
  //
  //

  final SupabaseClient supabase = Supabase.instance.client;
  final ConnectivityProvider connectivity =
      ConnectivityProvider();
  List<TempPurchase> _purchases = [];
  List<TempPurchase> get purchases => _purchases;
  final Set<String> _reversedPurchaseIds = {};

  final String tableName = 'purchases';
  final String itemPurchaseTableName =
      'item_purchase_records';

  void clearPurchases() {
    _purchases.clear();
    _reversedPurchaseIds.clear();
    // clearRecords();
    mainLocalLog('Purchases Cleared');
    notifyListeners();
  }

  // CREATE a new Purchase
  Future<TempPurchase?> createPurchase(
    TempPurchase purchase,
  ) async {
    await mainLocalLog('Inner Purchase Creation Started');
    if (purchase.uuid != null) {
      _reversedPurchaseIds.remove(purchase.uuid!);
    }
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      purchase.createdAt = DateTime.now().subtract(
        Duration(hours: 1),
      );
      try {
        final res =
            await supabase
                .from(tableName)
                .upsert(
                  purchase.toJson(),
                  onConflict: 'uuid',
                )
                .select()
                .single();
        final newPurchase = TempPurchase.fromJson(res);
        await PurchaseFunc().createPurchase(newPurchase);
        notifyListeners();
        // await loadPurchases(shopId());
        return newPurchase;
      } catch (e) {
        await mainLocalLog(
          '❌❌ Create Purchase Error Online: ${e.toString()}',
        );
        return null;
      }
    } else {
      try {
        purchase.createdAt = DateTime.now();
        await PurchaseFunc().createPurchase(purchase);
        await CreatedPurchasesFunc().createPurchases(
          CreatedPurchases(purchase: purchase),
        );
        notifyListeners();
        // await loadPurchases(shopId());
        return purchase;
      } catch (e) {
        await mainLocalLog(
          '❌❌ Create Purchase Error Offline: ${e.toString()}',
        );
        return null;
      }
    }
  }

  // CREATE a new Purchase
  Future<TempPurchase?> updatePurchase(
    TempPurchase purchase,
  ) async {
    await mainLocalLog('Inner Purchase Update Started');
    if (purchase.uuid != null) {
      _reversedPurchaseIds.remove(purchase.uuid!);
    }
    bool isOnline = await connectivity.isOnline();
    purchase.updatedAt = DateTime.now();
    if (isOnline) {
      try {
        final res =
            await supabase
                .from(tableName)
                .upsert(
                  purchase.toJson(),
                  onConflict: 'uuid',
                )
                .select()
                .single();
        final newPurchase = TempPurchase.fromJson(res);
        await PurchaseFunc().createPurchase(newPurchase);
        notifyListeners();
        await loadPurchases(shopId());
        return newPurchase;
      } catch (e) {
        await mainLocalLog(
          '❌❌ Update Purchase Error Online: ${e.toString()}',
        );
        return null;
      }
    } else {
      try {
        var res = await PurchaseFunc().createPurchase(
          purchase,
        );
        if (res == 1) {
          var containsCreated =
              CreatedPurchasesFunc()
                  .getPurchases()
                  .where(
                    (createdProduct) =>
                        createdProduct.purchase.uuid ==
                        purchase.uuid,
                  )
                  .toList();
          if (containsCreated.isEmpty) {
            await UpdatedPurchasesFunc()
                .createUpdatedPurchase(
                  UpdatedPurchases(purchase: purchase),
                );
          } else {
            await CreatedPurchasesFunc().createPurchases(
              CreatedPurchases(purchase: purchase),
            );
          }
        } else {
          notifyListeners();
          return null;
        }
        await loadPurchases(shopId());
        syncData();
        return purchase;
      } catch (e) {
        await mainLocalLog(
          '❌❌ Create Purchase Error Offline: ${e.toString()}',
        );
        return null;
      }
    }
  }

  /// Saves [name] as the supplier name of every purchase of
  /// [supplierUuid] (after the supplier is renamed). Only
  /// supplier_name and updated_at change: no stock, payment, total
  /// or date. Online it is one partial update on the server, so
  /// payments saved elsewhere are never overwritten; offline (or
  /// if that fails) the purchases are queued like any purchase
  /// edit. Returns the number of local purchases changed.
  Future<int> renameSupplierOnPurchases({
    required String supplierUuid,
    required String name,
  }) async {
    final now = DateTime.now();
    var local = _purchases;
    if (local.isEmpty) local = PurchaseFunc().getPurchases();
    final renamed =
        purchasesToRename(
          local,
          supplierUuid: supplierUuid,
          newName: name,
          pendingDeletedUuids:
              DeletedPurchasesFunc()
                  .getPurchaseIds()
                  .map((d) => d.purchaseUuid)
                  .toSet(),
        ).map((p) => renamedPurchase(p, name, now)).toList();

    bool isOnline = await connectivity.isOnline();
    if (!isOnline && renamed.isEmpty) return 0;

    var updatedOnline = false;
    if (isOnline) {
      try {
        // The local list may be incomplete: the server update
        // covers every purchase of the supplier.
        await supabase
            .from(tableName)
            .update({
              'supplier_name': name,
              'updated_at': now.toUtc().toIso8601String(),
            })
            .eq('supplier_id', supplierUuid)
            .eq('shop_id', shopId());
        updatedOnline = true;
        for (final purchase in renamed) {
          await PurchaseFunc().createPurchase(purchase);
        }
      } catch (e) {
        await mainLocalLog(
          '❌❌ Rename Supplier On Purchases Error Online: ${e.toString()}',
        );
      }
    }

    if (!updatedOnline) {
      final created =
          CreatedPurchasesFunc()
              .getPurchases()
              .map((c) => c.purchase.uuid)
              .toSet();
      for (final purchase in renamed) {
        await PurchaseFunc().createPurchase(purchase);
        if (created.contains(purchase.uuid)) {
          await CreatedPurchasesFunc().createPurchases(
            CreatedPurchases(purchase: purchase),
          );
        } else {
          await UpdatedPurchasesFunc().createUpdatedPurchase(
            UpdatedPurchases(purchase: purchase),
          );
        }
      }
      syncData();
    }

    await loadPurchases(shopId());
    return renamed.length;
  }

  // READ all Purchases for a shop
  Future<List<TempPurchase>> loadPurchases(
    int shopId,
  ) async {
    bool isOnline = await connectivity.isOnline();
    if (isOnline && PurchaseFunc().isSynced()) {
      await PurchaseFunc().clearPurchases();
      try {
        final data = await supabase
            .from(tableName)
            .select()
            .eq('shop_id', shopId)
            .order('created_at', ascending: false);
        if (data.isNotEmpty) {
          await mainLocalLog(
            'Purchases Gotten ${data.length}',
          );
        }

        _purchases =
            (data as List)
                .map((json) => TempPurchase.fromJson(json))
                .toList();
        await PurchaseFunc().insertAllPurchases(_purchases);
        await mainLocalLog('Loaded');
        notifyListeners();
      } catch (e) {
        await mainLocalLog(
          '❌ Error Getting Purchases: ${e.toString()}',
        );
        return [];
      }
    } else {
      _purchases = PurchaseFunc().getPurchases();
      await mainLocalLog('Offline Purchases Gotten');
      notifyListeners();
    }
    // await loadItemPurchaseRecords(shopId);
    notifyListeners();
    return _purchases;
  }

  // READ all Purchases for a shop
  Future<List<TempPurchase>> loadPurchasesOffline() async {
    _purchases = PurchaseFunc().getPurchases();
    await mainLocalLog('Offline Purchases Gotten');
    // await loadItemPurchaseRecordsOffline();
    notifyListeners();
    return _purchases;
  }

  DateTime? dateSet;

  void clearDate() {
    dateSet = null;
    rangeStartDate = null;
    rangeEndDate = null;
    notifyListeners();
  }

  void setDate(DateTime date) {
    if (dateSet == null) {
      dateSet = date;
      rangeStartDate = null;
      rangeEndDate = null;
      mainLocalLog('Date set: $date');
    } else {
      dateSet = null;
      mainLocalLog('Date Cleared');
    }
    notifyListeners();
  }

  DateTime? rangeStartDate;
  DateTime? rangeEndDate;

  void setRange(DateTime rangeStart, DateTime endOfrange) {
    rangeStartDate = rangeStart;
    rangeEndDate = endOfrange;
    mainLocalLog(
      'Date Range set: Start: $rangeStart End: $endOfrange ',
    );
    dateSet = null;
    notifyListeners();
  }

  TempProductClass? _findProduct(String? uuid) {
    if (uuid == null || uuid.isEmpty) return null;
    final inMemory = returnData().productListMain.where(
      (prod) => prod.uuid == uuid,
    );
    if (inMemory.isNotEmpty) return inMemory.first;
    try {
      final inHive = ProductsFunc().getProducts().where(
        (prod) => prod.uuid == uuid,
      );
      if (inHive.isNotEmpty) return inHive.first;
    } catch (_) {}
    return null;
  }

  TempStorageProducts? _findStorageProduct(String? uuid) {
    if (uuid == null || uuid.isEmpty) return null;
    final inMemory = returnStorageProductProvider()
        .storageProductListMain
        .where((prod) => prod.uuid == uuid);
    if (inMemory.isNotEmpty) return inMemory.first;
    try {
      final inHive = StorageProductsFunc()
          .getStorageProducts()
          .where((prod) => prod.uuid == uuid);
      if (inHive.isNotEmpty) return inHive.first;
    } catch (_) {}
    return null;
  }

  ProductUnitsClass _resolveSelectedUnitForProduct(
    TempItemPurchaseRecord item,
    TempProductClass product,
  ) {
    final productUnits = product.getUnitsList();
    final itemUnits =
        (item.unitsList != null &&
                item.unitsList!.isNotEmpty)
            ? item.getUnitsList()
            : <ProductUnitsClass>[];
    final combinedUnits = [...itemUnits, ...productUnits];

    if (item.unitUuid != null &&
        item.unitUuid!.isNotEmpty) {
      final matched = combinedUnits.where(
        (u) => u.uuid == item.unitUuid,
      );
      if (matched.isNotEmpty) {
        final unit = matched.first;
        if (product.quantityType == 2 &&
            unit.dimensionType == null) {
          final prodMatch = productUnits.where(
            (u) =>
                u.uuid == unit.uuid ||
                u.name.toLowerCase() ==
                    unit.name.toLowerCase(),
          );
          return unit.copyWith(
            dimensionType:
                prodMatch.isNotEmpty
                    ? prodMatch.first.dimensionType
                    : ProductUnitsClass.sheetUnit,
          );
        }
        return unit;
      }
    }

    if (item.isGroup == true) {
      final groupMatched = combinedUnits.where(
        (u) => !u.isPrimary,
      );
      if (groupMatched.isNotEmpty) {
        final unit = groupMatched.first;
        final conv =
            (item.qttyPerGroup != null &&
                    item.qttyPerGroup! > 0)
                ? item.qttyPerGroup!
                : unit.conversion;
        return unit.copyWith(
          conversion: conv,
          dimensionType:
              unit.dimensionType ??
              (product.quantityType == 2
                  ? ProductUnitsClass.sheetUnit
                  : null),
        );
      }
      final fallbackConv =
          (item.qttyPerGroup != null &&
                  item.qttyPerGroup! > 0)
              ? item.qttyPerGroup!
              : (product.qttyPerGroup != null &&
                  product.qttyPerGroup! > 0)
              ? product.qttyPerGroup!
              : 1.0;
      return ProductUnitsClass(
        uuid: '${product.uuid ?? ''}_group_unit',
        staffUuid: currentUser().userId,
        createdAt: DateTime.now(),
        staffName: currentUser().name,
        conversion: fallbackConv,
        name: item.unit ?? product.groupUnit ?? 'Group(s)',
        isPrimary: false,
        productUuid: product.uuid ?? '',
        dimensionType:
            product.quantityType == 2
                ? ProductUnitsClass.sheetUnit
                : null,
      );
    }

    if (item.unit != null && item.unit!.isNotEmpty) {
      final byName = combinedUnits.where(
        (u) =>
            u.name.toLowerCase() ==
            item.unit!.toLowerCase(),
      );
      if (byName.isNotEmpty) {
        final unit = byName.first;
        if (product.quantityType == 2 &&
            unit.dimensionType == null) {
          return unit.copyWith(
            dimensionType: ProductUnitsClass.sheetUnit,
          );
        }
        return unit;
      }
    }

    return product.getPrimaryUnit();
  }

  ProductUnitsClass _resolveSelectedUnitForStorage(
    TempItemPurchaseRecord item,
    TempStorageProducts storageProduct,
  ) {
    final storageUnits = storageProduct.getUnitsList();
    final itemUnits =
        (item.unitsList != null &&
                item.unitsList!.isNotEmpty)
            ? item.getUnitsList()
            : <ProductUnitsClass>[];
    final combinedUnits = [...itemUnits, ...storageUnits];

    if (item.unitUuid != null &&
        item.unitUuid!.isNotEmpty) {
      final matched = combinedUnits.where(
        (u) => u.uuid == item.unitUuid,
      );
      if (matched.isNotEmpty) {
        return matched.first;
      }
    }

    if (item.isGroup == true) {
      final groupMatched = combinedUnits.where(
        (u) => !u.isPrimary,
      );
      if (groupMatched.isNotEmpty) {
        final unit = groupMatched.first;
        final conv =
            (item.qttyPerGroup != null &&
                    item.qttyPerGroup! > 0)
                ? item.qttyPerGroup!
                : unit.conversion;
        return unit.copyWith(conversion: conv);
      }
      final fallbackConv =
          (item.qttyPerGroup != null &&
                  item.qttyPerGroup! > 0)
              ? item.qttyPerGroup!
              : (storageProduct.qttyPerGroup != null &&
                  storageProduct.qttyPerGroup! > 0)
              ? storageProduct.qttyPerGroup!
              : 1.0;
      return ProductUnitsClass(
        uuid: '${storageProduct.uuid ?? ''}_group_unit',
        staffUuid: currentUser().userId,
        createdAt: DateTime.now(),
        staffName: currentUser().name,
        conversion: fallbackConv,
        name:
            item.unit ??
            storageProduct.groupUnit ??
            'Group(s)',
        isPrimary: false,
        productUuid: storageProduct.uuid ?? '',
      );
    }

    if (item.unit != null && item.unit!.isNotEmpty) {
      final byName = combinedUnits.where(
        (u) =>
            u.name.toLowerCase() ==
            item.unit!.toLowerCase(),
      );
      if (byName.isNotEmpty) {
        return byName.first;
      }
    }

    return storageProduct.getPrimaryUnit();
  }

  // DELETE a Purchase
  Future<int> deletePurchase(
    TempPurchase purchase,
    bool? updateInventory,
    bool createUpdate,
  ) async {
    await mainLocalLog('Deleting Purchase');
    try {
      final purchaseUuid = purchase.uuid;
      if (purchaseUuid == null || purchaseUuid.isEmpty) {
        return 0;
      }
      final recordsToDelete =
          List<TempItemPurchaseRecord>.from(
            purchase.getItems(),
          );
      final shouldReverseInventory =
          updateInventory == true &&
          !_reversedPurchaseIds.contains(purchaseUuid);
      if (shouldReverseInventory) {
        _reversedPurchaseIds.add(purchaseUuid);
      }

      await mainLocalLog('Deleting Purchase Offline');
      await PurchaseFunc().deletePurchase(purchaseUuid);
      _purchases.removeWhere((p) => p.uuid == purchaseUuid);
      var containsCreated =
          CreatedPurchasesFunc()
              .getPurchases()
              .where(
                (purch) =>
                    purch.purchase.uuid == purchaseUuid,
              )
              .toList();
      var containsUpdate = UpdatedPurchasesFunc()
          .getPurchaseIds()
          .where(
            (purch) => purch.purchase.uuid == purchaseUuid,
          );
      if (containsCreated.isNotEmpty) {
        await CreatedPurchasesFunc().deletePurchase(
          purchaseUuid,
        );
      } else {
        final alreadyMarkedDeleted = DeletedPurchasesFunc()
            .getPurchaseIds()
            .any((d) => d.purchaseUuid == purchaseUuid);
        if (!alreadyMarkedDeleted) {
          await DeletedPurchasesFunc()
              .createDeletedPurchase(
                DeletedPurchases(
                  purchaseUuid: purchaseUuid,
                ),
              );
        }
      }
      if (containsUpdate.isNotEmpty) {
        await UpdatedPurchasesFunc().deleteUpdatedPurchase(
          purchaseUuid,
        );
      }
      // await ItemPurchaseFunc().deleteRecordsInPurchase(
      //   purchaseUuid,
      // );

      final isManageStorage =
          returnShopProvider()
              .userShop()
              ?.manageInventoryStorage ==
          true;

      for (var rec in recordsToDelete) {
        // if (rec.uuid != null) {
        //   await deleteItemPurchaseRecord(rec.uuid!);
        // }

        if (shouldReverseInventory) {
          if (isManageStorage) {
            final targetStorageId =
                rec.storageItemId ?? rec.itemId;
            final storageProd = _findStorageProduct(
              targetStorageId,
            );
            if (storageProd != null) {
              var newPro = storageProd.copyWith();
              final selectedUnit =
                  _resolveSelectedUnitForStorage(
                    rec,
                    newPro,
                  );
              final primaryUnit = newPro.getPrimaryUnit();
              // Stored quantity (sheets for 2D storage items).
              final deltaQty =
                  newPro.actualFromUnit(
                    selectedUnit,
                    rec.quantity ?? 0,
                  ) /
                  newPro.dimensionArea();
              final oldQty = newPro.quantity ?? 0;
              final newQty = oldQty - deltaQty;

              try {
                var product = newPro.copyWith();
                product.updatedAt = DateTime.now();
                product.quantity = newQty;

                StorageItemHistory? newUpdate;
                if (createUpdate) {
                  newUpdate = StorageItemHistory(
                    event:
                        StorageItemHistoryEventClass
                            .purchaseDeleted,
                    source:
                        StorageItemHistoryEventClass
                            .storageSource,
                    destination:
                        StorageItemHistoryEventClass
                            .purchaseDestination,
                    shopId:
                        purchase.shopId != 0
                            ? purchase.shopId
                            : shopId(),
                    title: 'Purchase Deleted',
                    createdAt: DateTime.now(),
                    storageDepartmentName:
                        returnDepartmentProvider()
                            .currentDepartment()
                            ?.name,
                    storageDepartmentUuid:
                        returnDepartmentProvider()
                            .currentDepartment()
                            ?.uuid,
                    storageItemName: product.name,
                    storageItemUuid: product.uuid,
                    storageStaffId: currentUser().userId,
                    storageStaffName: currentUser().name,
                    storageItemOldValue:
                        formatLargeNumberDouble(
                          primaryUnit
                              .getQuantityEquivDivided(
                                index: 4,
                                quantityTwo: oldQty,
                              ),
                        ),
                    storageItemNewValue:
                        formatLargeNumberDouble(
                          product
                              .getPrimaryUnit()
                              .getQuantityEquivDivided(
                                index: 4,
                                quantityTwo: newQty,
                              ),
                        ),
                    uuid: uuidGen(),
                    desc:
                        '${rec.quantity ?? 0} ${selectedUnit.name} of This Item Return From Purchase Purchased. Purchase Id: #${returnOnlyDigits(rec.purchaseId ?? purchaseUuid)}',
                    isIncreased: false,
                    quantityChange: rec.quantity,
                    storagePrimaryUnit: primaryUnit.name,
                    storageUnit: formatHistoryUnit(
                      selectedUnit: selectedUnit.name,
                      primaryUnit: primaryUnit.name,
                      primaryQuantity: deltaQty.abs(),
                    ),
                  );
                }

                await returnStorageProductProvider()
                    .updateProduct(
                      product: product,
                      storageItemHistory: newUpdate,
                      isQuantityUpdate: true,
                      quantityChange: deltaQty,
                      isIncrement: false,
                    );
              } catch (e) {
                await mainLocalLog(
                  '❌❌Error Updating Storage Product Quantity: ${e.toString()}',
                );
              }
            }
          } else {
            final targetProductId =
                rec.itemId ?? rec.storageItemId;
            final foundProduct = _findProduct(
              targetProductId,
            );
            if (foundProduct != null) {
              var oldPro = foundProduct.copyWith();
              var newPro = oldPro.copyWith();
              final selectedUnit =
                  _resolveSelectedUnitForProduct(
                    rec,
                    oldPro,
                  );
              final primaryUnit = oldPro.getPrimaryUnit();
              final oldArea =
                  oldPro.getActualQuantity() ?? 0;
              final isDimensionalSheet =
                  oldPro.quantityType == 2 &&
                  selectedUnit.dimensionType !=
                      ProductUnitsClass.areaUnit;
              final deltaArea = selectedUnit
                  .getQuantityEquivMultiplied(
                    index: 1,
                    product: oldPro,
                    newQuantity: rec.quantity ?? 0,
                    customWidth:
                        isDimensionalSheet
                            ? oldPro.widthDimension
                            : null,
                    customHeight:
                        isDimensionalSheet
                            ? oldPro.heightDimension
                            : null,
                  );
              final newArea = oldArea - deltaArea;
              final areaPerSheet = oldPro.dimensionArea();
              newPro.quantity =
                  (oldPro.quantityType == 2 &&
                          areaPerSheet > 0)
                      ? (newArea / areaPerSheet)
                      : newArea;
              newPro.updatedAt = DateTime.now();

              final rpcQuantityChange =
                  (oldPro.quantityType == 2 &&
                          areaPerSheet > 0)
                      ? (deltaArea / areaPerSheet)
                      : deltaArea;

              ItemHistory? itemHistory;
              if (createUpdate) {
                itemHistory = ItemHistory(
                  event: ItemHistoryEventClass.returnEvent,
                  isManaged: true,
                  source:
                      ItemHistoryEventClass.productSource,
                  destination:
                      ItemHistoryEventClass
                          .purchaseDestination,
                  desc:
                      '${rec.quantity} ${selectedUnit.name} of this Item Was Returned From Purchase. Purchase Id: #${returnOnlyDigits(rec.purchaseId ?? purchaseUuid)}',
                  shopId:
                      purchase.shopId != 0
                          ? purchase.shopId
                          : shopId(),
                  isIncreased: false,
                  oldValue: formatLargeNumberDouble(
                    primaryUnit.getQuantityEquivDivided(
                      index: 1,
                      newQuantity: oldArea,
                      product: oldPro,
                    ),
                  ),
                  newValue: formatLargeNumberDouble(
                    newPro
                        .getPrimaryUnit()
                        .getQuantityEquivDivided(
                          index: 1,
                          newQuantity:
                              newPro.getActualQuantity() ??
                              0,
                          product: newPro,
                        ),
                  ),
                  title: 'Purchased Deleted',
                  quantityChange: rec.quantity,
                  departmentName:
                      returnDepartmentProvider()
                          .currentDepartment()
                          ?.name,
                  departmentUuid:
                      returnDepartmentProvider()
                          .currentDepartment()
                          ?.uuid,
                  itemName: newPro.name,
                  itemUuid: newPro.uuid,
                  primaryUnit: primaryUnit.name,
                  unit: formatHistoryUnit(
                    selectedUnit: selectedUnit.name,
                    primaryUnit: primaryUnit.name,
                    primaryQuantity: deltaArea.abs(),
                  ),
                );
              }

              await returnData().updateProduct(
                itemHistory: itemHistory,
                includeQuantity: false,
                product: newPro,
                isQuantityUpdate: true,
                quantityChange: rpcQuantityChange,
                isIncrement: false,
              );
            }
          }
        }
      }
      returnData().syncData();

      await mainLocalLog('✅ Purchase successfully Delete.');
      notifyListeners();
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error Deleting Purchase: ${e.toString()}',
      );
      return 0;
    }
  }

  //
  //
  //
  //

  Future<void> createPurchasesSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      // Prepare batch payload
      if (CreatedPurchasesFunc()
              .getPurchases()
              .isNotEmpty &&
          isOnline) {
        final tempPurchases =
            CreatedPurchasesFunc().getPurchases().toList();
        // createdAt is serialized to UTC in toJson(); don't mutate the
        // shared in-memory purchase.
        var newPurchases = tempPurchases;
        final payload =
            newPurchases
                .map((p) => p.purchase.toJson())
                .toList();

        // Insert all at once
        final data =
            await supabase
                .from(tableName)
                .insert(payload)
                .select();

        await mainLocalLog(
          '${data.length} items added successfully ✅',
        );
        await CreatedPurchasesFunc().clearPurchases();
        await mainLocalLog('Unsynced Purchases Cleared');

        await mainLocalLog(
          'Mounted, refreshing Purchases ✅',
        );
        await loadPurchases(
          returnShopProvider().userShop()!.shopId!,
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Purchases insert failed ❌: $e',
      );
    }
  }

  //
  //
  //
  //
  //

  //
  //
  //
  //
  //

  Future<void> deletePurchasesSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      // Prepare batch payload
      if (DeletedPurchasesFunc()
              .getPurchaseIds()
              .isNotEmpty &&
          isOnline) {
        final tempPurchases =
            DeletedPurchasesFunc()
                .getPurchaseIds()
                .toList();

        for (var rec in tempPurchases) {
          await supabase
              .from(tableName)
              .delete()
              .eq('uuid', rec.purchaseUuid);
          // await DeletedPurchasesFunc()
          //     .deletedDeletedPurchases(rec.purchaseUuid);
        }

        await mainLocalLog(
          '${tempPurchases.length} Purchases Created successfully ✅',
        );
        await DeletedPurchasesFunc()
            .clearDeletedPurchases();
        await mainLocalLog(
          'Unsynced Deleted Purchases Cleared',
        );

        await mainLocalLog(
          'Mounted, refreshing Purchases ✅',
        );
        await loadPurchases(
          returnShopProvider().userShop()!.shopId!,
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Purchases Deleted failed ❌: $e',
      );
    }
  }

  //
  //
  //
  //

  Future<void> updatePurchaseSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      await mainLocalLog(
        UpdatedPurchasesFunc()
            .getPurchaseIds()
            .length
            .toString(),
      );

      if (UpdatedPurchasesFunc()
              .getPurchaseIds()
              .isNotEmpty &&
          isOnline) {
        final updatedPurchases =
            UpdatedPurchasesFunc().getPurchaseIds();

        final pendingDeleted =
            DeletedPurchasesFunc()
                .getPurchaseIds()
                .map((d) => d.purchaseUuid)
                .toSet();

        for (final updated in updatedPurchases) {
          final uuid = updated.purchase.uuid;
          final localCopy =
              uuid == null
                  ? null
                  : PurchaseFunc().getSinglePurchase(
                    uuid: uuid,
                  );
          // Deleted locally and waiting to sync: don't send it
          // back to the server.
          if (localCopy == null &&
              pendingDeleted.contains(uuid)) {
            await UpdatedPurchasesFunc().deleteIfUnchanged(
              updated,
            );
            continue;
          }
          // The current local copy holds every later local
          // change, so the newest edit is what gets sent.
          final localPurchases = purchaseToPush(
            updated.purchase,
            localCopy,
          );

          localPurchases.updatedAt ??=
              DateTime.now().toLocal();

          if (localPurchases.uuid == null) {
            await mainLocalLog(
              'Local Purchases Uuid is Null',
            );
          }
          final remoteData =
              await supabase
                  .from(tableName)
                  .select('uuid, updated_at')
                  .eq('uuid', localPurchases.uuid!)
                  .maybeSingle();

          if (remoteData == null) {
            await supabase
                .from(tableName)
                .insert(localPurchases.toJson());
            await mainLocalLog(
              'Inserted product with uuid ${localPurchases.uuid}',
            );
            await UpdatedPurchasesFunc().deleteIfUnchanged(
              updated,
            );
          } else {
            final remoteUpdatedAtRaw =
                remoteData['updated_at'];
            final remoteUpdatedAt =
                remoteUpdatedAtRaw == null
                    ? null
                    : DateTime.parse(
                      remoteUpdatedAtRaw,
                    ).toUtc();

            localPurchases.updatedAt =
                (localPurchases.updatedAt ?? DateTime.now())
                    .toUtc(); // ✅ keep both UTC
            await mainLocalLog(
              "Local updatedAt: ${localPurchases.updatedAt}",
            );
            await mainLocalLog(
              "Remote updatedAt: $remoteUpdatedAt",
            );

            if (shouldPushPurchaseUpdate(
              localUpdatedAt: localPurchases.updatedAt!,
              remoteUpdatedAt: remoteUpdatedAt,
            )) {
              await supabase
                  .from(tableName)
                  .update(localPurchases.toJson())
                  .eq('uuid', localPurchases.uuid!);
              await mainLocalLog(
                'Updated Purchase with uuid ${localPurchases.uuid}',
              );
            } else {
              await mainLocalLog(
                'Skipped Purchase ${localPurchases.uuid}, remote is newer ✅',
              );
            }
            await UpdatedPurchasesFunc().deleteIfUnchanged(
              updated,
            );
          }
        }

        await mainLocalLog(
          'Unsynced Purchase products cleared',
        );
        await mainLocalLog(
          'Mounted, refreshing products ✅',
        );
        await loadPurchases(
          returnShopProvider().userShop()!.shopId!,
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Purchases update failed ❌: $e',
      );
    }
  }
  //
  //

  List<TempItemPurchaseRecord> itemPurchaseRecords({
    BuildContext? context,
  }) {
    return purchases
        .expand((item) => (item.getItems(context: context)))
        .toList();
  }

  List<TempItemPurchaseRecord> _itemPurchaseRecords = [];

  List<TempItemPurchaseRecord>
  get getItemPurchaseReceipts => _itemPurchaseRecords;

  // CREATE a new product sale record
  Future<void> createItemPurchaseRecord(
    List<TempItemPurchaseRecord> records,
  ) async {
    try {
      final isManageStorage =
          returnShopProvider()
              .userShop()
              ?.manageInventoryStorage ==
          true;
      for (var item in records) {
        if (isManageStorage) {
          final targetStorageId =
              item.storageItemId ?? item.itemId;
          final storageProduct = _findStorageProduct(
            targetStorageId,
          );
          if (storageProduct == null) {
            await mainLocalLog(
              '❌ Storage Product not found for purchase item: $targetStorageId',
            );
            continue;
          }

          final selectedUnit =
              _resolveSelectedUnitForStorage(
                item,
                storageProduct,
              );
          final primaryUnit =
              storageProduct.getPrimaryUnit();
          // Stored quantity (sheets for 2D storage items).
          final deltaQty =
              storageProduct.actualFromUnit(
                selectedUnit,
                item.quantity ?? 0,
              ) /
              storageProduct.dimensionArea();
          final oldQty = storageProduct.quantity ?? 0;
          final newQty = oldQty + deltaQty;

          var newPr = storageProduct.copyWith();
          newPr.quantity = newQty;
          newPr.updatedAt = DateTime.now();

          var newUpdate = StorageItemHistory(
            event: StorageItemHistoryEventClass.purchase,
            source:
                StorageItemHistoryEventClass.purchaseSource,
            destination:
                StorageItemHistoryEventClass
                    .storageDestination,
            shopId:
                item.shopId != 0 ? item.shopId : shopId(),
            title: 'Stock In From Purchase',
            createdAt: DateTime.now(),
            storageDepartmentName:
                returnDepartmentProvider()
                    .currentDepartment()
                    ?.name,
            storageDepartmentUuid:
                returnDepartmentProvider()
                    .currentDepartment()
                    ?.uuid,
            storageItemName: newPr.name,
            storageItemUuid: newPr.uuid,
            storageStaffId: currentUser().userId,
            storageStaffName: currentUser().name,
            storageItemOldValue: formatLargeNumberDouble(
              primaryUnit.getQuantityEquivDivided(
                index: 4,
                quantityTwo: oldQty,
              ),
            ),
            storageItemNewValue: formatLargeNumberDouble(
              primaryUnit.getQuantityEquivDivided(
                index: 4,
                quantityTwo: newQty,
              ),
            ),
            uuid: uuidGen(),
            desc:
                '${item.quantity ?? 0} ${selectedUnit.name} of This Item Purchased. Purchase Id: #${returnOnlyDigits(item.purchaseId ?? '')}',
            isIncreased: true,
            quantityChange: item.quantity,
            storagePrimaryUnit: primaryUnit.name,
            storageUnit: formatHistoryUnit(
              selectedUnit: selectedUnit.name,
              primaryUnit: primaryUnit.name,
              primaryQuantity: deltaQty.abs(),
            ),
          );

          await returnStorageProductProvider()
              .updateProduct(
                product: newPr,
                storageItemHistory: newUpdate,
                isQuantityUpdate: true,
                quantityChange: deltaQty,
                isIncrement: true,
              );
        } else {
          final targetProductId =
              item.itemId ?? item.storageItemId;
          final product = _findProduct(targetProductId);
          if (product == null) {
            await mainLocalLog(
              '❌ Product not found for purchase item: $targetProductId',
            );
            continue;
          }

          final selectedUnit =
              _resolveSelectedUnitForProduct(item, product);
          final primaryUnit = product.getPrimaryUnit();
          final oldArea = product.getActualQuantity() ?? 0;
          final isDimensionalSheet =
              product.quantityType == 2 &&
              selectedUnit.dimensionType !=
                  ProductUnitsClass.areaUnit;
          final deltaArea = selectedUnit
              .getQuantityEquivMultiplied(
                index: 1,
                product: product,
                newQuantity: item.quantity ?? 0,
                customWidth:
                    isDimensionalSheet
                        ? product.widthDimension
                        : null,
                customHeight:
                    isDimensionalSheet
                        ? product.heightDimension
                        : null,
              );
          final newArea = oldArea + deltaArea;
          final areaPerSheet = product.dimensionArea();

          var newPr = product.copyWith();
          newPr.quantity =
              (product.quantityType == 2 &&
                      areaPerSheet > 0)
                  ? (newArea / areaPerSheet)
                  : newArea;
          newPr.updatedAt = DateTime.now();

          final rpcQuantityChange =
              (product.quantityType == 2 &&
                      areaPerSheet > 0)
                  ? (deltaArea / areaPerSheet)
                  : deltaArea;

          ItemHistory itemHistory = ItemHistory(
            event: ItemHistoryEventClass.purchase,
            isManaged: true,
            source: ItemHistoryEventClass.purchaseSource,
            destination:
                ItemHistoryEventClass.productDestination,
            desc:
                '${item.quantity} ${selectedUnit.name} of this Item Purchased. Purchase Id: #${returnOnlyDigits(item.purchaseId ?? '')}',
            shopId:
                item.shopId != 0 ? item.shopId : shopId(),
            isIncreased: true,
            oldValue: formatLargeNumberDouble(
              primaryUnit.getQuantityEquivDivided(
                index: 1,
                newQuantity: oldArea,
                product: product,
              ),
            ),
            newValue: formatLargeNumberDouble(
              newPr
                  .getPrimaryUnit()
                  .getQuantityEquivDivided(
                    index: 1,
                    newQuantity:
                        newPr.getActualQuantity() ?? 0,
                    product: newPr,
                  ),
            ),
            title: 'Item Purchased',
            quantityChange: item.quantity,
            departmentName:
                returnDepartmentProvider()
                    .currentDepartment()
                    ?.name,
            departmentUuid:
                returnDepartmentProvider()
                    .currentDepartment()
                    ?.uuid,
            itemName: newPr.name,
            itemUuid: newPr.uuid,
            primaryUnit: primaryUnit.name,
            unit: formatHistoryUnit(
              selectedUnit: selectedUnit.name,
              primaryUnit: primaryUnit.name,
              primaryQuantity: deltaArea.abs(),
            ),
          );

          await returnData().updateProduct(
            itemHistory: itemHistory,
            includeQuantity: false,
            isIncrement: true,
            isQuantityUpdate: true,
            quantityChange: rpcQuantityChange,
            product: newPr,
          );
        }
      }
    } catch (e) {
      await mainLocalLog('Error ${e.toString()}');
    }

    notifyListeners();
  }

  // Item uuid and stored quantity (sheets for 2D items) of one
  // purchase line, converted the same way as
  // createItemPurchaseRecord. Null when the item is not found.
  MapEntry<String, double>? _purchaseLineStock(
    TempItemPurchaseRecord item,
    bool isManageStorage,
  ) {
    if (isManageStorage) {
      final storageProduct = _findStorageProduct(
        item.storageItemId ?? item.itemId,
      );
      if (storageProduct?.uuid == null) return null;
      final selectedUnit = _resolveSelectedUnitForStorage(
        item,
        storageProduct!,
      );
      return MapEntry(
        storageProduct.uuid!,
        storageProduct.actualFromUnit(
              selectedUnit,
              item.quantity ?? 0,
            ) /
            storageProduct.dimensionArea(),
      );
    }
    final product = _findProduct(
      item.itemId ?? item.storageItemId,
    );
    if (product?.uuid == null) return null;
    final selectedUnit = _resolveSelectedUnitForProduct(
      item,
      product!,
    );
    final isDimensionalSheet =
        product.quantityType == 2 &&
        selectedUnit.dimensionType !=
            ProductUnitsClass.areaUnit;
    final area = selectedUnit.getQuantityEquivMultiplied(
      index: 1,
      product: product,
      newQuantity: item.quantity ?? 0,
      customWidth:
          isDimensionalSheet ? product.widthDimension : null,
      customHeight:
          isDimensionalSheet ? product.heightDimension : null,
    );
    return MapEntry(
      product.uuid!,
      area / product.dimensionArea(),
    );
  }

  /// Applies an edit of purchase [purchaseUuid] to stock by
  /// difference: each item changes by its new minus old stored
  /// quantity, with one history entry per changed item. Nothing is
  /// reversed or added again in full.
  Future<void> applyPurchaseEditInventory({
    required List<TempItemPurchaseRecord> oldItems,
    required List<TempItemPurchaseRecord> newItems,
    required String purchaseUuid,
    required DateTime createdAt,
  }) async {
    try {
      final isManageStorage =
          returnShopProvider()
              .userShop()
              ?.manageInventoryStorage ==
          true;
      List<MapEntry<String, double>> linesStock(
        List<TempItemPurchaseRecord> items,
      ) =>
          items
              .map(
                (item) =>
                    _purchaseLineStock(item, isManageStorage),
              )
              .whereType<MapEntry<String, double>>()
              .toList();
      final deltas = purchaseStockDeltas(
        stockByItem(linesStock(oldItems)),
        stockByItem(linesStock(newItems)),
      );
      final idDigits = returnOnlyDigits(purchaseUuid);

      for (final entry in deltas.entries) {
        final delta = entry.value;
        final isIncrease = delta > 0;

        if (isManageStorage) {
          final storageProduct = _findStorageProduct(
            entry.key,
          );
          if (storageProduct == null) continue;
          final primaryUnit =
              storageProduct.getPrimaryUnit();
          final oldQty = storageProduct.quantity ?? 0;
          final newQty = oldQty + delta;
          final primaryChange = primaryUnit
              .getQuantityEquivDivided(
                index: 4,
                quantityTwo: delta.abs(),
              );

          var newPr = storageProduct.copyWith();
          newPr.quantity = newQty;
          newPr.updatedAt = DateTime.now();

          var newUpdate = StorageItemHistory(
            event:
                isIncrease
                    ? StorageItemHistoryEventClass.purchase
                    : StorageItemHistoryEventClass
                        .purchaseDeleted,
            source:
                isIncrease
                    ? StorageItemHistoryEventClass
                        .purchaseSource
                    : StorageItemHistoryEventClass
                        .storageSource,
            destination:
                isIncrease
                    ? StorageItemHistoryEventClass
                        .storageDestination
                    : StorageItemHistoryEventClass
                        .purchaseDestination,
            shopId: shopId(),
            title: 'Purchase Updated',
            createdAt: createdAt,
            storageDepartmentName:
                returnDepartmentProvider()
                    .currentDepartment()
                    ?.name,
            storageDepartmentUuid:
                returnDepartmentProvider()
                    .currentDepartment()
                    ?.uuid,
            storageItemName: newPr.name,
            storageItemUuid: newPr.uuid,
            storageStaffId: currentUser().userId,
            storageStaffName: currentUser().name,
            storageItemOldValue: formatLargeNumberDouble(
              primaryUnit.getQuantityEquivDivided(
                index: 4,
                quantityTwo: oldQty,
              ),
            ),
            storageItemNewValue: formatLargeNumberDouble(
              primaryUnit.getQuantityEquivDivided(
                index: 4,
                quantityTwo: newQty,
              ),
            ),
            uuid: uuidGen(),
            desc:
                isIncrease
                    ? '${formatDimension(primaryChange)} ${primaryUnit.name} of This Item Added due to Purchase Update. Purchase Id: #$idDigits'
                    : '${formatDimension(primaryChange)} ${primaryUnit.name} of This Item Removed due to Purchase Update. Purchase Id: #$idDigits',
            isIncreased: isIncrease,
            quantityChange:
                isIncrease ? primaryChange : -primaryChange,
            storagePrimaryUnit: primaryUnit.name,
            storageUnit: formatHistoryUnit(
              selectedUnit: primaryUnit.name,
              primaryUnit: primaryUnit.name,
              primaryQuantity: delta.abs(),
            ),
          );

          await returnStorageProductProvider()
              .updateProduct(
                product: newPr,
                storageItemHistory: newUpdate,
                isQuantityUpdate: true,
                quantityChange: delta.abs(),
                isIncrement: isIncrease,
              );
        } else {
          final product = _findProduct(entry.key);
          if (product == null) continue;
          final primaryUnit = product.getPrimaryUnit();
          final areaPerSheet = product.dimensionArea();
          final deltaArea = delta * areaPerSheet;
          final oldArea = product.getActualQuantity() ?? 0;
          final newArea = oldArea + deltaArea;
          final primaryChange = primaryUnit
              .getQuantityEquivDivided(
                index: 1,
                newQuantity: deltaArea.abs(),
                product: product,
              );

          var newPr = product.copyWith();
          newPr.quantity = newArea / areaPerSheet;
          newPr.updatedAt = DateTime.now();

          ItemHistory itemHistory = ItemHistory(
            createdAt: createdAt,
            event:
                isIncrease
                    ? ItemHistoryEventClass.purchase
                    : ItemHistoryEventClass.returnEvent,
            isManaged: true,
            source:
                isIncrease
                    ? ItemHistoryEventClass.purchaseSource
                    : ItemHistoryEventClass.productSource,
            destination:
                isIncrease
                    ? ItemHistoryEventClass.productDestination
                    : ItemHistoryEventClass
                        .purchaseDestination,
            desc:
                isIncrease
                    ? '${formatDimension(primaryChange)} ${primaryUnit.name} of this Item Added due to Purchase Update. Purchase Id: #$idDigits'
                    : '${formatDimension(primaryChange)} ${primaryUnit.name} of this Item Returned due to Purchase Update. Purchase Id: #$idDigits',
            shopId: shopId(),
            isIncreased: isIncrease,
            oldValue: formatLargeNumberDouble(
              primaryUnit.getQuantityEquivDivided(
                index: 1,
                newQuantity: oldArea,
                product: product,
              ),
            ),
            newValue: formatLargeNumberDouble(
              newPr
                  .getPrimaryUnit()
                  .getQuantityEquivDivided(
                    index: 1,
                    newQuantity:
                        newPr.getActualQuantity() ?? 0,
                    product: newPr,
                  ),
            ),
            title:
                isIncrease
                    ? 'Item Purchased (Purchase Updated)'
                    : 'Item Returned (Purchase Updated)',
            quantityChange:
                isIncrease ? primaryChange : -primaryChange,
            departmentName:
                returnDepartmentProvider()
                    .currentDepartment()
                    ?.name,
            departmentUuid:
                returnDepartmentProvider()
                    .currentDepartment()
                    ?.uuid,
            itemName: newPr.name,
            itemUuid: newPr.uuid,
            primaryUnit: primaryUnit.name,
            unit: formatHistoryUnit(
              selectedUnit: primaryUnit.name,
              primaryUnit: primaryUnit.name,
              primaryQuantity: deltaArea.abs(),
            ),
          );

          await returnData().updateProduct(
            itemHistory: itemHistory,
            includeQuantity: false,
            isIncrement: isIncrease,
            isQuantityUpdate: true,
            quantityChange: delta.abs(),
            product: newPr,
          );
        }
      }
    } catch (e) {
      await mainLocalLog(
        'Error Applying Purchase Edit Inventory: ${e.toString()}',
      );
    }

    notifyListeners();
  }

  // // READ sales for a shop
  // Future<List<TempItemPurchaseRecord>>
  // loadItemPurchaseRecords(int shopId) async {
  //   bool isOnline = await connectivity.isOnline();
  //   try {
  //     if (isOnline && ItemPurchaseFunc().isSynced()) {
  //       final data = await supabase
  //           .from(itemPurchaseTableName)
  //           .select()
  //           .eq('shop_id', shopId)
  //           .order('created_at', ascending: false);

  //       await mainLocalLog(
  //         '✅Items Records gotten: ${data.length}',
  //       );
  //       _itemPurchaseRecords =
  //           (data as List)
  //               .map(
  //                 (json) =>
  //                     TempItemPurchaseRecord.fromJson(json),
  //               )
  //               .toList();
  //       await ItemPurchaseFunc()
  //           .insertAllItemPurchaseRecords(
  //             _itemPurchaseRecords,
  //           );
  //     } else {
  //       _itemPurchaseRecords =
  //           ItemPurchaseFunc().getItemPurchaseRecords();
  //     }

  //     notifyListeners();
  //     return _itemPurchaseRecords;
  //   } catch (e) {
  //     await mainLocalLog(
  //       '❌Error Getting Item Purchase Records: ${e.toString()}',
  //     );
  //     return [];
  //   }
  // }

  // // READ sales for a shop
  // Future<List<TempItemPurchaseRecord>>
  // loadItemPurchaseRecordsOffline() async {
  //   try {
  //     _itemPurchaseRecords =
  //         ItemPurchaseFunc().getItemPurchaseRecords();

  //     notifyListeners();
  //     return _itemPurchaseRecords;
  //   } catch (e) {
  //     await mainLocalLog(
  //       '❌Error Getting Item Purchase Records Offline: ${e.toString()}',
  //     );
  //     return [];
  //   }
  // }

  // // DELETE a sale record
  // Future<void> deleteItemPurchaseRecord(
  //   String recordUuid,
  // ) async {
  //   try {
  //     // if (isOnline) {
  //     //   await supabase
  //     //       .from(itemPurchaseTableName)
  //     //       .delete()
  //     //       .eq('uuid', recordUuid);

  //     //   notifyListeners();
  //     // } else {
  //     await ItemPurchaseFunc().deleteRecord(recordUuid);

  //     if (CreatedItemPurchaseFunc()
  //         .getRecords()
  //         .where((rec) => rec.record.uuid == recordUuid)
  //         .isNotEmpty) {
  //       await CreatedItemPurchaseFunc().deleteRecords(
  //         recordUuid,
  //       );
  //     } else {
  //       DeletedItemPurchaseFunc().createDeletedPurchase(
  //         DeletedItemRecords(recordUuid: recordUuid),
  //       );
  //     }
  //     // }

  //     loadItemPurchaseRecordsOffline();
  //   } catch (e) {
  //     await mainLocalLog(
  //       'Error Deleting Item Purchase Record: ${e.toString()}',
  //     );
  //   }
  // }

  //
  //
  //
  //
  //
  //

  //
  //
  //
  //
  //

  // Future<void> createRecordsSync() async {
  //   try {
  //     bool isOnline = await connectivity.isOnline();
  //     // Prepare batch payload
  //     if (CreatedItemPurchaseFunc()
  //             .getRecords()
  //             .isNotEmpty &&
  //         isOnline) {
  //       final tempRecords =
  //           CreatedItemPurchaseFunc().getRecords().toList();
  //       var newRecords = tempRecords.map((rec) {
  //         rec.record.createdAt =
  //             rec.record.createdAt.toUtc();
  //         return rec;
  //       });
  //       final payload =
  //           newRecords
  //               .map((p) => p.record.toJson())
  //               .toList();

  //       // Insert all at once
  //       final data =
  //           await supabase
  //               .from(itemPurchaseTableName)
  //               .insert(payload)
  //               .select();

  //       await mainLocalLog(
  //         '${data.length} items added successfully ✅',
  //       );
  //       await CreatedItemPurchaseFunc().clearRecords();
  //       await loadItemPurchaseRecords(shopId());
  //       await mainLocalLog(
  //         'Unsynced Purchase Item Records Cleared',
  //       );
  //     }
  //   } catch (e) {
  //     await mainLocalLog(
  //       'Batch Created Purchase Records insert failed ❌: $e',
  //     );
  //   }
  // }

  // //
  // //
  // //
  // //

  // Future<void> deleteItemRecordsSync() async {
  //   try {
  //     bool isOnline = await connectivity.isOnline();
  //     // Prepare batch payload
  //     if (DeletedItemPurchaseFunc()
  //             .getItemPurchaseIds()
  //             .isNotEmpty &&
  //         isOnline) {
  //       final tempItemPurchases =
  //           DeletedItemPurchaseFunc()
  //               .getItemPurchaseIds()
  //               .toList();

  //       for (var rec in tempItemPurchases) {
  //         await supabase
  //             .from(itemPurchaseTableName)
  //             .delete()
  //             .eq('uuid', rec.recordUuid);
  //         // await DeletedItemPurchaseFunc()
  //         //     .deletedDeletedPurchases(rec.purchaseUuid);
  //       }

  //       await mainLocalLog(
  //         '${tempItemPurchases.length} Purchase Item Records Deleted successfully ✅',
  //       );
  //       await DeletedItemPurchaseFunc()
  //           .clearDeletedItemRecords();
  //       await mainLocalLog(
  //         'Unsynced Deleted Purchase Item Records Cleared',
  //       );

  //       await mainLocalLog(
  //         'Mounted, refreshing Purchase Item Records ✅',
  //       );
  //       // await loadPurchases(
  //       //   returnShopProvider().userShop()!.shopId!,
  //       // );
  //     }
  //   } catch (e) {
  //     await mainLocalLog(
  //       'Batch Purchase Item Records Deleted failed ❌: $e',
  //     );
  //   }
  // }

  //
  //
  //
  //
  //

  List<TempPurchase> departmentPurchases() {
    if (returnShopProvider()
            .userShop()
            ?.manageDepartments ==
        true) {
      if (!authorization(
        authorized: Authorizations().viewAllDepartments,
      )) {
        return purchases.where((cat) {
          return cat.departmentUuid ==
              returnDepartmentProvider()
                  .currentDepartment()
                  ?.uuid;
        }).toList();
      } else {
        if (returnDepartmentProvider()
                .currentDepartment()
                ?.uuid ==
            null) {
          return purchases;
        } else {
          return purchases.where((cat) {
            return cat.departmentUuid ==
                returnDepartmentProvider()
                    .currentDepartment()
                    ?.uuid;
            // }
          }).toList();
        }
      }
    } else {
      return purchases;
    }
  }

  List<TempPurchase> returnPurchasesByDateForIndex() {
    if (returnShopProvider()
            .userShop()
            ?.manageDepartments ==
        true) {
      if (rangeStartDate != null) {
        return departmentPurchases().where((purchase) {
          final created = purchase.createdAt.toLocal();
          return !created.isBefore(
                fourAm(rangeStartDate!),
              ) &&
              created.isBefore(
                fourAmNextDay(
                  rangeEndDate ??
                      resolveBusinessDate(DateTime.now()),
                ),
              );
        }).toList();
      } else {
        // final currentDate = dateSet ?? DateTime.now();
        final currentDate =
            dateSet ?? resolveBusinessDate(DateTime.now());

        return departmentPurchases()
            .where(
              (purchase) =>
                  !purchase.createdAt.isBefore(
                    fourAm(currentDate),
                  ) &&
                  purchase.createdAt.isBefore(
                    fourAmNextDay(currentDate),
                  ),
            )
            .toList();
      }
    } else {
      if (rangeStartDate != null) {
        if (authorization(
          authorized:
              Authorizations().viewAllTransactionRecords,
        )) {
          return purchases.where((purchase) {
            final created = purchase.createdAt.toLocal();
            return !created.isBefore(
                  fourAm(rangeStartDate!),
                ) &&
                created.isBefore(
                  fourAmNextDay(
                    rangeEndDate ??
                        resolveBusinessDate(DateTime.now()),
                  ),
                );
          }).toList();
        } else {
          return purchases.where((purchase) {
            final created = purchase.createdAt.toLocal();
            return !created.isBefore(
                  fourAm(rangeStartDate!),
                ) &&
                created.isBefore(
                  fourAmNextDay(
                    rangeEndDate ??
                        resolveBusinessDate(DateTime.now()),
                  ),
                ) &&
                purchase.staffId == currentUser().userId;
          }).toList();
        }
      } else {
        final currentDate = dateSet ?? DateTime.now();

        if (authorization(
          authorized:
              Authorizations().viewAllTransactionRecords,
        )) {
          return purchases
              .where(
                (purchase) =>
                    !purchase.createdAt.isBefore(
                      fourAm(currentDate),
                    ) &&
                    !purchase.createdAt.isAfter(
                      fourAmNextDay(currentDate),
                    ),
              )
              .toList();
        } else {
          return purchases
              .where(
                (purchase) =>
                    !purchase.createdAt.isBefore(
                      fourAm(currentDate),
                    ) &&
                    !purchase.createdAt.isAfter(
                      fourAmNextDay(currentDate),
                    ) &&
                    purchase.staffId ==
                        currentUser().userId,
              )
              .toList();
        }
      }
    }
  }

  List<TempPurchase> returnOwnPurchasesByDayOrWeek({
    required int index,
  }) {
    if (index == 1) {
      return returnPurchasesByDateForIndex();
    } else if (index == 2) {
      return returnPurchasesByDateForIndex().where((purch) {
        if (getPurchasePaymentBalance(purch) == 0) {
          return true;
        } else {
          return false;
        }
      }).toList();
    } else {
      return returnPurchasesByDateForIndex().where((purch) {
        if (getPurchasePaymentBalance(purch) != 0) {
          return true;
        } else {
          return false;
        }
      }).toList();
    }
  }

  List<TempItemPurchaseRecord>
  returnItemPurchaseRecordByDayOrWeek() {
    List<TempItemPurchaseRecord> recordss = [];

    for (var rec in itemPurchaseRecords()) {
      TempPurchase? purchase;

      try {
        purchase = returnOwnPurchasesByDayOrWeek(
          index: 1,
        ).firstWhere((recx) => recx.uuid == rec.purchaseId);
      } catch (e) {
        purchase = null;
      }

      if (purchase != null) {
        recordss.add(rec);
      }
    }

    if (rangeStartDate != null) {
      if (authorization(
        authorized:
            Authorizations().viewAllTransactionRecords,
      )) {
        return recordss.where((record) {
          final created = record.createdAt.toLocal();
          return !created.isBefore(
                fourAm(rangeStartDate!),
              ) &&
              created.isBefore(
                fourAmNextDay(
                  rangeEndDate ??
                      resolveBusinessDate(DateTime.now()),
                ),
              );
        }).toList();
      } else {
        return recordss.where((record) {
          final created = record.createdAt.toLocal();
          return !created.isBefore(
                fourAm(rangeStartDate!),
              ) &&
              created.isBefore(
                fourAmNextDay(
                  rangeEndDate ??
                      resolveBusinessDate(DateTime.now()),
                ),
              ) &&
              record.staffId == currentUser().userId;
        }).toList();
      }
    }

    var currentDate = dateSet ?? DateTime.now();
    if (authorization(
      authorized:
          Authorizations().viewAllTransactionRecords,
    )) {
      return recordss
          .where(
            (record) =>
                !record.createdAt.isBefore(
                  fourAm(currentDate),
                ) &&
                !record.createdAt.isAfter(
                  fourAmNextDay(currentDate),
                ),
          )
          .toList();
    } else {
      return recordss
          .where(
            (record) =>
                !record.createdAt.isBefore(
                  fourAm(currentDate),
                ) &&
                !record.createdAt.isAfter(
                  fourAmNextDay(currentDate),
                ) &&
                record.staffId == currentUser().userId,
          )
          .toList();
    }
  }

  double getTotalRevenueForSelectedDayAll({
    String? staffId,
    String? supplierUuid,
    required int index,
  }) {
    double tempTotalRevenue = 0;

    for (var purchase
        in (staffId != null
            ? returnOwnPurchasesByDayOrWeek(
              index: index,
            ).where((rec) => rec.staffId == staffId)
            : supplierUuid != null
            ? returnOwnPurchasesByDayOrWeek(
              index: index,
            ).where((rec) => rec.supplierId == supplierUuid)
            : returnOwnPurchasesByDayOrWeek(
              index: index,
            ))) {
      tempTotalRevenue += getTotalMainRevenuePurchase(
        purchase,
      );
    }

    return tempTotalRevenue;
  }

  int getPurchaseStatus(TempPurchase purchase) {
    if (getPurchasePaymentBalance(purchase) ==
        getTotalMainRevenuePurchase(purchase)) {
      return 0;
    } else if (getPurchasePaymentBalance(purchase) <
            getTotalMainRevenuePurchase(purchase) &&
        getPurchasePaymentBalance(purchase) > 0) {
      return 1;
    } else {
      return 2;
    }
  }

  double getTotalPurchasePayments(TempPurchase purchase) {
    var total = 0.0;
    for (var temp in purchase.purchasePayments) {
      total += temp.amount;
    }
    return total;
  }

  double getPurchasePaymentBalance(TempPurchase purchase) {
    return getTotalMainRevenuePurchase(purchase) -
        getTotalPurchasePayments(purchase);
  }

  double getTotalMainRevenuePurchase(
    TempPurchase purchase,
  ) {
    var total = ((purchase.total ?? 0));

    return total;
  }
}

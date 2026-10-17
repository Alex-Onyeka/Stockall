import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/classes/temp_item_history/item_history_event_class.dart';
import 'package:stockall/classes/temp_item_purchase_record/temp_item_purchase_record.dart';
import 'package:stockall/classes/temp_item_purchase_record/unsynced/deleted_item_records/deleted_item_records.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/classes/temp_purchase/unsynced/created_purchases/created_purchases.dart';
import 'package:stockall/classes/temp_purchase/unsynced/deleted_purchase/deleted_purchases.dart';
import 'package:stockall/classes/temp_purchase/unsynced/updated/updated_purchases.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history_event_class.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/generate_barcode.dart';
import 'package:stockall/local_database/item_purchase_func.dart%20copy/item_purchase_func.dart';
import 'package:stockall/local_database/item_purchase_func.dart%20copy/unsync_funcs/created/created_item_purchase_func.dart';
import 'package:stockall/local_database/item_purchase_func.dart%20copy/unsync_funcs/deleted/deleted_item_purchase_func.dart';
import 'package:stockall/local_database/purchases/purchase_func.dart';
import 'package:stockall/local_database/purchases/unsync_funcs/created/created_purchases_func.dart';
import 'package:stockall/local_database/purchases/unsync_funcs/deleted/deleted_purchases_func.dart';
import 'package:stockall/local_database/purchases/unsync_funcs/updated/updated_purchases_func.dart';
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

  final String tableName = 'purchases';
  final String itemPurchaseTableName =
      'item_purchase_records';

  void clearPurchases() {
    _purchases.clear();
    // clearRecords();
    mainLocalLog('Purchases Cleared');
    notifyListeners();
  }

  // CREATE a new Purchase
  Future<TempPurchase?> createPurchase(
    TempPurchase purchase,
  ) async {
    await mainLocalLog('Inner Purchase Creation Started');
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
      purchase.updatedAt = DateTime.now().add(
        Duration(days: 1),
      );
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
    await loadItemPurchaseRecords(shopId);
    notifyListeners();
    return _purchases;
  }

  // READ all Purchases for a shop
  Future<List<TempPurchase>> loadPurchasesOffline() async {
    _purchases = PurchaseFunc().getPurchases();
    await mainLocalLog('Offline Purchases Gotten');
    await loadItemPurchaseRecordsOffline();
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

  // DELETE a Purchase
  Future<int> deletePurchase(
    TempPurchase purchase,
    bool? updateInventory,
    bool createUpdate,
  ) async {
    await mainLocalLog('Deleting Purchase');
    try {
      await mainLocalLog('Deleting Purchase Offline');
      await PurchaseFunc().deletePurchase(purchase.uuid!);
      var containsCreated =
          CreatedPurchasesFunc()
              .getPurchases()
              .where(
                (purch) =>
                    purch.purchase.uuid == purchase.uuid,
              )
              .toList();
      var containsUpdate = UpdatedPurchasesFunc()
          .getPurchaseIds()
          .where(
            (purch) =>
                purch.purchase.uuid == purchase.uuid!,
          );
      if (containsCreated.isNotEmpty) {
        await CreatedPurchasesFunc().deletePurchase(
          purchase.uuid!,
        );
      } else {
        await DeletedPurchasesFunc().createDeletedPurchase(
          DeletedPurchases(purchaseUuid: purchase.uuid!),
        );
      }
      if (containsUpdate.isNotEmpty) {
        await UpdatedPurchasesFunc().deleteUpdatedPurchase(
          purchase.uuid!,
        );
      }
      await ItemPurchaseFunc().deleteRecordsInPurchase(
        purchase.uuid!,
      );
      // }

      for (var rec in purchase.items ?? []) {
        await deleteItemPurchaseRecord(rec.uuid!);

        if (updateInventory == true) {
          if (returnShopProvider()
                  .userShop()
                  ?.manageInventoryStorage ==
              true) {
            List<TempStorageProducts> storageProducts =
                returnStorageProductProvider()
                    .storageProductListMain
                    .where(
                      (pro) =>
                          pro.uuid == rec.storageItemId,
                    )
                    .toList();
            if (storageProducts.isNotEmpty) {
              var newPro = storageProducts.first.copyWith();

              // Stored quantity (sheets for 2D storage items).
              var quantity = newPro.quantityAfterRemoving(
                newPro.actualFromUnit(
                  rec.getSelectedUnit(),
                  rec.quantity ?? 0,
                ),
              );

              try {
                var product = newPro.copyWith();
                product.updatedAt = DateTime.now();
                product.quantity = quantity;

                await returnStorageProductProvider()
                    .updateProduct(
                      product: product,
                      isQuantityUpdate: true,
                      quantityChange: rec
                          .getSelectedUnit()
                          .getQuantityEquivMultiplied(
                            index: 1,
                            quantityTwo:
                                (rec.quantity ?? 0),
                          ),
                      isIncrement: false,
                    );
                try {
                  if (createUpdate) {
                    var newUpdate = StorageItemHistory(
                      event:
                          StorageItemHistoryEventClass
                              .purchaseDeleted,
                      source:
                          StorageItemHistoryEventClass
                              .storageSource,
                      destination:
                          StorageItemHistoryEventClass
                              .purchaseDestination,
                      shopId: shopId(),
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
                      storageItemName: rec.itemName,
                      storageItemUuid: rec.storageItemId,
                      storageStaffId: currentUser().userId,
                      storageStaffName: currentUser().name,
                      storageItemOldValue:
                          formatLargeNumberDouble(
                            (newPro
                                .getPrimaryUnit()
                                .getQuantityEquivDivided(
                                  index: 1,
                                  quantityTwo:
                                      (newPro.quantity ??
                                          0),
                                )),
                          ),
                      storageItemNewValue:
                          formatLargeNumberDouble(
                            product
                                .getPrimaryUnit()
                                .getQuantityEquivDivided(
                                  index: 1,
                                  quantityTwo:
                                      (product.quantity ??
                                          0),
                                ),
                          ),
                      uuid: uuidGen(),
                      desc:
                          '${rec.quantity ?? 0} ${rec.unit} of This Item Return From Purchase Purchased. Purchase Id: #${returnOnlyDigits(rec.purchaseId ?? '')}',
                      isIncreased: false,
                      quantityChange: rec.quantity,
                      storagePrimaryUnit:
                          rec.getPrimaryUnit().name,
                      storageUnit: rec.unit,
                    );

                    await returnStorageItemHistoryProvider()
                        .createStorageItemHistory(
                          newUpdate,
                        );
                    await returnData().getProducts(
                      shopId(),
                    );
                  }
                } catch (e) {
                  await mainLocalLog(
                    '❌❌Error Creating Inventory Update: ${e.toString()}',
                  );
                }
              } catch (e) {
                await mainLocalLog(
                  '❌❌Error Updating Storage Product Quantity: ${e.toString()}',
                );
              }
            }
          } else {
            List<TempProductClass> products =
                returnData().productListMain
                    .where((pro) => pro.uuid == rec.itemId)
                    .toList();
            if (products.isNotEmpty) {
              var oldPro = products.first.copyWith();
              var newPro = oldPro.copyWith();
              newPro.quantity =
                  (newPro.getActualQuantity() ?? 0) -
                  rec
                      .getSelectedUnit()
                      .getQuantityEquivMultiplied(
                        index: 1,
                        quantityTwo: rec.quantity ?? 0,
                      );

              ItemHistory itemHistory = ItemHistory(
                event: ItemHistoryEventClass.returnEvent,
                isManaged: true,
                source: ItemHistoryEventClass.productSource,
                destination:
                    ItemHistoryEventClass
                        .purchaseDestination,
                desc:
                    '${rec.quantity} ${rec.unit} of this Item Was Returned From Purchase. Purchase Id: #${returnOnlyDigits(rec.purchaseId ?? '')}',
                shopId: shopId(),
                isIncreased: false,
                oldValue: formatLargeNumberDouble(
                  (oldPro
                      .getPrimaryUnit()
                      .getQuantityEquivDivided(
                        index: 1,
                        quantityTwo:
                            (oldPro.getActualQuantity() ??
                                0),
                      )),
                ),
                newValue: formatLargeNumberDouble(
                  newPro
                      .getPrimaryUnit()
                      .getQuantityEquivDivided(
                        index: 1,
                        quantityTwo:
                            (newPro.getActualQuantity() ??
                                0),
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
                itemName: rec.itemName,
                itemUuid: rec.itemId,
                primaryUnit: rec.getPrimaryUnit().name,
                unit: rec.getSelectedUnit().name,
              );

              await returnData().updateProduct(
                itemHistory: itemHistory,
                includeQuantity: false,
                product: newPro,
                isQuantityUpdate: true,
                quantityChange: rec
                    .getSelectedUnit()
                    .getQuantityEquivMultiplied(
                      index: 1,
                      quantityTwo: rec.quantity ?? 0,
                    ),
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

        for (final updated in updatedPurchases) {
          final localPurchases = updated.purchase;

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
            await UpdatedPurchasesFunc()
                .deleteUpdatedPurchase(
                  localPurchases.uuid ?? '',
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

            if (remoteUpdatedAt == null ||
                localPurchases.updatedAt!.isAfter(
                  remoteUpdatedAt,
                )) {
              await supabase
                  .from(tableName)
                  .update(localPurchases.toJson())
                  .eq('uuid', localPurchases.uuid!);
              await mainLocalLog(
                'Updated Purchase with uuid ${localPurchases.uuid}',
              );
              await UpdatedPurchasesFunc()
                  .deleteUpdatedPurchase(
                    localPurchases.uuid ?? '',
                  );
            } else {
              await mainLocalLog(
                'Skipped Purchase ${localPurchases.uuid}, remote is newer ✅',
              );
            }
          }
        }

        await UpdatedPurchasesFunc()
            .clearUpdatedPurchases();
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
      // var newRecords =
      //     records.map((rec) {
      //       rec.createdAt = DateTime.now();

      //       return rec;
      //     }).toList();
      // await ItemPurchaseFunc()
      //     .insertSalesItemPurchaseRecords(newRecords);
      // List<CreatedItemRecords> cRecords =
      //     newRecords.map((r) {
      //       return CreatedItemRecords(record: r);
      //     }).toList();
      // await CreatedItemPurchaseFunc().insertAllRecords(
      //   cRecords,
      // );
      for (var item in records) {
        if (returnShopProvider()
                .userShop()
                ?.manageInventoryStorage ==
            true) {
          var storageProduct =
              returnStorageProductProvider()
                  .storageProductListMain
                  .firstWhere(
                    (prod) =>
                        prod.uuid == item.storageItemId,
                  );

          var newPr = storageProduct.copyWith();
          // Stored quantity (sheets for 2D storage items).
          newPr.quantity =
              ((newPr.getActualQuantity() ?? 0) +
                  newPr.actualFromUnit(
                    item.getSelectedUnit(),
                    item.quantity ?? 0,
                  )) /
              newPr.dimensionArea();
          newPr.updatedAt = DateTime.now();

          await returnStorageProductProvider()
              .updateProduct(
                product: newPr,
                isQuantityUpdate: true,
                quantityChange: item
                    .getSelectedUnit()
                    .getQuantityEquivMultiplied(
                      index: 1,
                      quantityTwo: (item.quantity ?? 0),
                    ),
                isIncrement: true,
              );
          try {
            var newUpdate = StorageItemHistory(
              event: StorageItemHistoryEventClass.purchase,
              source:
                  StorageItemHistoryEventClass
                      .purchaseSource,
              destination:
                  StorageItemHistoryEventClass
                      .storageDestination,
              shopId: shopId(),
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
                (storageProduct
                    .getPrimaryUnit()
                    .getQuantityEquivDivided(
                      index: 1,
                      quantityTwo:
                          (storageProduct.quantity ?? 0),
                    )),
              ),
              storageItemNewValue: formatLargeNumberDouble(
                storageProduct
                    .getPrimaryUnit()
                    .getQuantityEquivDivided(
                      index: 1,
                      quantityTwo: (newPr.quantity ?? 0),
                    ),
              ),
              uuid: uuidGen(),
              desc:
                  '${item.quantity ?? 0} ${item.unit} of This Item Purchased. Purchase Id: #${returnOnlyDigits(item.purchaseId ?? '')}',
              isIncreased: true,
              quantityChange: item.quantity,
              storagePrimaryUnit:
                  item.getPrimaryUnit().name,
              storageUnit: item.unit,
            );

            await returnStorageItemHistoryProvider()
                .createStorageItemHistory(newUpdate);
          } catch (e) {
            await mainLocalLog(
              '❌❌Error Creating Inventory Update: ${e.toString()}',
            );
          }
        } else {
          var product = returnData().productListMain
              .firstWhere(
                (prod) => prod.uuid == item.itemId,
              );

          var newPr = product.copyWith();
          newPr.quantity =
              (newPr.quantity ?? 0) +
              item
                  .getSelectedUnit()
                  .getQuantityEquivMultiplied(
                    index: 1,
                    quantityTwo: (item.quantity ?? 0),
                  );
          newPr.updatedAt = DateTime.now();
          ItemHistory itemHistory = ItemHistory(
            event: ItemHistoryEventClass.purchase,
            isManaged: true,
            source: ItemHistoryEventClass.purchaseSource,
            destination:
                ItemHistoryEventClass.productDestination,
            desc:
                '${item.quantity} ${item.unit} of this Item Purchased. Purchase Id: #${returnOnlyDigits(item.purchaseId ?? '')}',
            shopId: shopId(),
            isIncreased: true,
            oldValue: formatLargeNumberDouble(
              (product
                  .getPrimaryUnit()
                  .getQuantityEquivDivided(
                    index: 1,
                    quantityTwo: (product.quantity ?? 0),
                  )),
            ),
            newValue: formatLargeNumberDouble(
              product
                  .getPrimaryUnit()
                  .getQuantityEquivDivided(
                    index: 1,
                    quantityTwo: (newPr.quantity ?? 0),
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
            primaryUnit: item.getPrimaryUnit().name,
            unit: item.getSelectedUnit().name,
          );

          await returnData().updateProduct(
            itemHistory: itemHistory,
            includeQuantity: false,
            isIncrement: true,
            isQuantityUpdate: true,
            quantityChange: item
                .getSelectedUnit()
                .getQuantityEquivMultiplied(
                  index: 1,
                  quantityTwo: (item.quantity ?? 0),
                ),
            product: newPr,
          );
        }
      }
      // }
    } catch (e) {
      await mainLocalLog('Error ${e.toString()}');
    }

    notifyListeners();
  }

  // READ sales for a shop
  Future<List<TempItemPurchaseRecord>>
  loadItemPurchaseRecords(int shopId) async {
    bool isOnline = await connectivity.isOnline();
    try {
      if (isOnline && ItemPurchaseFunc().isSynced()) {
        final data = await supabase
            .from(itemPurchaseTableName)
            .select()
            .eq('shop_id', shopId)
            .order('created_at', ascending: false);

        await mainLocalLog(
          '✅Items Records gotten: ${data.length}',
        );
        _itemPurchaseRecords =
            (data as List)
                .map(
                  (json) =>
                      TempItemPurchaseRecord.fromJson(json),
                )
                .toList();
        await ItemPurchaseFunc()
            .insertAllItemPurchaseRecords(
              _itemPurchaseRecords,
            );
      } else {
        _itemPurchaseRecords =
            ItemPurchaseFunc().getItemPurchaseRecords();
      }

      notifyListeners();
      return _itemPurchaseRecords;
    } catch (e) {
      await mainLocalLog(
        '❌Error Getting Item Purchase Records: ${e.toString()}',
      );
      return [];
    }
  }

  // READ sales for a shop
  Future<List<TempItemPurchaseRecord>>
  loadItemPurchaseRecordsOffline() async {
    try {
      _itemPurchaseRecords =
          ItemPurchaseFunc().getItemPurchaseRecords();

      notifyListeners();
      return _itemPurchaseRecords;
    } catch (e) {
      await mainLocalLog(
        '❌Error Getting Item Purchase Records Offline: ${e.toString()}',
      );
      return [];
    }
  }

  // DELETE a sale record
  Future<void> deleteItemPurchaseRecord(
    String recordUuid,
  ) async {
    try {
      // if (isOnline) {
      //   await supabase
      //       .from(itemPurchaseTableName)
      //       .delete()
      //       .eq('uuid', recordUuid);

      //   notifyListeners();
      // } else {
      await ItemPurchaseFunc().deleteRecord(recordUuid);

      if (CreatedItemPurchaseFunc()
          .getRecords()
          .where((rec) => rec.record.uuid == recordUuid)
          .isNotEmpty) {
        await CreatedItemPurchaseFunc().deleteRecords(
          recordUuid,
        );
      } else {
        DeletedItemPurchaseFunc().createDeletedPurchase(
          DeletedItemRecords(recordUuid: recordUuid),
        );
      }
      // }

      loadItemPurchaseRecordsOffline();
    } catch (e) {
      await mainLocalLog(
        'Error Deleting Item Purchase Record: ${e.toString()}',
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

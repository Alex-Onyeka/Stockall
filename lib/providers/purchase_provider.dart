import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_inventory_updates/temp_inventory_update_class.dart';
import 'package:stockall/classes/temp_item_purchase_record/temp_item_purchase_record.dart';
import 'package:stockall/classes/temp_item_purchase_record/unsynced/created_item_records/created_item_records.dart';
import 'package:stockall/classes/temp_item_purchase_record/unsynced/deleted_item_records/deleted_item_records.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/unsynced/created_products/created_products.dart';
import 'package:stockall/classes/temp_product_class/unsynced/updated/updated_products.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/classes/temp_purchase/unsynced/created_purchases/created_purchases.dart';
import 'package:stockall/classes/temp_purchase/unsynced/deleted_purchase/deleted_purchases.dart';
import 'package:stockall/classes/temp_purchase/unsynced/updated/updated_purchases.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';
import 'package:stockall/classes/temp_storage_product/unsynced/created_storage_products/created_storage_products.dart';
import 'package:stockall/classes/temp_storage_product/unsynced/updated/updated_storage_product.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/local_database/item_purchase_func.dart%20copy/item_purchase_func.dart';
import 'package:stockall/local_database/item_purchase_func.dart%20copy/unsync_funcs/created/created_item_purchase_func.dart';
import 'package:stockall/local_database/item_purchase_func.dart%20copy/unsync_funcs/deleted/deleted_item_purchase_func.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/created_products/created_product_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/updated_products/updated_products_func.dart';
import 'package:stockall/local_database/purchases/purchase_func.dart';
import 'package:stockall/local_database/purchases/unsync_funcs/created/created_purchases_func.dart';
import 'package:stockall/local_database/purchases/unsync_funcs/deleted/deleted_purchases_func.dart';
import 'package:stockall/local_database/purchases/unsync_funcs/updated/updated_purchases_func.dart';
import 'package:stockall/local_database/storage_product/storage_products_func.dart';
import 'package:stockall/local_database/storage_product/unsync_funcs/created/created_storage_products_func.dart';
import 'package:stockall/local_database/storage_product/unsync_funcs/updated/updated_storage_products_func.dart';
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
    print(
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

  void clearPurchases() {
    _purchases.clear();
    // clearRecords();
    print('Purchases Cleared');
    notifyListeners();
  }

  // CREATE a new receipt
  Future<TempPurchase?> createPurchase(
    TempPurchase purchase,
  ) async {
    print('Inner Purchase Creation Started');
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
        print(
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
        print(
          '❌❌ Create Purchase Error Offline: ${e.toString()}',
        );
        return null;
      }
    }
  }

  // CREATE a new receipt
  Future<TempPurchase?> updatePurchase(
    TempPurchase purchase,
  ) async {
    print('Inner Purchase Update Started');
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
        print(
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
        return purchase;
      } catch (e) {
        print(
          '❌❌ Create Purchase Error Offline: ${e.toString()}',
        );
        return null;
      }
    }
  }

  // READ all receipts for a shop
  Future<List<TempPurchase>> loadPurchases(
    int shopId,
  ) async {
    bool isOnline = await connectivity.isOnline();
    if (isOnline && returnData().isSynced() == 1) {
      await PurchaseFunc().clearPurchases();
      try {
        final data = await supabase
            .from(tableName)
            .select()
            .eq('shop_id', shopId)
            .order('created_at', ascending: false);
        if (data.isNotEmpty) {
          print('Purchases Gotten ${data.length}');
        }

        _purchases =
            (data as List)
                .map((json) => TempPurchase.fromJson(json))
                .toList();
        await PurchaseFunc().insertAllPurchases(_purchases);
        print('Loaded');
        await loadItemPurchaseRecords(shopId);
        notifyListeners();
      } catch (e) {
        print('❌ Error Getting Purchases: ${e.toString()}');
        return [];
      }
    } else {
      _purchases = PurchaseFunc().getPurchases();
      await loadItemPurchaseRecords(shopId);
      print('Offline Purchases Gotten');
      notifyListeners();
    }
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
      print('Date set: $date');
    } else {
      dateSet = null;
      print('Date Cleared');
    }
    notifyListeners();
  }

  DateTime? rangeStartDate;
  DateTime? rangeEndDate;

  void setRange(DateTime rangeStart, DateTime endOfrange) {
    rangeStartDate = rangeStart;
    rangeEndDate = endOfrange;
    print(
      'Date Range set: Start: $rangeStart End: $endOfrange ',
    );
    dateSet = null;
    notifyListeners();
  }

  // DELETE a receipt
  Future<int> deletePurchase(
    TempPurchase purchase,
    bool? updateInventory,
    bool createUpdate,
  ) async {
    print('Deleting Purchase');
    bool isOnline = await connectivity.isOnline();
    List<TempItemPurchaseRecord> records =
        itemPurchaseRecords
            .where(
              (item) => item.purchaseId == purchase.uuid,
            )
            .toList();
    try {
      if (isOnline) {
        print('Deleting Purchase Online');
        await supabase
            .from(tableName)
            .delete()
            .eq('uuid', purchase.uuid!);
        print('Finished Deleting Purchase Online');
        var containsUpdate = UpdatedPurchasesFunc()
            .getPurchaseIds()
            .where(
              (purch) =>
                  purch.purchase.uuid == purchase.uuid,
            );
        if (containsUpdate.isNotEmpty) {
          await UpdatedPurchasesFunc()
              .deleteUpdatedPurchase(purchase.uuid!);
        }
      } else {
        print('Deleting Purchase Offline');
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
          await DeletedPurchasesFunc()
              .createDeletedPurchase(
                DeletedPurchases(
                  purchaseUuid: purchase.uuid!,
                ),
              );
        }
        if (containsUpdate.isNotEmpty) {
          await UpdatedPurchasesFunc()
              .deleteUpdatedPurchase(purchase.uuid!);
        }
        await ItemPurchaseFunc().deleteRecordsInPurchase(
          purchase.uuid!,
        );
      }

      for (var rec in records) {
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

              var quantity =
                  rec.isGroup == true
                      ? (newPro.quantity ?? 0) -
                          ((rec.quantity ?? 0) *
                              (newPro.qttyPerGroup ?? 1))
                      : (newPro.quantity ?? 0) -
                          (rec.quantity ?? 0);

              try {
                if (isOnline) {
                  await supabase
                      .from('storage_products')
                      .update({'quantity': quantity})
                      .eq('uuid', newPro.uuid!);
                } else {
                  var product = newPro.copyWith();
                  product.updatedAt = DateTime.now();
                  product.quantity = quantity;
                  var res = await StorageProductsFunc()
                      .updateStorageProduct(product);
                  if (res == 1) {
                    List<CreatedStorageProducts>
                    containsCreated =
                        CreatedStorageProductsFunc()
                            .getStorageProducts()
                            .where(
                              (createdProduct) =>
                                  createdProduct
                                      .storageProduct
                                      .uuid ==
                                  product.uuid,
                            )
                            .toList();
                    if (containsCreated.isEmpty) {
                      await UpdatedStorageProductsFunc()
                          .createUpdatedStorageProduct(
                            UpdatedStorageProduct(
                              updatedStorageProduct:
                                  product,
                            ),
                          );
                    } else {
                      await CreatedStorageProductsFunc()
                          .updateCreatedStorageProduct(
                            CreatedStorageProducts(
                              storageProduct: product,
                            ),
                          );
                    }
                  }
                }

                print(
                  'Storage Product Updated Successfully',
                );
                try {
                  if (createUpdate) {
                    var newUpdate =
                        TempInventoryUpdateClass(
                          shopId: shopId(),
                          title: 'Stock Out',
                          createdAt: DateTime.now(),
                          departmentName:
                              returnDepartmentProvider()
                                  .currentDepartment()
                                  ?.name,
                          departmentUuid:
                              returnDepartmentProvider()
                                  .currentDepartment()
                                  ?.uuid,
                          departmentNameTwo: null,
                          departmentUuidTwo: null,
                          itemName: newPro.name,
                          itemUuid: newPro.uuid,
                          staffId: currentUser().userId,
                          staffName: currentUser().name,
                          staffIdTwo: null,
                          staffNameTwo: null,
                          oldValue:
                              (newPro.quantity ?? 0)
                                  .toString(),
                          newValue: quantity.toString(),
                          uuid: uuidGen(),
                          itemTwoOldValue: null,
                          itemTwoNewValue: null,
                          itemTwoUuid: null,
                        );

                    await returnInventoryUpdatesProvider()
                        .createInventoryUpdate(newUpdate);
                    await returnData().getProducts(
                      shopId(),
                    );
                  }
                } catch (e) {
                  print(
                    '❌❌Error Creating Inventory Update: ${e.toString()}',
                  );
                }
              } catch (e) {
                print(
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
              var newPro = products.first.copyWith();

              var quantity =
                  rec.isGroup == true
                      ? (newPro.quantity ?? 0) -
                          ((rec.quantity ?? 0) *
                              (newPro.qttyPerGroup ?? 1))
                      : (newPro.quantity ?? 0) -
                          (rec.quantity ?? 0);

              try {
                if (isOnline) {
                  await supabase
                      .from('products')
                      .update({'quantity': quantity})
                      .eq('uuid', newPro.uuid!);
                } else {
                  var product = newPro.copyWith();
                  product.updatedAt = DateTime.now();
                  product.quantity = quantity;
                  var res = await ProductsFunc()
                      .updateProduct(product);
                  if (res == 1) {
                    var containsCreated =
                        CreatedProductFunc()
                            .getProducts()
                            .where(
                              (createdProduct) =>
                                  createdProduct
                                      .product
                                      .uuid ==
                                  product.uuid,
                            )
                            .toList();
                    if (containsCreated.isEmpty) {
                      await UpdatedProductsFunc()
                          .createUpdatedProduct(
                            UpdatedProducts(
                              product: product,
                            ),
                          );
                    } else {
                      await CreatedProductFunc()
                          .updateProduct(
                            CreatedProducts(
                              product: product,
                            ),
                          );
                    }
                  }
                }
                print('Product Updated Successfully');
                if (createUpdate) {
                  await returnEventsLogProvider().createLog(
                    returnEventsLogProvider()
                        .productAdapter(newPro, 2),
                  );
                  await returnData().getProducts(shopId());
                }
              } catch (e) {
                print(
                  '❌❌Error Updating Product Quantity: ${e.toString()}',
                );
              }
            }
          }
        }
      }

      // if (productNames.isNotEmpty) {
      //   await returnEventsLogProvider().createLog(
      //     returnEventsLogProvider().receiptAdapter(
      //       receipt,
      //       productNames,
      //       3,
      //     ),
      //   );
      // }

      print('✅ Purchase successfully Delete.');

      // await loadPurchases(
      //   returnShopProvider().userShop()!.shopId!,
      // );

      print('Totally Finished Deleting Receipt');
      notifyListeners();
      return 1;
    } catch (e) {
      print('Error Deleting Purchase: ${e.toString()}');
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
        var newPurchases = tempPurchases.map((rec) {
          rec.purchase.createdAt =
              rec.purchase.createdAt.toUtc();
          return rec;
        });
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

        print('${data.length} items added successfully ✅');
        await CreatedPurchasesFunc().clearPurchases();
        print('Unsynced Purchases Cleared');

        print('Mounted, refreshing Purchases ✅');
        await loadPurchases(
          returnShopProvider().userShop()!.shopId!,
        );
      }
    } catch (e) {
      print('Batch Purchases insert failed ❌: $e');
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

        print(
          '${tempPurchases.length} Purchases Created successfully ✅',
        );
        await DeletedPurchasesFunc()
            .clearDeletedPurchases();
        print('Unsynced Deleted Purchases Cleared');

        print('Mounted, refreshing Purchases ✅');
        await loadPurchases(
          returnShopProvider().userShop()!.shopId!,
        );
      }
    } catch (e) {
      print('Batch Purchases Deleted failed ❌: $e');
    }
  }

  //
  //
  //
  //

  Future<void> updatePurchaseSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      print(
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
            print('Local Purchases Uuid is Null');
          }
          final remoteData =
              await supabase
                  .from('purchases')
                  .select('uuid, updated_at')
                  .eq('uuid', localPurchases.uuid!)
                  .maybeSingle();

          if (remoteData == null) {
            await supabase
                .from('purchases')
                .insert(localPurchases.toJson());
            print(
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
            print(
              "Local updatedAt: ${localPurchases.updatedAt}",
            );
            print("Remote updatedAt: $remoteUpdatedAt");

            if (remoteUpdatedAt == null ||
                localPurchases.updatedAt!.isAfter(
                  remoteUpdatedAt,
                )) {
              await supabase
                  .from('purchases')
                  .update(localPurchases.toJson())
                  .eq('uuid', localPurchases.uuid!);
              print(
                'Updated Purchase with uuid ${localPurchases.uuid}',
              );
              await UpdatedPurchasesFunc()
                  .deleteUpdatedPurchase(
                    localPurchases.uuid ?? '',
                  );
            } else {
              print(
                'Skipped Purchase ${localPurchases.uuid}, remote is newer ✅',
              );
            }
          }
        }

        await UpdatedPurchasesFunc()
            .clearUpdatedPurchases();
        print('Unsynced Purchase products cleared');
        print('Mounted, refreshing products ✅');
        await loadPurchases(
          returnShopProvider().userShop()!.shopId!,
        );
      }
    } catch (e) {
      print('Batch update failed ❌: $e');
    }
  }
  //
  //

  List<TempItemPurchaseRecord> _itemPurchaseRecords = [];
  List<TempItemPurchaseRecord> get itemPurchaseRecords =>
      _itemPurchaseRecords;

  // CREATE a new product sale record
  Future<void> createItemPurchaseRecord(
    List<TempItemPurchaseRecord> records,
  ) async {
    bool isOnline = await connectivity.isOnline();
    try {
      final dataToInsert =
          records.map((e) => e.toJson()).toList();
      if (isOnline) {
        await supabase
            .from('item_purchase_records')
            .upsert(dataToInsert, onConflict: 'uuid');
        await ItemPurchaseFunc()
            .insertSalesItemPurchaseRecords(records);
        for (var item in records) {
          if (returnShopProvider()
                  .userShop()
                  ?.manageInventoryStorage ==
              true) {
            var storageProducts =
                returnStorageProductProvider()
                    .storageProductListMain
                    .firstWhere(
                      (prod) =>
                          prod.uuid == item.storageItemId,
                    );

            var newPr = storageProducts.copyWith();
            newPr.quantity =
                item.isGroup == true
                    ? (newPr.quantity ?? 0) +
                        ((item.quantity ?? 0) *
                            (newPr.qttyPerGroup ?? 1))
                    : (newPr.quantity ?? 0) +
                        (item.quantity ?? 0);

            newPr.updatedAt = DateTime.now();

            await returnStorageProductProvider()
                .updateProduct(product: newPr);
            try {
              var newUpdate = TempInventoryUpdateClass(
                shopId: shopId(),
                title: 'Stock In',
                createdAt: DateTime.now(),
                departmentName:
                    returnDepartmentProvider()
                        .currentDepartment()
                        ?.name,
                departmentUuid:
                    returnDepartmentProvider()
                        .currentDepartment()
                        ?.uuid,
                departmentNameTwo: null,
                departmentUuidTwo: null,
                itemName: newPr.name,
                itemUuid: newPr.uuid,
                staffId: currentUser().userId,
                staffName: currentUser().name,
                staffIdTwo: null,
                staffNameTwo: null,
                oldValue:
                    ((newPr.quantity ?? 0) -
                            (item.isGroup == true
                                ? ((item.quantity ?? 0) *
                                    (newPr.qttyPerGroup ??
                                        1))
                                : (item.quantity ?? 0)))
                        .toString(),
                newValue: newPr.quantity.toString(),
                uuid: uuidGen(),
                itemTwoOldValue: null,
                itemTwoNewValue: null,
                itemTwoUuid: null,
              );

              await returnInventoryUpdatesProvider()
                  .createInventoryUpdate(newUpdate);
            } catch (e) {
              print(
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
                item.isGroup == true
                    ? (newPr.quantity ?? 0) +
                        ((item.quantity ?? 0) *
                            (newPr.qttyPerGroup ?? 1))
                    : (newPr.quantity ?? 0) +
                        (item.quantity ?? 0);
            newPr.updatedAt = DateTime.now();

            await returnData().updateProduct(
              product: newPr,
            );
          }
        }
      } else {
        var newRecords =
            records.map((rec) {
              rec.createdAt = DateTime.now();

              return rec;
            }).toList();
        await ItemPurchaseFunc()
            .insertSalesItemPurchaseRecords(newRecords);
        List<CreatedItemRecords> cRecords =
            newRecords.map((r) {
              return CreatedItemRecords(record: r);
            }).toList();
        await CreatedItemPurchaseFunc().insertAllRecords(
          cRecords,
        );
        for (var item in records) {
          if (returnShopProvider()
                  .userShop()
                  ?.manageInventoryStorage ==
              true) {
            var storageProducts =
                returnStorageProductProvider()
                    .storageProductListMain
                    .firstWhere(
                      (prod) =>
                          prod.uuid == item.storageItemId,
                    );

            var newPr = storageProducts.copyWith();
            newPr.quantity =
                item.isGroup == true
                    ? (newPr.quantity ?? 0) +
                        ((item.quantity ?? 0) *
                            (newPr.qttyPerGroup ?? 1))
                    : (newPr.quantity ?? 0) +
                        (item.quantity ?? 0);
            newPr.updatedAt = DateTime.now();

            await returnStorageProductProvider()
                .updateProduct(product: newPr);
            try {
              var newUpdate = TempInventoryUpdateClass(
                shopId: shopId(),
                title: 'Stock In',
                createdAt: DateTime.now(),
                departmentName:
                    returnDepartmentProvider()
                        .currentDepartment()
                        ?.name,
                departmentUuid:
                    returnDepartmentProvider()
                        .currentDepartment()
                        ?.uuid,
                departmentNameTwo: null,
                departmentUuidTwo: null,
                itemName: newPr.name,
                itemUuid: newPr.uuid,
                staffId: currentUser().userId,
                staffName: currentUser().name,
                staffIdTwo: null,
                staffNameTwo: null,
                oldValue:
                    ((newPr.quantity ?? 0) -
                            (item.isGroup == true
                                ? ((item.quantity ?? 0) *
                                    (newPr.qttyPerGroup ??
                                        1))
                                : (item.quantity ?? 0)))
                        .toString(),
                newValue: newPr.quantity.toString(),
                uuid: uuidGen(),
                itemTwoOldValue: null,
                itemTwoNewValue: null,
                itemTwoUuid: null,
              );

              await returnInventoryUpdatesProvider()
                  .createInventoryUpdate(newUpdate);
            } catch (e) {
              print(
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
                item.isGroup == true
                    ? (newPr.quantity ?? 0) +
                        ((item.quantity ?? 0) *
                            (newPr.qttyPerGroup ?? 1))
                    : (newPr.quantity ?? 0) +
                        (item.quantity ?? 0);
            newPr.updatedAt = DateTime.now();

            await returnData().updateProduct(
              product: newPr,
            );
          }
        }
      }
    } catch (e) {
      print('Error ${e.toString()}');
    }

    notifyListeners();
  }

  // READ sales for a shop
  Future<List<TempItemPurchaseRecord>>
  loadItemPurchaseRecords(int shopId) async {
    bool isOnline = await connectivity.isOnline();
    try {
      if (isOnline && returnData().isSynced() == 1) {
        final data = await supabase
            .from('item_purchase_records')
            .select()
            .eq('shop_id', shopId)
            .order('created_at', ascending: false);

        print('✅Items Records gotten: ${data.length}');
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
      print(
        '❌Error Getting Item Purchase Records: ${e.toString()}',
      );
      return [];
    }
  }

  // DELETE a sale record
  Future<void> deleteItemPurchaseRecord(
    String recordUuid,
  ) async {
    bool isOnline = await connectivity.isOnline();
    try {
      if (isOnline) {
        await supabase
            .from('item_purchase_records')
            .delete()
            .eq('uuid', recordUuid);

        notifyListeners();
      } else {
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
      }

      loadItemPurchaseRecords(
        returnShopProvider().userShop()!.shopId!,
      );
    } catch (e) {
      print(
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

  Future<void> createRecordsSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      // Prepare batch payload
      if (CreatedItemPurchaseFunc()
              .getRecords()
              .isNotEmpty &&
          isOnline) {
        final tempRecords =
            CreatedItemPurchaseFunc().getRecords().toList();
        var newRecords = tempRecords.map((rec) {
          rec.record.createdAt =
              rec.record.createdAt.toUtc();
          return rec;
        });
        final payload =
            newRecords
                .map((p) => p.record.toJson())
                .toList();

        // Insert all at once
        final data =
            await supabase
                .from('item_purchase_records')
                .insert(payload)
                .select();

        print('${data.length} items added successfully ✅');
        await CreatedItemPurchaseFunc().clearRecords();
        await loadItemPurchaseRecords(shopId());
        print('Unsynced Purchase Item Records Cleared');
      }
    } catch (e) {
      print(
        'Batch Created Purchase Records insert failed ❌: $e',
      );
    }
  }

  //
  //
  //
  //

  Future<void> deleteItemRecordsSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      // Prepare batch payload
      if (DeletedItemPurchaseFunc()
              .getItemPurchaseIds()
              .isNotEmpty &&
          isOnline) {
        final tempItemPurchases =
            DeletedItemPurchaseFunc()
                .getItemPurchaseIds()
                .toList();

        for (var rec in tempItemPurchases) {
          await supabase
              .from('item_purchase_records')
              .delete()
              .eq('uuid', rec.recordUuid);
          // await DeletedItemPurchaseFunc()
          //     .deletedDeletedPurchases(rec.purchaseUuid);
        }

        print(
          '${tempItemPurchases.length} Purchase Item Records Deleted successfully ✅',
        );
        await DeletedItemPurchaseFunc()
            .clearDeletedItemRecords();
        print(
          'Unsynced Deleted Purchase Item Records Cleared',
        );

        print(
          'Mounted, refreshing Purchase Item Records ✅',
        );
        // await loadPurchases(
        //   returnShopProvider().userShop()!.shopId!,
        // );
      }
    } catch (e) {
      print(
        'Batch Purchase Item Records Deleted failed ❌: $e',
      );
    }
  }

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

    for (var rec in itemPurchaseRecords) {
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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_item_history/production_item_history.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/production_item.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/unsynced/created/created_production_item.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/unsynced/deleted/deleted_production_item.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/unsynced/production_item_quantity_update/production_item_quantity_update.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/unsynced/updated/updated_production_item.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/local_database/production_items/production_items_func.dart';
import 'package:stockall/local_database/production_items/unsync_funcs/created/created_production_items_func.dart';
import 'package:stockall/local_database/production_items/unsync_funcs/deleted/deleted_production_items_func.dart';
import 'package:stockall/local_database/production_items/unsync_funcs/updated/updated_production_items_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/providers/error_log_provider.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class ProductionItemsProvider extends ChangeNotifier {
  static final ProductionItemsProvider _instance =
      ProductionItemsProvider._internal();
  factory ProductionItemsProvider() => _instance;
  ProductionItemsProvider._internal();

  bool isLoading = false;
  ConnectivityProvider connectivity =
      ConnectivityProvider();

  void toggleIsLoading(bool value) {
    isLoading = value;
    mainLocalLog('Loading: ${value.toString()}');
    notifyListeners();
  }

  String unitText({
    required ProductionItem productionItem,
  }) {
    return isGroupUnit
        ? productionItem.groupUnit ?? 'Group'
        : productionItem.unit;
  }

  bool isGroupUnit = false;

  void toggleGroupUnit({required bool value}) {
    isGroupUnit = value;
    notifyListeners();
  }

  final String tableName = 'production_items';

  final supabase = Supabase.instance.client;

  //
  //
  //
  //
  //
  //

  Future<void> createProductionItem({
    required ProductionItem productionItem,
    required ProductionItemHistory? productionItemHistory,
  }) async {
    productionItem.updatedAt = DateTime.now();
    productionItem.createdAt ??= DateTime.now();

    await ProductionItemsFunc().createProductionItem(
      productionItem,
    );
    await CreatedProductionItemsFunc().createProductionItem(
      CreatedProductionItem(
        productionItem: productionItem,
        includeQuantity: true,
      ),
    );
    await mainLocalLog(
      'Offline ProductionItem inserted Successfully',
    );
    await getProductionItemsOffline(
      returnShopProvider().userShop()!.shopId!,
    );
    if (productionItemHistory != null) {
      productionItemHistory.itemName = productionItem.name;
      productionItemHistory.itemUuid = productionItem.uuid;
      await returnProductionItemHistoryProvider()
          .createProductionItemHistory(
            productionItemHistory,
          );
    }

    syncData();

    returnData().clearFields();
  }

  Future<void> createdProductionItemsSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      // Prepare batch payload
      if (CreatedProductionItemsFunc()
              .getProductionItems()
              .isNotEmpty &&
          isOnline) {
        final tempProductionItems =
            CreatedProductionItemsFunc()
                .getProductionItems()
                .toList();
        int count = 0;
        for (var item in tempProductionItems) {
          try {
            // Insert all at once
            var res =
                await supabase
                    .from(tableName)
                    .insert(
                      item.productionItem.toJson(
                        isIncludeQuantity:
                            item.includeQuantity ?? true,
                      ),
                    )
                    .select()
                    .maybeSingle();
            if (res != null) {
              count++;
              await CreatedProductionItemsFunc()
                  .deleteProductionItem(
                    item.productionItem.uuid!,
                  );
            } else {
              await createErrorLog(
                error:
                    'Error Synchronizing Created Production Item ${item.productionItem.name}',
              );
            }
          } on PostgrestException catch (e) {
            if (e.code == '23505') {
              await CreatedProductionItemsFunc()
                  .deleteProductionItem(
                    item.productionItem.uuid!,
                  );
            }
            await createErrorLog(
              error:
                  'Error Synchronizing ProductionItem ${item.productionItem.name}: $e',
            );
          }
        }

        await mainLocalLog(
          '$count productionItems added successfully ✅',
        );
        // await CreatedProductionItemsFunc().clearProductionItems();
        await mainLocalLog(
          'Mounted, refreshing productionItems ✅',
        );
        await getProductionItems();

        returnData().clearFields();
        await mainLocalLog(
          'Unsynced ProductionItems Cleared',
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Batch ProductionItems insert failed ❌: $e',
      );
      await createErrorLog(
        error: 'Batch ProductionItems insert failed ❌: $e',
      );
    }
  }

  Future<void> deletedProductionItemsSync() async {
    try {
      bool isOnline = await connectivity.isOnline();

      if (DeletedProductionItemsFunc()
              .getProductionItemIds()
              .isNotEmpty &&
          isOnline) {
        final uuids =
            DeletedProductionItemsFunc()
                .getProductionItemIds()
                .map((p) => p.productionItemUuid)
                .toList();

        final data =
            await supabase
                .from(tableName)
                .delete()
                .inFilter('uuid', uuids)
                .select();

        await mainLocalLog(
          '${data.length} productionItems deleted successfully ✅',
        );

        await DeletedProductionItemsFunc()
            .clearDeletedProductionItem();

        await mainLocalLog(
          'Mounted, refreshing productionItems ✅',
        );
        await getProductionItems();

        returnData().clearFields();
        await mainLocalLog(
          'Unsynced deleted productionItems cleared',
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Batch ProductionItems delete failed ❌: $e',
      );
      await createErrorLog(
        error: 'Batch ProductionItems delete failed ❌: $e',
      );
    }
  }

  Future<void> updatedProductionItemsSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      await mainLocalLog(
        UpdatedProductionItemsFunc()
            .getProductionItems()
            .length
            .toString(),
      );

      if (UpdatedProductionItemsFunc()
              .getProductionItems()
              .isNotEmpty &&
          isOnline) {
        final updatedProductionItems =
            UpdatedProductionItemsFunc()
                .getProductionItems();

        for (final updated in updatedProductionItems) {
          final localProductionItem =
              updated.productionItem;

          localProductionItem.updatedAt ??=
              DateTime.now().toLocal();

          if (localProductionItem.uuid == null) {
            await mainLocalLog(
              'Local ProductionItem Uuid is Null',
            );
          }
          final remoteData =
              await supabase
                  .from(tableName)
                  .select('uuid, updated_at')
                  .eq('uuid', localProductionItem.uuid!)
                  .maybeSingle();

          if (remoteData == null) {
            try {
              await supabase
                  .from(tableName)
                  .insert(
                    localProductionItem.toJson(
                      isIncludeQuantity:
                          updated.includeQuantity,
                    ),
                  );
              await mainLocalLog(
                'Inserted productionItem with uuid ${localProductionItem.uuid}',
              );
              await UpdatedProductionItemsFunc()
                  .deleteUpdatedProductionItem(
                    localProductionItem.uuid ?? '',
                  );
            } on PostgrestException catch (e) {
              if (e.code == '23505') {
                await UpdatedProductionItemsFunc()
                    .deleteUpdatedProductionItem(
                      localProductionItem.uuid ?? '',
                    );
              }
              await createErrorLog(
                error:
                    'Error Synchronizing ProductionItems ${localProductionItem.name}: $e',
              );
            }
          } else {
            final remoteUpdatedAtRaw =
                remoteData['updated_at'];
            final remoteUpdatedAt =
                remoteUpdatedAtRaw == null
                    ? null
                    : DateTime.parse(
                      remoteUpdatedAtRaw,
                    ).toUtc();

            localProductionItem.updatedAt =
                (localProductionItem.updatedAt ??
                        DateTime.now())
                    .toUtc(); // ✅ keep both UTC
            await mainLocalLog(
              "Local updatedAt: ${localProductionItem.updatedAt}",
            );
            await mainLocalLog(
              "Remote updatedAt: $remoteUpdatedAt",
            );

            if (remoteUpdatedAt == null ||
                localProductionItem.updatedAt!.isAfter(
                  remoteUpdatedAt,
                )) {
              try {
                await supabase
                    .from(tableName)
                    .update(
                      localProductionItem.toJson(
                        isIncludeQuantity:
                            updated.includeQuantity,
                      ),
                    )
                    .eq('uuid', localProductionItem.uuid!);
                await mainLocalLog(
                  'Updated productionItem with uuid ${localProductionItem.uuid}',
                );
                await UpdatedProductionItemsFunc()
                    .deleteUpdatedProductionItem(
                      localProductionItem.uuid ?? '',
                    );
              } on PostgrestException catch (e) {
                if (e.code == '23505') {
                  await UpdatedProductionItemsFunc()
                      .deleteUpdatedProductionItem(
                        localProductionItem.uuid ?? '',
                      );
                }
                await createErrorLog(
                  error:
                      'Error Synchronizing ProductionItems ${localProductionItem.name}: $e',
                );
              }
            } else {
              await mainLocalLog(
                'Skipped productionItem ${localProductionItem.uuid}, remote is newer ✅',
              );
            }
          }
        }

        // await UpdatedProductionItemsFunc().clearupdatedProductionItems();
        await mainLocalLog(
          'Unsynced updated productionItems cleared',
        );
        await mainLocalLog(
          'Mounted, refreshing productionItems ✅',
        );
        await getProductionItems();
        returnData().clearFields();
      }
    } catch (e) {
      await mainLocalLog(
        'Batch ProductionItems update failed ❌: $e',
      );
      await createErrorLog(
        error: 'Batch ProductionItems Update failed ❌: $e',
      );
    }
  }

  //
  //
  //
  //
  //
  //

  List<ProductionItem> productionItemListMain = [];

  List<ProductionItem> productionItemList() {
    if (returnShopProvider()
            .userShop()
            ?.manageDepartments ==
        true) {
      if (!authorization(
        authorized: Authorizations().viewAllDepartments,
      )) {
        return productionItemListMain.where((cat) {
          if (cat.departmentUuid == null) {
            return true;
          } else {
            return cat.departmentUuid ==
                returnDepartmentProvider()
                    .currentDepartment()
                    ?.uuid;
          }
        }).toList();
      } else {
        if (returnDepartmentProvider()
                .currentDepartment()
                ?.uuid ==
            null) {
          return productionItemListMain;
        } else {
          return productionItemListMain.where((cat) {
            if (cat.departmentUuid == null) {
              return true;
            } else {
              return cat.departmentUuid ==
                  returnDepartmentProvider()
                      .currentDepartment()
                      ?.uuid;
            }
          }).toList();
        }
      }
    } else {
      return productionItemListMain;
    }
  }

  void clearProductionItems() {
    productionItemListMain.clear();
    mainLocalLog('ProductionItems Cleared');
    notifyListeners();
  }

  int? allowedRangeProductionItems;

  Future<List<ProductionItem>> getProductionItems() async {
    try {
      bool isOnline = await connectivity.isOnline();
      await mainLocalLog('✅✅ ProductionItems List Cleared');
      if (isOnline &&
          ProductionItemsFunc().isSynced() &&
          returnShopProvider()
                  .userShop()
                  ?.manageProductions ==
              true &&
          authorization(
            authorized: Authorizations().viewProductions,
          ) &&
          GeneralSettingsAuthAction().manageProductions(
            context: null,
          )) {
        final data = await supabase
            .from(tableName)
            .select()
            .eq('shop_id', shopId())
            .order('name', ascending: true)
            .range(
              0,
              allowedRangeProductionItems != null
                  ? (allowedRangeProductionItems ?? 0) - 1
                  : 1000,
            );

        await mainLocalLog(
          'ProductionItems gotten: ${data.length}',
        );

        productionItemListMain =
            (data as List)
                .map(
                  (json) => ProductionItem.fromJson(json),
                )
                .toList();
        productionItemListMain.sort(
          (a, b) => a.name.toLowerCase().compareTo(
            b.name.toLowerCase(),
          ),
        );
        await mainLocalLog(
          'ProductionItem List Set: ${productionItemListMain.length}',
        );
        if (data.length > 999) {
          final data2 = await supabase
              .from(tableName)
              .select()
              .eq('shop_id', shopId())
              .order('name', ascending: true)
              .range(
                1001,
                allowedRangeProductionItems != null
                    ? (allowedRangeProductionItems ?? 0) - 1
                    : 2000,
              );
          await mainLocalLog(
            'ProductionItems 2 gotten: ${data2.length}',
          );
          productionItemListMain.addAll(
            (data2 as List)
                .map(
                  (stuff) => ProductionItem.fromJson(stuff),
                )
                .toList(),
          );
          productionItemListMain.sort(
            (a, b) => a.name.toLowerCase().compareTo(
              b.name.toLowerCase(),
            ),
          );
          await mainLocalLog(
            'ProductionItem List 2 Set: ${productionItemListMain.length}',
          );

          if (productionItemListMain.length > 1999) {
            final data3 = await supabase
                .from(tableName)
                .select()
                .eq('shop_id', shopId())
                .order('name', ascending: true)
                .range(
                  2001,
                  allowedRangeProductionItems ?? 3000,
                );
            await mainLocalLog(
              'ProductionItems 3 gotten: ${data3.length}',
            );
            productionItemListMain.addAll(
              (data3 as List)
                  .map(
                    (stuff) =>
                        ProductionItem.fromJson(stuff),
                  )
                  .toList(),
            );
            productionItemListMain.sort(
              (a, b) => a.name.toLowerCase().compareTo(
                b.name.toLowerCase(),
              ),
            );
            await mainLocalLog(
              'ProductionItem List 3 Set: ${productionItemListMain.length}',
            );
          }
          notifyListeners();
        }
        notifyListeners();

        await ProductionItemsFunc()
            .insertAllProductionItems(
              productionItemListMain,
            );
      } else {
        returnData().syncData();
        await mainLocalLog(
          "Offline Data Gotten: ${ProductionItemsFunc().getProductionItems().length}",
        );
        productionItemListMain =
            ProductionItemsFunc().getProductionItems();
        notifyListeners();
      }

      notifyListeners();
      return productionItemListMain;
    } catch (e) {
      await mainLocalLog(
        "Error Getting ProductionItems Online: ${e.toString()}",
      );
      return [];
    }
  }

  Future<List<ProductionItem>> getProductionItemsOffline(
    int shopId,
  ) async {
    try {
      await mainLocalLog(
        "Offline Data Gotten: ${ProductionItemsFunc().getProductionItems().length}",
      );
      productionItemListMain =
          ProductionItemsFunc().getProductionItems();
      notifyListeners();
      await returnInventoryUpdatesProvider()
          .getInventoryUpdatesOffline();

      notifyListeners();
      return productionItemListMain;
    } catch (e) {
      await mainLocalLog(
        "Error Getting ProductionItems Offline: ${e.toString()}",
      );
      return [];
    }
  }

  Future<ProductionItem?> updateProductionItem({
    required ProductionItem productionItem,
    required bool isQuantityUpdate,
    required bool includeQuantity,
    required double? quantityChange,
    required bool? isIncrement,
    required ProductionItemHistory? productionItemHistory,
    ProductionItem? oldProductionItem,
    bool? isMultipleUpdate,
  }) async {
    try {
      await mainLocalLog(
        productionItem.isManaged.toString(),
      );
      var res = await ProductionItemsFunc()
          .updateProductionItem(productionItem);
      if (res == 1) {
        if (isQuantityUpdate == false) {
          var containsCreated =
              CreatedProductionItemsFunc()
                  .getProductionItems()
                  .where(
                    (createdProductionItem) =>
                        createdProductionItem
                            .productionItem
                            .uuid ==
                        productionItem.uuid,
                  )
                  .toList();
          if (containsCreated.isEmpty) {
            await UpdatedProductionItemsFunc()
                .createUpdatedProductionItem(
                  UpdatedProductionItem(
                    productionItem: productionItem,
                    includeQuantity: includeQuantity,
                  ),
                );
          } else {
            await CreatedProductionItemsFunc()
                .updateProductionItem(
                  CreatedProductionItem(
                    productionItem: productionItem,
                    includeQuantity: includeQuantity,
                  ),
                );
          }
        } else {
          ProductionItemQuantityUpdate
          productionItemsQuantityUpdate =
              ProductionItemQuantityUpdate(
                quantity: (quantityChange ?? 0).abs(),
                productionItemUuid: productionItem.uuid!,
                isIncrement: isIncrement ?? true,
              );
          await returnProductionItemsQuantityUpdateProvider()
              .createProductionItemQuantityUpdate(
                productionItemsQuantityUpdate:
                    productionItemsQuantityUpdate,
              );
        }
        if ((isQuantityUpdate || includeQuantity) &&
            productionItemHistory != null) {
          productionItemHistory.itemName =
              productionItem.name;
          productionItemHistory.itemUuid =
              productionItem.uuid;
          await returnProductionItemHistoryProvider()
              .createProductionItemHistory(
                productionItemHistory,
              );
        }
        await getProductionItemsOffline(
          returnShopProvider().userShop()!.shopId!,
        );
        notifyListeners();
        if (isMultipleUpdate != true) {
          syncData();
        }
        return ProductionItemsFunc()
            .getSingleProductionItem(
              uuid: productionItem.uuid!,
            );
      } else {
        notifyListeners();
        return null;
      }
    } catch (e) {
      notifyListeners();
      await mainLocalLog(
        "Error Updating ProductionItem: ${e.toString()}",
      );
      return null;
    }
  }

  Future<void> deleteProductionItemMain({
    required ProductionItem productionItem,
    bool? isMultipleDelete,
    required ProductionItemHistory? productionItemHistory,
  }) async {
    await ProductionItemsFunc().deleteProductionItem(
      productionItem.uuid!,
    );
    var containsCreated =
        CreatedProductionItemsFunc()
            .getProductionItems()
            .where(
              (pr) =>
                  pr.productionItem.uuid ==
                  productionItem.uuid,
            )
            .toList();

    var containsUpdated =
        UpdatedProductionItemsFunc()
            .getProductionItems()
            .where(
              (pr) =>
                  pr.productionItem.uuid ==
                  productionItem.uuid,
            )
            .toList();
    if (containsCreated.isNotEmpty) {
      await CreatedProductionItemsFunc()
          .createdProductionItemsBox
          .delete(productionItem.uuid);
    } else {
      await DeletedProductionItemsFunc()
          .createDeletedProductionItem(
            DeletedProductionItem(
              productionItemUuid: productionItem.uuid!,
            ),
          );
    }
    if (containsUpdated.isNotEmpty) {
      await UpdatedProductionItemsFunc()
          .deleteUpdatedProductionItem(
            containsUpdated.first.productionItem.uuid!,
          );
      await mainLocalLog('Deleted Update Log');
    }
    await getProductionItemsOffline(
      returnShopProvider().userShop()!.shopId!,
    );
    if (productionItemHistory != null) {
      productionItemHistory.itemName = productionItem.name;
      productionItemHistory.itemUuid = null;
      await returnProductionItemHistoryProvider()
          .createProductionItemHistory(
            productionItemHistory,
          );
    }
    notifyListeners();
    if (isMultipleDelete != true) {
      syncData();
    }
  }

  //
  //
  //
  //
  //
  //
  double returnGroupQuantityValue(
    ProductionItem productionItem,
  ) {
    return productionItem.quantity != null &&
            productionItem.qttyPerGroup != null
        ? (productionItem.quantity ?? 0) /
            (productionItem.qttyPerGroup ?? 0)
        : 0;
  }

  double returnTotalGroupQuantityValue(
    ProductionItem productionItem,
    double totalValue,
  ) {
    return productionItem.qttyPerGroup != null
        ? totalValue / (productionItem.qttyPerGroup ?? 0)
        : 0;
  }
  //
  //
  //
  //
  //
  //

  bool isSelectProductionItems = false;
  List<ProductionItem> selectedProductionItems = [];

  void toggleIsSelectProductionItem(bool value) {
    isSelectProductionItems = value;
    if (!value) {
      selectedProductionItems.clear();
    }
    notifyListeners();
  }

  void selectProductionItem(
    ProductionItem newProductionItem,
  ) {
    if (selectedProductionItems.contains(
      newProductionItem,
    )) {
      selectedProductionItems.remove(newProductionItem);
    } else {
      selectedProductionItems.add(newProductionItem);
    }
    notifyListeners();
  }

  List<ProductionItem> returnRemainingProductionItems() {
    return productionItemList()
        .where((item) => (item.quantity ?? 0) != 0)
        .toList();
  }

  List<ProductionItem> returnFinishedProductionItems() {
    return productionItemList()
        .where((item) => (item.quantity ?? 0) == 0)
        .toList();
  }

  double getTotalRemainingItems() {
    return returnRemainingProductionItems()
        .map((item) => (item.quantity ?? 0))
        .toList()
        .fold(0, (a, b) => a + b);
  }

  double getTotalFinishedItems() {
    return returnFinishedProductionItems()
        .map((item) => (item.quantity ?? 0))
        .toList()
        .fold(0, (a, b) => a + b);
  }

  Future<int> deleteSelectedProductionItems() async {
    try {
      for (var pr in ProductionItemsFunc()
          .getProductionItems()
          .where(
            (prr) => selectedProductionItems.contains(prr),
          )) {
        ProductionItemHistory productionItemHistory =
            ProductionItemHistory(
              shopId: shopId(),
              title: 'Item Deleted',
              quantityChange: 0,
              newValue: (pr.quantity ?? 0).toString(),
              desc: 'Production Item Deleted Now',
              isIncreased: false,
              oldValue: (pr.quantity ?? 0).toString(),
            );
        await deleteProductionItemMain(
          productionItemHistory: productionItemHistory,
          productionItem: pr,
          isMultipleDelete: true,
        );
      }
      toggleIsSelectProductionItem(false);
      syncData();
      return 1;
    } catch (e) {
      await mainLocalLog(
        "Error Deleting Multiple ProductionItems: ${e.toString()}",
      );
      return 0;
    }
  }

  Future<int> duplicateSelectedProductionItems() async {
    try {
      for (var pr in selectedProductionItems) {
        final newProductionItem = pr.copyWith(
          uuid: uuidGen(),
          name: '${pr.name} Copy ${randomCode()}',
          createdAt: DateTime.now(),
        );

        await ProductionItemsFunc().createProductionItem(
          newProductionItem,
        );

        await CreatedProductionItemsFunc()
            .createProductionItem(
              CreatedProductionItem(
                productionItem: newProductionItem,
                includeQuantity: true,
              ),
            );
      }
      await getProductionItemsOffline(shopId());
      toggleIsSelectProductionItem(false);
      syncData();
      return 1;
      // }
    } catch (e) {
      await mainLocalLog(
        "Error Duplicating Multiple ProductionItems: ${e.toString()}",
      );
      return 0;
    }
  }

  Future<int>
  duplicateSelectedProductionItemsForShops() async {
    try {
      for (var pr in selectedProductionItems) {
        for (var shop
            in returnShopProvider().multipleSelectedShops) {
          final newProductionItem = pr.copyWith(
            categories: [],
            departmentName: null,
            departmentUuid: null,
            uuid: uuidGen(),
            shopId: shop.shopId,
            name: '${pr.name} ${randomCode()}',
            createdAt: DateTime.now(),
          );

          await supabase
              .from(tableName)
              .insert(
                newProductionItem.toJson(
                  isIncludeQuantity: true,
                ),
              );
        }
      }
      await getProductionItemsOffline(shopId());
      toggleIsSelectProductionItem(false);
      returnShopProvider().clearMulitpleSelectedShops();
      syncData();
      return 1;
    } catch (e) {
      await mainLocalLog(
        "Error Duplicating Multiple ProductionItems To Selected Shops: ${e.toString()}",
      );
      return 0;
    }
  }

  Future<int>
  duplicateSelectedProductionItemsForDepartments() async {
    try {
      for (var pr in selectedProductionItems) {
        for (var depart
            in returnDepartmentProvider()
                .multipleSelectedDepartments) {
          final newProductionItem = pr.copyWith(
            uuid: uuidGen(),
            departmentUuid: depart.uuid,
            departmentName: depart.name,
            name: '${pr.name} ${randomCode()}',
            createdAt: DateTime.now(),
          );

          await ProductionItemsFunc().createProductionItem(
            newProductionItem,
          );

          await CreatedProductionItemsFunc()
              .createProductionItem(
                CreatedProductionItem(
                  productionItem: newProductionItem,
                  includeQuantity: true,
                ),
              );
        }
      }
      toggleIsSelectProductionItem(false);
      returnDepartmentProvider()
          .clearMulitpleSelectedDepartments();
      syncData();
      return 1;
    } catch (e) {
      await mainLocalLog(
        "Error Duplicating Multiple ProductionItems To Selected Departments: ${e.toString()}",
      );
      return 0;
    }
  }
}

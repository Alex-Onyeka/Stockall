import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_item_history/materials_item_history.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_materials_usage/production_materials_usage.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_materials_usage/unsynced/created/created_production_materials_usage.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_materials_usage/unsynced/deleted/deleted_production_materials_usage.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/local_database/materials_usage/production_materials_usage_func.dart';
import 'package:stockall/local_database/materials_usage/unsync_funcs/created/created_production_materials_usage_func.dart';
import 'package:stockall/local_database/materials_usage/unsync_funcs/deleted/deleted_production_materials_usage_func.dart';
import 'package:stockall/local_database/materials_usage/unsync_funcs/updated/updated_production_materials_usage_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/providers/error_log_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MaterialsUsageProvider extends ChangeNotifier {
  static final MaterialsUsageProvider _instance =
      MaterialsUsageProvider._internal();
  factory MaterialsUsageProvider() => _instance;
  MaterialsUsageProvider._internal();
  bool isLoading = false;
  void toggleIsLoading(bool value) {
    isLoading = value;
    mainLocalLog(
      'Production Materials Usage is ${value ? 'Loading on' : 'Loading Off'}',
    );
    notifyListeners();
  }
  //
  //
  //

  final SupabaseClient supabase = Supabase.instance.client;
  final ConnectivityProvider connectivity =
      ConnectivityProvider();
  List<ProductionMaterialsUsage> _productionMaterialsUsage =
      [];
  List<ProductionMaterialsUsage>
  get productionMaterialsUsage => _productionMaterialsUsage;

  final String tableName = 'production_materials_usage';

  void clearProductionMaterialsUsage() {
    _productionMaterialsUsage.clear();
    mainLocalLog('Production Materials Usage Cleared');
    notifyListeners();
  }

  // CREATE a new ProductionMaterialsUsage
  Future<ProductionMaterialsUsage?>
  createProductionMaterialsUsage(
    ProductionMaterialsUsage productionMaterialsUsage,
  ) async {
    try {
      await mainLocalLog(
        'Inner Production Materials Usage Creation Started',
      );
      productionMaterialsUsage.createdAt = DateTime.now();
      await ProductionMaterialsUsageFunc()
          .createProductionMaterialsUsage(
            productionMaterialsUsage,
          );
      await CreatedProductionMaterialsUsageFunc()
          .createProductionMaterialsUsage(
            CreatedProductionMaterialsUsage(
              createdProductionMaterialsUsage:
                  productionMaterialsUsage,
            ),
          );
      notifyListeners();
      var materials = returnMaterialsProvider()
          .materialListMain
          .where(
            (item) =>
                item.uuid ==
                productionMaterialsUsage.materialUuid,
          );
      if (materials.isNotEmpty) {
        var oldMaterial = materials.first;
        var newMaterial = oldMaterial.copyWith();
        newMaterial.quantity =
            (newMaterial.quantity ?? 0) -
            productionMaterialsUsage.quantity;
        MaterialsItemHistory
        materialsItemHistory = MaterialsItemHistory(
          shopId: newMaterial.shopId,
          title: 'Material Used',
          newValue: (newMaterial.quantity ?? 0).toString(),
          oldValue: (oldMaterial.quantity ?? 0).toString(),
          quantityChange: productionMaterialsUsage.quantity,
          desc: 'This Material Was used.',
          isIncreased: false,
        );
        await returnMaterialsProvider().updateMaterial(
          material: newMaterial,
          isQuantityUpdate: true,
          includeQuantity: true,
          quantityChange: productionMaterialsUsage.quantity,
          isIncrement: true,
          materialsItemHistory: materialsItemHistory,
        );
      }

      await returnMaterialsUsageActionProvider()
          .removeMaterialItemFromCart(
            itemUuid: productionMaterialsUsage.uuid,
          );
      return productionMaterialsUsage;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Create Production Materials Usage Error Offline: ${e.toString()}',
      );
      return null;
    }
  }

  // // CREATE a new ProductionMaterialsUsage
  // Future<ProductionMaterialsUsage?>
  // updateProductionMaterialsUsage(
  //   ProductionMaterialsUsage productionMaterialsUsage,
  // ) async {
  //   await mainLocalLog(
  //     'Inner ProductionMaterialsUsage Update Started',
  //   );
  //   productionMaterialsUsage.updatedAt = DateTime.now().add(
  //     Duration(days: 1),
  //   );
  //   try {
  //     var res = await ProductionMaterialsUsageFunc()
  //         .createProductionMaterialsUsage(
  //           productionMaterialsUsage,
  //         );
  //     if (res == 1) {
  //       var containsCreated =
  //           CreatedProductionMaterialsUsageFunc()
  //               .getProductionMaterialsUsage()
  //               .where(
  //                 (createdProduct) =>
  //                     createdProduct
  //                         .createdProductionMaterialsUsage
  //                         .uuid ==
  //                     productionMaterialsUsage.uuid,
  //               )
  //               .toList();
  //       if (containsCreated.isEmpty) {
  //         await UpdatedProductionMaterialsUsageFunc()
  //             .createUpdatedProductionMaterialsUsage(
  //               UpdatedProductionMaterialsUsage(
  //                 updatedProductionMaterialsUsage:
  //                     productionMaterialsUsage,
  //               ),
  //             );
  //       } else {
  //         await CreatedProductionMaterialsUsageFunc()
  //             .createProductionMaterialsUsage(
  //               CreatedProductionMaterialsUsage(
  //                 createdProductionMaterialsUsage:
  //                     productionMaterialsUsage,
  //               ),
  //             );
  //       }
  //     } else {
  //       notifyListeners();
  //       return null;
  //     }
  //     await getProductionMaterialsUsageOffline();
  //     syncData();
  //     return productionMaterialsUsage;
  //   } catch (e) {
  //     await mainLocalLog(
  //       '❌❌ Create Production Materials Usage Error Offline: ${e.toString()}',
  //     );
  //     return null;
  //   }
  // }

  // READ all ProductionMaterialsUsage for a shop
  Future<List<ProductionMaterialsUsage>>
  getProductionMaterialsUsage(int shopId) async {
    bool isOnline = await connectivity.isOnline();
    if (isOnline &&
        ProductionMaterialsUsageFunc().isSynced() &&
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
      await ProductionMaterialsUsageFunc()
          .clearProductionMaterialsUsages();
      try {
        final data = await supabase
            .from(tableName)
            .select()
            .eq('shop_id', shopId)
            .order('created_at', ascending: false);
        if (data.isNotEmpty) {
          await mainLocalLog(
            'Production Materials Usage Gotten ${data.length}',
          );
        }

        _productionMaterialsUsage =
            (data as List)
                .map(
                  (json) =>
                      ProductionMaterialsUsage.fromJson(
                        json,
                      ),
                )
                .toList();
        await ProductionMaterialsUsageFunc()
            .insertAllProductionMaterialsUsages(
              _productionMaterialsUsage,
            );
        await mainLocalLog('Loaded');
        notifyListeners();
      } catch (e) {
        await mainLocalLog(
          '❌ Error Getting ProductionMaterialsUsage: ${e.toString()}',
        );
        return [];
      }
    } else {
      _productionMaterialsUsage =
          ProductionMaterialsUsageFunc()
              .getProductionMaterialsUsages();
      await mainLocalLog(
        'Offline Production Materials Usage Gotten',
      );
      notifyListeners();
    }
    notifyListeners();
    return _productionMaterialsUsage;
  }

  Future<List<ProductionMaterialsUsage>>
  getProductionMaterialsUsageOffline() async {
    _productionMaterialsUsage =
        ProductionMaterialsUsageFunc()
            .getProductionMaterialsUsages();
    await mainLocalLog(
      'Offline Production Materials Usage Gotten',
    );
    notifyListeners();
    notifyListeners();
    return _productionMaterialsUsage;
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

  // DELETE a ProductionMaterialsUsage
  Future<int> deleteProductionMaterialsUsage(
    ProductionMaterialsUsage productionMaterialsUsage,
    bool? updateInventory,
    bool createUpdate,
  ) async {
    await mainLocalLog(
      'Deleting Production Materials Usage',
    );
    try {
      await mainLocalLog(
        'Deleting ProductionMaterialsUsage Offline',
      );
      await ProductionMaterialsUsageFunc()
          .deleteProductionMaterialsUsage(
            productionMaterialsUsage.uuid,
          );
      var containsCreated =
          CreatedProductionMaterialsUsageFunc()
              .getProductionMaterialsUsage()
              .where(
                (purch) =>
                    purch
                        .createdProductionMaterialsUsage
                        .uuid ==
                    productionMaterialsUsage.uuid,
              )
              .toList();
      var containsUpdate =
          UpdatedProductionMaterialsUsageFunc()
              .getProductionMaterialsUsageIds()
              .where(
                (purch) =>
                    purch
                        .updatedProductionMaterialsUsage
                        .uuid ==
                    productionMaterialsUsage.uuid,
              );
      if (containsCreated.isNotEmpty) {
        await CreatedProductionMaterialsUsageFunc()
            .deleteCreatedProductionMaterialsUsage(
              productionMaterialsUsage.uuid,
            );
      } else {
        await DeletedProductionMaterialsUsageFunc()
            .createDeletedDeletedProductionMaterialsUsage(
              DeletedProductionMaterialsUsage(
                materialsUsageUuid:
                    productionMaterialsUsage.uuid,
              ),
            );
      }
      if (containsUpdate.isNotEmpty) {
        await UpdatedProductionMaterialsUsageFunc()
            .deleteUpdatedProductionMaterialsUsage(
              productionMaterialsUsage.uuid,
            );
      }
      if (updateInventory == true) {
        var materials = returnMaterialsProvider()
            .materialListMain
            .where(
              (item) =>
                  item.uuid ==
                  productionMaterialsUsage.materialUuid,
            );
        if (materials.isNotEmpty) {
          var oldMaterial = materials.first;
          var newMaterial = oldMaterial.copyWith();
          newMaterial.quantity =
              (newMaterial.quantity ?? 0) +
              productionMaterialsUsage.quantity;

          MaterialsItemHistory materialsItemHistory =
              MaterialsItemHistory(
                shopId: newMaterial.shopId,
                title: 'Material Usage Deleted',
                newValue:
                    (newMaterial.quantity ?? 0).toString(),
                oldValue:
                    (oldMaterial.quantity ?? 0).toString(),
                quantityChange:
                    productionMaterialsUsage.quantity,
                desc:
                    'This Material Usage Used Was Deleted.',
                isIncreased: true,
              );
          await returnMaterialsProvider().updateMaterial(
            material: newMaterial,
            isQuantityUpdate: true,
            includeQuantity: true,
            quantityChange:
                productionMaterialsUsage.quantity,
            isIncrement: true,
            materialsItemHistory: materialsItemHistory,
          );
        }
      }

      returnData().syncData();
      await getProductionMaterialsUsageOffline();
      await mainLocalLog(
        '✅ ProductionMaterialsUsage successfully Delete.',
      );
      notifyListeners();
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error Deleting ProductionMaterialsUsage: ${e.toString()}',
      );
      return 0;
    }
  }

  //
  //
  //
  //

  Future<void> createProductionMaterialsUsageSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      // Prepare batch payload
      if (CreatedProductionMaterialsUsageFunc()
              .getProductionMaterialsUsage()
              .isNotEmpty &&
          isOnline) {
        final tempProductionMaterialsUsage =
            CreatedProductionMaterialsUsageFunc()
                .getProductionMaterialsUsage()
                .toList();
        var newProductionMaterialsUsage =
            tempProductionMaterialsUsage.map((rec) {
              rec
                  .createdProductionMaterialsUsage
                  .createdAt = rec
                      .createdProductionMaterialsUsage
                      .createdAt
                      ?.toUtc();
              return rec;
            });
        final payload =
            newProductionMaterialsUsage
                .map(
                  (p) =>
                      p.createdProductionMaterialsUsage
                          .toJson(),
                )
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
        await CreatedProductionMaterialsUsageFunc()
            .clearCreatedProductionMaterialsUsage();
        await mainLocalLog(
          'Unsynced ProductionMaterialsUsage Cleared',
        );

        await mainLocalLog(
          'Mounted, refreshing ProductionMaterialsUsage ✅',
        );
        await getProductionMaterialsUsage(
          returnShopProvider().userShop()!.shopId!,
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Production Materials Usage insert failed ❌: $e',
      );
      await createErrorLog(
        error:
            'Batch Production Material sUsage insert failed ❌: $e',
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

  Future<void> deleteProductionMaterialsUsageSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      // Prepare batch payload
      if (DeletedProductionMaterialsUsageFunc()
              .getDeletedProductionMaterialsUsageIds()
              .isNotEmpty &&
          isOnline) {
        final tempProductionMaterialsUsage =
            DeletedProductionMaterialsUsageFunc()
                .getDeletedProductionMaterialsUsageIds()
                .toList();

        for (var rec in tempProductionMaterialsUsage) {
          await supabase
              .from(tableName)
              .delete()
              .eq('uuid', rec.materialsUsageUuid);
        }

        await mainLocalLog(
          '${tempProductionMaterialsUsage.length} Production Materials Usage Created successfully ✅',
        );
        await DeletedProductionMaterialsUsageFunc()
            .clearDeletedProductionMaterialsUsage();
        await mainLocalLog(
          'Unsynced Deleted Production Materials Usage Cleared',
        );

        await mainLocalLog(
          'Mounted, refreshing Production Materials Usage ✅',
        );
        await getProductionMaterialsUsage(
          returnShopProvider().userShop()!.shopId!,
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Production Materials Usage Deleted failed ❌: $e',
      );
      await createErrorLog(
        error:
            'Batch Production Materials Usage Delete failed ❌: $e',
      );
    }
  }

  //
  //
  //
  //

  Future<void> updateProductionMaterialsUsageSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      await mainLocalLog(
        UpdatedProductionMaterialsUsageFunc()
            .getProductionMaterialsUsageIds()
            .length
            .toString(),
      );

      if (UpdatedProductionMaterialsUsageFunc()
              .getProductionMaterialsUsageIds()
              .isNotEmpty &&
          isOnline) {
        final updatedProductionMaterialsUsage =
            UpdatedProductionMaterialsUsageFunc()
                .getProductionMaterialsUsageIds();

        for (final updated
            in updatedProductionMaterialsUsage) {
          final localProductionMaterialsUsage =
              updated.updatedProductionMaterialsUsage;

          localProductionMaterialsUsage.updatedAt ??=
              DateTime.now().toLocal();

          final remoteData =
              await supabase
                  .from(tableName)
                  .select('uuid, updated_at')
                  .eq(
                    'uuid',
                    localProductionMaterialsUsage.uuid,
                  )
                  .maybeSingle();

          if (remoteData == null) {
            await supabase
                .from(tableName)
                .insert(
                  localProductionMaterialsUsage.toJson(),
                );
            await mainLocalLog(
              'Inserted product with uuid ${localProductionMaterialsUsage.uuid}',
            );
            await UpdatedProductionMaterialsUsageFunc()
                .deleteUpdatedProductionMaterialsUsage(
                  localProductionMaterialsUsage.uuid,
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

            localProductionMaterialsUsage.updatedAt =
                (localProductionMaterialsUsage.updatedAt ??
                        DateTime.now())
                    .toUtc(); // ✅ keep both UTC
            await mainLocalLog(
              "Local updatedAt: ${localProductionMaterialsUsage.updatedAt}",
            );
            await mainLocalLog(
              "Remote updatedAt: $remoteUpdatedAt",
            );

            if (remoteUpdatedAt == null ||
                localProductionMaterialsUsage.updatedAt!
                    .isAfter(remoteUpdatedAt)) {
              await supabase
                  .from(tableName)
                  .update(
                    localProductionMaterialsUsage.toJson(),
                  )
                  .eq(
                    'uuid',
                    localProductionMaterialsUsage.uuid,
                  );
              await mainLocalLog(
                'Updated Production Materials Usage with uuid ${localProductionMaterialsUsage.uuid}',
              );
              await UpdatedProductionMaterialsUsageFunc()
                  .deleteUpdatedProductionMaterialsUsage(
                    localProductionMaterialsUsage.uuid,
                  );
            } else {
              await mainLocalLog(
                'Skipped Production Materials Usage ${localProductionMaterialsUsage.uuid}, remote is newer ✅',
              );
            }
          }
        }

        await UpdatedProductionMaterialsUsageFunc()
            .clearUpdatedProductionMaterialsUsage();
        await mainLocalLog(
          'Unsynced ProductionMaterialsUsage products cleared',
        );
        await mainLocalLog(
          'Mounted, refreshing ProductionMaterials Usage ✅',
        );
        await getProductionMaterialsUsage(
          returnShopProvider().userShop()!.shopId!,
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Production Materials Usage update failed ❌: $e',
      );
      await createErrorLog(
        error:
            'Batch ProductionMaterialsUsage Update failed ❌: $e',
      );
    }
  }
  //
  //

  //
  //
  //

  List<ProductionMaterialsUsage>
  departmentProductionMaterialsUsage() {
    if (returnShopProvider()
            .userShop()
            ?.manageDepartments ==
        true) {
      if (!authorization(
        authorized: Authorizations().viewAllDepartments,
      )) {
        return productionMaterialsUsage.where((cat) {
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
          return productionMaterialsUsage;
        } else {
          return productionMaterialsUsage.where((cat) {
            return cat.departmentUuid ==
                returnDepartmentProvider()
                    .currentDepartment()
                    ?.uuid;
            // }
          }).toList();
        }
      }
    } else {
      return productionMaterialsUsage;
    }
  }

  List<ProductionMaterialsUsage>
  returnOwnProductionMaterialsUsageByDayOrWeek() {
    if (returnShopProvider()
            .userShop()
            ?.manageDepartments ==
        true) {
      if (rangeStartDate != null) {
        return departmentProductionMaterialsUsage().where((
          productionMaterialsUsage,
        ) {
          final created =
              productionMaterialsUsage.createdAt!.toLocal();
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

        return departmentProductionMaterialsUsage()
            .where(
              (productionMaterialsUsage) =>
                  !productionMaterialsUsage.createdAt!
                      .isBefore(fourAm(currentDate)) &&
                  productionMaterialsUsage.createdAt!
                      .isBefore(fourAmNextDay(currentDate)),
            )
            .toList();
      }
    } else {
      if (rangeStartDate != null) {
        if (authorization(
          authorized:
              Authorizations().viewAllTransactionRecords,
        )) {
          return productionMaterialsUsage.where((
            productionMaterialsUsage,
          ) {
            final created =
                productionMaterialsUsage.createdAt!
                    .toLocal();
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
          return productionMaterialsUsage.where((
            productionMaterialsUsage,
          ) {
            final created =
                productionMaterialsUsage.createdAt!
                    .toLocal();
            return !created.isBefore(
                  fourAm(rangeStartDate!),
                ) &&
                created.isBefore(
                  fourAmNextDay(
                    rangeEndDate ??
                        resolveBusinessDate(DateTime.now()),
                  ),
                ) &&
                productionMaterialsUsage.staffUuid ==
                    currentUser().userId;
          }).toList();
        }
      } else {
        final currentDate = dateSet ?? DateTime.now();

        if (authorization(
          authorized:
              Authorizations().viewAllTransactionRecords,
        )) {
          return productionMaterialsUsage
              .where(
                (productionMaterialsUsage) =>
                    !productionMaterialsUsage.createdAt!
                        .isBefore(fourAm(currentDate)) &&
                    !productionMaterialsUsage.createdAt!
                        .isAfter(
                          fourAmNextDay(currentDate),
                        ),
              )
              .toList();
        } else {
          return productionMaterialsUsage
              .where(
                (productionMaterialsUsage) =>
                    !productionMaterialsUsage.createdAt!
                        .isBefore(fourAm(currentDate)) &&
                    !productionMaterialsUsage.createdAt!
                        .isAfter(
                          fourAmNextDay(currentDate),
                        ) &&
                    productionMaterialsUsage.staffUuid ==
                        currentUser().userId,
              )
              .toList();
        }
      }
    }
  }

  double getTotalRevenueForSelectedDayAll() {
    double tempTotalRevenue = 0;

    for (var productionMaterialsUsage
        in (returnOwnProductionMaterialsUsageByDayOrWeek())) {
      tempTotalRevenue +=
          getTotalMainRevenueProductionMaterialsUsage(
            productionMaterialsUsage,
          );
    }

    return tempTotalRevenue;
  }

  double getTotalMaterialsUsed() {
    return returnOwnProductionMaterialsUsageByDayOrWeek()
        .map((item) => item.quantity)
        .fold(0, (a, b) => a + b);
  }

  double getTotalMainRevenueProductionMaterialsUsage(
    ProductionMaterialsUsage productionMaterialsUsage,
  ) {
    var total = ((productionMaterialsUsage.getTotalCost()));

    return total;
  }
}

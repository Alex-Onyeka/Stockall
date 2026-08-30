import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/material_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/unsynced/created_materials/created_material.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/unsynced/deleted_materials/deleted_material.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/unsynced/material_quantity_update/material_quantity_update.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/unsynced/updated/updated_material.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_item_history/materials_item_history.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/local_database/materials/materials_func.dart';
import 'package:stockall/local_database/materials/unsync_funcs/created_materials/created_materials_func.dart';
import 'package:stockall/local_database/materials/unsync_funcs/deleted_materials/deleted_materials_func.dart';
import 'package:stockall/local_database/materials/unsync_funcs/updated_materials/updated_materials_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class MaterialsProvider extends ChangeNotifier {
  static final MaterialsProvider _instance =
      MaterialsProvider._internal();
  factory MaterialsProvider() => _instance;
  MaterialsProvider._internal();

  bool isLoading = false;
  ConnectivityProvider connectivity =
      ConnectivityProvider();

  void toggleIsLoading(bool value) {
    isLoading = value;
    mainLocalLog('Loading: ${value.toString()}');
    notifyListeners();
  }

  String unitText({required MaterialClass material}) {
    return isGroupUnit
        ? material.groupUnit ?? 'Group'
        : material.unit;
  }

  bool isGroupUnit = false;

  void toggleGroupUnit({required bool value}) {
    isGroupUnit = value;
    notifyListeners();
  }

  final String tableName = 'production_materials';

  final supabase = Supabase.instance.client;

  //
  //
  //
  //
  //
  //

  Future<void> createMaterial({
    required MaterialClass material,
    required MaterialsItemHistory? materialsItemHistoy,
  }) async {
    material.updatedAt = DateTime.now();
    material.createdAt ??= DateTime.now();

    await MaterialsFunc().createMaterial(material);
    await CreatedMaterialsFunc().createMaterial(
      CreatedMaterial(
        material: material,
        includeQuantity: true,
      ),
    );
    await mainLocalLog(
      'Offline Material inserted Successfully',
    );
    await getMaterialsOffline(
      returnShopProvider().userShop()!.shopId!,
    );
    if (materialsItemHistoy != null) {
      materialsItemHistoy.itemName = material.name;
      materialsItemHistoy.itemUuid = material.uuid;
      await returnMaterialsItemHistoryProvider()
          .createMaterialsItemHistory(materialsItemHistoy);
    }

    syncData();

    returnData().clearFields();
  }

  Future<void> createdMaterialsSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      // Prepare batch payload
      if (CreatedMaterialsFunc()
              .getMaterials()
              .isNotEmpty &&
          isOnline) {
        final tempMaterials =
            CreatedMaterialsFunc().getMaterials().toList();
        int count = 0;
        for (var item in tempMaterials) {
          try {
            // Insert all at once
            await supabase
                .from(tableName)
                .insert(
                  item.material.toJson(
                    isIncludeQuantity:
                        item.includeQuantity ?? true,
                  ),
                )
                .select();
            count++;
            await CreatedMaterialsFunc().deleteMaterial(
              item.material.uuid!,
            );
          } on PostgrestException catch (e) {
            if (e.code == '23505') {
              await CreatedMaterialsFunc().deleteMaterial(
                item.material.uuid!,
              );
            }
          }
        }

        await mainLocalLog(
          '$count materials added successfully ✅',
        );
        // await CreatedMaterialsFunc().clearMaterials();
        await mainLocalLog(
          'Mounted, refreshing materials ✅',
        );
        await getMaterials();

        returnData().clearFields();
        await mainLocalLog('Unsynced Materials Cleared');
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Materials insert failed ❌: $e',
      );
    }
  }

  Future<void> deletedMaterialsSync() async {
    try {
      bool isOnline = await connectivity.isOnline();

      if (DeletedMaterialsFunc()
              .getMaterialIds()
              .isNotEmpty &&
          isOnline) {
        final uuids =
            DeletedMaterialsFunc()
                .getMaterialIds()
                .map((p) => p.materialUuid)
                .toList();

        final data =
            await supabase
                .from(tableName)
                .delete()
                .inFilter('uuid', uuids)
                .select();

        await mainLocalLog(
          '${data.length} materials deleted successfully ✅',
        );

        await DeletedMaterialsFunc().clearDeletedMaterial();

        await mainLocalLog(
          'Mounted, refreshing materials ✅',
        );
        await getMaterials();

        returnData().clearFields();
        await mainLocalLog(
          'Unsynced deleted materials cleared',
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Materials delete failed ❌: $e',
      );
    }
  }

  Future<void> updatedMaterialsSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      await mainLocalLog(
        UpdatedMaterialsFunc()
            .getMaterials()
            .length
            .toString(),
      );

      if (UpdatedMaterialsFunc()
              .getMaterials()
              .isNotEmpty &&
          isOnline) {
        final updatedMaterials =
            UpdatedMaterialsFunc().getMaterials();

        for (final updated in updatedMaterials) {
          final localMaterial = updated.material;

          localMaterial.updatedAt ??=
              DateTime.now().toLocal();

          if (localMaterial.uuid == null) {
            await mainLocalLog(
              'Local Material Uuid is Null',
            );
          }
          final remoteData =
              await supabase
                  .from(tableName)
                  .select('uuid, updated_at')
                  .eq('uuid', localMaterial.uuid!)
                  .maybeSingle();

          if (remoteData == null) {
            try {
              await supabase
                  .from(tableName)
                  .insert(
                    localMaterial.toJson(
                      isIncludeQuantity:
                          updated.includeQuantity,
                    ),
                  );
              await mainLocalLog(
                'Inserted material with uuid ${localMaterial.uuid}',
              );
              await UpdatedMaterialsFunc()
                  .deleteUpdatedMaterial(
                    localMaterial.uuid ?? '',
                  );
            } on PostgrestException catch (e) {
              if (e.code == '23505') {
                await UpdatedMaterialsFunc()
                    .deleteUpdatedMaterial(
                      localMaterial.uuid ?? '',
                    );
              }
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

            localMaterial.updatedAt =
                (localMaterial.updatedAt ?? DateTime.now())
                    .toUtc(); // ✅ keep both UTC
            await mainLocalLog(
              "Local updatedAt: ${localMaterial.updatedAt}",
            );
            await mainLocalLog(
              "Remote updatedAt: $remoteUpdatedAt",
            );

            if (remoteUpdatedAt == null ||
                localMaterial.updatedAt!.isAfter(
                  remoteUpdatedAt,
                )) {
              try {
                await supabase
                    .from(tableName)
                    .update(
                      localMaterial.toJson(
                        isIncludeQuantity:
                            updated.includeQuantity,
                      ),
                    )
                    .eq('uuid', localMaterial.uuid!);
                await mainLocalLog(
                  'Updated material with uuid ${localMaterial.uuid}',
                );
                await UpdatedMaterialsFunc()
                    .deleteUpdatedMaterial(
                      localMaterial.uuid ?? '',
                    );
              } on PostgrestException catch (e) {
                if (e.code == '23505') {
                  await UpdatedMaterialsFunc()
                      .deleteUpdatedMaterial(
                        localMaterial.uuid ?? '',
                      );
                }
              }
            } else {
              await mainLocalLog(
                'Skipped material ${localMaterial.uuid}, remote is newer ✅',
              );
            }
          }
        }

        // await UpdatedMaterialsFunc().clearupdatedMaterials();
        await mainLocalLog(
          'Unsynced updated materials cleared',
        );
        await mainLocalLog(
          'Mounted, refreshing materials ✅',
        );
        await getMaterials();
        returnData().clearFields();
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Materials update failed ❌: $e',
      );
    }
  }

  //
  //
  //
  //
  //
  //

  List<MaterialClass> materialListMain = [];

  List<MaterialClass> materialList() {
    if (returnShopProvider()
            .userShop()
            ?.manageDepartments ==
        true) {
      if (!authorization(
        authorized: Authorizations().viewAllDepartments,
      )) {
        return materialListMain.where((cat) {
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
          return materialListMain;
        } else {
          return materialListMain.where((cat) {
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
      return materialListMain;
    }
  }

  void clearMaterials() {
    materialListMain.clear();
    mainLocalLog('Materials Cleared');
    notifyListeners();
  }

  int? allowedRangeMaterials;

  Future<List<MaterialClass>> getMaterials() async {
    try {
      bool isOnline = await connectivity.isOnline();
      await mainLocalLog('✅✅ Materials List Cleared');
      if (isOnline &&
          MaterialsFunc().isSynced() &&
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
              allowedRangeMaterials != null
                  ? (allowedRangeMaterials ?? 0) - 1
                  : 1000,
            );

        await mainLocalLog(
          'Materials gotten: ${data.length}',
        );

        materialListMain =
            (data as List)
                .map((json) => MaterialClass.fromJson(json))
                .toList();
        materialListMain.sort(
          (a, b) => a.name.toLowerCase().compareTo(
            b.name.toLowerCase(),
          ),
        );
        await mainLocalLog(
          'Material List Set: ${materialListMain.length}',
        );
        if (data.length > 999) {
          final data2 = await supabase
              .from(tableName)
              .select()
              .eq('shop_id', shopId())
              .order('name', ascending: true)
              .range(
                1001,
                allowedRangeMaterials != null
                    ? (allowedRangeMaterials ?? 0) - 1
                    : 2000,
              );
          await mainLocalLog(
            'Materials 2 gotten: ${data2.length}',
          );
          materialListMain.addAll(
            (data2 as List)
                .map(
                  (stuff) => MaterialClass.fromJson(stuff),
                )
                .toList(),
          );
          materialListMain.sort(
            (a, b) => a.name.toLowerCase().compareTo(
              b.name.toLowerCase(),
            ),
          );
          await mainLocalLog(
            'Material List 2 Set: ${materialListMain.length}',
          );

          if (materialListMain.length > 1999) {
            final data3 = await supabase
                .from(tableName)
                .select()
                .eq('shop_id', shopId())
                .order('name', ascending: true)
                .range(2001, allowedRangeMaterials ?? 3000);
            await mainLocalLog(
              'Materials 3 gotten: ${data3.length}',
            );
            materialListMain.addAll(
              (data3 as List)
                  .map(
                    (stuff) =>
                        MaterialClass.fromJson(stuff),
                  )
                  .toList(),
            );
            materialListMain.sort(
              (a, b) => a.name.toLowerCase().compareTo(
                b.name.toLowerCase(),
              ),
            );
            await mainLocalLog(
              'Material List 3 Set: ${materialListMain.length}',
            );
          }
          notifyListeners();
        }
        notifyListeners();

        await MaterialsFunc().insertAllMaterials(
          materialListMain,
        );
      } else {
        returnData().syncData();
        await mainLocalLog(
          "Offline Data Gotten: ${MaterialsFunc().getMaterials().length}",
        );
        materialListMain = MaterialsFunc().getMaterials();
        notifyListeners();
      }

      notifyListeners();
      return materialListMain;
    } catch (e) {
      await mainLocalLog(
        "Error Getting Materials Online: ${e.toString()}",
      );
      return [];
    }
  }

  Future<List<MaterialClass>> getMaterialsOffline(
    int shopId,
  ) async {
    try {
      await mainLocalLog(
        "Offline Data Gotten: ${MaterialsFunc().getMaterials().length}",
      );
      materialListMain = MaterialsFunc().getMaterials();
      notifyListeners();
      await returnInventoryUpdatesProvider()
          .getInventoryUpdatesOffline();

      notifyListeners();
      return materialListMain;
    } catch (e) {
      await mainLocalLog(
        "Error Getting Materials Offline: ${e.toString()}",
      );
      return [];
    }
  }

  Future<List<MaterialClass>> getMaterialsForOtherShops(
    int shopId,
  ) async {
    List<MaterialClass> tempMaterials = [];
    final data = await supabase
        .from(tableName)
        .select()
        .eq('shop_id', shopId)
        .order('name', ascending: true)
        .range(0, 1000);

    await mainLocalLog('Items gotten: ${data.length}');

    tempMaterials =
        (data as List)
            .map((json) => MaterialClass.fromJson(json))
            .toList();
    tempMaterials.sort(
      (a, b) => a.name.toLowerCase().compareTo(
        b.name.toLowerCase(),
      ),
    );
    await mainLocalLog(
      'Materials List Set: ${tempMaterials.length}',
    );
    if (data.length > 999) {
      final data2 = await supabase
          .from(tableName)
          .select()
          .eq('shop_id', shopId)
          .order('name', ascending: true)
          .range(1001, 2000);
      await mainLocalLog('Items 2 gotten: ${data2.length}');
      tempMaterials.addAll(
        (data2 as List)
            .map((stuff) => MaterialClass.fromJson(stuff))
            .toList(),
      );
      tempMaterials.sort(
        (a, b) => a.name.toLowerCase().compareTo(
          b.name.toLowerCase(),
        ),
      );
      await mainLocalLog(
        'Materials List 2 Set: ${tempMaterials.length}',
      );

      if (tempMaterials.length > 1999) {
        final data3 = await supabase
            .from(tableName)
            .select()
            .eq('shop_id', shopId)
            .order('name', ascending: true)
            .range(2001, 3000);
        await mainLocalLog(
          'Items 3 gotten: ${data3.length}',
        );
        tempMaterials.addAll(
          (data3 as List)
              .map((stuff) => MaterialClass.fromJson(stuff))
              .toList(),
        );
        tempMaterials.sort(
          (a, b) => a.name.toLowerCase().compareTo(
            b.name.toLowerCase(),
          ),
        );
        await mainLocalLog(
          'Materials List 3 Set: ${tempMaterials.length}',
        );
      }
      notifyListeners();
    }
    return tempMaterials;
  }

  Future<MaterialClass?> updateMaterial({
    required MaterialClass material,
    required bool isQuantityUpdate,
    required bool includeQuantity,
    required double? quantityChange,
    required bool? isIncrement,
    required MaterialsItemHistory? materialsItemHistory,
    MaterialClass? oldMaterial,
    bool? isMultipleUpdate,
  }) async {
    try {
      await mainLocalLog(material.isManaged.toString());
      var res = await MaterialsFunc().updateMaterial(
        material,
      );
      if (res == 1) {
        if (isQuantityUpdate == false) {
          var containsCreated =
              CreatedMaterialsFunc()
                  .getMaterials()
                  .where(
                    (createdMaterial) =>
                        createdMaterial.material.uuid ==
                        material.uuid,
                  )
                  .toList();
          if (containsCreated.isEmpty) {
            await UpdatedMaterialsFunc()
                .createUpdatedMaterial(
                  UpdatedMaterial(
                    material: material,
                    includeQuantity: includeQuantity,
                  ),
                );
          } else {
            await CreatedMaterialsFunc().updateMaterial(
              CreatedMaterial(
                material: material,
                includeQuantity: includeQuantity,
              ),
            );
          }
        } else {
          MaterialQuantityUpdate materialsQuantityUpdate =
              MaterialQuantityUpdate(
                quantity: (quantityChange ?? 0).abs(),
                materialUuid: material.uuid!,
                isIncrement: isIncrement ?? true,
              );
          await returnMaterialsQuantityUpdateProvider()
              .createMaterialQuantityUpdate(
                materialsQuantityUpdate:
                    materialsQuantityUpdate,
              );
        }
        if ((isQuantityUpdate || includeQuantity) &&
            materialsItemHistory != null) {
          materialsItemHistory.itemName = material.name;
          materialsItemHistory.itemUuid = material.uuid;
          await returnMaterialsItemHistoryProvider()
              .createMaterialsItemHistory(
                materialsItemHistory,
              );
        }
        await getMaterialsOffline(
          returnShopProvider().userShop()!.shopId!,
        );
        notifyListeners();
        if (isMultipleUpdate != true) {
          syncData();
        }
        return MaterialsFunc().getSingleMaterial(
          uuid: material.uuid!,
        );
      } else {
        notifyListeners();
        return null;
      }
    } catch (e) {
      notifyListeners();
      await mainLocalLog(
        "Error Updating Material: ${e.toString()}",
      );
      return null;
    }
  }

  Future<MaterialClass?> updateMaterialForOtherShops({
    required MaterialClass material,
    required MaterialsItemHistory? materialsItemHistory,
    MaterialClass? oldMaterial,
  }) async {
    try {
      material.updatedAt = DateTime.now();
      var res =
          await supabase
              .from(tableName)
              .update(
                material.toJson(isIncludeQuantity: true),
              )
              .eq('uuid', material.uuid!)
              .select()
              .maybeSingle();
      if (res != null) {
        MaterialClass? resMaterial = MaterialClass.fromJson(
          res,
        );
        if (materialsItemHistory != null) {
          materialsItemHistory.itemName = material.name;
          materialsItemHistory.itemUuid = material.uuid;
          await returnMaterialsItemHistoryProvider()
              .createMaterialsItemHistory(
                materialsItemHistory,
              );
        }
        return resMaterial;
      } else {
        return null;
      }
    } catch (e) {
      notifyListeners();
      await mainLocalLog(
        "Error Updating Material: ${e.toString()}",
      );
      return null;
    }
  }

  Future<void> deleteMaterialMain({
    required MaterialClass material,
    bool? isMultipleDelete,
    required MaterialsItemHistory? materialsItemHistory,
  }) async {
    await MaterialsFunc().deleteMaterial(material.uuid!);
    var containsCreated =
        CreatedMaterialsFunc()
            .getMaterials()
            .where(
              (pr) => pr.material.uuid == material.uuid,
            )
            .toList();

    var containsUpdated =
        UpdatedMaterialsFunc()
            .getMaterials()
            .where(
              (pr) => pr.material.uuid == material.uuid,
            )
            .toList();
    if (containsCreated.isNotEmpty) {
      await CreatedMaterialsFunc().createdMaterialsBox
          .delete(material.uuid);
    } else {
      await DeletedMaterialsFunc().createDeletedMaterial(
        DeletedMaterial(materialUuid: material.uuid!),
      );
    }
    if (containsUpdated.isNotEmpty) {
      await UpdatedMaterialsFunc().deleteUpdatedMaterial(
        containsUpdated.first.material.uuid!,
      );
      await mainLocalLog('Deleted Update Log');
    }
    if (materialsItemHistory != null) {
      materialsItemHistory.itemName = material.name;
      materialsItemHistory.itemUuid = null;
      await returnMaterialsItemHistoryProvider()
          .createMaterialsItemHistory(materialsItemHistory);
    }
    await getMaterialsOffline(
      returnShopProvider().userShop()!.shopId!,
    );
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
  double returnGroupQuantityValue(MaterialClass material) {
    return material.quantity != null &&
            material.qttyPerGroup != null
        ? (material.quantity ?? 0) /
            (material.qttyPerGroup ?? 0)
        : 0;
  }

  double returnTotalGroupQuantityValue(
    MaterialClass material,
    double totalValue,
  ) {
    return material.qttyPerGroup != null
        ? totalValue / (material.qttyPerGroup ?? 0)
        : 0;
  }
  //
  //
  //
  //
  //
  //

  bool isSelectMaterials = false;
  List<MaterialClass> selectedMaterials = [];

  void toggleIsSelectMaterial(bool value) {
    isSelectMaterials = value;
    if (!value) {
      selectedMaterials.clear();
    }
    notifyListeners();
  }

  void selectMaterial(MaterialClass newMaterial) {
    if (selectedMaterials.contains(newMaterial)) {
      selectedMaterials.remove(newMaterial);
    } else {
      selectedMaterials.add(newMaterial);
    }
    notifyListeners();
  }

  Future<int> deleteSelectedMaterials() async {
    try {
      for (var pr in MaterialsFunc().getMaterials().where(
        (prr) => selectedMaterials.contains(prr),
      )) {
        MaterialsItemHistory materialsItemHistory =
            MaterialsItemHistory(
              shopId: shopId(),
              title: 'Item Deleted',
              quantityChange: 0,
              newValue: (pr.quantity ?? 0).toString(),
              desc: 'Materials Item Deleted Now',
              isIncreased: false,
              oldValue: (pr.quantity ?? 0).toString(),
            );
        await deleteMaterialMain(
          materialsItemHistory: materialsItemHistory,
          material: pr,
          isMultipleDelete: true,
        );
      }
      toggleIsSelectMaterial(false);
      syncData();
      return 1;
    } catch (e) {
      await mainLocalLog(
        "Error Deleting Multiple Materials: ${e.toString()}",
      );
      return 0;
    }
  }

  Future<int> duplicateSelectedMaterials() async {
    try {
      for (var pr in selectedMaterials) {
        final newMaterial = pr.copyWith(
          uuid: uuidGen(),
          name: '${pr.name} Copy ${randomCode()}',
          createdAt: DateTime.now(),
        );

        await MaterialsFunc().createMaterial(newMaterial);

        await CreatedMaterialsFunc().createMaterial(
          CreatedMaterial(
            material: newMaterial,
            includeQuantity: true,
          ),
        );
      }
      await getMaterialsOffline(shopId());
      toggleIsSelectMaterial(false);
      syncData();
      return 1;
      // }
    } catch (e) {
      await mainLocalLog(
        "Error Duplicating Multiple Materials: ${e.toString()}",
      );
      return 0;
    }
  }

  Future<int> duplicateSelectedMaterialsForShops() async {
    try {
      for (var pr in selectedMaterials) {
        for (var shop
            in returnShopProvider().multipleSelectedShops) {
          final newMaterial = pr.copyWith(
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
                newMaterial.toJson(isIncludeQuantity: true),
              );
        }
      }
      await getMaterialsOffline(shopId());
      toggleIsSelectMaterial(false);
      returnShopProvider().clearMulitpleSelectedShops();
      syncData();
      return 1;
    } catch (e) {
      await mainLocalLog(
        "Error Duplicating Multiple Materials To Selected Shops: ${e.toString()}",
      );
      return 0;
    }
  }

  Future<int>
  duplicateSelectedMaterialsForDepartments() async {
    try {
      for (var pr in selectedMaterials) {
        for (var depart
            in returnDepartmentProvider()
                .multipleSelectedDepartments) {
          final newMaterial = pr.copyWith(
            uuid: uuidGen(),
            departmentUuid: depart.uuid,
            departmentName: depart.name,
            name: '${pr.name} ${randomCode()}',
            createdAt: DateTime.now(),
          );

          await MaterialsFunc().createMaterial(newMaterial);

          await CreatedMaterialsFunc().createMaterial(
            CreatedMaterial(
              material: newMaterial,
              includeQuantity: true,
            ),
          );
        }
      }
      toggleIsSelectMaterial(false);
      returnDepartmentProvider()
          .clearMulitpleSelectedDepartments();
      syncData();
      return 1;
    } catch (e) {
      await mainLocalLog(
        "Error Duplicating Multiple Materials To Selected Departments: ${e.toString()}",
      );
      return 0;
    }
  }

  // Future<int> generateStorageSelectedMaterials() async {
  //   try {
  //     for (var pr in selectedMaterials) {
  //       var newUuid = uuidGen();
  //       await returnStorageMaterialProvider()
  //           .createStorageMaterial(
  //             isMultiple: true,
  //             material: TempStorageMaterials(
  //               name: pr.name,
  //               shopId: pr.shopId,
  //               groupUnit: pr.groupUnit,
  //               unit: pr.unit,
  //               createdAt: DateTime.now(),
  //               uuid: newUuid,
  //               updatedAt: DateTime.now(),
  //               qttyPerGroup: pr.qttyPerGroup,
  //               costPrice: pr.costPrice,
  //               sellingPrice: pr.sellingPrice,
  //             ),
  //           );

  //       var material = pr.copyWith(storageUuid: newUuid);

  //       await updateMaterial(
  //         itemHistory: null,
  //         includeQuantity: true,
  //         material: material,
  //         isMultipleUpdate: true,
  //         isIncrement: null,
  //         isQuantityUpdate: false,
  //         quantityChange: null,
  //       );
  //     }
  //     await getMaterialsOffline(shopId());
  //     toggleIsSelectMaterial(false);
  //     return 1;
  //     // }
  //   } catch (e) {
  //     await mainLocalLog(
  //       "Error Generating Multiple Storage Materials: ${e.toString()}",
  //     );
  //     return 0;
  //   }
  // }
}

// class MaterialInput {
//   final String name;
//   final int shopId;
//   final String materialUuid;
//   final String? singleUnit;
//   final String? groupUnit;

//   MaterialInput({
//     required this.name,
//     required this.shopId,
//     required this.materialUuid,
//     this.singleUnit,
//     this.groupUnit,
//   });

//   /// Convert object → JSON (for Supabase RPC)
//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'shop_id': shopId,
//       'material_uuid': materialUuid,
//       'single_unit': singleUnit,
//       'group_unit': groupUnit,
//     };
//   }

//   /// Optional: create object from JSON
//   factory MaterialInput.fromJson(
//     Map<String, dynamic> json,
//   ) {
//     return MaterialInput(
//       name: json['name'] as String,
//       shopId: json['shop_id'] as int,
//       materialUuid: json['material_uuid'] as String,
//       singleUnit: json['single_unit'] as String?,
//       groupUnit: json['group_unit'] as String?,
//     );
//   }
// }

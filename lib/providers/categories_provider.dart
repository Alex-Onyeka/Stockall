import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_categories/category_class.dart';
import 'package:stockall/classes/temp_categories/unsynced/created_category/created_category.dart';
import 'package:stockall/classes/temp_categories/unsynced/deleted_category/deleted_category.dart';
import 'package:stockall/classes/temp_categories/unsynced/updated/updated_category.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/local_database/category/category_func.dart';
import 'package:stockall/local_database/category/unsync_funcs/created_categories/created_categories_func.dart';
import 'package:stockall/local_database/category/unsync_funcs/deleted_categories/deleted_categories_func.dart';
import 'package:stockall/local_database/category/unsync_funcs/updated_categories/updated_categories_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoriesProvider extends ChangeNotifier {
  static final CategoriesProvider _instance =
      CategoriesProvider._internal();
  factory CategoriesProvider() => _instance;
  CategoriesProvider._internal();
  final supabase = Supabase.instance.client;
  final ConnectivityProvider connectivity =
      ConnectivityProvider();

  List<CategoryClass> categoriesMain = [];

  List<CategoryClass> categories() {
    if (returnShopProvider()
            .userShop()
            ?.manageDepartments ==
        true) {
      if (!authorization(
        authorized: Authorizations().viewAllDepartments,
      )) {
        return categoriesMain.where((cat) {
          if (cat.departmentId == null) {
            return true;
          } else {
            return cat.departmentId ==
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
          return categoriesMain;
        } else {
          return categoriesMain.where((cat) {
            if (cat.departmentId == null) {
              return true;
            } else {
              return cat.departmentId ==
                  returnDepartmentProvider()
                      .currentDepartment()
                      ?.uuid;
            }
          }).toList();
        }
      }
    } else {
      return categoriesMain;
    }
  }

  final String tableName = 'categories';
  void clearCategories() {
    categoriesMain.clear();
    mainLocalLog('Categories Cleared');
    notifyListeners();
  }

  Future<int> addCategory({
    required CategoryClass category,
  }) async {
    category.updatedAt = DateTime.now();
    try {
      category.createdAt ??= DateTime.now();
      await CategoryFunc().createCategory(category);
      await CreatedCategoriesFunc().createCategory(
        CreatedCategory(category: category),
      );
      // }
      await mainLocalLog('Category Created');
      await getCategoriesOffline(shopId());
      notifyListeners();
      syncData();
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error Creating Category: ${e.toString()}',
      );
      return 0;
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

  Future<List<CategoryClass>> getCategories(
    int shopId,
  ) async {
    bool isOnline = await connectivity.isOnline();
    if (isOnline && CategoryFunc().isSynced()) {
      try {
        final response = await supabase
            .from(tableName)
            .select()
            .eq('shop_id', shopId)
            .order('name', ascending: true);
        await mainLocalLog(
          'Categories Gotten: ${response.length}',
        );

        categoriesMain =
            (response as List)
                .map((e) => CategoryClass.fromJson(e))
                .toList();

        await CategoryFunc().insertAllCategories(
          categoriesMain,
        );
        notifyListeners();
        return categoriesMain;
      } catch (e) {
        await mainLocalLog(
          'Error Getting Categories Online: ${e.toString()}',
        );
        notifyListeners();
        return [];
      }
    } else {
      try {
        categoriesMain = CategoryFunc().getCategories();

        notifyListeners();
        return categoriesMain;
      } catch (e) {
        await mainLocalLog(
          'Error Getting Categories Offline: ${e.toString()}',
        );
        notifyListeners();
        return [];
      }
    }
  }

  Future<List<CategoryClass>> getCategoriesOffline(
    int shopId,
  ) async {
    try {
      categoriesMain = CategoryFunc().getCategories();

      notifyListeners();
      return categoriesMain;
    } catch (e) {
      await mainLocalLog(
        'Error Getting Categories Offline: ${e.toString()}',
      );
      notifyListeners();
      return [];
    }
  }

  //
  //
  //
  //
  //
  //
  //
  Future<int> updateCategory(CategoryClass category) async {
    // bool isOnline = await connectivity.isOnline();
    try {
      category.updatedAt = DateTime.now();
      await mainLocalLog(category.uuid);
      await CategoryFunc().updateCategory(category);
      var containsCreated =
          CreatedCategoriesFunc()
              .getCreateCategories()
              .where(
                (cat) => cat.category.uuid == category.uuid,
              )
              .toList();
      if (containsCreated.isEmpty) {
        await UpdatedCategoriesFunc().createUpdatedCategory(
          UpdatedCategory(category: category),
        );
      } else {
        await CreatedCategoriesFunc().updateCategory(
          CreatedCategory(category: category),
        );
      }
      await getCategoriesOffline(shopId());
      notifyListeners();
      syncData();
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error Updating Category: ${e.toString()}',
      );
      return 0;
    }
  }
  //
  //
  //
  //
  //
  //
  //

  Future<int> deleteCategory({
    required CategoryClass category,
  }) async {
    try {
      var containsCreated =
          CreatedCategoriesFunc()
              .getCreateCategories()
              .where(
                (cat) => cat.category.uuid == category.uuid,
              )
              .toList();
      var containsUpdated =
          UpdatedCategoriesFunc()
              .getCategories()
              .where(
                (cat) => cat.category.uuid == category.uuid,
              )
              .toList();
      await CategoryFunc().deleteCategory(category.uuid);

      if (containsCreated.isNotEmpty) {
        CreatedCategoriesFunc().deleteCategory(
          category.uuid,
        );
      } else {
        await DeletedCategoriesFunc().createDeletedCategory(
          DeletedCategory(
            categoryUuid: category.uuid,
            shopId:
                returnShopProvider().userShop()!.shopId!,
          ),
        );
      }
      if (containsUpdated.isNotEmpty) {
        UpdatedCategoriesFunc().deleteUpdatedCategory(
          category.uuid,
        );
      }
      await getCategoriesOffline(shopId());
      notifyListeners();
      syncData();
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error Deleting Category: ${e.toString()}',
      );
      return 0;
    }
  }

  //
  //
  //
  //
  //

  Future<void> createCategoriesSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      // Prepare batch payload
      if (CreatedCategoriesFunc()
              .getCreateCategories()
              .isNotEmpty &&
          isOnline) {
        final tempCategories =
            CreatedCategoriesFunc()
                .getCreateCategories()
                .toList();
        for (var cat in tempCategories) {
          await mainLocalLog(
            'Updated Time: ${cat.category.updatedAt?.toString()}',
          );
        }
        final payload =
            tempCategories
                .map((p) => p.category.toJson())
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
        await CreatedCategoriesFunc().clearCategories();
        await mainLocalLog('Unsynced Categories Cleared');
        await mainLocalLog(
          'Mounted, refreshing Categories ✅',
        );
        await getCategories(
          returnShopProvider().userShop()!.shopId!,
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Categories insert failed ❌: $e',
      );
    }
  }

  //
  //
  //
  //
  //

  Future<void> deleteCategoriesSync() async {
    try {
      bool isOnline = await connectivity.isOnline();

      if (DeletedCategoriesFunc()
              .getCategoryIds()
              .isNotEmpty &&
          isOnline) {
        final uuids =
            DeletedCategoriesFunc()
                .getCategoryIds()
                .map((p) => p.categoryUuid)
                .toList();

        final data =
            await supabase
                .from(tableName)
                .delete()
                .inFilter(
                  'uuid',
                  uuids,
                ) // delete where id is in the list
                .select();

        await mainLocalLog(
          '${data.length} items deleted successfully ✅',
        );

        await DeletedCategoriesFunc()
            .clearDeletedCategories();
        await mainLocalLog(
          'Unsynced deleted Categories cleared',
        );
        await mainLocalLog(
          'Mounted, refreshing Categories ✅',
        );
        await getCategories(
          returnShopProvider().userShop()!.shopId!,
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Categories delete failed ❌: $e',
      );
    }
  }

  //
  //
  //

  Future<void> updateCategoriesSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      await mainLocalLog(
        UpdatedCategoriesFunc()
            .getCategories()
            .length
            .toString(),
      );

      if (UpdatedCategoriesFunc()
              .getCategories()
              .isNotEmpty &&
          isOnline) {
        final updatedCategory =
            UpdatedCategoriesFunc().getCategories();

        for (final updated in updatedCategory) {
          final localCategories = updated.category;

          localCategories.updatedAt ??=
              DateTime.now().toLocal();

          final remoteData =
              await supabase
                  .from(tableName)
                  .select('uuid, updated_at')
                  .eq('uuid', localCategories.uuid)
                  .maybeSingle();

          if (remoteData == null) {
            await supabase
                .from(tableName)
                .insert(localCategories.toJson());
            await mainLocalLog(
              'Inserted Category with uuid ${localCategories.uuid}',
            );
            await UpdatedCategoriesFunc()
                .deleteUpdatedCategory(
                  localCategories.uuid,
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

            localCategories.updatedAt =
                (localCategories.updatedAt ??
                        DateTime.now())
                    .toUtc();
            await mainLocalLog(
              "Local updatedAt: ${localCategories.updatedAt}",
            );
            await mainLocalLog(
              "Remote updatedAt: $remoteUpdatedAt",
            );

            if (remoteUpdatedAt == null ||
                localCategories.updatedAt!.isAfter(
                  remoteUpdatedAt,
                )) {
              await supabase
                  .from(tableName)
                  .update(localCategories.toJson())
                  .eq('uuid', localCategories.uuid);
              await mainLocalLog(
                'Updated Category with uuid ${localCategories.uuid}',
              );
              await UpdatedCategoriesFunc()
                  .deleteUpdatedCategory(
                    localCategories.uuid,
                  );
            } else {
              await mainLocalLog(
                'Skipped Category ${localCategories.uuid}, remote is newer ✅',
              );
            }
          }
        }

        await UpdatedCategoriesFunc()
            .clearUpdatedCategory();
        await mainLocalLog(
          'Unsynced updated Categories cleared',
        );
        await mainLocalLog(
          'Mounted, refreshing Categories ✅',
        );
        await getCategories(
          returnShopProvider().userShop()!.shopId!,
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Categories update failed ❌: $e',
      );
    }
  }

  //
  //
  //
  //
}

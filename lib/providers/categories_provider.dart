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

  List<CategoryClass> categories = [];
  final String tableName = 'categories';
  void clearCategories() {
    categories.clear();
    print('Categories Cleared');
    notifyListeners();
  }

  Future<int> addCategory({
    required CategoryClass category,
  }) async {
    bool isOnline = await connectivity.isOnline();
    category.updatedAt = DateTime.now();
    try {
      if (isOnline) {
        Map<String, dynamic> res =
            await supabase
                .from(tableName)
                .insert(category.toJson())
                .select()
                .single();

        CategoryClass cat = CategoryClass.fromJson(res);
        await CategoryFunc().createCategory(cat);
      } else {
        category.createdAt ??= DateTime.now();
        await CategoryFunc().createCategory(category);
        await CreatedCategoriesFunc().createCategory(
          CreatedCategory(category: category),
        );
      }
      print('Category Created');
      await getCategories(shopId());
      notifyListeners();
      return 1;
    } catch (e) {
      print('Error Creating Category: ${e.toString()}');
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
    if (isOnline) {
      try {
        final response = await supabase
            .from(tableName)
            .select()
            .eq('shop_id', shopId)
            .order('name', ascending: true);
        print('Categories Gotten: ${response.length}');

        List<CategoryClass> tempCategories =
            (response as List)
                .map((e) => CategoryClass.fromJson(e))
                .toList();

        if (returnShopProvider()
                .userShop()
                ?.manageDepartments ==
            true) {
          if (authorization(
            authorized: Authorizations().viewAllDepartments,
          )) {
            categories = tempCategories;
          } else {
            categories =
                tempCategories
                    .where(
                      (cat) =>
                          cat.departmentId ==
                          returnDepartmentProvider()
                              .currentDepartment()
                              ?.uuid,
                    )
                    .toList();
          }
        } else {
          categories = tempCategories;
        }

        await CategoryFunc().insertAllCategories(
          categories,
        );
        notifyListeners();
        return categories;
      } catch (e) {
        print(
          'Error Getting Categories Online: ${e.toString()}',
        );
        notifyListeners();
        return [];
      }
    } else {
      try {
        List<CategoryClass> tempCategories =
            CategoryFunc().getCategories();
        if (returnShopProvider()
                .userShop()
                ?.manageDepartments ==
            true) {
          if (authorization(
            authorized: Authorizations().viewAllDepartments,
          )) {
            categories = tempCategories;
          } else {
            categories =
                tempCategories
                    .where(
                      (cat) =>
                          cat.departmentId ==
                          returnDepartmentProvider()
                              .currentDepartment()
                              ?.uuid,
                    )
                    .toList();
          }
        } else {
          categories = tempCategories;
        }

        notifyListeners();
        return categories;
      } catch (e) {
        print(
          'Error Getting Categories Offline: ${e.toString()}',
        );
        notifyListeners();
        return [];
      }
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
    bool isOnline = await connectivity.isOnline();
    try {
      category.updatedAt = DateTime.now();
      print(category.uuid);
      if (isOnline) {
        await supabase
            .from(tableName)
            .update(category.toJson())
            .eq('uuid', category.uuid);
      } else {
        await CategoryFunc().updateCategory(category);
        var containsCreated =
            CreatedCategoriesFunc()
                .getCreateCategories()
                .where(
                  (cat) =>
                      cat.category.uuid == category.uuid,
                )
                .toList();
        if (containsCreated.isEmpty) {
          await UpdatedCategoriesFunc()
              .createUpdatedCategory(
                UpdatedCategory(category: category),
              );
        } else {
          await CreatedCategoriesFunc().updateCategory(
            CreatedCategory(category: category),
          );
        }
      }
      await getCategories(shopId());
      notifyListeners();
      return 1;
    } catch (e) {
      print('Error Updating Category: ${e.toString()}');
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
    bool isOnline = await connectivity.isOnline();
    try {
      if (isOnline) {
        await supabase
            .from(tableName)
            .delete()
            .eq('uuid', category.uuid);
      } else {
        var containsCreated =
            CreatedCategoriesFunc()
                .getCreateCategories()
                .where(
                  (cat) =>
                      cat.category.uuid == category.uuid,
                )
                .toList();
        var containsUpdated =
            UpdatedCategoriesFunc()
                .getCategories()
                .where(
                  (cat) =>
                      cat.category.uuid == category.uuid,
                )
                .toList();
        await CategoryFunc().deleteCategory(category.uuid);

        if (containsCreated.isNotEmpty) {
          CreatedCategoriesFunc().deleteCategory(
            category.uuid,
          );
        } else {
          await DeletedCategoriesFunc()
              .createDeletedCategory(
                DeletedCategory(
                  categoryUuid: category.uuid,
                  shopId:
                      returnShopProvider()
                          .userShop()!
                          .shopId!,
                ),
              );
        }
        if (containsUpdated.isNotEmpty) {
          UpdatedCategoriesFunc().deleteUpdatedCategory(
            category.uuid,
          );
        }
      }

      await getCategories(shopId());
      notifyListeners();
      return 1;
    } catch (e) {
      print('Error Deleting Category: ${e.toString()}');
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
          print(
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

        print('${data.length} items added successfully ✅');
        await CreatedCategoriesFunc().clearCategories();
        print('Unsynced Categories Cleared');
      }
    } catch (e) {
      print('Batch Categories insert failed ❌: $e');
    }

    print('Mounted, refreshing Categories ✅');
    await getCategories(
      returnShopProvider().userShop()!.shopId!,
    );
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

        print(
          '${data.length} items deleted successfully ✅',
        );

        await DeletedCategoriesFunc()
            .clearDeletedCategories();
        print('Unsynced deleted Categories cleared');
      }
    } catch (e) {
      print('Batch delete failed ❌: $e');
    }

    print('Mounted, refreshing Categories ✅');
    await getCategories(
      returnShopProvider().userShop()!.shopId!,
    );
  }

  //
  //
  //

  Future<void> updateCategoriesSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      print(
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
            print(
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
            print(
              "Local updatedAt: ${localCategories.updatedAt}",
            );
            print("Remote updatedAt: $remoteUpdatedAt");

            if (remoteUpdatedAt == null ||
                localCategories.updatedAt!.isAfter(
                  remoteUpdatedAt,
                )) {
              await supabase
                  .from(tableName)
                  .update(localCategories.toJson())
                  .eq('uuid', localCategories.uuid);
              print(
                'Updated Category with uuid ${localCategories.uuid}',
              );
              await UpdatedCategoriesFunc()
                  .deleteUpdatedCategory(
                    localCategories.uuid,
                  );
            } else {
              print(
                'Skipped Category ${localCategories.uuid}, remote is newer ✅',
              );
            }
          }
        }

        await UpdatedCategoriesFunc()
            .clearUpdatedCategory();
        print('Unsynced updated Categories cleared');
      }
    } catch (e) {
      print('Batch update failed ❌: $e');
    }

    print('Mounted, refreshing Categories ✅');
    await getCategories(
      returnShopProvider().userShop()!.shopId!,
    );
  }

  //
  //
  //
  //
}

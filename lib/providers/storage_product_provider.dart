import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';
import 'package:stockall/classes/temp_storage_product/unsynced/created_storage_products/created_storage_products.dart';
import 'package:stockall/classes/temp_storage_product/unsynced/deleted_storage_products/deleted_storage_product.dart';
import 'package:stockall/classes/temp_storage_product/unsynced/updated/updated_storage_product.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/local_database/storage_product/storage_products_func.dart';
import 'package:stockall/local_database/storage_product/unsync_funcs/created/created_storage_products_func.dart';
import 'package:stockall/local_database/storage_product/unsync_funcs/deleted/deleted_storage_products_func.dart';
import 'package:stockall/local_database/storage_product/unsync_funcs/updated/updated_storage_products_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/providers/error_log_provider.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class StorageProductProvider extends ChangeNotifier {
  static final StorageProductProvider _instance =
      StorageProductProvider._internal();
  factory StorageProductProvider() => _instance;
  StorageProductProvider._internal();

  bool isLoading = false;
  ConnectivityProvider connectivity =
      ConnectivityProvider();

  void toggleIsLoading(bool value) {
    isLoading = value;
    print('Loading: ${value.toString()}');
    notifyListeners();
  }

  String unitText({
    required TempStorageProducts storageProduct,
  }) {
    return isGroupUnit
        ? storageProduct.groupUnit ?? 'Group'
        : storageProduct.unit ?? 'Unit';
  }

  bool isGroupUnit = false;

  void toggleGroupUnit({required bool value}) {
    isGroupUnit = value;
    notifyListeners();
  }

  final String tableName = 'storage_products';

  final supabase = Supabase.instance.client;

  Future<void> createStorageProduct({
    required TempStorageProducts product,
    bool? isMultiple,
  }) async {
    // bool isOnline = await connectivity.isOnline();
    product.updatedAt = DateTime.now();
    // if (isOnline) {
    //   var data =
    //       await supabase
    //           .from(tableName)
    //           .upsert(product.toJson(), onConflict: 'uuid')
    //           .select()
    //           .single();
    //   print('Storage Product Created successfully');
    //   final newProduct = TempStorageProducts.fromJson(data);
    //   await StorageProductsFunc().createStorageProduct(
    //     newProduct,
    //   );
    //   // await returnEventsLogProvider().createLog(
    //   //   returnEventsLogProvider(
    //   //     // ignore: use_build_context_synchronously
    //   //   ).productAdapter(product, 1),
    //   //   // ignore: use_build_context_synchronously
    //   // );
    //   print('Total Success');
    // } else {
    product.createdAt ??= DateTime.now();

    await StorageProductsFunc().createStorageProduct(
      product,
    );
    await CreatedStorageProductsFunc().createStorageProduct(
      CreatedStorageProducts(storageProduct: product),
    );
    // await returnEventsLogProvider().createLog(
    //   returnEventsLogProvider(
    //     // ignore: use_build_context_synchronously
    //   ).productAdapter(product, 1),
    //   // ignore: use_build_context_synchronously
    // );
    print('Offline Success');
    print('Offline Storage Product inserted Successfully');
    // }

    await getStorageProductsOffline(
      returnShopProvider().userShop()!.shopId!,
    );
    if (isMultiple != true) {
      syncData();
    }
  }

  Future<void> createStorageProductsSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      // Prepare batch payload
      if (CreatedStorageProductsFunc()
              .getStorageProducts()
              .isNotEmpty &&
          isOnline) {
        final tempProducts =
            CreatedStorageProductsFunc()
                .getStorageProducts()
                .toList();
        // final payload =
        //     tempProducts
        //         .map((p) => p.storageProduct.toJson())
        //         .toList();

        // Insert all at once
        int count = 0;
        for (var item in tempProducts) {
          try {
            // Insert all at once
            await supabase
                .from(tableName)
                .insert(item.storageProduct.toJson())
                .select();
            count++;
            await CreatedStorageProductsFunc()
                .deleteCreatedStorageProduct(
                  item.storageProduct.uuid!,
                );
          } on PostgrestException catch (e) {
            if (e.code == '23505') {
              await CreatedStorageProductsFunc()
                  .deleteCreatedStorageProduct(
                    item.storageProduct.uuid!,
                  );
            }
            await createErrorLog(
              error:
                  'Error Synchronizing Storage Product ${item.storageProduct.name}: $e',
            );
          }
        }

        print('$count items added successfully ✅');
        // await CreatedStorageProductsFunc()
        //     .clearCreatedStorageProducts();
        print('Mounted, refreshing Storage Products ✅');
        await getStorageProducts(
          returnShopProvider().userShop()!.shopId!,
        );
        print('Unsynced Storage Products Cleared');
      }
    } catch (e) {
      print('Batch Storage Products Insert failed ❌: $e');
      await createErrorLog(
        error: 'Batch Storage Products Insert failed ❌: $e',
      );
    }
  }

  Future<void> deleteStorageProductsSync() async {
    try {
      bool isOnline = await connectivity.isOnline();

      if (DeletedStorageProductsFunc()
              .getStorageProductIds()
              .isNotEmpty &&
          isOnline) {
        final uuids =
            DeletedStorageProductsFunc()
                .getStorageProductIds()
                .map((p) => p.storageProducteUuid)
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

        await DeletedStorageProductsFunc()
            .clearDeletedStorageProduct();
        print('Mounted, refreshing Storage Products ✅');
        await getStorageProducts(
          returnShopProvider().userShop()!.shopId!,
        );
        print('Unsynced deleted Storage products cleared');
      }
    } catch (e) {
      print('Batch Storage Products Delete failed ❌: $e');
      await createErrorLog(
        error: 'Batch Storage Products Delete failed ❌: $e',
      );
    }
  }

  Future<void> updateStorageProductsSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      print(
        UpdatedStorageProductsFunc()
            .getStorageProductIds()
            .length
            .toString(),
      );

      if (UpdatedStorageProductsFunc()
              .getStorageProductIds()
              .isNotEmpty &&
          isOnline) {
        final updatedProducts =
            UpdatedStorageProductsFunc()
                .getStorageProductIds();

        for (final updated in updatedProducts) {
          final localProduct =
              updated.updatedStorageProduct;

          localProduct.updatedAt ??=
              DateTime.now().toLocal();

          if (localProduct.uuid == null) {
            print('Local Storage Product Uuid is Null');
          }
          final remoteData =
              await supabase
                  .from(tableName)
                  .select('uuid, updated_at')
                  .eq('uuid', localProduct.uuid!)
                  .maybeSingle();

          if (remoteData == null) {
            await supabase
                .from(tableName)
                .insert(localProduct.toJson());
            print(
              'Inserted Storage product with uuid ${localProduct.uuid}',
            );
            await UpdatedStorageProductsFunc()
                .deleteUpdatedStorageProduct(
                  localProduct.uuid ?? '',
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

            localProduct.updatedAt =
                (localProduct.updatedAt ?? DateTime.now())
                    .toUtc(); // ✅ keep both UTC
            print(
              "Local updatedAt: ${localProduct.updatedAt}",
            );
            print("Remote updatedAt: $remoteUpdatedAt");

            if (remoteUpdatedAt == null ||
                localProduct.updatedAt!.isAfter(
                  remoteUpdatedAt,
                )) {
              await supabase
                  .from(tableName)
                  .update(localProduct.toJson())
                  .eq('uuid', localProduct.uuid!);
              print(
                'Updated product with uuid ${localProduct.uuid}',
              );
              await UpdatedStorageProductsFunc()
                  .deleteUpdatedStorageProduct(
                    localProduct.uuid ?? '',
                  );
            } else {
              print(
                'Skipped Storage product ${localProduct.uuid}, remote is newer ✅',
              );
            }
          }
        }

        await UpdatedStorageProductsFunc()
            .clearUpdatedStorageProduct();
        print('Unsynced updated Storage products cleared');
        print('Mounted, refreshing products ✅');
        await getStorageProducts(
          returnShopProvider().userShop()!.shopId!,
        );
      }
    } catch (e) {
      print('Batch Storage Products Update failed ❌: $e');
      await createErrorLog(
        error: 'Batch Storage Products Update failed ❌: $e',
      );
    }
  }

  //
  //
  //
  //
  //
  //

  List<TempStorageProducts> storageProductListMain = [];

  void clearProducts() {
    storageProductListMain.clear();
    print('Products Cleared');
    notifyListeners();
  }

  int? allowedRangeItems;

  void setAllowedRange({
    int? plan,
    required BuildContext context,
  }) {
    allowedRangeItems =
        plan == 3
            ? null
            : subPlans
                .firstWhere((sub) => sub.plan == plan)
                .itemsAuth
                .numberOfItems;
    notifyListeners();
  }

  Future<List<TempStorageProducts>> getStorageProducts(
    int shopId,
  ) async {
    bool isOnline = await connectivity.isOnline();
    print('✅✅ Products List Cleared');
    if (isOnline && StorageProductsFunc().isSynced()) {
      final data = await supabase
          .from(tableName)
          .select()
          .eq('shop_id', shopId)
          .order('name', ascending: true)
          .range(
            0,
            allowedRangeItems != null
                ? (allowedRangeItems ?? 0) - 1
                : 1000,
          );

      print('Items gotten: ${data.length}');

      storageProductListMain =
          (data as List)
              .map(
                (json) =>
                    TempStorageProducts.fromJson(json),
              )
              .toList();
      storageProductListMain.sort(
        (a, b) => a.name.toLowerCase().compareTo(
          b.name.toLowerCase(),
        ),
      );
      print(
        'Product List Set: ${storageProductListMain.length}',
      );
      if (data.length > 999) {
        final data2 = await supabase
            .from(tableName)
            .select()
            .eq('shop_id', shopId)
            .order('name', ascending: true)
            .range(
              1001,
              allowedRangeItems != null
                  ? (allowedRangeItems ?? 0) - 1
                  : 2000,
            );
        print('Items 2 gotten: ${data2.length}');
        storageProductListMain.addAll(
          (data2 as List)
              .map(
                (stuff) =>
                    TempStorageProducts.fromJson(stuff),
              )
              .toList(),
        );
        storageProductListMain.sort(
          (a, b) => a.name.toLowerCase().compareTo(
            b.name.toLowerCase(),
          ),
        );
        print(
          'Product List 2 Set: ${storageProductListMain.length}',
        );

        if (storageProductListMain.length > 1999) {
          final data3 = await supabase
              .from(tableName)
              .select()
              .eq('shop_id', shopId)
              .order('name', ascending: true)
              .range(2001, allowedRangeItems ?? 3000);
          print('Items 3 gotten: ${data3.length}');
          storageProductListMain.addAll(
            (data3 as List)
                .map(
                  (stuff) =>
                      TempStorageProducts.fromJson(stuff),
                )
                .toList(),
          );
          storageProductListMain.sort(
            (a, b) => a.name.toLowerCase().compareTo(
              b.name.toLowerCase(),
            ),
          );
          print(
            'Product List 3 Set: ${storageProductListMain.length}',
          );
        }
        notifyListeners();
      }
      notifyListeners();
      await returnInventoryUpdatesProvider()
          .getInventoryUpdates();

      await StorageProductsFunc().insertAllStorageProducts(
        storageProductListMain,
      );
    } else {
      print(
        "Offline Data Gotten: ${StorageProductsFunc().getStorageProducts().length}",
      );
      storageProductListMain =
          StorageProductsFunc().getStorageProducts();
      notifyListeners();
      await returnInventoryUpdatesProvider()
          .getInventoryUpdatesOffline();
    }

    notifyListeners();
    return storageProductListMain;
  }

  Future<List<TempStorageProducts>>
  getStorageProductsOffline(int shopId) async {
    print(
      "Offline Data Gotten: ${StorageProductsFunc().getStorageProducts().length}",
    );
    storageProductListMain =
        StorageProductsFunc().getStorageProducts();
    notifyListeners();
    await returnInventoryUpdatesProvider()
        .getInventoryUpdatesOffline();

    notifyListeners();
    return storageProductListMain;
  }

  Future<int> updateProduct({
    required TempStorageProducts product,
    TempStorageProducts? oldProduct,
  }) async {
    // bool isOnline = await connectivity.isOnline();
    try {
      // if (isOnline) {
      //   product.updatedAt = DateTime.now().toLocal();
      //   var res =
      //       await supabase
      //           .from(tableName)
      //           .update(product.toJson())
      //           .eq('uuid', product.uuid!)
      //           .select()
      //           .maybeSingle();
      //   if (res != null) {
      //     print('${product.uuid}');
      //     await getStorageProducts(
      //       returnShopProvider().userShop()!.shopId!,
      //     );
      //     notifyListeners();
      //     // return TempStorageProducts.fromJson(res);
      //     return 1;
      //   } else {
      //     print('Storage Product Update Failed');
      //     return 0;
      //   }
      // } else {
      var res = await StorageProductsFunc()
          .updateStorageProduct(product);
      if (res == 1) {
        List<CreatedStorageProducts> containsCreated =
            CreatedStorageProductsFunc()
                .getStorageProducts()
                .where(
                  (createdProduct) =>
                      createdProduct.storageProduct.uuid ==
                      product.uuid,
                )
                .toList();
        if (containsCreated.isEmpty) {
          await UpdatedStorageProductsFunc()
              .createUpdatedStorageProduct(
                UpdatedStorageProduct(
                  updatedStorageProduct: product,
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
        print(product.updatedAt.toString());
        print('${product.uuid}');
        print('Context Mounted');
        await getStorageProductsOffline(
          returnShopProvider().userShop()!.shopId!,
        );
        notifyListeners();
        syncData();
        return 1;
      } else {
        notifyListeners();
        return 0;
      }
      // }
    } catch (e) {
      notifyListeners();
      print("Error Updating Product: ${e.toString()}");
      return 0;
    }
  }

  Future<void> deleteProductMain(
    TempStorageProducts product,
    // BuildContext context,
  ) async {
    // bool isOnline = await connectivity.isOnline();
    // if (isOnline) {
    //   await supabase
    //       .from(tableName)
    //       .delete()
    //       .eq('uuid', product.uuid!);
    //   // await returnEventsLogProvider().createLog(
    //   //   returnEventsLogProvider(
    //   //     // ignore: use_build_context_synchronously
    //   //   ).productAdapter(product, 3),
    //   //   // ignore: use_build_context_synchronously
    //   // );
    // } else {
    await StorageProductsFunc().deleteStorageProduct(
      product.uuid!,
    );
    var containsCreated =
        CreatedStorageProductsFunc()
            .getStorageProducts()
            .where(
              (product) =>
                  product.storageProduct.uuid ==
                  product.storageProduct.uuid,
            )
            .toList();

    var containsUpdated =
        UpdatedStorageProductsFunc()
            .getStorageProductIds()
            .where(
              (product) =>
                  product.updatedStorageProduct.uuid ==
                  product.updatedStorageProduct.uuid,
            )
            .toList();
    print('Updated: ${containsCreated.length.toString()}');
    print('Updated: ${containsUpdated.length.toString()}');
    if (containsCreated.isNotEmpty) {
      await CreatedStorageProductsFunc()
          .deleteCreatedStorageProduct(product.uuid!);
    } else {
      await DeletedStorageProductsFunc()
          .createDeletedStorageProduct(
            DeletedStorageProduct(
              storageProducteUuid: product.uuid!,
            ),
          );
    }
    if (containsUpdated.isNotEmpty) {
      await UpdatedStorageProductsFunc()
          .deleteUpdatedStorageProduct(
            containsUpdated
                .first
                .updatedStorageProduct
                .uuid!,
          );
      print('Deleted Update Log');
    }
    // await returnEventsLogProvider().createLog(
    //   returnEventsLogProvider(
    //     // ignore: use_build_context_synchronously
    //   ).productAdapter(product, 3),
    //   // ignore: use_build_context_synchronously
    // );
    // }
    await getStorageProductsOffline(
      returnShopProvider().userShop()!.shopId!,
    );
    notifyListeners();
    syncData();
  }
}

class StorageProductInput {
  final String name;
  final int shopId;
  final String productUuid;
  final String? singleUnit;
  final String? groupUnit;

  StorageProductInput({
    required this.name,
    required this.shopId,
    required this.productUuid,
    this.singleUnit,
    this.groupUnit,
  });

  /// Convert object → JSON (for Supabase RPC)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'shop_id': shopId,
      'product_uuid': productUuid,
      'single_unit': singleUnit,
      'group_unit': groupUnit,
    };
  }

  /// Optional: create object from JSON
  factory StorageProductInput.fromJson(
    Map<String, dynamic> json,
  ) {
    return StorageProductInput(
      name: json['name'] as String,
      shopId: json['shop_id'] as int,
      productUuid: json['product_uuid'] as String,
      singleUnit: json['single_unit'] as String?,
      groupUnit: json['group_unit'] as String?,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_suppliers/suppliers_class.dart';
import 'package:stockall/classes/temp_suppliers/unsynced/created_suppliers/created_suppliers.dart';
import 'package:stockall/classes/temp_suppliers/unsynced/deleted_suppliers/deleted_supplier.dart';
import 'package:stockall/classes/temp_suppliers/unsynced/updated/updated_suppliers.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/local_database/suppliers_func/suppliers_func.dart';
import 'package:stockall/local_database/suppliers_func/unsync_funcs/created/created_supplier_func.dart';
import 'package:stockall/local_database/suppliers_func/unsync_funcs/deleted/deleted_supplier_func.dart';
import 'package:stockall/local_database/suppliers_func/unsync_funcs/updated/updated_supplier_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SuppliersProvider extends ChangeNotifier {
  static final SuppliersProvider _instance = SuppliersProvider._internal();
  factory SuppliersProvider() => _instance;
  SuppliersProvider._internal();
  //
  //
  //
  //

  final SupabaseClient supabase = Supabase.instance.client;
  final ConnectivityProvider connectivity = ConnectivityProvider();
  List<SuppliersClass> suppliers = [];
  final String tableName = 'suppliers';
  DateTime? _lastSyncAt;
  int? _lastSyncShopId;

  void clearSuppliers() {
    suppliers.clear();
    _lastSyncAt = null;
    _lastSyncShopId = null;
    mainLocalLog('Suppliers Cleared');
    notifyListeners();
  }

  List<SuppliersClass> suppliersMain() {
    if (returnShopProvider().userShop()?.manageDepartments == true) {
      if (!authorization(authorized: Authorizations().viewAllDepartments)) {
        return suppliers.where((cat) {
          if (cat.departmentId == null) {
            return true;
          } else {
            return cat.departmentId ==
                returnDepartmentProvider().currentDepartment()?.uuid;
          }
        }).toList();
      } else {
        if (returnDepartmentProvider().currentDepartment()?.uuid == null) {
          return suppliers;
        } else {
          return suppliers.where((cat) {
            if (cat.departmentId == null) {
              return true;
            } else {
              return cat.departmentId ==
                  returnDepartmentProvider().currentDepartment()?.uuid;
            }
          }).toList();
        }
      }
    } else {
      return suppliers;
    }
  }

  /// Fetch all Suppliers by shop ID
  Future<List<SuppliersClass>> fetchSuppliers(
    int shopId, {
    bool forceRefresh = false,
  }) async {
    suppliers = SuppliersFunc().getSuppliers();
    notifyListeners();
    bool isOnline = await connectivity.isOnline();
    if (isOnline && SuppliersFunc().isSynced()) {
      if (!forceRefresh &&
          _lastSyncAt != null &&
          _lastSyncShopId == shopId &&
          suppliers.isNotEmpty) {
        try {
          final safeSince = _lastSyncAt!
              .subtract(const Duration(seconds: 5))
              .toUtc();
          final res = await supabase
              .from(tableName)
              .select()
              .eq('shop_id', shopId)
              .gt('updated_at', safeSince.toIso8601String())
              .order('updated_at', ascending: true);
          if (res.isNotEmpty) {
            final pendingUuids = {
              ...UpdatedSupplierFunc()
                  .getSuppliers()
                  .map((u) => u.suppliers.uuid),
              ...CreatedSupplierFunc()
                  .getSuppliers()
                  .map((c) => c.supplier.uuid),
            };
            final updated =
                (res as List)
                    .map((j) => SuppliersClass.fromJson(j))
                    .where((s) => !pendingUuids.contains(s.uuid))
                    .toList();
            for (final item in updated) {
              final idx = suppliers.indexWhere(
                (s) => s.uuid == item.uuid,
              );
              if (idx != -1) {
                suppliers[idx] = item;
              } else {
                suppliers.add(item);
              }
            }
            suppliers.sort(
              (a, b) => a.name.toLowerCase().compareTo(
                b.name.toLowerCase(),
              ),
            );
            await SuppliersFunc().insertAllSuppliers(suppliers);
            notifyListeners();
          }
          _lastSyncAt = DateTime.now().toUtc();
          return suppliers;
        } catch (e) {
          await mainLocalLog('Incremental Suppliers Sync error: $e');
        }
      }

      final data = await supabase
          .from(tableName)
          .select()
          .eq('shop_id', shopId)
          .order('name', ascending: true);
      await mainLocalLog(data.length.toString());

      suppliers =
          (data as List).map((json) => SuppliersClass.fromJson(json)).toList();

      await SuppliersFunc().insertAllSuppliers(suppliers);
      _lastSyncAt = DateTime.now().toUtc();
      _lastSyncShopId = shopId;
    } else {
      suppliers = SuppliersFunc().getSuppliers();
    }
    notifyListeners();
    return suppliers;
  }

  /// Add a new Supplier
  Future<void> addSupplierMain(
    SuppliersClass supplier,
    final BuildContext context,
  ) async {
    final shopProvider = returnShopProvider();
    bool isOnline = await connectivity.isOnline();
    supplier.updatedAt = DateTime.now();
    supplier.createdAt = DateTime.now();
    supplier.uuid = uuidGen();
    if (isOnline) {
      final res =
          await supabase
              .from(tableName)
              .insert(supplier.toJson())
              .select()
              .single();
      // await mainLocalLog(res);

      final newSupplier = SuppliersClass.fromJson(res);
      await SuppliersFunc().createSupplier(newSupplier);
    } else {
      GeneralSettingsAuthAction().allowOfflineUseAction(
        context: context,
        action: () async {
          await SuppliersFunc().createSupplier(supplier);
          await CreatedSupplierFunc().createSuppliers(
            CreatedSuppliers(supplier: supplier),
          );
        },
      );
    }
    // suppliers.insert(0, newSupplier);
    await fetchSuppliers(shopProvider.userShop()!.shopId!);
    notifyListeners();
  }

  /// Update a Supplier by ID
  Future<void> updateSupplierrMain(
    SuppliersClass supplier,
    BuildContext context,
  ) async {
    final shopProvider = returnShopProvider();
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      supplier.updatedAt = DateTime.now();
      await supabase
          .from(tableName)
          .update(supplier.toJson())
          .eq('uuid', supplier.uuid!);
    } else {
      await SuppliersFunc().updateSupplier(supplier);
      var containsCreated =
          CreatedSupplierFunc()
              .getSuppliers()
              .where((cus) => cus.supplier.uuid == supplier.uuid)
              .toList();
      if (containsCreated.isEmpty) {
        await UpdatedSupplierFunc().createUpdatedSupplier(
          UpdatedSuppliers(suppliers: supplier),
        );
      } else {
        await CreatedSupplierFunc().updateSuppliers(
          CreatedSuppliers(supplier: supplier),
        );
      }
    }
    await fetchSuppliers(shopProvider.userShop()!.shopId!);
    notifyListeners();
    // Purchases keep the name saved when they were made: give them
    // the new one. A failure here never fails the supplier edit.
    try {
      await returnPurchaseProvider().renameSupplierOnPurchases(
        supplierUuid: supplier.uuid!,
        name: supplier.name,
      );
    } catch (e) {
      await mainLocalLog('Rename supplier on purchases failed ❌: $e');
    }
  }

  /// Delete a Supplier by ID
  Future<void> deleteSupplierMain(
    SuppliersClass supplier,
    BuildContext context,
  ) async {
    final shopProvider = returnShopProvider();
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      await supabase.from(tableName).delete().eq('uuid', supplier.uuid!);
      await mainLocalLog('Supplier Deleted');
    } else {
      var containsCreated =
          CreatedSupplierFunc()
              .getSuppliers()
              .where((supp) => supp.supplier.uuid == supplier.uuid)
              .toList();
      var containsUpdated =
          UpdatedSupplierFunc()
              .getSuppliers()
              .where((supp) => supp.suppliers.uuid == supplier.uuid)
              .toList();
      await SuppliersFunc().deleteSupplier(supplier.uuid!);
      if (containsCreated.isNotEmpty) {
        await CreatedSupplierFunc().deleteSupplier(supplier.uuid!);
      } else {
        await DeletedSupplierFunc().createDeletedSupplier(
          DeletedSupplier(supplierUuid: supplier.uuid!),
        );
      }
      if (containsUpdated.isNotEmpty) {
        await UpdatedSupplierFunc().deleteUpdatedSupplier(supplier.uuid!);
      }
    }

    await fetchSuppliers(shopProvider.userShop()!.shopId!);
    notifyListeners();
  }

  /// Get single Supplier by ID
  SuppliersClass? getSupplierByIdMain(String uuid) {
    try {
      return suppliers.firstWhere((c) => c.uuid == uuid);
    } catch (e) {
      return null;
    }
  }

  // void clearSelectedSupplier(BuildContext context) {
  //   returnSalesProvider().currentCart().selectedSupplier =
  //       null;
  //   returnSalesProvider()
  //       .currentCart()
  //       .selectedSupplierName = null;
  //   CartFunc().updateMainCart(
  //     returnSalesProvider().currentMainCart(),
  //   );
  //   notifyListeners();
  // }

  // void selectSupplier({
  //   required String id,
  //   required String name,
  //   required BuildContext context,
  // }) {
  //   returnSalesProvider().currentCart().selectedSupplier =
  //       id;
  //   returnSalesProvider()
  //       .currentCart()
  //       .selectedSupplierName = name;
  //   notifyListeners();
  //   CartFunc().updateMainCart(
  //     returnSalesProvider().currentMainCart(),
  //   );
  // }

  //
  //
  //
  //
  //

  Future<void> createSupplierSync(
    // BuildContext context,
  ) async {
    try {
      bool isOnline = await connectivity.isOnline();
      // Prepare batch payload
      if (CreatedSupplierFunc().getSuppliers().isNotEmpty && isOnline) {
        final tempSuppliers = CreatedSupplierFunc().getSuppliers().toList();
        for (var supp in tempSuppliers) {
          await mainLocalLog(
            'Updated Time: ${supp.supplier.updatedAt?.toString()}',
          );
        }
        final payload = tempSuppliers.map((p) => p.supplier.toJson()).toList();

        // Insert all at once
        final data = await supabase.from(tableName).insert(payload).select('uuid');

        await mainLocalLog('${data.length} items added successfully ✅');
        await CreatedSupplierFunc().clearSuppliers();
        await mainLocalLog('Unsynced Suppliers Cleared');
      }
    } catch (e) {
      await mainLocalLog('Batch Suppliers Insert failed ❌: $e');
    }
  }

  //
  //
  //
  //
  //

  Future<void> updateSuppliersSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      await mainLocalLog(
        UpdatedSupplierFunc().getSuppliers().length.toString(),
      );

      if (UpdatedSupplierFunc().getSuppliers().isNotEmpty && isOnline) {
        final updatedSuppliers = UpdatedSupplierFunc().getSuppliers();

        for (final updated in updatedSuppliers) {
          final localSupplier = updated.suppliers;

          localSupplier.updatedAt ??= DateTime.now().toLocal();

          if (localSupplier.uuid == null) {
            await mainLocalLog('Local Supplier Uuid is Null');
          }
          final remoteData =
              await supabase
                  .from(tableName)
                  .select('uuid, updated_at')
                  .eq('uuid', localSupplier.uuid!)
                  .maybeSingle();

          if (remoteData == null) {
            await supabase.from(tableName).insert(localSupplier.toJson());
            await mainLocalLog(
              'Inserted Supplier with uuid ${localSupplier.uuid}',
            );
            await UpdatedSupplierFunc().deleteUpdatedSupplier(
              localSupplier.uuid ?? '',
            );
          } else {
            final remoteUpdatedAtRaw = remoteData['updated_at'];
            final remoteUpdatedAt =
                remoteUpdatedAtRaw == null
                    ? null
                    : DateTime.parse(remoteUpdatedAtRaw).toUtc();

            localSupplier.updatedAt =
                (localSupplier.updatedAt ?? DateTime.now())
                    .toUtc(); // ✅ keep both UTC
            await mainLocalLog("Local updatedAt: ${localSupplier.updatedAt}");
            await mainLocalLog("Remote updatedAt: $remoteUpdatedAt");

            if (remoteUpdatedAt == null ||
                localSupplier.updatedAt!.isAfter(remoteUpdatedAt)) {
              await supabase
                  .from(tableName)
                  .update(localSupplier.toJson())
                  .eq('uuid', localSupplier.uuid!);
              await mainLocalLog(
                'Updated Supplier with uuid ${localSupplier.uuid}',
              );
              await UpdatedSupplierFunc().deleteUpdatedSupplier(
                localSupplier.uuid ?? '',
              );
            } else {
              await mainLocalLog(
                'Skipped Supplier ${localSupplier.uuid}, remote is newer ✅',
              );
            }
          }
        }

        await UpdatedSupplierFunc().clearUpdatedSuppliers();
        await mainLocalLog('Unsynced updated Suppliers cleared');
      }
    } catch (e) {
      await mainLocalLog('Batch Suppliers Update failed ❌: $e');
    }
  }

  //
  //
  //
  //

  Future<void> deletedSuppliersSync() async {
    try {
      bool isOnline = await connectivity.isOnline();

      if (DeletedSupplierFunc().getSupplierIds().isNotEmpty && isOnline) {
        final uuids =
            DeletedSupplierFunc()
                .getSupplierIds()
                .map((p) => p.supplierUuid)
                .toList();

        final data =
            await supabase
                .from(tableName)
                .delete()
                .inFilter('uuid', uuids) // delete where id is in the list
                .select('uuid');

        await mainLocalLog('${data.length} items deleted successfully ✅');

        await DeletedSupplierFunc().clearDeletedSupplier();
        await mainLocalLog('Unsynced deleted Suppliers cleared');
      }
    } catch (e) {
      await mainLocalLog('Batch Suppliers Delete failed ❌: $e');
    }
  }
}

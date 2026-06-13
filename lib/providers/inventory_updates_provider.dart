import 'package:flutter/widgets.dart';
import 'package:stockall/classes/temp_inventory_updates/temp_inventory_update_class.dart';
import 'package:stockall/classes/temp_inventory_updates/unsynced/created_inventory_updates_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/local_database/inventory_updates/inventory_updates_func.dart';
import 'package:stockall/local_database/inventory_updates/unsync_funcs/created_inventory_updates_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/providers/error_log_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InventoryUpdatesProvider with ChangeNotifier {
  final SupabaseClient client = Supabase.instance.client;
  final String tableName = 'inventory_updates';
  static final InventoryUpdatesProvider _instance =
      InventoryUpdatesProvider._internal();
  factory InventoryUpdatesProvider() => _instance;
  InventoryUpdatesProvider._internal();

  List<TempInventoryUpdateClass> inventoryUpdates = [];

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

  List<TempInventoryUpdateClass>
  departmentInventoryUpdates() {
    if (returnShopProvider()
            .userShop()
            ?.manageDepartments ==
        true) {
      if (!authorization(
        authorized: Authorizations().viewAllDepartments,
      )) {
        return inventoryUpdates.where((cat) {
          return cat.departmentUuid ==
              returnDepartmentProvider()
                  .currentDepartment()
                  ?.uuid;
          // }
        }).toList();
      } else {
        if (returnDepartmentProvider()
                .currentDepartment()
                ?.uuid ==
            null) {
          return inventoryUpdates;
        } else {
          return inventoryUpdates.where((cat) {
            return cat.departmentUuid ==
                returnDepartmentProvider()
                    .currentDepartment()
                    ?.uuid;
            // }
          }).toList();
        }
      }
    } else {
      return inventoryUpdates;
    }
  }

  List<TempInventoryUpdateClass> returnInventoryUpdates() {
    departmentInventoryUpdates().sort(
      (a, b) => b.createdAt!.compareTo(a.createdAt!),
    );
    if (dateSet == null &&
        rangeEndDate == null &&
        rangeStartDate == null) {
      departmentInventoryUpdates().sort(
        (a, b) => b.createdAt!.compareTo(a.createdAt!),
      );
      return departmentInventoryUpdates();
    } else if (dateSet != null) {
      return departmentInventoryUpdates()
          .where(
            (inventoryUpdate) =>
                !inventoryUpdate.createdAt!.isBefore(
                  fourAm(dateSet!),
                ) &&
                !inventoryUpdate.createdAt!.isAfter(
                  fourAmNextDay(dateSet!),
                ),
          )
          .toList();
    } else {
      return departmentInventoryUpdates()
          .where(
            (update) =>
                ((!update.createdAt!.isBefore(
                      fourAm(rangeStartDate!),
                    )) &&
                    (!update.createdAt!.isAfter(
                      fourAmNextDay(rangeEndDate!),
                    ))),
          )
          .toList();
    }
  }

  Future<List<TempInventoryUpdateClass>>
  getInventoryUpdates() async {
    bool isOnline = await ConnectivityProvider().isOnline();
    var shopId = returnShopProvider().userShop()!.shopId!;
    if (isOnline && InventoryUpdatesFunc().isSynced()) {
      try {
        var res = await client
            .from(tableName)
            .select()
            .eq('shop_id', shopId)
            .order('created_at', ascending: false);
        if (res.isEmpty) {
          print('No Inventory Updates Returned');
          inventoryUpdates.clear();
          InventoryUpdatesFunc().clearInventoryUpdates();
          notifyListeners();
          return [];
        }
        inventoryUpdates =
            res
                .map(
                  (m) =>
                      TempInventoryUpdateClass.fromJson(m),
                )
                .toList();
        await InventoryUpdatesFunc()
            .insertAllInventoryUpdates(inventoryUpdates);
        print(
          '✅✅ Inventory Updates Gotten Successfully Online',
        );
        notifyListeners();

        return inventoryUpdates;
      } catch (e) {
        print(
          '❌❌ Inventory Updates Getting Online Failed: ${e.toString()}',
        );
        return [];
      }
    } else {
      inventoryUpdates =
          InventoryUpdatesFunc().getInventoryUpdatess();
      print(
        'Inventory Updates Gotten Successfully Offline',
      );
      notifyListeners();
      return inventoryUpdates;
    }
  }

  Future<List<TempInventoryUpdateClass>>
  getInventoryUpdatesOffline() async {
    inventoryUpdates =
        InventoryUpdatesFunc().getInventoryUpdatess();
    print('Inventory Updates Gotten Successfully Offline');
    notifyListeners();
    return inventoryUpdates;
  }

  Future<int> createInventoryUpdate(
    TempInventoryUpdateClass inventoryUpdate,
  ) async {
    if (returnShopProvider()
            .userShop()
            ?.manageInventoryStorage ==
        true) {
      // bool isOnline =
      //     await ConnectivityProvider().isOnline();
      inventoryUpdate.uuid = uuidGen();
      inventoryUpdate.createdAt ??= DateTime.now();
      // if (isOnline) {
      //   try {
      //     Map<String, dynamic>? res =
      //         await client
      //             .from(tableName)
      //             .insert(inventoryUpdate.toJson())
      //             .select()
      //             .maybeSingle();
      //     if (res == null) {
      //       print('Inventory Updating Failed');
      //       return 0;
      //     }
      //     inventoryUpdates.add(
      //       TempInventoryUpdateClass.fromJson(res),
      //     );
      //     await InventoryUpdatesFunc()
      //         .createInventoryUpdates(
      //           TempInventoryUpdateClass.fromJson(res),
      //         );
      //     notifyListeners();
      //     // await getInventoryUpdates();
      //     print(
      //       '✅✅ Inventory Updating Successfully Online',
      //     );
      //     return 1;
      //   } catch (e) {
      //     print('Creating Online Failed: ${e.toString()}');
      //     return 0;
      //   }
      // } else {
      try {
        await InventoryUpdatesFunc().createInventoryUpdates(
          inventoryUpdate,
        );
        await CreatedInventoryUpdatesFunc()
            .createInventoryUpdate(
              CreatedInventoryUpdatesClass(
                inventoryUpdate: inventoryUpdate,
              ),
            );
        // await getInventoryUpdates();
        return 1;
      } catch (e) {
        print('Offline Creating Failed: ${e.toString()}');
        return 0;
      }
      // }
    } else {
      return 0;
    }
  }

  Future<void> inventoryUpdatesSync() async {
    try {
      bool isOnline =
          await ConnectivityProvider().isOnline();
      if (CreatedInventoryUpdatesFunc()
              .getCreatedInventoryUpdatess()
              .isNotEmpty &&
          isOnline) {
        final tempInventoryUpdates =
            CreatedInventoryUpdatesFunc()
                .getCreatedInventoryUpdatess()
                .toList();
        var newInventoryUpdates = tempInventoryUpdates.map((
          inventoryUpdate,
        ) {
          inventoryUpdate.inventoryUpdate.createdAt =
              inventoryUpdate.inventoryUpdate.createdAt!;
          return inventoryUpdate;
        });
        final payload =
            newInventoryUpdates
                .map((p) => p.inventoryUpdate.toJson())
                .toList();

        // Insert all at once
        final data =
            await client
                .from(tableName)
                .insert(payload)
                .select();

        print(
          '${data.length} Inventory Update items added successfully ✅',
        );
        await CreatedInventoryUpdatesFunc()
            .clearInventoryUpdate();
        print('Unsynced Inventory Updates Cleared');
        print('Mounted, refreshing Inventory Updates ✅');
        await getInventoryUpdates();
      }
    } catch (e) {
      print('Batch Inventory Updates insert failed ❌: $e');
      await createErrorLog(
        error:
            'Batch Inventory Updates insert failed ❌: $e',
      );
    }
  }

  List<TempInventoryUpdateClass> testInventoryUpdates = [
    TempInventoryUpdateClass(
      newValue: '45000',
      oldValue: '50000',
      title: 'Item Quantity Updated',
      uuid: uuidGen(),
      shopId: 12,
      createdAt: DateTime.now(),
      itemName: 'A new Item is Created',
      staffName: 'Alex Onyeka',
      itemTwoUuid: '',
    ),
  ];
}

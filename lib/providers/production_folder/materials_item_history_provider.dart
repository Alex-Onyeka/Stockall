import 'package:flutter/widgets.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_item_history/materials_item_history.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_item_history/unsynced/created_materials_item_history.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/local_database/materials_item_history/materials_item_histories_func.dart';
import 'package:stockall/local_database/materials_item_history/unsync_funcs/created_materials_item_histories_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MaterialsItemHistoryProvider with ChangeNotifier {
  final SupabaseClient client = Supabase.instance.client;
  final String tableName =
      'production_materials_item_history';
  static final MaterialsItemHistoryProvider _instance =
      MaterialsItemHistoryProvider._internal();
  factory MaterialsItemHistoryProvider() => _instance;
  MaterialsItemHistoryProvider._internal();

  List<MaterialsItemHistory> materialsItemHistories = [];

  void clearMaterialsItemHistories() {
    materialsItemHistories.clear();
    mainLocalLog('Materials Cleared');
    notifyListeners();
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

  List<MaterialsItemHistory>
  departmentMaterialsItemHistories() {
    if (returnShopProvider()
            .userShop()
            ?.manageDepartments ==
        true) {
      if (!authorization(
        authorized: Authorizations().viewAllDepartments,
      )) {
        return materialsItemHistories.where((cat) {
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
          return materialsItemHistories;
        } else {
          return materialsItemHistories.where((cat) {
            return cat.departmentUuid ==
                returnDepartmentProvider()
                    .currentDepartment()
                    ?.uuid;
            // }
          }).toList();
        }
      }
    } else {
      return materialsItemHistories;
    }
  }

  List<MaterialsItemHistory>
  returnMaterialsItemHistories() {
    departmentMaterialsItemHistories().sort(
      (a, b) => b.createdAt!.compareTo(a.createdAt!),
    );
    if (dateSet == null &&
        rangeEndDate == null &&
        rangeStartDate == null) {
      departmentMaterialsItemHistories().sort(
        (a, b) => b.createdAt!.compareTo(a.createdAt!),
      );
      return departmentMaterialsItemHistories();
    } else if (dateSet != null) {
      return departmentMaterialsItemHistories()
          .where(
            (itemHistory) =>
                !itemHistory.createdAt!.isBefore(
                  fourAm(dateSet!),
                ) &&
                !itemHistory.createdAt!.isAfter(
                  fourAmNextDay(dateSet!),
                ),
          )
          .toList();
    } else {
      return departmentMaterialsItemHistories()
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

  Future<List<MaterialsItemHistory>>
  getMaterialsItemHistories() async {
    bool isOnline = await ConnectivityProvider().isOnline();
    var shop = returnShopProvider().userShop()!;
    var shopId = shop.shopId!;
    if (isOnline &&
        MaterialsItemHistoriesFunc().isSynced() &&
        ItemsAuthAction().trackItemHistoryAction(
          context: null,
        ) &&
        shop.manageProductions == true &&
        GeneralSettingsAuthAction().manageProductions(
          context: null,
        ) &&
        authorization(
          authorized: Authorizations().viewProductions,
        )) {
      try {
        var res = await client
            .from(tableName)
            .select()
            .eq('shop_id', shopId)
            .order('created_at', ascending: false);
        if (res.isEmpty) {
          await mainLocalLog(
            'No Materials Item Histories Returned',
          );
          materialsItemHistories.clear();
          MaterialsItemHistoriesFunc()
              .clearMaterialsItemHistories();
          notifyListeners();
          return [];
        }
        materialsItemHistories =
            res
                .map(
                  (m) => MaterialsItemHistory.fromJson(m),
                )
                .toList();
        await MaterialsItemHistoriesFunc()
            .insertAllMaterialsItemHistories(
              materialsItemHistories,
            );
        await mainLocalLog(
          '✅✅ Materials Item Histories Gotten Successfully Online',
        );
        notifyListeners();

        return materialsItemHistories;
      } catch (e) {
        await mainLocalLog(
          '❌❌ Materials Item Histories Getting Online Failed: ${e.toString()}',
        );
        return [];
      }
    } else {
      materialsItemHistories =
          MaterialsItemHistoriesFunc()
              .getMaterialsItemHistories();
      await mainLocalLog(
        'Materials Item Histories Gotten Successfully Offline',
      );
      notifyListeners();
      return materialsItemHistories;
    }
  }

  Future<List<MaterialsItemHistory>>
  getMaterialsItemHistoriesOffline() async {
    materialsItemHistories =
        MaterialsItemHistoriesFunc()
            .getMaterialsItemHistories();
    await mainLocalLog(
      'Materials Item Histories Gotten Successfully Offline',
    );
    notifyListeners();
    return materialsItemHistories;
  }

  Future<int> createMaterialsItemHistory(
    MaterialsItemHistory materialsItemHistory,
  ) async {
    if (ItemsAuthAction().trackItemHistoryAction(
      context: null,
    )) {
      materialsItemHistory.uuid = uuidGen();
      materialsItemHistory.createdAt ??= DateTime.now();
      materialsItemHistory.staffId = currentUser().userId;
      materialsItemHistory.staffName = currentUser().name;
      materialsItemHistory.departmentName ??=
          returnDepartmentProvider()
              .currentDepartment()
              ?.name;
      materialsItemHistory.departmentUuid ??=
          returnDepartmentProvider()
              .currentDepartment()
              ?.uuid;
      try {
        await MaterialsItemHistoriesFunc()
            .createMaterialsItemHistories(
              materialsItemHistory,
            );
        await CreatedMaterialsItemHistoriesFunc()
            .createMaterialsItemHistory(
              CreatedMaterialsItemHistory(
                createdMaterialsItemHistory:
                    materialsItemHistory,
              ),
            );
        await getMaterialsItemHistoriesOffline();
        syncData();
        return 1;
      } catch (e) {
        await mainLocalLog(
          'Offline Creating Failed: ${e.toString()}',
        );
        return 0;
      }
    } else {
      return 0;
    }
  }

  Future<void> materialsItemHistoriesSync() async {
    try {
      bool isOnline =
          await ConnectivityProvider().isOnline();
      if (CreatedMaterialsItemHistoriesFunc()
              .getCreatedMaterialsItemHistoriess()
              .isNotEmpty &&
          isOnline) {
        final tempMaterialsItemHistories =
            CreatedMaterialsItemHistoriesFunc()
                .getCreatedMaterialsItemHistoriess()
                .toList();
        var newMaterialsItemHistories =
            tempMaterialsItemHistories.map((itemHistory) {
              itemHistory
                  .createdMaterialsItemHistory
                  .createdAt = itemHistory
                      .createdMaterialsItemHistory
                      .createdAt!;
              return itemHistory;
            });
        final payload =
            newMaterialsItemHistories
                .map(
                  (p) =>
                      p.createdMaterialsItemHistory
                          .toJson(),
                )
                .toList();

        // Insert all at once
        final data =
            await client
                .from(tableName)
                .insert(payload)
                .select();

        await mainLocalLog(
          '${data.length} Materials Item Histories added successfully ✅',
        );
        await CreatedMaterialsItemHistoriesFunc()
            .clearMaterialsItemHistory();
        await mainLocalLog(
          'Unsynced Materials Item Histories Cleared',
        );
        await mainLocalLog(
          'Mounted, refreshing Materials Item Histories ✅',
        );
        await getMaterialsItemHistories();
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Materials Item Histories insert failed ❌: $e',
      );
    }
  }

  // List<MaterialsItemHistory> testMaterialsItemHistories = [
  //   MaterialsItemHistory(
  //     newValue: '45000',
  //     oldValue: '50000',
  //     title: 'Item Quantity Updated',
  //     uuid: uuidGen(),
  //     shopId: 12,
  //     createdAt: DateTime.now(),
  //     itemName: 'A new Item is Created',
  //     staffName: 'Alex Onyeka',
  //   ),
  // ];
}

import 'package:flutter/widgets.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/local_database/item_history/item_histories_func.dart';
import 'package:stockall/local_database/item_history/unsync_funcs/created_item_histories_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/providers/error_log_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ItemHistoryProvider with ChangeNotifier {
  final SupabaseClient client = Supabase.instance.client;
  final String tableName = 'item_history';
  static final ItemHistoryProvider _instance =
      ItemHistoryProvider._internal();
  factory ItemHistoryProvider() => _instance;
  ItemHistoryProvider._internal();

  List<ItemHistory> itemHistories = [];

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

  List<ItemHistory> departmentItemHistories() {
    if (returnShopProvider()
            .userShop()
            ?.manageDepartments ==
        true) {
      if (!authorization(
        authorized: Authorizations().viewAllDepartments,
      )) {
        return itemHistories.where((cat) {
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
          return itemHistories;
        } else {
          return itemHistories.where((cat) {
            return cat.departmentUuid ==
                returnDepartmentProvider()
                    .currentDepartment()
                    ?.uuid;
            // }
          }).toList();
        }
      }
    } else {
      return itemHistories;
    }
  }

  List<ItemHistory> returnItemHistories() {
    departmentItemHistories().sort(
      (a, b) => b.createdAt!.compareTo(a.createdAt!),
    );
    if (dateSet == null &&
        rangeEndDate == null &&
        rangeStartDate == null) {
      departmentItemHistories().sort(
        (a, b) => b.createdAt!.compareTo(a.createdAt!),
      );
      return departmentItemHistories();
    } else if (dateSet != null) {
      return departmentItemHistories()
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
      return departmentItemHistories()
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

  Future<List<ItemHistory>> getItemHistories() async {
    // bool isOnline = await ConnectivityProvider().isOnline();
    // var shopId = returnShopProvider().userShop()!.shopId!;
    // if (isOnline && ItemHistoriesFunc().isSynced()) {
    //   try {
    //     var res = await client
    //         .from(tableName)
    //         .select()
    //         .eq('shop_id', shopId)
    //         .order('created_at', ascending: false);
    //     if (res.isEmpty) {
    //       await mainLocalLog('No Item Histories Returned');
    //       itemHistories.clear();
    //       ItemHistoriesFunc().clearItemHistories();
    //       notifyListeners();
    //       return [];
    //     }
    //     itemHistories =
    //         res
    //             .map((m) => ItemHistory.fromJson(m))
    //             .toList();
    //     await ItemHistoriesFunc().insertAllItemHistories(
    //       itemHistories,
    //     );
    //     await mainLocalLog(
    //       '✅✅ Item Histories Gotten Successfully Online',
    //     );
    //     notifyListeners();

    //     return itemHistories;
    //   } catch (e) {
    //     await mainLocalLog(
    //       '❌❌ Item Histories Getting Online Failed: ${e.toString()}',
    //     );
    //     return [];
    //   }
    // } else {
    //   itemHistories =
    //       ItemHistoriesFunc().getItemHistories();
    //   await mainLocalLog('Item Histories Gotten Successfully Offline');
    //   notifyListeners();
    //   return itemHistories;
    // }
    return [];
  }

  Future<List<ItemHistory>>
  getItemHistoriesOffline() async {
    itemHistories = ItemHistoriesFunc().getItemHistories();
    await mainLocalLog(
      'Item Histories Gotten Successfully Offline',
    );
    notifyListeners();
    return itemHistories;
  }

  Future<int> createItemHistory(
    ItemHistory itemHistory,
  ) async {
    // if (ItemsAuthAction().trackItemHistoryAction(
    //   context: null,
    // )) {
    //   itemHistory.uuid = uuidGen();
    //   itemHistory.createdAt ??= DateTime.now();
    //   itemHistory.staffId = currentUser().userId;
    //   itemHistory.staffName = currentUser().name;
    //   itemHistory.departmentName =
    //       returnDepartmentProvider()
    //           .currentDepartment()
    //           ?.name;
    //   itemHistory.departmentUuid =
    //       returnDepartmentProvider()
    //           .currentDepartment()
    //           ?.uuid;
    //   try {
    //     await ItemHistoriesFunc().createItemHistories(
    //       itemHistory,
    //     );
    //     await CreatedItemHistoriesFunc().createItemHistory(
    //       CreatedItemHistory(itemHistory: itemHistory),
    //     );
    //     await getItemHistoriesOffline();
    //     syncData();
    //     return 1;
    //   } catch (e) {
    //     await mainLocalLog('Offline Creating Failed: ${e.toString()}');
    //     return 0;
    //   }
    // } else {
    //   return 0;
    // }
    return 1;
  }

  Future<void> itemHistoriesSync() async {
    try {
      bool isOnline =
          await ConnectivityProvider().isOnline();
      if (CreatedItemHistoriesFunc()
              .getCreatedItemHistoriess()
              .isNotEmpty &&
          isOnline) {
        final tempItemHistories =
            CreatedItemHistoriesFunc()
                .getCreatedItemHistoriess()
                .toList();
        var newItemHistories = tempItemHistories.map((
          itemHistory,
        ) {
          itemHistory.itemHistory.createdAt =
              itemHistory.itemHistory.createdAt!;
          return itemHistory;
        });
        final payload =
            newItemHistories
                .map((p) => p.itemHistory.toJson())
                .toList();

        // Insert all at once
        final data =
            await client
                .from(tableName)
                .insert(payload)
                .select();

        await mainLocalLog(
          '${data.length} Item Histories added successfully ✅',
        );
        await CreatedItemHistoriesFunc().clearItemHistory();
        await mainLocalLog(
          'Unsynced Item Histories Cleared',
        );
        await mainLocalLog(
          'Mounted, refreshing Item Histories ✅',
        );
        await getItemHistories();
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Item Histories insert failed ❌: $e',
      );
      await createErrorLog(
        error: 'Batch Item Histories insert failed ❌: $e',
      );
    }
  }

  List<ItemHistory> testItemHistories = [
    ItemHistory(
      newValue: '45000',
      oldValue: '50000',
      title: 'Item Quantity Updated',
      uuid: uuidGen(),
      shopId: 12,
      createdAt: DateTime.now(),
      itemName: 'A new Item is Created',
      staffName: 'Alex Onyeka',
    ),
  ];
}

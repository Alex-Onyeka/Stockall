import 'package:flutter/widgets.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history_event_class.dart';
import 'package:stockall/classes/temp_storage_item_history/unsynced/created_storage_item_history.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/local_database/storage_item_history/storage_item_histories_func.dart';
import 'package:stockall/local_database/storage_item_history/unsync_funcs/created_item_histories_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageItemHistoryProvider with ChangeNotifier {
  final SupabaseClient client = Supabase.instance.client;
  final String tableName = 'storage_item_history';
  static final StorageItemHistoryProvider _instance =
      StorageItemHistoryProvider._internal();
  factory StorageItemHistoryProvider() => _instance;
  StorageItemHistoryProvider._internal();

  List<StorageItemHistory> storageItemHistories = [];

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

  List<StorageItemHistory>
  departmentStorageItemHistories() {
    if (returnShopProvider()
            .userShop()
            ?.manageDepartments ==
        true) {
      if (!authorization(
        authorized: Authorizations().viewAllDepartments,
      )) {
        return storageItemHistories.where((cat) {
          return cat.storageDepartmentUuid ==
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
          return storageItemHistories;
        } else {
          return storageItemHistories.where((cat) {
            return cat.storageDepartmentUuid ==
                returnDepartmentProvider()
                    .currentDepartment()
                    ?.uuid;
            // }
          }).toList();
        }
      }
    } else {
      return storageItemHistories;
    }
  }

  List<StorageItemHistory> returnItemHistories() {
    departmentStorageItemHistories().sort(
      (a, b) => b.createdAt!.compareTo(a.createdAt!),
    );
    if (dateSet == null &&
        rangeEndDate == null &&
        rangeStartDate == null) {
      departmentStorageItemHistories().sort(
        (a, b) => b.createdAt!.compareTo(a.createdAt!),
      );
      return departmentStorageItemHistories();
    } else {
      return departmentStorageItemHistories()
          .where(
            (itemHistory) => isDateTimeInBusinessWindow(
              dateTime: itemHistory.createdAt,
              dateSet: dateSet,
              rangeStartDate: rangeStartDate,
              rangeEndDate: rangeEndDate,
            ),
          )
          .toList();
    }
  }

  Future<List<StorageItemHistory>>
  getItemHistories() async {
    await getItemHistoriesOffline();
    bool isOnline = await ConnectivityProvider().isOnline();
    var shop = returnShopProvider().userShop()!;
    var shopId = shop.shopId!;
    if (isOnline &&
        StorageItemHistoriesFunc().isSynced() &&
        ItemsAuthAction().trackItemHistoryAction(
          context: null,
        ) &&
        authorization(
          authorized: Authorizations().viewItemsHistory,
        )) {
      try {
        var res = await client
            .from(tableName)
            .select()
            .eq('shop_id', shopId)
            .order('created_at', ascending: false);
        if (res.isEmpty) {
          await mainLocalLog(
            'No Storage Item Histories Returned',
          );
          storageItemHistories.clear();
          StorageItemHistoriesFunc()
              .clearStorageItemHistories();
          notifyListeners();
          return [];
        }
        storageItemHistories =
            res
                .map((m) => StorageItemHistory.fromJson(m))
                .toList();
        await StorageItemHistoriesFunc()
            .insertAllStorageItemHistories(
              storageItemHistories,
            );
        await mainLocalLog(
          '✅✅ Storage Item Histories Gotten Successfully Online',
        );
        notifyListeners();

        return storageItemHistories;
      } catch (e) {
        await mainLocalLog(
          '❌❌ Storage Item Histories Getting Online Failed: ${e.toString()}',
        );
        return [];
      }
    } else {
      storageItemHistories =
          StorageItemHistoriesFunc()
              .getStorageItemHistories();
      await mainLocalLog(
        'Storage Item Histories Gotten Successfully Offline',
      );
      notifyListeners();
      return storageItemHistories;
    }
  }

  Future<List<StorageItemHistory>>
  getItemHistoriesOffline() async {
    storageItemHistories =
        StorageItemHistoriesFunc()
            .getStorageItemHistories();
    await mainLocalLog(
      'Storage Item Histories Gotten Successfully Offline',
    );
    notifyListeners();
    return storageItemHistories;
  }

  Future<int> createStorageItemHistory(
    StorageItemHistory itemHistory,
  ) async {
    if (ItemsAuthAction().trackItemHistoryAction(
      context: null,
    )) {
      itemHistory.uuid = uuidGen();
      itemHistory.createdAt ??= DateTime.now();
      itemHistory.storageStaffId = currentUser().userId;
      itemHistory.storageStaffName = currentUser().name;
      itemHistory.destination ??=
          StorageItemHistoryEventClass.unKnownDestination;
      itemHistory.source ??=
          StorageItemHistoryEventClass.unKnownSource;
      itemHistory.destination ??=
          StorageItemHistoryEventClass.unKnownDestination;
      itemHistory.source ??=
          StorageItemHistoryEventClass.unKnownSource;
      itemHistory.storageDepartmentName ??=
          returnDepartmentProvider()
              .currentDepartment()
              ?.name;
      itemHistory.storageDepartmentUuid ??=
          returnDepartmentProvider()
              .currentDepartment()
              ?.uuid;
      try {
        await StorageItemHistoriesFunc()
            .createStorageItemHistories(itemHistory);
        await CreatedStorageItemHistoriesFunc()
            .createStorageItemHistory(
              CreatedStorageItemHistory(
                storageItemHistory: itemHistory,
              ),
            );
        await getItemHistoriesOffline();
        // syncData();
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

  Future<void> storageItemHistoriesSync() async {
    try {
      bool isOnline =
          await ConnectivityProvider().isOnline();
      if (CreatedStorageItemHistoriesFunc()
              .getCreatedStorageItemHistoriess()
              .isNotEmpty &&
          isOnline) {
        final tempItemHistories =
            CreatedStorageItemHistoriesFunc()
                .getCreatedStorageItemHistoriess()
                .toList();
        var newItemHistories = tempItemHistories.map((
          itemHistory,
        ) {
          itemHistory.storageItemHistory.createdAt =
              itemHistory.storageItemHistory.createdAt!;
          return itemHistory;
        });
        final payload =
            newItemHistories
                .map((p) => p.storageItemHistory.toJson())
                .toList();

        // Insert all at once
        final data =
            await client
                .from(tableName)
                .insert(payload)
                .select();

        await mainLocalLog(
          '${data.length} Storage Item Histories added successfully ✅',
        );
        await CreatedStorageItemHistoriesFunc()
            .clearStorageItemHistory();
        await mainLocalLog(
          'Unsynced Storage Item Histories Cleared',
        );
        await mainLocalLog(
          'Mounted, refreshing Storage Item Histories ✅',
        );
        await getItemHistories();
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Storage Item Histories insert failed ❌: $e',
      );
    }
  }

  // List<StorageItemHistory> testItemHistories = [
  //   StorageItemHistory(
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

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
  final Set<String> _fetchedDateKeys = {};
  int? _fetchedShopId;

  String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  bool _isRangeFetched(int shopId, DateTime start, DateTime end) {
    if (_fetchedShopId != shopId) return false;
    var cursor = DateTime(start.year, start.month, start.day);
    final last = DateTime(end.year, end.month, end.day);
    while (!cursor.isAfter(last)) {
      if (!_fetchedDateKeys.contains(_dateKey(cursor))) return false;
      cursor = cursor.add(const Duration(days: 1));
    }
    return true;
  }

  void _markRangeFetched(int shopId, DateTime start, DateTime end) {
    if (_fetchedShopId != shopId) {
      _fetchedDateKeys.clear();
      _fetchedShopId = shopId;
    }
    var cursor = DateTime(start.year, start.month, start.day);
    final last = DateTime(end.year, end.month, end.day);
    while (!cursor.isAfter(last)) {
      _fetchedDateKeys.add(_dateKey(cursor));
      cursor = cursor.add(const Duration(days: 1));
    }
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
      getItemHistories(startDate: date, endDate: date);
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
    getItemHistories(
      startDate: rangeStart,
      endDate: endOfrange,
    );
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
  getItemHistories({
    DateTime? startDate,
    DateTime? endDate,
    bool fetchAll = false,
    bool forceRefresh = false,
  }) async {
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
      final effectiveStart =
          startDate ??
          dateSet ??
          rangeStartDate ??
          resolveBusinessDate(DateTime.now());
      final effectiveEnd =
          endDate ??
          (dateSet ?? rangeEndDate ?? effectiveStart);

      if (!fetchAll &&
          !forceRefresh &&
          _isRangeFetched(
            shopId,
            effectiveStart,
            effectiveEnd,
          )) {
        return storageItemHistories;
      }

      final windowStart = fourAm(effectiveStart);
      final windowEnd = fourAmNextDay(effectiveEnd);

      try {
        var query = client
            .from(tableName)
            .select()
            .eq('shop_id', shopId);
        if (!fetchAll) {
          query = query
              .gte(
                'created_at',
                windowStart.toUtc().toIso8601String(),
              )
              .lt(
                'created_at',
                windowEnd.toUtc().toIso8601String(),
              );
        }
        var res = await query.order(
          'created_at',
          ascending: false,
        );
        final fetched =
            res
                .map((m) => StorageItemHistory.fromJson(m))
                .toList();
        if (fetchAll) {
          if (fetched.isEmpty) {
            await mainLocalLog(
              'No Storage Item Histories Returned',
            );
            storageItemHistories.clear();
            StorageItemHistoriesFunc()
                .clearStorageItemHistories();
            notifyListeners();
            return [];
          }
          storageItemHistories = fetched;
        } else {
          final fetchedUuids =
              fetched.map((e) => e.uuid).toSet();
          final outsideWindow =
              storageItemHistories.where((rec) {
                if (fetchedUuids.contains(rec.uuid)) {
                  return false;
                }
                final created = rec.createdAt;
                if (created == null) return true;
                final inWindow =
                    !created.isBefore(windowStart) &&
                    created.isBefore(windowEnd);
                return !inWindow;
              }).toList();
          storageItemHistories = [
              ...fetched,
              ...outsideWindow,
            ]
            ..sort(
              (a, b) => (b.createdAt ?? DateTime(1970))
                  .compareTo(a.createdAt ?? DateTime(1970)),
            );
          _markRangeFetched(
            shopId,
            effectiveStart,
            effectiveEnd,
          );
        }
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
    itemHistory.uuid = uuidGen();
    itemHistory.createdAt ??= DateTime.now();
    itemHistory.storageStaffId = currentUser().userId;
    itemHistory.storageStaffName = currentUser().name;
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
        final data = await client
            .from(tableName)
            .insert(payload)
            .select('uuid');

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

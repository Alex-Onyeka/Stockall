import 'package:flutter/widgets.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/classes/temp_item_history/item_history_event_class.dart';
import 'package:stockall/classes/temp_item_history/unsynced/created_item_history.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/local_database/item_history/item_histories_func.dart';
import 'package:stockall/local_database/item_history/unsync_funcs/created_item_histories_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
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
    itemHistories.sort(
      (a, b) => b.createdAt!.compareTo(a.createdAt!),
    );
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
    if (dateSet == null &&
        rangeEndDate == null &&
        rangeStartDate == null) {
      departmentItemHistories().sort(
        (a, b) => b.createdAt!.compareTo(a.createdAt!),
      );
      return departmentItemHistories();
    } else {
      return departmentItemHistories()
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

  Future<List<ItemHistory>> getItemHistories({String? productUuid}) async {
    await getItemHistoriesOffline();
    bool isOnline = await ConnectivityProvider().isOnline();
    var shop = returnShopProvider().userShop()!;
    var shopId = shop.shopId!;
    if (isOnline &&
        ItemsAuthAction().trackItemHistoryAction(
          context: null,
        ) &&
        authorization(
          authorized: Authorizations().viewItemsHistory,
        )) {
      try {
        var query = client
            .from(tableName)
            .select()
            .eq('shop_id', shopId);
        if (productUuid != null && productUuid.isNotEmpty) {
          query = query.eq('item_uuid', productUuid);
        }
        var res = await query.order('created_at', ascending: false);
        if (res.isEmpty) {
          await mainLocalLog('No Item Histories Returned');
          if (productUuid == null) {
            itemHistories.clear();
            ItemHistoriesFunc().clearItemHistories();
          }
          notifyListeners();
          return [];
        }
        final fetched =
            res
                .map((m) => ItemHistory.fromJson(m))
                .toList();
        await ItemHistoriesFunc().insertAllItemHistories(
          fetched,
        );
        itemHistories = ItemHistoriesFunc().getItemHistories();
        await mainLocalLog(
          '✅✅ Item Histories Gotten Successfully Online',
        );
        notifyListeners();

        return itemHistories;
      } catch (e) {
        await mainLocalLog(
          '❌❌ Item Histories Getting Online Failed: ${e.toString()}',
        );
        return [];
      }
    } else {
      itemHistories =
          ItemHistoriesFunc().getItemHistories();
      await mainLocalLog(
        'Item Histories Gotten Successfully Offline',
      );
      notifyListeners();
      return itemHistories;
    }
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
    itemHistory.uuid = uuidGen();
    itemHistory.createdAt ??= DateTime.now();
    itemHistory.staffId = currentUser().userId;
    itemHistory.staffName = currentUser().name;
    itemHistory.destination ??=
        ItemHistoryEventClass.unKnownDestination;
    itemHistory.source ??=
        ItemHistoryEventClass.unKnownSource;
    itemHistory.departmentName ??=
        returnDepartmentProvider()
            .currentDepartment()
            ?.name;
    itemHistory.departmentUuid ??=
        returnDepartmentProvider()
            .currentDepartment()
            ?.uuid;
    try {
      await ItemHistoriesFunc().createItemHistories(
        itemHistory,
      );
      await CreatedItemHistoriesFunc().createItemHistory(
        CreatedItemHistory(itemHistory: itemHistory),
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

  Future<void> itemHistoriesSync() async {
    try {
      bool isOnline = await ConnectivityProvider().isOnline();
      if (CreatedItemHistoriesFunc()
              .getCreatedItemHistoriess()
              .isNotEmpty &&
          isOnline) {
        final tempItemHistories =
            CreatedItemHistoriesFunc()
                .getCreatedItemHistoriess()
                .toList();
        var newItemHistories = tempItemHistories.map((itemHistory) {
          itemHistory.itemHistory.createdAt =
              itemHistory.itemHistory.createdAt!;
          return itemHistory;
        }).toList();
        final payload =
            newItemHistories.map((p) => p.itemHistory.toJson()).toList();

        try {
          // Attempt batch insert first
          final data = await client.from(tableName).insert(payload).select();
          await mainLocalLog(
            '${data.length} Item Histories added successfully ✅',
          );
          await CreatedItemHistoriesFunc().clearItemHistory();
        } catch (batchErr) {
          await mainLocalLog(
            'Batch Item Histories insert failed, falling back to item-by-item: $batchErr',
          );
          // Fall back to item-by-item insert so valid items sync and problematic ones don't poison queue
          for (var item in tempItemHistories) {
            final uuid = item.itemHistory.uuid;
            if (uuid == null || uuid.isEmpty) continue;
            try {
              await client
                  .from(tableName)
                  .insert(item.itemHistory.toJson())
                  .select();
              await CreatedItemHistoriesFunc().deleteItemHistory(uuid);
            } on PostgrestException catch (pe) {
              // 23505 = duplicate, 23503 = foreign key violation, 23502 = not null violation
              if (pe.code == '23505' || pe.code == '23503' || pe.code == '23502') {
                await CreatedItemHistoriesFunc().deleteItemHistory(uuid);
              }
              await mainLocalLog('Error syncing single item history $uuid: $pe');
            } catch (err) {
              // Network or connection error: stop to retry later
              await mainLocalLog('Single item history network error: $err');
              break;
            }
          }
        }

        await getItemHistories();
      }
    } catch (e) {
      await mainLocalLog(
        'Item Histories sync error ❌: $e',
      );
    }
  }

  // List<ItemHistory> testItemHistories = [
  //   ItemHistory(
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

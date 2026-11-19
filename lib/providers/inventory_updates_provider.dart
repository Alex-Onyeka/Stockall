import 'package:flutter/widgets.dart';
import 'package:stockall/classes/temp_inventory_updates/temp_inventory_update_class.dart';
import 'package:stockall/classes/temp_inventory_updates/unsynced/created_inventory_updates_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/local_database/inventory_updates/inventory_updates_func.dart';
import 'package:stockall/local_database/inventory_updates/unsync_funcs/created_inventory_updates_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InventoryUpdatesProvider with ChangeNotifier {
  final SupabaseClient client = Supabase.instance.client;
  final String tableName = 'inventory_updates';
  static final InventoryUpdatesProvider _instance =
      InventoryUpdatesProvider._internal();
  factory InventoryUpdatesProvider() => _instance;
  InventoryUpdatesProvider._internal();

  List<TempInventoryUpdateClass> inventoryUpdates = [];
  final Set<String> _fetchedDateKeys = {};
  int? _fetchedShopId;

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month}-${d.day}';

  bool _isRangeFetched(
    int shopId,
    DateTime start,
    DateTime end,
  ) {
    if (_fetchedShopId != shopId) return false;
    var cursor = DateTime(
      start.year,
      start.month,
      start.day,
    );
    final last = DateTime(end.year, end.month, end.day);
    while (!cursor.isAfter(last)) {
      if (!_fetchedDateKeys.contains(_dateKey(cursor)))
        return false;
      cursor = cursor.add(const Duration(days: 1));
    }
    return true;
  }

  void _markRangeFetched(
    int shopId,
    DateTime start,
    DateTime end,
  ) {
    if (_fetchedShopId != shopId) {
      _fetchedDateKeys.clear();
      _fetchedShopId = shopId;
    }
    var cursor = DateTime(
      start.year,
      start.month,
      start.day,
    );
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
      getInventoryUpdates(startDate: date, endDate: date);
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
    getInventoryUpdates(
      startDate: rangeStart,
      endDate: endOfrange,
    );
    notifyListeners();
  }

  List<TempInventoryUpdateClass>
  departmentInventoryUpdates() {
    return inventoryUpdates.where((cat) {
      return returnDepartmentProvider()
          .matchesCurrentDepartment(
            departmentUuid: cat.departmentUuid,
          );
    }).toList();
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
  getInventoryUpdates({
    DateTime? startDate,
    DateTime? endDate,
    bool fetchAll = false,
    bool forceRefresh = false,
  }) async {
    await getInventoryUpdatesOffline();
    bool isOnline = await ConnectivityProvider().isOnline();
    var shopId = returnShopProvider().userShop()!.shopId!;
    if (isOnline && InventoryUpdatesFunc().isSynced()) {
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
        return inventoryUpdates;
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
                .map(
                  (m) =>
                      TempInventoryUpdateClass.fromJson(m),
                )
                .toList();
        if (fetchAll) {
          if (fetched.isEmpty) {
            await mainLocalLog(
              'No Inventory Updates Returned',
            );
            inventoryUpdates.clear();
            InventoryUpdatesFunc().clearInventoryUpdates();
            notifyListeners();
            return [];
          }
          inventoryUpdates = fetched;
        } else {
          final fetchedUuids =
              fetched.map((e) => e.uuid).toSet();
          final outsideWindow =
              inventoryUpdates.where((rec) {
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
          inventoryUpdates = [...fetched, ...outsideWindow]
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
        await InventoryUpdatesFunc()
            .insertAllInventoryUpdates(inventoryUpdates);
        await mainLocalLog(
          '✅✅ Inventory Updates Gotten Successfully Online',
        );
        notifyListeners();

        return inventoryUpdates;
      } catch (e) {
        await mainLocalLog(
          '❌❌ Inventory Updates Getting Online Failed: ${e.toString()}',
        );
        return [];
      }
    } else {
      inventoryUpdates =
          InventoryUpdatesFunc().getInventoryUpdatess();
      await mainLocalLog(
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
    await mainLocalLog(
      'Inventory Updates Gotten Successfully Offline',
    );
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
      inventoryUpdate.uuid = uuidGen();
      inventoryUpdate.createdAt ??= DateTime.now();
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
        await getInventoryUpdatesOffline();
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
        final data = await client
            .from(tableName)
            .insert(payload)
            .select('uuid');

        await mainLocalLog(
          '${data.length} Inventory Update items added successfully ✅',
        );
        await CreatedInventoryUpdatesFunc()
            .clearInventoryUpdate();
        await mainLocalLog(
          'Unsynced Inventory Updates Cleared',
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Inventory Updates insert failed ❌: $e',
      );
    }
  }

  // List<TempInventoryUpdateClass> testInventoryUpdates = [
  //   TempInventoryUpdateClass(
  //     newValue: '45000',
  //     oldValue: '50000',
  //     title: 'Item Quantity Updated',
  //     uuid: uuidGen(),
  //     shopId: 12,
  //     createdAt: DateTime.now(),
  //     itemName: 'A new Item is Created',
  //     staffName: 'Alex Onyeka',
  //     itemTwoUuid: '',
  //   ),
  // ];
}

import 'package:flutter/widgets.dart';
import 'package:stockall/classes/temp_error_log/temp_error_log_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/local_database/error_log/error_log_func.dart';
import 'package:stockall/local_database/error_log/unsync_funcs/created_events_log_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorLogProvider with ChangeNotifier {
  final SupabaseClient client = Supabase.instance.client;
  final String tableName = 'error_logs';
  static final ErrorLogProvider _instance =
      ErrorLogProvider._internal();
  factory ErrorLogProvider() => _instance;
  ErrorLogProvider._internal();

  List<TempErrorLogClass> logs = [];
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
      getErrorLogs(startDate: date, endDate: date);
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
    getErrorLogs(
      startDate: rangeStart,
      endDate: endOfrange,
    );
    notifyListeners();
  }

  List<TempErrorLogClass> departmentError() {
    if (returnShopProvider()
            .userShop()
            ?.manageDepartments ==
        true) {
      if (!authorization(
        authorized: Authorizations().viewAllDepartments,
      )) {
        return logs.where((cat) {
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
          return logs;
        } else {
          return logs.where((cat) {
            return cat.departmentUuid ==
                returnDepartmentProvider()
                    .currentDepartment()
                    ?.uuid;
          }).toList();
        }
      }
    } else {
      return logs;
    }
  }

  List<TempErrorLogClass> returnLogs() {
    departmentError().sort(
      (a, b) => b.createdAt!.compareTo(a.createdAt!),
    );
    if (dateSet == null &&
        rangeEndDate == null &&
        rangeStartDate == null) {
      departmentError().sort(
        (a, b) => b.createdAt!.compareTo(a.createdAt!),
      );
      return departmentError();
    } else if (dateSet != null) {
      return departmentError()
          .where(
            (log) =>
                !log.createdAt!.isBefore(
                  fourAm(dateSet!),
                ) &&
                log.createdAt!.isBefore(
                  fourAmNextDay(dateSet!),
                ),
          )
          .toList();
    } else {
      return departmentError()
          .where(
            (log) =>
                !log.createdAt!.isBefore(
                  fourAm(rangeStartDate!),
                ) &&
                log.createdAt!.isBefore(
                  fourAmNextDay(
                    rangeEndDate ??
                        resolveBusinessDate(DateTime.now()),
                  ),
                ),
          )
          .toList();
    }
  }

  Future<List<TempErrorLogClass>> getErrorLogs({
    DateTime? startDate,
    DateTime? endDate,
    bool fetchAll = false,
    bool forceRefresh = false,
  }) async {
    bool isOnline = await ConnectivityProvider().isOnline();
    var shopId = returnShopProvider().userShop()!.shopId!;
    if (isOnline && returnData().isSynced() == 1) {
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
        return logs;
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
                .map((m) => TempErrorLogClass.fromJson(m))
                .toList();
        if (fetchAll) {
          if (fetched.isEmpty) {
            await mainLocalLog('No Error Logs Returned');
            logs.clear();
            ErrorLogFunc().clearErrorLog();
            notifyListeners();
            return [];
          }
          logs = fetched;
        } else {
          final fetchedUuids =
              fetched.map((e) => e.uuid).toSet();
          final outsideWindow =
              logs.where((rec) {
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
          logs = [...fetched, ...outsideWindow]
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

        await ErrorLogFunc().insertAllErrorLog(logs);
        await mainLocalLog(
          '✅✅ Error Gotten Successfully Online',
        );
        notifyListeners();

        return logs;
      } catch (e) {
        await mainLocalLog(
          '❌❌ Error Getting Online Failed: ${e.toString()}',
        );
        return [];
      }
    } else {
      logs = ErrorLogFunc().getErrorLogs();

      await mainLocalLog(
        'Error Gotten Successfully Offline',
      );
      notifyListeners();
      return logs;
    }
  }

  Future<List<TempErrorLogClass>>
  getErrorLogsOffline() async {
    logs = ErrorLogFunc().getErrorLogs();

    await mainLocalLog('Error Gotten Successfully Offline');
    notifyListeners();
    return logs;
  }

  TempErrorLogClass createLogAdapter({
    required String error,
  }) {
    return TempErrorLogClass(
      shopId: shopId(),
      tableName: tableName,
      createdAt: DateTime.now(),
      uuid: uuidGen(),
      title: 'Error Occoured',
      error: error,
      staffName:
          returnUserProviderSingle().currentUserMain?.name,
      staffId:
          returnUserProviderSingle()
              .currentUserMain
              ?.userId,
      departmentName:
          returnDepartmentProvider()
              .currentDepartment()
              ?.name,
      departmentUuid:
          returnDepartmentProvider()
              .currentDepartment()
              ?.uuid,
    );
  }

  Future<int> createLog({required String error}) async {
    // if (ReportAuthAction().viewErrorLogAction()) {
    // bool isOnline =
    //     await ConnectivityProvider().isOnline();
    // log.uuid = uuidGen();
    // log.createdAt ??= DateTime.now();
    // if (isOnline) {
    //   try {
    //     Map<String, dynamic>? res =
    //         await client
    //             .from(tableName)
    //             .insert(log.toJson())
    //             .select()
    //             .maybeSingle();
    //     if (res == null) {
    //       await mainLocalLog('Error Logging Failed');
    //       return 0;
    //     }
    //     logs.add(TempErrorLogClass.fromJson(res));
    //     await ErrorLogFunc().createErrorLog(
    //       TempErrorLogClass.fromJson(res),
    //     );
    //     notifyListeners();
    //     await getErrorLogs();
    //     await mainLocalLog('✅✅ Error Logged Successfully Online');
    //     return 1;
    //   } catch (e) {
    //     await mainLocalLog(
    //       'Error Creating Online Failed: ${e.toString()}',
    //     );
    //     return 0;
    //   }
    // } else {
    // try {
    //   var log = createLogAdapter(error: error);
    //   await ErrorLogFunc().createErrorLog(log);
    //   await CreatedErrorLogFunc().createErrorLog(
    //     CreatedErrorLogClass(errorLog: log),
    //   );
    //   await getErrorLogsOffline();
    //   syncData();
    //   return 1;
    // } catch (e) {
    //   await mainLocalLog(
    //     'Offline Error Creating Failed: ${e.toString()}',
    //   );
    //   return 0;
    // }
    // }
    // } else {
    //   return 0;
    // }
    return 1;
  }

  Future<void> errorsLogSync() async {
    try {
      bool isOnline =
          await ConnectivityProvider().isOnline();
      // Prepare batch payload
      if (CreatedErrorLogFunc()
              .getCreatedErrorLogs()
              .isNotEmpty &&
          isOnline) {
        final tempErrorLogs =
            CreatedErrorLogFunc()
                .getCreatedErrorLogs()
                .toList();
        // var newError = tempErrorLogs.map((log) {
        //   log.errorLog.createdAt = log.errorLog.createdAt!;
        //   return log;
        // });
        // final payload =
        //     newError
        //         .map((p) => p.errorLog.toJson())
        //         .toList();

        // Insert all at once
        int count = 0;
        for (var item in tempErrorLogs) {
          try {
            // Insert all at once
            await client
                .from(tableName)
                .insert(item.errorLog.toJson());
            count++;
            await CreatedErrorLogFunc().deleteErrorLog(
              item.errorLog.uuid!,
            );
          } on PostgrestException catch (e) {
            // if (e.code == '23505') {
            await CreatedErrorLogFunc().deleteErrorLog(
              item.errorLog.uuid!,
            );
            await mainLocalLog(
              'Error Occoured While Creating Error Log: ${e.toString()}',
            );
            // }
            // await createErrorLog(
            //   error:
            //       'Error Synchronizing Error Log: ${item.errorLog.title}: $e',
            // );
          }
        }

        await mainLocalLog(
          '$count Error Log items added successfully ✅',
        );
        await CreatedErrorLogFunc().clearError();
        await mainLocalLog('Unsynced Error Logs Cleared');
        await mainLocalLog(
          'Mounted, refreshing Receipts ✅',
        );
        await getErrorLogs();
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Error Logs insert failed ❌: $e',
      );
      // await createErrorLog(
      //   error: 'Batch Error Logs insert failed ❌: $e',
      // );
    }
  }
}

// Future<void> createErrorLog({required String error}) async {
//   // await returnErrorLogProvider().createLog(error: error);
// }

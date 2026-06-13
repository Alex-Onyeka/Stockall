import 'package:flutter/widgets.dart';
import 'package:stockall/classes/temp_error_log/temp_error_log_class.dart';
import 'package:stockall/classes/temp_error_log/unsynced/created_error_log_class.dart';
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

  Future<List<TempErrorLogClass>> getErrorLogs() async {
    bool isOnline = await ConnectivityProvider().isOnline();
    var shopId = returnShopProvider().userShop()!.shopId!;
    if (isOnline && returnData().isSynced() == 1) {
      try {
        var res = await client
            .from(tableName)
            .select()
            .eq('shop_id', shopId)
            .order('created_at', ascending: false);
        if (res.isEmpty) {
          print('No Error Logs Returned');
          logs.clear();
          ErrorLogFunc().clearErrorLog();
          notifyListeners();
          return [];
        }
        logs =
            res
                .map((m) => TempErrorLogClass.fromJson(m))
                .toList();

        await ErrorLogFunc().insertAllErrorLog(logs);
        print('✅✅ Error Gotten Successfully Online');
        notifyListeners();

        return logs;
      } catch (e) {
        print(
          '❌❌ Error Getting Online Failed: ${e.toString()}',
        );
        return [];
      }
    } else {
      logs = ErrorLogFunc().getErrorLogs();

      print('Error Gotten Successfully Offline');
      notifyListeners();
      return logs;
    }
  }

  Future<List<TempErrorLogClass>>
  getErrorLogsOffline() async {
    logs = ErrorLogFunc().getErrorLogs();

    print('Error Gotten Successfully Offline');
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
          returnUserProviderSingle().currentUserMain!.name,
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
    //       print('Error Logging Failed');
    //       return 0;
    //     }
    //     logs.add(TempErrorLogClass.fromJson(res));
    //     await ErrorLogFunc().createErrorLog(
    //       TempErrorLogClass.fromJson(res),
    //     );
    //     notifyListeners();
    //     await getErrorLogs();
    //     print('✅✅ Error Logged Successfully Online');
    //     return 1;
    //   } catch (e) {
    //     print(
    //       'Error Creating Online Failed: ${e.toString()}',
    //     );
    //     return 0;
    //   }
    // } else {
    try {
      var log = createLogAdapter(error: error);
      await ErrorLogFunc().createErrorLog(log);
      await CreatedErrorLogFunc().createErrorLog(
        CreatedErrorLogClass(errorLog: log),
      );
      await getErrorLogsOffline();
      return 1;
    } catch (e) {
      print(
        'Offline Error Creating Failed: ${e.toString()}',
      );
      return 0;
    }
    // }
    // } else {
    //   return 0;
    // }
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
        var newError = tempErrorLogs.map((log) {
          log.errorLog.createdAt = log.errorLog.createdAt!;
          return log;
        });
        final payload =
            newError
                .map((p) => p.errorLog.toJson())
                .toList();

        // Insert all at once
        final data =
            await client
                .from(tableName)
                .insert(payload)
                .select();

        print(
          '${data.length} Error Log items added successfully ✅',
        );
        await CreatedErrorLogFunc().clearError();
        print('Unsynced Error Logs Cleared');
        print('Mounted, refreshing Receipts ✅');
        await getErrorLogs();
      }
    } catch (e) {
      print('Batch Error Logs insert failed ❌: $e');
      await createErrorLog(
        error: 'Batch Error Logs insert failed ❌: $e',
      );
    }
  }
}

Future<void> createErrorLog({required String error}) async {
  await returnErrorLogProvider().createLog(error: error);
}

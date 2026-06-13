import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_error_log/temp_error_log_class.dart';
import 'package:stockall/local_database/error_log/unsync_funcs/created_events_log_func.dart';

class ErrorLogFunc {
  static final ErrorLogFunc instance =
      ErrorLogFunc._internal();
  factory ErrorLogFunc() => instance;
  ErrorLogFunc._internal();
  late Box<TempErrorLogClass> errorLogBox;
  final String errorLogBoxName = 'errorLogBoxStockall';

  Future<void> init() async {
    Hive.registerAdapter(TempErrorLogClassAdapter());
    errorLogBox = await Hive.openBox(errorLogBoxName);
    await CreatedErrorLogFunc().init();
    print('Error Log Box Initialized');
  }

  List<TempErrorLogClass> getErrorLogs() {
    List<TempErrorLogClass> errorLog =
        errorLogBox.values.toList();
    errorLog.sort(
      (a, b) => a.createdAt!.compareTo(b.createdAt!),
    );
    return errorLog;
  }

  Future<int> insertAllErrorLog(
    List<TempErrorLogClass> errorLog,
  ) async {
    await clearErrorLog();
    try {
      for (var log in errorLog) {
        await errorLogBox.put(log.uuid, log);
      }
      print(
        "Offline Error Log inserted: ${errorLog.length}",
      );
      print(getErrorLogs().length);
      return 1;
    } catch (e) {
      print(
        'Offline Error Log Insertion failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> createErrorLog(
    TempErrorLogClass errorLog,
  ) async {
    try {
      await errorLogBox.put(errorLog.uuid, errorLog);
      print('Offline Error Log inserted Successfully');

      return 1;
    } catch (e) {
      print(
        'Offline Error Log Insertion Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearErrorLog() async {
    try {
      if (errorLogBox.values.isNotEmpty) {
        await errorLogBox.clear();
        print('Offline Error Log Cleared');
      }
      return 1;
    } catch (e) {
      print(
        '❌❌ Offline Error Log Clear Error: ${e.toString()}',
      );
      return 0;
    }
  }
}

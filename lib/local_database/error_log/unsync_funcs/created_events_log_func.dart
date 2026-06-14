import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_error_log/unsynced/created_error_log_class.dart';

class CreatedErrorLogFunc {
  static final CreatedErrorLogFunc instance =
      CreatedErrorLogFunc._internal();
  factory CreatedErrorLogFunc() => instance;
  CreatedErrorLogFunc._internal();

  Box<CreatedErrorLogClass>? _createdErrorLogBox;
  final String createdErrorLogBoxName =
      'createdErrorLogBoxStockall';

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(
      CreatedErrorLogClassAdapter().typeId,
    )) {
      Hive.registerAdapter(CreatedErrorLogClassAdapter());
      print('CreatedErrorLogClassAdapter registered ✅');
    }

    if (!Hive.isBoxOpen(createdErrorLogBoxName)) {
      _createdErrorLogBox =
          await Hive.openBox<CreatedErrorLogClass>(
            createdErrorLogBoxName,
          );
      print('Created Error Log Box opened ✅');
    } else {
      _createdErrorLogBox = Hive.box<CreatedErrorLogClass>(
        createdErrorLogBoxName,
      );
      print('Created Error Log Box already open, reused ✅');
    }
  }

  /// Safe getter for the box
  Box<CreatedErrorLogClass> get createdErrorLogBox {
    if (_createdErrorLogBox == null) {
      throw Exception(
        "CreatedErrorLogFunc not initialized. Call await CreatedErrorLogFunc.instance.init() first.",
      );
    }
    return _createdErrorLogBox!;
  }

  List<CreatedErrorLogClass> getCreatedErrorLogs() {
    return createdErrorLogBox.values.toList();
  }

  Future<int> insertAllCreatedErrorLog(
    List<CreatedErrorLogClass> createdErrorLog,
  ) async {
    try {
      for (var log in createdErrorLog) {
        await createdErrorLogBox.put(
          log.errorLog.uuid,
          log,
        );
      }
      print("Offline Created Error Log inserted ✅");
      return 1;
    } catch (e) {
      print(
        'Offline Created Error Log insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createErrorLog(
    CreatedErrorLogClass createdErrorLog,
  ) async {
    try {
      await createdErrorLogBox.put(
        createdErrorLog.errorLog.uuid,
        createdErrorLog,
      );
      print(
        'Offline Created Error Log inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline Created Error Log insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteErrorLog(String uuid) async {
    try {
      print(
        createdErrorLogBox.containsKey(uuid).toString(),
      );
      await createdErrorLogBox.delete(uuid);
      print('Created Error Log Deleted');
      return 1;
    } catch (e) {
      print(
        'Created Error Log Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearError() async {
    try {
      await createdErrorLogBox.clear();
      print('All Created Error Logs cleared ✅');
      return 1;
    } catch (e) {
      print(
        'Error while clearing Created Error Logs ❌: $e',
      );
      return 0;
    }
  }
}

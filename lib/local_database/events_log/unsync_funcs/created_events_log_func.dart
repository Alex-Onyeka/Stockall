import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_event_log/unsynced/created_events_log_class.dart';

class CreatedEventsLogFunc {
  static final CreatedEventsLogFunc instance =
      CreatedEventsLogFunc._internal();
  factory CreatedEventsLogFunc() => instance;
  CreatedEventsLogFunc._internal();

  Box<CreatedEventsLogClass>? _createdEventsLogBox;
  final String createdEventsLogBoxName =
      'createdEventsLogBoxStockall';

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(
      CreatedEventsLogClassAdapter().typeId,
    )) {
      Hive.registerAdapter(CreatedEventsLogClassAdapter());
      print('CreatedEventsLogClassAdapter registered ✅');
    }

    if (!Hive.isBoxOpen(createdEventsLogBoxName)) {
      _createdEventsLogBox =
          await Hive.openBox<CreatedEventsLogClass>(
            createdEventsLogBoxName,
          );
      print('Created Events Log Box opened ✅');
    } else {
      _createdEventsLogBox =
          Hive.box<CreatedEventsLogClass>(
            createdEventsLogBoxName,
          );
      print(
        'Created Events Log Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<CreatedEventsLogClass> get createdEventsLogBox {
    if (_createdEventsLogBox == null) {
      throw Exception(
        "CreatedEventsLogFunc not initialized. Call await CreatedEventsLogFunc.instance.init() first.",
      );
    }
    return _createdEventsLogBox!;
  }

  List<CreatedEventsLogClass> getCreatedEventsLogs() {
    return createdEventsLogBox.values.toList();
  }

  Future<int> insertAllCreatedEventsLog(
    List<CreatedEventsLogClass> createdEventsLog,
  ) async {
    try {
      for (var log in createdEventsLog) {
        await createdEventsLogBox.put(
          log.eventLog.uuid,
          log,
        );
      }
      print("Offline Created Events Log inserted ✅");
      return 1;
    } catch (e) {
      print(
        'Offline Created Events Log insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createEventLog(
    CreatedEventsLogClass createdEventsLog,
  ) async {
    try {
      await createdEventsLogBox.put(
        createdEventsLog.eventLog.uuid,
        createdEventsLog,
      );
      print(
        'Offline Created Events Log inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline Created Events Log insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteEventLog(String uuid) async {
    try {
      print(
        createdEventsLogBox.containsKey(uuid).toString(),
      );
      await createdEventsLogBox.delete(uuid);
      print('Created Event Log Deleted');
      return 1;
    } catch (e) {
      print(
        'Created Event Log Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearEvents() async {
    try {
      await createdEventsLogBox.clear();
      print('All Created Events Logs cleared ✅');
      return 1;
    } catch (e) {
      print(
        'Error while clearing Created Events Logs ❌: $e',
      );
      return 0;
    }
  }
}

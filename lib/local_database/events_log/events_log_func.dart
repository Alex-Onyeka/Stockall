import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_event_log/temp_event_log_class.dart';
import 'package:stockall/local_database/events_log/unsync_funcs/created_events_log_func.dart';
import 'package:stockall/main.dart';

class EventsLogFunc {
  static final EventsLogFunc instance =
      EventsLogFunc._internal();
  factory EventsLogFunc() => instance;
  EventsLogFunc._internal();
  late Box<TempEventLogClass> eventsLogBox;
  final String eventsLogBoxName = 'eventsLogBoxStockall';

  Future<void> init() async {
    Hive.registerAdapter(TempEventLogClassAdapter());
    eventsLogBox = await Hive.openBox(eventsLogBoxName);
    await CreatedEventsLogFunc().init();
    print('Events Log Box Initialized');
  }

  List<TempEventLogClass> getEventsLogs() {
    List<TempEventLogClass> eventsLog =
        eventsLogBox.values.toList();
    eventsLog.sort(
      (a, b) => a.createdAt!.compareTo(b.createdAt!),
    );
    return eventsLog;
  }

  Future<int> insertAllEventsLog(
    List<TempEventLogClass> eventsLog,
  ) async {
    await clearEventsLog();
    try {
      for (var log in eventsLog) {
        await eventsLogBox.put(log.uuid, log);
      }
      print(
        "Offline Events Log inserted: ${eventsLog.length}",
      );
      print(getEventsLogs().length);
      return 1;
    } catch (e) {
      print(
        'Offline Events Log Insertion failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> createEventsLog(
    TempEventLogClass eventsLog,
  ) async {
    try {
      await eventsLogBox.put(eventsLog.uuid, eventsLog);
      print('Offline Events Log inserted Successfully');

      return 1;
    } catch (e) {
      print(
        'Offline Events Log Insertion Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearEventsLog() async {
    try {
      if (eventsLogBox.values.isNotEmpty) {
        await eventsLogBox.clear();
        print('Offline Events Log Cleared');
      }
      return 1;
    } catch (e) {
      print(
        '❌❌ Offline Events Log Clear Error: ${e.toString()}',
      );
      return 0;
    }
  }

  bool isSynced() {
    if (CreatedEventsLogFunc()
            .getCreatedEventsLogs()
            .isEmpty &&
        returnData().isSyncing == false) {
      return true;
    } else {
      return false;
    }
  }
}

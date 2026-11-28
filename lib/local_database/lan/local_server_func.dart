import 'package:hive/hive.dart';
import 'package:stockall/classes/lan/local_server_record.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/main.dart';

class LocalServerFunc {
  static final LocalServerFunc instance = LocalServerFunc._internal();
  factory LocalServerFunc() => instance;
  LocalServerFunc._internal();

  late Box<LocalServerRecord> localServerRecordBox;
  final String localServerRecordBoxName = 'localServerRecordBoxStockall';

  /// The highest epoch this device has seen per shop. Never cleared, so a
  /// store switch or logout can't make this device claim a stale epoch.
  late Box<int> epochFloorBox;
  final String epochFloorBoxName = 'localServerEpochFloorBoxStockall';

  Future<void> init() async {
    try {
      safeRegisterAdapter(LocalServerRecordAdapter());
      localServerRecordBox = await openBoxSafely<LocalServerRecord>(
        localServerRecordBoxName,
      );
      epochFloorBox = await openBoxSafely<int>(epochFloorBoxName);
      await mainLocalLog('✅ Local Server Record Box Initialized');
    } catch (e, s) {
      await mainLocalLog(
        'Error Initializing Local Server Record Box: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
    }
  }

  LocalServerRecord? getRecord(int shopId) {
    return localServerRecordBox.get(shopId);
  }

  Future<void> putRecord(LocalServerRecord record) async {
    await localServerRecordBox.put(record.shopId, record);
  }

  Future<void> deleteRecord(int shopId) async {
    await localServerRecordBox.delete(shopId);
  }

  List<LocalServerRecord> allRecords() {
    return localServerRecordBox.values.toList();
  }

  int epochFloor(int shopId) {
    return epochFloorBox.get(shopId) ?? 0;
  }

  Future<void> raiseEpochFloor(int shopId, int epoch) async {
    if (epoch > epochFloor(shopId)) {
      await epochFloorBox.put(shopId, epoch);
    }
  }

  /// Clears the records only. The epoch floor is kept on purpose.
  Future<void> clearLocalServerRecords() async {
    await localServerRecordBox.clear();
    await mainLocalLog('Local Server Records Cleared');
  }
}

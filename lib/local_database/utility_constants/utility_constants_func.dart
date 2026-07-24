import 'package:hive/hive.dart';
import 'package:stockall/classes/utility_constants/utility_constants.dart';
import 'package:stockall/main.dart';

class UtilityConstantsFunc {
  static final UtilityConstantsFunc instance =
      UtilityConstantsFunc._internal();
  factory UtilityConstantsFunc() => instance;
  UtilityConstantsFunc._internal();
  late Box<UtilityConstants> utilityConstantsBox;
  final String utilityConstantsBoxName =
      'utilityConstantsBoxStockall';

  Future<void> init() async {
    try {
      // await Hive.deleteBoxFromDisk(utilityConstantsBoxName);
      Hive.registerAdapter(UtilityConstantsAdapter());
      utilityConstantsBox = await Hive.openBox(
        utilityConstantsBoxName,
      );
      await mainLocalLog(
        '✅Utility Constants Box Initialized',
      );
    } catch (e, s) {
      await mainLocalLog(
        'Error Initializing Utility Constants Box: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
    }
  }

  UtilityConstants? getUtilityConstants() {
    return utilityConstantsBox.values.isNotEmpty
        ? utilityConstantsBox.values.first
        : null;
  }

  Future<int> insertUtilityConstant(
    UtilityConstants utilityConstant,
  ) async {
    try {
      await utilityConstantsBox.put(
        utilityConstant.uuid,
        utilityConstant,
      );
      await mainLocalLog(
        'Utility Constant inserted Success',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Insert Utility Constant Offline Error: ${e.toString()}',
      );
      return 0;
    }
  }

  Future clearUtilityConstants() async {
    await utilityConstantsBox.clear();
    await mainLocalLog('Offline Utility Constant Cleared');
  }
}

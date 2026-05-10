import 'package:hive/hive.dart';
import 'package:stockall/classes/utility_constants/utility_constants.dart';

class UtilityConstantsFunc {
  static final UtilityConstantsFunc instance =
      UtilityConstantsFunc._internal();
  factory UtilityConstantsFunc() => instance;
  UtilityConstantsFunc._internal();
  late Box<UtilityConstants> utilityConstantsBox;
  final String utilityConstantsBoxName =
      'utilityConstantsBoxStockall';

  Future<void> init() async {
    // await Hive.deleteBoxFromDisk(utilityConstantsBoxName);
    Hive.registerAdapter(UtilityConstantsAdapter());
    utilityConstantsBox = await Hive.openBox(
      utilityConstantsBoxName,
    );
    print('✅Utility Constants Box Initialized');
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
      print('Utility Constant inserted Success');
      return 1;
    } catch (e) {
      print(
        '❌❌ Insert Utility Constant Offline Error: ${e.toString()}',
      );
      return 0;
    }
  }

  Future clearUtilityConstants() async {
    await utilityConstantsBox.clear();
    print('Offline Utility Constant Cleared');
  }
}

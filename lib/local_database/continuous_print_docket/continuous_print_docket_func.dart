import 'package:hive/hive.dart';
import 'package:stockall/classes/continuous_print_docket/continuous_print_docket.dart';
import 'package:stockall/main.dart';

class ContinuousPrintDocketFunc {
  static final ContinuousPrintDocketFunc instance =
      ContinuousPrintDocketFunc._internal();
  factory ContinuousPrintDocketFunc() => instance;
  ContinuousPrintDocketFunc._internal();
  late Box<ContinuousPrintDocket> continuousPrintDocketBox;
  final String continuousPrintDocketBoxName =
      'continuousPrintDocketBoxStockall';

  Future<void> init() async {
    try {
      Hive.registerAdapter(ContinuousPrintDocketAdapter());

      continuousPrintDocketBox = await Hive.openBox(
        continuousPrintDocketBoxName,
      );

      // Initialize default value
      if (continuousPrintDocketBox.isEmpty) {
        await insertContinuousPrintDocket(
          ContinuousPrintDocket(id: 1, isOn: false),
        );
      }

      await mainLocalLog(
        '✅App ContinuousPrintDocket Box Initialized',
      );
    } catch (e, s) {
      await mainLocalLog(
        'Error Initializing Continuous Print Docket Box: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
    }
  }

  ContinuousPrintDocket? getContinuousPrintDocket() {
    return continuousPrintDocketBox.values.isNotEmpty
        ? continuousPrintDocketBox.values.first
        : null;
  }

  Future<int> insertContinuousPrintDocket(
    ContinuousPrintDocket continuousPrintDocket,
  ) async {
    try {
      await continuousPrintDocketBox.put(
        continuousPrintDocket.id,
        continuousPrintDocket,
      );
      await mainLocalLog(
        'ContinuousPrintDocket inserted Success',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Insert ContinuousPrintDocket Offline Error: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> toggleContinuousPrintDocket() async {
    try {
      var temp = getContinuousPrintDocket();
      if (temp != null) {
        if (temp.isOn) {
          temp.isOn = false;
        } else {
          temp.isOn = true;
        }
        await insertContinuousPrintDocket(temp);
        return 1;
      } else {
        return 0;
      }
    } catch (e) {
      await mainLocalLog(
        'Error Toggling Continuous Print Docket Value: ${e.toString()}',
      );
      return 0;
    }
  }

  Future clearContinuousPrintDockets() async {
    await continuousPrintDocketBox.clear();
    await mainLocalLog(
      'Offline ContinuousPrintDocket Cleared',
    );
  }
}

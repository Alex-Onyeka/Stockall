import 'package:hive/hive.dart';
import 'package:stockall/classes/app_version/app_version.dart';
import 'package:stockall/main.dart';

class AppVersionFunc {
  static final AppVersionFunc instance =
      AppVersionFunc._internal();
  factory AppVersionFunc() => instance;
  AppVersionFunc._internal();
  late Box<AppVersion> appVersionBox;
  final String appVersionBoxName = 'appVersionBoxStockall';

  Future<void> init() async {
    try {
      // await Hive.deleteBoxFromDisk(appVersionBoxName);
      Hive.registerAdapter(AppVersionAdapter());
      appVersionBox = await Hive.openBox(appVersionBoxName);
      await mainLocalLog('✅App Version Box Initialized');
    } catch (e, s) {
      await mainLocalLog(
        'Error Initializing App Versions Box: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
    }
  }

  AppVersion? getAppVersion() {
    return appVersionBox.values.isNotEmpty
        ? appVersionBox.values.first
        : null;
  }

  Future<int> insertVersion(AppVersion version) async {
    try {
      await appVersionBox.put(version.id, version);
      await mainLocalLog('Version inserted Success');
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Insert Version Offline Error: ${e.toString()}',
      );
      return 0;
    }
  }

  Future clearVersions() async {
    await appVersionBox.clear();
    await mainLocalLog('Offline Version Cleared');
  }
}

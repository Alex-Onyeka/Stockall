import 'package:hive/hive.dart';
import 'package:stockall/classes/app_version/app_version.dart';

class AppVersionFunc {
  static final AppVersionFunc instance =
      AppVersionFunc._internal();
  factory AppVersionFunc() => instance;
  AppVersionFunc._internal();
  late Box<AppVersion> appVersionBox;
  final String appVersionBoxName = 'appVersionBoxStockall';

  Future<void> init() async {
    // await Hive.deleteBoxFromDisk(appVersionBoxName);
    Hive.registerAdapter(AppVersionAdapter());
    appVersionBox = await Hive.openBox(appVersionBoxName);
    print('✅App Version Box Initialized');
  }

  AppVersion? getAppVersion() {
    return appVersionBox.values.isNotEmpty
        ? appVersionBox.values.first
        : null;
  }

  Future<int> insertVersion(AppVersion version) async {
    try {
      await appVersionBox.put(version.id, version);
      print('Version inserted Success');
      return 1;
    } catch (e) {
      print(
        '❌❌ Insert Version Offline Error: ${e.toString()}',
      );
      return 0;
    }
  }

  Future clearVersions() async {
    await appVersionBox.clear();
    print('Offline Version Cleared');
  }
}

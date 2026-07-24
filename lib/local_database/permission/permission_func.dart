import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_permission/temp_permission_class.dart';
import 'package:stockall/main.dart';

class PermissionFunc {
  static final PermissionFunc instance =
      PermissionFunc._internal();
  factory PermissionFunc() => instance;
  PermissionFunc._internal();
  late Box<PermissionModel> permissionModelBox;
  final String permissionModelBoxName =
      'permissionModelBoxStockall';

  Future<void> init() async {
    try {
      // await Hive.deleteBoxFromDisk(permissionModelBoxName);
      Hive.registerAdapter(PermissionModelAdapter());
      permissionModelBox = await Hive.openBox(
        permissionModelBoxName,
      );
      await mainLocalLog(
        '✅ Permisson Model Box Initialized',
      );
    } catch (e, s) {
      await mainLocalLog(
        'Error Initializing Permissions Box: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
    }
  }

  List<PermissionModel> getPermissionModel() {
    return permissionModelBox.values.toList();
  }

  Future<int> insertAllPermissions(
    List<PermissionModel> permissions,
  ) async {
    await clearPermission();
    try {
      for (var permit in permissions) {
        await permissionModelBox.put(permit.id, permit);
      }
      await mainLocalLog(
        'Offline Permissions Inserted Successfully',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Offline Permissions insertion Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future clearPermission() async {
    await permissionModelBox.clear();
    await mainLocalLog('Offline Permission Cleared');
  }
}

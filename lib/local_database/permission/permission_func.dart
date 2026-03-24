import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_permission/temp_permission_class.dart';

class PermissionFunc {
  static final PermissionFunc instance =
      PermissionFunc._internal();
  factory PermissionFunc() => instance;
  PermissionFunc._internal();
  late Box<PermissionModel> permissionModelBox;
  final String permissionModelBoxName =
      'permissionModelBoxStockall';

  Future<void> init() async {
    // await Hive.deleteBoxFromDisk(permissionModelBoxName);
    Hive.registerAdapter(PermissionModelAdapter());
    permissionModelBox = await Hive.openBox(
      permissionModelBoxName,
    );
    print('✅ Permisson Model Box Initialized');
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
      print('Offline Permissions Inserted Successfully');
      return 1;
    } catch (e) {
      print(
        '❌❌ Offline Permissions insertion Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future clearPermission() async {
    await permissionModelBox.clear();
    print('Offline Permission Cleared');
  }
}

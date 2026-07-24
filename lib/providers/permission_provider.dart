import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_permission/temp_permission_class.dart';
import 'package:stockall/local_database/permission/permission_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PermissionProvider extends ChangeNotifier {
  static final PermissionProvider _instance =
      PermissionProvider._internal();
  factory PermissionProvider() => _instance;
  PermissionProvider._internal();
  final supabase = Supabase.instance.client;
  final ConnectivityProvider connectivity =
      ConnectivityProvider();

  List<PermissionModel> permissionsCache = [];
  final String tableName = 'permissions';
  List<PermissionModel> permissions() {
    for (var perm in permissionsCache) {
      perm.access.sort();
    }
    return permissionsCache;
  }

  void clearPermissions() {
    permissionsCache.clear();
    mainLocalLog('Permissions Cleared');
    notifyListeners();
  }

  //
  //
  //
  //
  //
  //
  //
  //

  Future<List<PermissionModel>> getPermissions() async {
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      final response =
          await supabase.from(tableName).select();
      await mainLocalLog(
        'Permissions Gotten: ${response.length}',
      );

      permissionsCache =
          (response as List)
              .map((e) => PermissionModel.fromJson(e))
              .toList();

      await PermissionFunc().insertAllPermissions(
        permissionsCache,
      );
    } else {
      permissionsCache =
          PermissionFunc().getPermissionModel();
    }
    permissionsCache.sort(
      (a, b) => a.permitNumber!.compareTo(b.permitNumber!),
    );
    notifyListeners();
    return permissionsCache;
  }

  //
  //
  //
  //
  //

  //
  //
  //
}

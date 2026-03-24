import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_permission/temp_permission_class.dart';
import 'package:stockall/local_database/permission/permission_func.dart';
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

  List<PermissionModel> permissions = [];
  final String tableName = 'permissions';
  void clearPermissions() {
    permissions.clear();
    print('Permissions Cleared');
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
      print('Permissions Gotten: ${response.length}');

      permissions =
          (response as List)
              .map((e) => PermissionModel.fromJson(e))
              .toList();

      await PermissionFunc().insertAllPermissions(
        permissions,
      );
    } else {
      permissions = PermissionFunc().getPermissionModel();
    }
    notifyListeners();
    return permissions;
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

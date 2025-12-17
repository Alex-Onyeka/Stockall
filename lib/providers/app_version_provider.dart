import 'package:flutter/cupertino.dart';
import 'package:stockall/classes/app_version/app_version.dart';
import 'package:stockall/local_database/app_version/app_version_func.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppVersionProvider extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  final String tableName = 'app_version';

  AppVersion? appVersion;

  bool isUpdated = false;

  void toggleUpdated(bool value) {
    isUpdated = value;
    notifyListeners();
  }

  Future<AppVersion?> getAppVersion() async {
    bool isOnline = await ConnectivityProvider().isOnline();
    if (isOnline) {
      try {
        var res =
            await _client
                .from(tableName)
                .select()
                .eq('id', 1)
                .single();

        appVersion = AppVersion.fromJson(res);
        AppVersionFunc().insertVersion(
          AppVersion.fromJson(res),
        );
        notifyListeners();
        print('App Version gotten Successfully');
        return appVersion;
      } catch (e) {
        print(
          '❌Error Getting App Version: ${e.toString()}',
        );
        return null;
      }
    } else {
      appVersion = AppVersionFunc().getAppVersion();
      print('App version gotten Offline');
      return appVersion;
    }
  }
}

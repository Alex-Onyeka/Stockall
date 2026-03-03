import 'package:flutter/cupertino.dart';
import 'package:stockall/classes/app_version/app_version.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/local_database/app_version/app_version_func.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppVersionProvider extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  final String tableName = 'app_version';

  AppVersion? appVersion;

  bool isUpdated = true;

  void toggleUpdated(bool value) {
    isUpdated = value;
    notifyListeners();
  }

  Future<AppVersion?> getAppVersion(
    BuildContext context,
  ) async {
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
        if (screenWidth(context) <= mobileScreen) {
          if (appVersion?.mobileVersion !=
              appVersionMobile) {
            toggleUpdated(false);
          } else {
            toggleUpdated(true);
          }
        } else {
          if (appVersion?.desktopVersion !=
              appVersionDesktop) {
            toggleUpdated(false);
          } else {
            toggleUpdated(true);
          }
        }
        return appVersion;
      } catch (e) {
        print(
          '❌Error Getting App Version: ${e.toString()}',
        );
        return null;
      }
    } else {
      appVersion = AppVersionFunc().getAppVersion();
      if (screenWidth(context) <= mobileScreen) {
        if (appVersion?.mobileVersion != appVersionMobile) {
          toggleUpdated(false);
        } else {
          toggleUpdated(true);
        }
      } else {
        if (appVersion?.desktopVersion !=
            appVersionDesktop) {
          toggleUpdated(false);
        } else {
          toggleUpdated(true);
        }
      }
      print('App version gotten Offline');
      return appVersion;
    }
  }
}

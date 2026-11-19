import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/app_version/app_version.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/local_database/app_version/app_version_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppVersionProvider extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  final String tableName = 'app_version';

  AppVersion? appVersion;
  DateTime? _lastFetchedAt;

  bool isUpdated = true;

  static const String _prefsBoxName = 'app_update_prefs';
  static const int _maxOptionalDismissals = 2;

  String? _cachedDismissVersion;
  int _cachedDismissCount = 0;

  void toggleUpdated(bool value) {
    isUpdated = value;
    notifyListeners();
  }

  bool get _isCompulsoryUpdate =>
      returnUtilityConstantProvider()
          .utilityConstants
          ?.isCompulsory ??
      false;

  String? _targetVersion(BuildContext context) {
    if (appVersion == null) return null;
    return screenWidth(context) <= mobileScreen
        ? appVersion!.mobileVersion
        : appVersion!.desktopVersion;
  }

  Future<Box> _openPrefsBox() async {
    return Hive.isBoxOpen(_prefsBoxName)
        ? Hive.box(_prefsBoxName)
        : await Hive.openBox(_prefsBoxName);
  }

  Future<int> _getDismissCount(String version) async {
    final box = await _openPrefsBox();
    final count =
        (box.get('dismiss_count_$version') as int?) ?? 0;
    _cachedDismissVersion = version;
    _cachedDismissCount = count;
    return count;
  }

  Future<void> _syncPopupStateForVersion(
    BuildContext context, {
    required bool resetIfEligible,
  }) async {
    if (!hasAvailableUpdate(context)) {
      isUpdated = true;
      notifyListeners();
      return;
    }
    final version = _targetVersion(context);
    if (version == null) return;
    if (_isCompulsoryUpdate) {
      if (resetIfEligible) {
        isUpdated = false;
      }
      notifyListeners();
      return;
    }
    final count = await _getDismissCount(version);
    if (count >= _maxOptionalDismissals) {
      isUpdated = true;
    } else if (resetIfEligible) {
      isUpdated = false;
    }
    notifyListeners();
  }

  bool shouldShowUpdatePopup(BuildContext context) {
    if (!hasAvailableUpdate(context)) return false;
    if (isUpdated) return false;
    if (_isCompulsoryUpdate) return true;
    final version = _targetVersion(context);
    if (version == null) return false;
    if (_cachedDismissVersion == version &&
        _cachedDismissCount >= _maxOptionalDismissals) {
      return false;
    }
    return true;
  }

  Future<void> dismissUpdatePopup(
    BuildContext context,
  ) async {
    isUpdated = true;
    notifyListeners();
    if (_isCompulsoryUpdate) return;
    final version = _targetVersion(context);
    if (version == null) return;
    final box = await _openPrefsBox();
    final nextCount =
        ((box.get('dismiss_count_$version') as int?) ?? 0) +
        1;
    await box.put('dismiss_count_$version', nextCount);
    _cachedDismissVersion = version;
    _cachedDismissCount = nextCount;
    notifyListeners();
  }

  Future<void> onDashboardOpened(
    BuildContext context,
  ) async {
    if (returnUtilityConstantProvider().utilityConstants ==
        null) {
      await returnUtilityConstantProvider()
          .getUtilityConstants();
    }
    if (!context.mounted) return;
    await _syncPopupStateForVersion(
      context,
      resetIfEligible: true,
    );
  }

  /// True when the latest fetched/cached version differs from the
  /// running app version for this screen size.
  bool hasAvailableUpdate(BuildContext context) {
    if (appVersion == null) return false;
    if (screenWidth(context) <= mobileScreen) {
      return appVersion!.mobileVersion != appVersionMobile;
    } else {
      return appVersion!.desktopVersion !=
          appVersionDesktop;
    }
  }

  Future<AppVersion?> getAppVersion(
    BuildContext context, {
    bool forceRefresh = false,
  }) async {
    await returnPermissionProvider().getPermissions(
      forceRefresh: forceRefresh,
    );
    if (!context.mounted) return appVersion;
    if (!forceRefresh &&
        _lastFetchedAt != null &&
        DateTime.now().difference(_lastFetchedAt!) <
            const Duration(minutes: 10) &&
        appVersion != null) {
      await _syncPopupStateForVersion(
        context,
        resetIfEligible: false,
      );
      return appVersion;
    }
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
        _lastFetchedAt = DateTime.now();
        AppVersionFunc().insertVersion(
          AppVersion.fromJson(res),
        );
        await mainLocalLog(
          'App Version gotten Successfully',
        );
        if (!context.mounted) return appVersion;
        await _syncPopupStateForVersion(
          context,
          resetIfEligible: true,
        );
        return appVersion;
      } catch (e) {
        await mainLocalLog(
          '❌Error Getting App Version: ${e.toString()}',
        );
        return null;
      }
    } else {
      appVersion = AppVersionFunc().getAppVersion();
      if (!context.mounted) return appVersion;
      await _syncPopupStateForVersion(
        context,
        resetIfEligible: true,
      );
      await mainLocalLog('App version gotten Offline');
      return appVersion;
    }
  }
}

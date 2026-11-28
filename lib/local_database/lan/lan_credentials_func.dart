import 'package:hive/hive.dart';
import 'package:stockall/classes/lan/lan_user_credential.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/main.dart';

/// The LAN server's user store, keyed `"$shopId:$userId"`. Shop data:
/// cleared by `clearAllShopData`.
class LanCredentialsFunc {
  static final LanCredentialsFunc instance = LanCredentialsFunc._internal();
  factory LanCredentialsFunc() => instance;
  LanCredentialsFunc._internal();

  late Box<LanUserCredential> credentialsBox;
  final String credentialsBoxName = 'lanUserCredentialsBoxStockall';

  Future<void> init() async {
    try {
      safeRegisterAdapter(LanUserCredentialAdapter());
      credentialsBox = await openBoxSafely<LanUserCredential>(
        credentialsBoxName,
      );
      await mainLocalLog('✅ LAN Credentials Box Initialized');
    } catch (e, s) {
      await mainLocalLog(
        'Error Initializing LAN Credentials Box: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
    }
  }

  List<LanUserCredential> forShop(int shopId) {
    return credentialsBox.values.where((c) => c.shopId == shopId).toList();
  }

  LanUserCredential? get(int shopId, String userId) {
    return credentialsBox.get(LanUserCredential.keyFor(shopId, userId));
  }

  LanUserCredential? byEmail(int shopId, String email) {
    final wanted = email.trim().toLowerCase();
    for (final credential in credentialsBox.values) {
      if (credential.shopId == shopId && credential.email == wanted) {
        return credential;
      }
    }
    return null;
  }

  /// Makes [credentials] the whole store for [shopId].
  Future<void> replaceForShop(
    int shopId,
    List<LanUserCredential> credentials,
  ) async {
    final keep = {for (final c in credentials) c.storageKey};
    final stale = [
      for (final c in forShop(shopId))
        if (!keep.contains(c.storageKey)) c.storageKey,
    ];
    await credentialsBox.deleteAll(stale);
    await credentialsBox.putAll({
      for (final c in credentials) c.storageKey: c,
    });
  }

  Future<void> clearCredentials() async {
    await credentialsBox.clear();
  }
}

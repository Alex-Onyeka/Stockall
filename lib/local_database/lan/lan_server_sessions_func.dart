import 'package:hive/hive.dart';
import 'package:stockall/classes/lan/lan_server_session.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/main.dart';

/// Sessions the LAN server has issued, keyed by token hash. Shop data:
/// cleared by `clearAllShopData`.
class LanServerSessionsFunc {
  static final LanServerSessionsFunc instance =
      LanServerSessionsFunc._internal();
  factory LanServerSessionsFunc() => instance;
  LanServerSessionsFunc._internal();

  late Box<LanServerSession> sessionsBox;
  final String sessionsBoxName = 'lanServerSessionsBoxStockall';

  Future<void> init() async {
    try {
      safeRegisterAdapter(LanServerSessionAdapter());
      sessionsBox = await openBoxSafely<LanServerSession>(sessionsBoxName);
      await mainLocalLog('✅ LAN Server Sessions Box Initialized');
    } catch (e, s) {
      await mainLocalLog(
        'Error Initializing LAN Server Sessions Box: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
    }
  }

  LanServerSession? get(String tokenHash) => sessionsBox.get(tokenHash);

  Future<void> put(LanServerSession session) async {
    await sessionsBox.put(session.tokenHash, session);
  }

  Future<void> delete(String tokenHash) async {
    await sessionsBox.delete(tokenHash);
  }

  /// Ends every session of one user on one device (a new login replaces
  /// them).
  Future<void> deleteForDevice({
    required int shopId,
    required String userId,
    required String deviceId,
  }) async {
    await sessionsBox.deleteAll([
      for (final s in sessionsBox.values)
        if (s.shopId == shopId && s.userId == userId && s.deviceId == deviceId)
          s.tokenHash,
    ]);
  }

  /// Ends every session of a user, e.g. when they leave the shop.
  Future<void> deleteForUser({
    required int shopId,
    required String userId,
  }) async {
    await sessionsBox.deleteAll([
      for (final s in sessionsBox.values)
        if (s.shopId == shopId && s.userId == userId) s.tokenHash,
    ]);
  }

  Future<void> clearSessions() async {
    await sessionsBox.clear();
  }
}

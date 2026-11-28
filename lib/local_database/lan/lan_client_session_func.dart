import 'package:hive/hive.dart';
import 'package:stockall/classes/lan/lan_client_session.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/main.dart';

/// This device's LAN session per shop, keyed by shop id. Shop data:
/// cleared by `clearAllShopData`.
class LanClientSessionFunc {
  static final LanClientSessionFunc instance =
      LanClientSessionFunc._internal();
  factory LanClientSessionFunc() => instance;
  LanClientSessionFunc._internal();

  late Box<LanClientSession> clientSessionBox;
  final String clientSessionBoxName = 'lanClientSessionBoxStockall';

  Future<void> init() async {
    try {
      safeRegisterAdapter(LanClientSessionAdapter());
      clientSessionBox = await openBoxSafely<LanClientSession>(
        clientSessionBoxName,
      );
      await mainLocalLog('✅ LAN Client Session Box Initialized');
    } catch (e, s) {
      await mainLocalLog(
        'Error Initializing LAN Client Session Box: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
    }
  }

  LanClientSession? get(int shopId) => clientSessionBox.get(shopId);

  List<LanClientSession> all() => clientSessionBox.values.toList();

  Future<void> put(LanClientSession session) async {
    await clientSessionBox.put(session.shopId, session);
  }

  Future<void> delete(int shopId) async {
    await clientSessionBox.delete(shopId);
  }

  Future<void> clearClientSessions() async {
    await clientSessionBox.clear();
  }
}

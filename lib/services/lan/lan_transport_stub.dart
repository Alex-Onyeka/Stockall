import 'package:stockall/classes/lan/local_server_record.dart';
import 'package:stockall/services/lan/lan_handoffs.dart';
import 'package:stockall/services/lan/lan_transport_types.dart';
import 'package:stockall/services/lan/stock/lan_holds.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Web: no sockets and no mDNS, so LAN sync is unavailable. The server
/// can never start here.
class LanTransport implements LanTransportApi {
  static final LanTransport _instance = LanTransport._internal();
  factory LanTransport() => _instance;
  LanTransport._internal();

  static const LanPairOutcome _unavailable = LanPairOutcome(
    LanPairResult.failed,
    message: 'LAN sync is not available on this platform',
  );

  @override
  void Function()? onChanged;

  @override
  LanServerViewCallback? onServerView;

  @override
  void Function()? onServerSynced;

  @override
  void Function(String device, int epoch)? onFormerServerHandedOver;

  @override
  void Function(Set<String>? tables)? onInvalidate;

  @override
  void Function(Map<String, double> reserved)? onStock;

  @override
  void Function()? onConnected;

  @override
  LanStockLink? stockLink({String? userId}) => null;

  @override
  Future<void> Function(LanServerCandidate winner)? onOutranked;

  @override
  void Function(LanServerCandidate loser)? onOutranks;

  @override
  Future<LanServerCandidate?> proveServer({
    required String shopKey,
    required List<String> addresses,
    required int port,
    String? fingerprint,
  }) async => null;

  @override
  Future<LanServerCandidate?> findOutrankingServer({
    required String shopKey,
    required String ownDeviceId,
    required LanServerView self,
    Duration timeout = Duration.zero,
  }) async => null;

  @override
  void broadcastMoved(LanServerCandidate winner) {}

  @override
  Future<void> announceSteppingDown(LanServerCandidate winner) async {}

  @override
  void broadcastHandedOver(int epoch) {}

  @override
  Future<void> Function(
    int shopId,
    LanServerView from,
    LanServerCandidate to,
  )?
  onMoved;

  @override
  LanServerView? get clientServerView => null;

  @override
  LanServerHealth? get serverHealth => null;

  @override
  List<LanConnectedDevice> connectedDevices() => const [];

  @override
  Future<int> releaseDeviceHolds(String deviceId) async => 0;

  @override
  Future<void> Function(int shopId, LanServerView cleared)? onClearedElsewhere;

  @override
  Future<bool> reportHandedOver(int epoch) async => false;

  @override
  Future<List<LanServerCandidate>> findProvenServers({
    required String shopKey,
    required String ownDeviceId,
    Duration timeout = Duration.zero,
  }) async => const [];

  @override
  SupabaseClient? get lanClient => null;

  @override
  bool get isAvailable => false;

  @override
  bool get isServing => false;

  @override
  int? get servingShopId => null;

  @override
  int? get serverPort => null;

  @override
  String? get pendingPairingCode => null;

  @override
  bool get isClientConnected => false;

  @override
  List<String> get clientAddresses => const [];

  @override
  Future<String> serverFingerprint() {
    throw UnsupportedError('LAN server is not available on this platform');
  }

  @override
  Future<LanClaimPreflight> claimPreflight({
    required String shopKey,
    required String ownDeviceId,
    List<String> lastKnownAddresses = const [],
  }) async {
    return const LanClaimPreflight(liveServerFound: false, maxEpoch: 0);
  }

  @override
  Future<int> startServer({
    required LocalServerRecord record,
    required String deviceId,
    required String shopKey,
  }) {
    throw UnsupportedError('LAN server is not available on this platform');
  }

  @override
  Future<void> updateServerRecord(LocalServerRecord record) async {}

  @override
  Future<void> stopServer() async {}

  @override
  Future<String?> pairingQrPayload() async => null;

  @override
  void cancelPairingQr() {}

  @override
  int get qrPairings => 0;

  @override
  void cancelServerPairing() {}

  @override
  Future<void> advertisePeer({
    required String shopKey,
    required int epoch,
    required String deviceId,
  }) async {}

  @override
  Future<void> stopPeer() async {}

  @override
  Future<List<LanFound>> browseServers() async => const [];

  @override
  Future<bool> connectToServer({
    required int shopId,
    required String shopKey,
    required String pin,
    required List<String> addresses,
    required int port,
    required String token,
    required String deviceId,
    bool quick = false,
    Map<String, dynamic>? Function(LanServerView view, String fingerprint)?
    staleNotice,
  }) async => false;

  @override
  Future<void> disconnectClient() async {}

  @override
  Future<LanHandoffStatus?> handoffStatus() async => null;

  @override
  void notifyServerSynced() {}

  @override
  void interfaceChanged() {}

  @override
  Future<bool> shopPeerVisible({
    required String shopKey,
    required String ownDeviceId,
  }) async => false;

  @override
  Future<List<String>> ownLanAddresses() async => const [];

  @override
  Future<LanLoginOutcome> loginToPairedServer({
    required String email,
    required String password,
    required String deviceId,
    String? serverDeviceId,
  }) async => const LanLoginOutcome(LanAuthResult.unreachable);

  @override
  Future<bool> requestCredentialRefresh({required String deviceId}) async =>
      false;

  @override
  Future<void> logoutFromServer({
    required String serverDeviceId,
    required String token,
    required String deviceId,
  }) async {}

  @override
  Future<LanAuthResult> verifyPasswordOnServer({
    required String serverDeviceId,
    required String token,
    required String deviceId,
    required String password,
  }) async => LanAuthResult.unreachable;

  @override
  Future<LanPairOutcome> beginPairing({
    required List<String> addresses,
    required int port,
  }) async => _unavailable;

  @override
  Future<LanPairOutcome> submitPairingCode(String code) async => _unavailable;

  @override
  Future<LanPairOutcome> pairFromQr(String payload) async => _unavailable;

  @override
  Future<void> cancelPairing() async {}
}

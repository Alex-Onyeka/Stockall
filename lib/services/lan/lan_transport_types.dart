import 'package:stockall/classes/lan/lan_paired_server.dart';
import 'package:stockall/classes/lan/local_server_record.dart';
import 'package:stockall/services/lan/lan_constants.dart';
import 'package:stockall/services/lan/lan_handoffs.dart';
import 'package:stockall/services/lan/stock/lan_holds.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Types shared by the dart:io transport and the web stub. Pure Dart.

/// A service seen over mDNS.
class LanFound {
  const LanFound({
    required this.name,
    required this.addresses,
    required this.port,
    required this.txt,
  });

  final String name;
  final List<String> addresses;
  final int port;
  final Map<String, String> txt;

  String? get shopTag => txt['t'];
  String? get deviceId => txt['d'];
  int get epoch => int.tryParse(txt['e'] ?? '') ?? 0;
}

class LanClaimPreflight {
  const LanClaimPreflight({
    required this.liveServerFound,
    required this.maxEpoch,
  });

  final bool liveServerFound;
  final int maxEpoch;
}

/// What `GET /v1/server` returns without a session: no shop id and no
/// user id. With a session the server adds the rest ([fullJson]).
class LanServerView {
  const LanServerView({
    required this.shopTag,
    required this.epoch,
    required this.serverDeviceId,
    required this.cleared,
    required this.claimedAt,
  });

  final String shopTag;
  final int epoch;
  final String? serverDeviceId;
  final bool cleared;
  final DateTime? claimedAt;

  factory LanServerView.fromRecord(LocalServerRecord record, String tag) {
    return LanServerView(
      shopTag: tag,
      epoch: record.epoch,
      serverDeviceId: record.serverDeviceId,
      cleared: record.isCleared,
      claimedAt: record.claimedAt,
    );
  }

  /// The full record, for a signed-in member.
  static Map<String, dynamic> fullJson(LocalServerRecord record, String tag) {
    return {
      ...LanServerView.fromRecord(record, tag).toJson(),
      'shop_id': record.shopId,
      'claimed_by_user_id': record.claimedByUserId,
      'cert_fingerprint': record.certFingerprint,
      'last_known_addresses': record.lastKnownAddresses,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'v': LanConstants.protocolVersion,
      'tv': LanConstants.shopTagVersion,
      'shop_tag': shopTag,
      'epoch': epoch,
      'server_device_id': serverDeviceId,
      'cleared': cleared,
      'claimed_at': claimedAt?.toIso8601String(),
    };
  }

  static LanServerView? fromJson(Map<String, dynamic> json) {
    final tag = json['shop_tag'];
    final epoch = json['epoch'];
    final cleared = json['cleared'];
    final device = json['server_device_id'];
    final claimedAt = json['claimed_at'];
    if (tag is! String || epoch is! int || cleared is! bool) return null;
    if (device != null && device is! String) return null;
    return LanServerView(
      shopTag: tag,
      epoch: epoch,
      serverDeviceId: device as String?,
      cleared: cleared,
      claimedAt: claimedAt is String ? DateTime.tryParse(claimedAt) : null,
    );
  }
}

/// A server of the shop that proved its claim: its view, the
/// fingerprint of the TLS certificate the proof was bound to, and where it
/// answered.
class LanServerCandidate {
  const LanServerCandidate({
    required this.view,
    required this.fingerprint,
    required this.addresses,
    required this.port,
  });

  final LanServerView view;
  final String fingerprint;
  final List<String> addresses;
  final int port;

  /// Positive when this server outranks the claim given, negative
  /// when outranked, 0 for the same claim.
  int rankAgainst({
    required int epoch,
    required DateTime? claimedAt,
    required String? deviceId,
  }) => LocalServerRecord.compareRank(
    epoch: view.epoch,
    claimedAt: view.claimedAt,
    deviceId: view.serverDeviceId,
    otherEpoch: epoch,
    otherClaimedAt: claimedAt,
    otherDeviceId: deviceId,
  );

  int rankAgainstView(LanServerView other) => rankAgainst(
    epoch: other.epoch,
    claimedAt: other.claimedAt,
    deviceId: other.serverDeviceId,
  );

  /// The record this device keeps when it follows this server.
  LocalServerRecord toRecord(int shopId) => LocalServerRecord(
    shopId: shopId,
    epoch: view.epoch,
    serverDeviceId: view.serverDeviceId,
    claimedAt: view.claimedAt,
    certFingerprint: fingerprint,
    lastKnownAddresses: addresses,
  );

  Map<String, dynamic> toJson() => {
    'view': view.toJson(),
    'fingerprint': fingerprint,
    'addresses': addresses,
    'port': port,
  };

  static LanServerCandidate? fromJson(Object? json) {
    if (json is! Map) return null;
    final view = json['view'] is Map
        ? LanServerView.fromJson(Map<String, dynamic>.from(json['view'] as Map))
        : null;
    final fingerprint = json['fingerprint'];
    final addresses = json['addresses'];
    final port = json['port'];
    if (view == null ||
        fingerprint is! String ||
        addresses is! List ||
        port is! int) {
      return null;
    }
    return LanServerCandidate(
      view: view,
      fingerprint: fingerprint,
      addresses: [
        for (final a in addresses)
          if (a is String) a,
      ],
      port: port,
    );
  }
}

/// Where the server's first load from Supabase is: "loading
/// store data" until done.
class LanBackfillStatus {
  const LanBackfillStatus({
    required this.running,
    required this.done,
    this.table,
    this.at,
  });

  final bool running;

  /// A complete backfill has finished (now or before).
  final bool done;

  /// The table it is on.
  final String? table;
  final DateTime? at;

  static LanBackfillStatus? fromJson(Object? json) {
    if (json is! Map) return null;
    final running = json['running'];
    final done = json['done'];
    if (running is! bool || done is! bool) return null;
    final table = json['table'];
    final at = json['at'];
    return LanBackfillStatus(
      running: running,
      done: done,
      table: table is String ? table : null,
      at: at is String ? DateTime.tryParse(at) : null,
    );
  }
}

/// What this device knows of the store server beyond its claim:
/// whether it can reach the internet, and its backfill.
class LanServerHealth {
  const LanServerHealth({this.online, this.backfill});

  /// Null when not known (a server that doesn't say).
  final bool? online;
  final LanBackfillStatus? backfill;

  /// From the full `GET /v1/server` view.
  static LanServerHealth fromJson(Map<String, dynamic> json) {
    final online = json['online'];
    return LanServerHealth(
      online: online is bool ? online : null,
      backfill: LanBackfillStatus.fromJson(json['backfill']),
    );
  }
}

/// One cart's hold of one product.
typedef LanDeviceHold = ({String cartId, String productUuid, double quantity});

/// A device signed in on this server, for the settings screen.
class LanConnectedDevice {
  const LanConnectedDevice({
    required this.deviceId,
    required this.isThisDevice,
    required this.connected,
    required this.holds,
    this.userEmail,
    this.lastSeen,
  });

  final String deviceId;

  /// The server's own till.
  final bool isThisDevice;

  /// Whether it has a WebSocket open now.
  final bool connected;

  /// What its carts hold.
  final List<LanDeviceHold> holds;

  /// Who is signed in there (its latest session).
  final String? userEmail;
  final DateTime? lastSeen;
}

enum LanPairResult { awaitingCode, paired, codeMismatch, failed }

class LanPairOutcome {
  const LanPairOutcome(this.result, {this.server, this.message});

  final LanPairResult result;
  final LanPairedServer? server;
  final String? message;
}

enum LanAuthResult { ok, invalidCredentials, rateLimited, unreachable, failed }

/// The result of a LAN login, with what the server returned on success.
class LanLoginOutcome {
  const LanLoginOutcome(
    this.result, {
    this.serverDeviceId,
    this.token,
    this.expiresAt,
    this.user,
    this.shop,
    this.shopKey,
    this.notPairedBy = const [],
  });

  final LanAuthResult result;

  /// Servers that refused this device as not paired with them (it must
  /// pair again): with [LanAuthResult.unreachable] when none other
  /// answered.
  final List<String> notPairedBy;
  final String? serverDeviceId;
  final String? token;
  final DateTime? expiresAt;

  /// `TempUserClass` JSON without the password.
  final Map<String, dynamic>? user;

  /// `TempShopClass` JSON including `shop_id`.
  final Map<String, dynamic>? shop;
  final String? shopKey;
}

typedef LanServerViewCallback =
    void Function(
      int shopId,
      LanServerView view,
      List<String> addresses,
      String fingerprint,
    );

/// The transport as the provider sees it. `lan_transport_io.dart` and
/// `lan_transport_stub.dart` both implement it, so the analyzer checks the
/// web stub against the same surface.
abstract class LanTransportApi {
  bool get isAvailable;
  bool get isServing;
  int? get servingShopId;
  int? get serverPort;
  String? get pendingPairingCode;
  bool get isClientConnected;
  List<String> get clientAddresses;

  abstract void Function()? onChanged;
  abstract LanServerViewCallback? onServerView;

  /// The connected server says its queues reached Supabase (handoffs).
  abstract void Function()? onServerSynced;

  /// The connected server says these tables changed; null after
  /// the connection came back: every table (changes may have been missed).
  abstract void Function(Set<String>? tables)? onInvalidate;

  /// Cart stock holds changed: each product's total held, for
  /// the products that changed. On the server, for its own till too.
  abstract void Function(Map<String, double> reserved)? onStock;

  /// A client's WebSocket to its server (re)opened: its holds are
  /// re-synced.
  abstract void Function()? onConnected;

  /// How this device reaches its store server's stock holds: in process
  /// while it serves, over the LAN client while connected, else null.
  LanStockLink? stockLink({String? userId});

  /// A proven server of the shop outranks the one this
  /// device serves (found by the watch, or told by a `superseded` notice
  /// and proven).
  abstract Future<void> Function(LanServerCandidate winner)? onOutranked;

  /// This device's server outranks a proven one (that one is told to
  /// step down).
  abstract void Function(LanServerCandidate loser)? onOutranks;

  /// Asks the server at [addresses]:[port] to prove its claim,
  /// pinned to [fingerprint] when given; null when it doesn't answer or
  /// the proof fails.
  Future<LanServerCandidate?> proveServer({
    required String shopKey,
    required List<String> addresses,
    required int port,
    String? fingerprint,
  });

  /// Browses for [timeout] and returns the proven server of the shop that
  /// outranks [self] most, if any (a desktop's check before it serves).
  Future<LanServerCandidate?> findOutrankingServer({
    required String shopKey,
    required String ownDeviceId,
    required LanServerView self,
    Duration timeout,
  });

  /// Tells connected clients the shop's server is now [winner].
  void broadcastMoved(LanServerCandidate winner);

  /// Before this device stops serving for [winner]: tells it, so it can
  /// prove this server while it still serves and then let its paired
  /// tills sign in with the move this server signs. Best effort.
  Future<void> announceSteppingDown(LanServerCandidate winner);

  /// Tells connected clients this server delivers what it acknowledged at
  /// [epoch] itself, before a normal clear: their copies of its
  /// deltas end, so only a force-clear leaves any to report.
  void broadcastHandedOver(int epoch);

  /// The server this device is connected to as a client said
  /// the shop's server is now [to]. [from] is that server's view.
  abstract Future<void> Function(
    int shopId,
    LanServerView from,
    LanServerCandidate to,
  )?
  onMoved;

  /// The view of the server this device is connected to as a client.
  LanServerView? get clientServerView;

  /// On the server, its own internet and backfill; on a
  /// connected client, what its server last said; else null.
  LanServerHealth? get serverHealth;

  /// On the server, the devices signed in on it (this one
  /// first), with their holds; else empty.
  List<LanConnectedDevice> connectedDevices();

  /// On the server, releases [deviceId]'s holds. Returns how
  /// many.
  Future<int> releaseDeviceHolds(String deviceId);

  /// A device proved the shop's server was cleared at a higher
  /// epoch while this one was away ([cleared]): this one stops serving.
  abstract Future<void> Function(int shopId, LanServerView cleared)?
  onClearedElsewhere;

  /// Tells the server this device is connected to that the
  /// queue it kept while serving at [epoch] is all there. True when the
  /// server took it.
  Future<bool> reportHandedOver(int epoch);

  /// Browses for [timeout] and returns the proven servers of the shop,
  /// other than [ownDeviceId] (a client that missed a `moved` event looks
  /// for the server it should follow).
  Future<List<LanServerCandidate>> findProvenServers({
    required String shopKey,
    required String ownDeviceId,
    Duration timeout,
  });

  /// The connection's LAN `SupabaseClient`: one per connection, made on
  /// connect and disposed (with its JSON-decoding isolate) when the
  /// connection ends. Null when not connected.
  SupabaseClient? get lanClient;

  Future<String> serverFingerprint();
  Future<LanClaimPreflight> claimPreflight({
    required String shopKey,
    required String ownDeviceId,
    List<String> lastKnownAddresses,
  });
  Future<int> startServer({
    required LocalServerRecord record,
    required String deviceId,
    required String shopKey,
  });
  Future<void> updateServerRecord(LocalServerRecord record);
  Future<void> stopServer();
  Future<String?> pairingQrPayload();

  /// Ends the pairing session this server shows (its Cancel button).
  void cancelServerPairing();

  Future<void> advertisePeer({
    required String shopKey,
    required int epoch,
    required String deviceId,
  });
  Future<void> stopPeer();

  Future<List<LanFound>> browseServers();
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
  });
  Future<void> disconnectClient();

  /// What the connected server has synced to Supabase; null when not
  /// connected or it doesn't answer.
  Future<LanHandoffStatus?> handoffStatus();

  /// On the server: tells connected clients its queues are empty (sent to
  /// Supabase), when they are.
  void notifyServerSynced();

  /// The network interface went up or down: on the server, its schedule
  /// looks at once (a catch-up and a login refresh when it came back).
  void interfaceChanged();

  /// Whether another device of the shop advertises itself nearby (one
  /// sign of being on the shop's LAN).
  Future<bool> shopPeerVisible({
    required String shopKey,
    required String ownDeviceId,
  });

  /// This device's usable LAN addresses.
  Future<List<String>> ownLanAddresses();

  /// Signs in on the first paired server that answers; only on
  /// [serverDeviceId] when given.
  Future<LanLoginOutcome> loginToPairedServer({
    required String email,
    required String password,
    required String deviceId,
    String? serverDeviceId,
  });

  /// Asks the paired servers this device holds a pair secret for to fetch
  /// their logins again: the cloud took a password they refused. Best
  /// effort; never throws. True when one took the request.
  Future<bool> requestCredentialRefresh({required String deviceId});

  /// Best effort; never throws.
  Future<void> logoutFromServer({
    required String serverDeviceId,
    required String token,
    required String deviceId,
  });

  Future<LanAuthResult> verifyPasswordOnServer({
    required String serverDeviceId,
    required String token,
    required String deviceId,
    required String password,
  });

  Future<LanPairOutcome> beginPairing({
    required List<String> addresses,
    required int port,
  });
  Future<LanPairOutcome> submitPairingCode(String code);
  Future<LanPairOutcome> pairFromQr(String payload);
  Future<void> cancelPairing();
}

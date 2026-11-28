/// Fixed values for LAN sync transport. Pure Dart: safe to import on web.
class LanConstants {
  LanConstants._();

  static const int port = 47811;
  static const List<int> fallbackPorts = [47812, 47813, 47814, 47815];
  static const List<int> allPorts = [port, ...fallbackPorts];

  static const String serverServiceType = '_stockall._tcp';
  static const String peerServiceType = '_stockall-peer._tcp';

  /// Every TLS connection uses this name, whatever address the socket is
  /// opened to. Scoped IPv6 literals can't be used as a TLS host name.
  static const String tlsHost = 'stockall-lan';

  static const String protocolVersion = '1';
  static const String shopTagVersion = '2';

  /// Tunnel, VPN and AirDrop interfaces. Their link-local addresses time
  /// out, so they are never used as targets or zones.
  static const List<String> skippedInterfacePrefixes = [
    'utun',
    'awdl',
    'llw',
    'ipsec',
    'ppp',
    'gif',
    'stf',
    'anpi',
    'tun',
    'tap',
  ];

  static const Duration connectTimeout = Duration(seconds: 3);
  static const Duration requestTimeout = Duration(seconds: 10);
  static const Duration raceStagger = Duration(milliseconds: 250);
  static const Duration claimBrowse = Duration(seconds: 8);
  static const Duration findBrowse = Duration(seconds: 5);
  static const Duration sweepTimeout = Duration(milliseconds: 200);
  static const int sweepConcurrency = 64;
  static const Duration wsPing = Duration(seconds: 10);
  static const Duration pairingSessionTtl = Duration(minutes: 2);
  static const int pairingStartsPerMinute = 5;
  static const int maxRequestBodyBytes = 64 * 1024;

  /// `/rest/v1` bodies: bulk inserts of products can be large.
  static const int maxRestBodyBytes = 16 * 1024 * 1024;

  /// A LAN client gives up on a `/rest/v1` request after this long.
  static const Duration restTimeout = Duration(seconds: 30);

  /// The server starts its own sync this long after the last LAN write,
  /// so a client's burst of writes goes to Supabase in one run.
  static const Duration syncAfterWrites = Duration(seconds: 2);

  /// Tables and RPCs only Supabase has: the LAN server forwards them
  /// when it is online and answers `LAN01` when it isn't.
  static const Set<String> onlineOnlyTables = {
    'subscription',
    'subscription_payments',
    'app_version',
    'utility_constants',
    'notifications',
  };
  static const Set<String> onlineOnlyRpcs = {
    'mark_all_notifications_viewed',
    'get_this_month_subscription_payments',
  };

  /// The delta RPCs: a handoff of one waits for the LAN server,
  /// because Supabase's RPCs are not idempotent yet.
  static const Set<String> deltaRpcs = {
    'update_product_quantities',
    'update_materials_quantities',
    'update_production_items_quantities',
    'update_customer_account',
    // A checkout's stock change: never sent to Supabase.
    stockCheckoutRpc,
  };

  /// Cart stock holds: the server's own RPCs, answered from its Hive,
  /// never forwarded to Supabase.
  static const String stockReserveRpc = 'lan_stock_reserve';
  static const String stockSyncRpc = 'lan_stock_sync';
  static const String stockReleaseRpc = 'lan_stock_release';
  static const String stockCheckoutRpc = 'lan_checkout';

  /// A device's holds are released this long after its last WebSocket
  /// closed (a dead link is noticed by the 10 s ping within 10–20 s, so
  /// about 30–40 s after it died).
  static const Duration holdGrace = Duration(seconds: 20);

  /// `stock` events (hold totals) are batched for this long.
  static const Duration stockEventBatch = Duration(milliseconds: 100);

  /// The LAN server's clock (ms since epoch) on every `/rest/v1` answer:
  /// a handoff is confirmed once the server says it synced through it.
  static const String serverTimeHeader = 'x-stockall-time';

  /// Routing: how often a client on the LAN tries the server again,
  /// and how often a client off the LAN checks whether it is back.
  static const Duration lanDownRetry = Duration(seconds: 30);
  static const Duration offLanRecheck = Duration(minutes: 2);

  /// Invalidate events: the server batches table changes for this
  /// long into one event; a client refreshes a table at most this often.
  static const Duration invalidateBatch = Duration(milliseconds: 500);
  static const Duration invalidateRefreshGap = Duration(seconds: 5);

  /// The LAN server's schedule while serving and online:
  /// how often it checks what is due; the busy tables' and the other
  /// tables' pulls; the logins' refresh; and the pull after its own sync.
  static const Duration pullTick = Duration(seconds: 15);
  static const Duration pullFastEvery = Duration(seconds: 60);
  static const Duration pullSlowEvery = Duration(minutes: 5);
  static const Duration credentialsEvery = Duration(minutes: 15);
  static const Duration pullAfterSyncDelay = Duration(seconds: 2);

  /// The least time between two refreshes of the logins a till asks for
  /// (after the cloud took a password the server didn't).
  static const Duration credentialRefreshGap = Duration(seconds: 60);

  /// A delta handoff older than this is reported (it waits for the server).
  static const Duration staleDeltaHandoff = Duration(days: 3);

  /// While serving, look for another server of the shop this
  /// often, browsing this long each time (also the check before a desktop
  /// resumes serving).
  static const Duration serverWatchEvery = Duration(seconds: 30);
  static const Duration serverWatchBrowse = Duration(seconds: 5);

  /// The event an outranked server sends its clients before it stops:
  /// `{type: moved, to: LanServerCandidate}`.
  static const String movedEvent = 'moved';

  /// A former server's queue is all here: tills end their held
  /// deltas for it.
  static const String handedOverEvent = 'handed_over';

  /// While the server's backfill runs, how often a client reads its view
  /// again for the progress.
  static const Duration backfillPoll = Duration(seconds: 5);

  /// Force-clear: how long no server must have answered.
  static const Duration forceClearAfter = Duration(seconds: 60);

  /// PBKDF2-HMAC-SHA256. 100k takes ~380 ms on a 2024 Mac (JIT); each
  /// credential stores its own count, so this can be raised later.
  static const int pbkdf2Iterations = 100000;
  static const int pbkdf2SaltBytes = 16;
  static const int pbkdf2KeyBytes = 32;

  static const Duration sessionTtl = Duration(days: 30);

  /// A used session's expiry is pushed forward at most this often.
  static const Duration sessionTouchEvery = Duration(hours: 1);
  static const int sessionTokenBytes = 32;

  static const int loginFailuresPerEmail = 5;
  static const Duration loginFailureWindow = Duration(minutes: 5);
  static const int loginAttemptsPerAddressPerMinute = 30;

  /// Sent with every session request; must match the session's device.
  static const String deviceHeader = 'x-stockall-device';

  /// LAN login looks for the paired server this long before falling back
  /// to the existing Supabase / offline login.
  static const Duration loginBrowse = Duration(seconds: 3);
  static const Duration logoutTimeout = Duration(seconds: 2);
}

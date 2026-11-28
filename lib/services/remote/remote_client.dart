import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Where this device's queries and syncs go:
enum LanRoute {
  /// No LAN session for the shop: Supabase, as before LAN sync.
  standalone,

  /// This device is the shop's LAN server: its own client is Supabase.
  server,

  /// A LAN client whose server answers: everything goes to the server.
  lanUp,

  /// A LAN client on the LAN whose server doesn't answer: work offline and
  /// queue (never Supabase, which would race the server).
  lanDown,

  /// A LAN client away from the LAN: Supabase directly when online.
  offLan,
}

/// Chooses where the providers' queries go: Supabase, the shop's LAN server
/// (a LAN `SupabaseClient`, one per connection), or nowhere (offline on the
/// LAN). Web-safe: on web the route stays [LanRoute.standalone].
class RemoteRouter {
  RemoteRouter._();

  static LanRoute _route = LanRoute.standalone;
  static SupabaseClient? _lan;
  static SupabaseClient? _offline;
  static final List<VoidCallback> _listeners = [];

  static LanRoute get route => _route;

  static bool _needsCloudSignIn = false;

  /// Away from the store's network ([LanRoute.offLan]) on a device signed
  /// in only through the store server: it has no cloud session, so it
  /// can't reach Supabase. It works offline and queues until the user
  /// signs in to the cloud.
  static bool get needsCloudSignIn =>
      _route == LanRoute.offLan && _needsCloudSignIn;

  /// True while the LAN server answers (the delta syncs then send their
  /// queue-entry uuids, which only the LAN server reads).
  static bool get usingLan => _route == LanRoute.lanUp && _lan != null;

  /// Whether the backend can be reached, given whether a network interface
  /// is up: on the LAN the server's connection decides; elsewhere the
  /// interface does, as before.
  static bool reachable(bool interfaceUp) {
    switch (_route) {
      case LanRoute.lanUp:
        return _lan != null;
      case LanRoute.lanDown:
        return false;
      case LanRoute.offLan:
        return interfaceUp && !_needsCloudSignIn;
      case LanRoute.standalone:
      case LanRoute.server:
        return interfaceUp;
    }
  }

  /// [client] is the connection's LAN client; its owner disposes it when
  /// the connection ends.
  static void useLan(SupabaseClient client) {
    _set(LanRoute.lanUp, client);
  }

  /// Supabase: [LanRoute.standalone], [LanRoute.server] or
  /// [LanRoute.offLan].
  static void useSupabase([LanRoute route = LanRoute.standalone]) {
    assert(route != LanRoute.lanUp && route != LanRoute.lanDown);
    _set(route, null);
  }

  /// Off the store's network: Supabase directly, or, with [needsSignIn]
  /// (no cloud session on this device), nowhere until the user signs in.
  static void useOffLan({required bool needsSignIn}) {
    final changed = _needsCloudSignIn != needsSignIn;
    _needsCloudSignIn = needsSignIn;
    _set(LanRoute.offLan, null, force: changed);
  }

  /// On the LAN without the server: no backend.
  static void useNothing() {
    _set(LanRoute.lanDown, null);
  }

  @visibleForTesting
  static void debugUseLan(SupabaseClient lanClient) => useLan(lanClient);

  static void _set(LanRoute route, SupabaseClient? lan, {bool force = false}) {
    final changed = force || route != _route || !identical(lan, _lan);
    if (route != LanRoute.offLan) _needsCloudSignIn = false;
    _route = route;
    _lan = lan;
    if (!changed) return;
    for (final listener in List.of(_listeners)) {
      try {
        listener();
      } catch (_) {}
    }
  }

  static void addListener(VoidCallback listener) => _listeners.add(listener);
  static void removeListener(VoidCallback listener) =>
      _listeners.remove(listener);

  /// Run by `DataProvider.syncData()` before and after each online run
  /// (LAN routing: replay handoffs first off the LAN; confirm them after a
  /// run on the LAN). Errors never stop the sync.
  static Future<void> Function()? onBeforeSync;
  static Future<void> Function()? onAfterSync;

  static Future<void> beforeSync() async {
    try {
      await onBeforeSync?.call();
    } catch (_) {}
  }

  static Future<void> afterSync() async {
    try {
      await onAfterSync?.call();
    } catch (_) {}
  }

  /// A client whose every request fails as a network error, so the
  /// providers' existing offline handling runs. Made once, on first use.
  static SupabaseClient get _nowhere {
    return _offline ??= SupabaseClient(
      'https://stockall-lan.invalid',
      'offline',
      httpClient: _OfflineHttpClient(),
      accessToken: () async => null,
    );
  }
}

class _OfflineHttpClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return Future.error(
      http.ClientException(
        'The store server is not reachable; working offline',
        request.url,
      ),
    );
  }
}

/// The client every provider queries through.
SupabaseClient backend() {
  switch (RemoteRouter._route) {
    case LanRoute.lanUp:
      return RemoteRouter._lan ?? RemoteRouter._nowhere;
    case LanRoute.lanDown:
      return RemoteRouter._nowhere;
    case LanRoute.offLan:
      return RemoteRouter._needsCloudSignIn
          ? RemoteRouter._nowhere
          : Supabase.instance.client;
    case LanRoute.standalone:
    case LanRoute.server:
      return Supabase.instance.client;
  }
}

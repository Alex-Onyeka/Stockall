import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:stockall/services/lan/lan_constants.dart';
import 'package:stockall/services/lan/lan_tls.dart';

class LanEndpoint {
  const LanEndpoint(this.address, this.port);

  /// An IP address as text, possibly with a `%zone`.
  final String address;
  final int port;

  @override
  bool operator ==(Object other) =>
      other is LanEndpoint && other.address == address && other.port == port;

  @override
  int get hashCode => Object.hash(address, port);

  @override
  String toString() =>
      address.contains(':') ? '[$address]:$port' : '$address:$port';
}

/// A session token and this device's id, sent with session requests.
class LanSessionHeaders {
  const LanSessionHeaders({required this.token, required this.deviceId});
  final String token;
  final String deviceId;

  Map<String, String> get headers => {
    HttpHeaders.authorizationHeader: 'Bearer $token',
    LanConstants.deviceHeader: deviceId,
  };
}

class LanPinException implements Exception {
  const LanPinException(this.endpoint);
  final LanEndpoint endpoint;

  @override
  String toString() => 'LanPinException: certificate mismatch at $endpoint';
}

class LanHttpException implements Exception {
  const LanHttpException(this.statusCode, this.body);
  final int statusCode;
  final Map<String, dynamic> body;

  String? get errorCode => body['error'] as String?;

  @override
  String toString() => 'LanHttpException($statusCode, $body)';
}

/// Opens TCP to the real address, then TLS under the fixed name
/// [LanConstants.tlsHost]. With a [pin], any other certificate is refused,
/// during the handshake and again afterwards. A null [pin] accepts any
/// certificate and is only used for pairing and the claim preflight.
Future<SecureSocket> connectTls(
  LanEndpoint endpoint, {
  required String? pin,
  Duration timeout = LanConstants.connectTimeout,
}) async {
  // Always re-parsed from text: reused InternetAddress objects lose scope.
  final socket = await Socket.connect(
    InternetAddress(endpoint.address),
    endpoint.port,
    timeout: timeout,
  );
  try {
    final secure = await SecureSocket.secure(
      socket,
      host: LanConstants.tlsHost,
      onBadCertificate: (cert) => pin == null || pinMatches(cert, pin),
    ).timeout(timeout);
    final peer = secure.peerCertificate;
    if (peer == null || (pin != null && !pinMatches(peer, pin))) {
      secure.destroy();
      throw LanPinException(endpoint);
    }
    return secure;
  } catch (_) {
    socket.destroy();
    rethrow;
  }
}

class LanRaceWinner {
  const LanRaceWinner(this.endpoint, this.socket);
  final LanEndpoint endpoint;
  final SecureSocket socket;
}

/// Tries [endpoints] in parallel, each started [stagger] after the previous
/// one, and returns the first that completes TLS (with the pin). The losers
/// are closed. Returns null when every attempt fails.
Future<LanRaceWinner?> raceConnect(
  List<LanEndpoint> endpoints, {
  required String? pin,
  Duration stagger = LanConstants.raceStagger,
  Duration timeout = LanConstants.connectTimeout,
}) {
  if (endpoints.isEmpty) return Future.value(null);
  final done = Completer<LanRaceWinner?>();
  var pending = endpoints.length;
  for (var i = 0; i < endpoints.length; i++) {
    final endpoint = endpoints[i];
    Future<void>.delayed(stagger * i, () async {
      try {
        if (done.isCompleted) return;
        final socket = await connectTls(endpoint, pin: pin, timeout: timeout);
        if (done.isCompleted) {
          socket.destroy();
        } else {
          done.complete(LanRaceWinner(endpoint, socket));
        }
      } catch (_) {
        // This attempt failed; the others may still win.
      } finally {
        pending--;
        if (pending == 0 && !done.isCompleted) done.complete(null);
      }
    });
  }
  return done.future;
}

/// TCP-only probe of [hosts] on [ports]. Returns the endpoints that accept
/// a connection; TLS and the pin are checked afterwards by [raceConnect].
Future<List<LanEndpoint>> tcpSweep(
  List<String> hosts,
  List<int> ports, {
  int concurrency = LanConstants.sweepConcurrency,
  Duration timeout = LanConstants.sweepTimeout,
}) async {
  final queue = [
    for (final host in hosts)
      for (final port in ports) LanEndpoint(host, port),
  ];
  final open = <LanEndpoint>[];
  var next = 0;
  Future<void> worker() async {
    while (next < queue.length) {
      final endpoint = queue[next++];
      try {
        final socket = await Socket.connect(
          InternetAddress(endpoint.address),
          endpoint.port,
          timeout: timeout,
        );
        socket.destroy();
        open.add(endpoint);
      } catch (_) {
        // Closed or unreachable.
      }
    }
  }

  await Future.wait(List.generate(concurrency, (_) => worker()));
  return open;
}

/// A pinned connection to a LAN server over one of several addresses.
/// Every request goes through `connectionFactory`: the URL is always
/// `https://stockall-lan:<port>/…` and the socket is opened to the current
/// address. When the address stops working, it fails over to the others.
class LanConnection {
  LanConnection._(
    List<LanEndpoint> endpoints,
    this._current,
    this._pin,
    this._refresh,
  ) : _endpoints = List.of(endpoints) {
    _client = _newClient();
  }

  final String _pin;
  final Future<List<LanEndpoint>> Function()? _refresh;
  List<LanEndpoint> _endpoints;
  LanEndpoint _current;
  late HttpClient _client;
  bool _closed = false;

  String get pin => _pin;
  LanEndpoint get current => _current;

  /// The pinned client every request goes through. Replaced by
  /// [failover], so read it per request; never close it.
  HttpClient get httpClient => _client;
  List<LanEndpoint> get endpoints => List.unmodifiable(_endpoints);

  /// Connects with a known [pin].
  static Future<LanConnection?> open(
    List<LanEndpoint> endpoints, {
    required String pin,
    Future<List<LanEndpoint>> Function()? refresh,
    Duration stagger = LanConstants.raceStagger,
  }) async {
    final winner = await raceConnect(endpoints, pin: pin, stagger: stagger);
    if (winner == null) return null;
    winner.socket.destroy();
    return LanConnection._(
      _winnerFirst(endpoints, winner.endpoint),
      winner.endpoint,
      pin.toLowerCase(),
      refresh,
    );
  }

  /// Trust on first use, for pairing and the claim preflight only: the
  /// certificate seen on the first connection is pinned for the rest.
  static Future<LanConnection?> openUnpinned(
    List<LanEndpoint> endpoints, {
    Duration stagger = LanConstants.raceStagger,
  }) async {
    final winner = await raceConnect(endpoints, pin: null, stagger: stagger);
    if (winner == null) return null;
    final peer = winner.socket.peerCertificate;
    winner.socket.destroy();
    if (peer == null) return null;
    return LanConnection._(
      _winnerFirst(endpoints, winner.endpoint),
      winner.endpoint,
      fingerprintOfDer(peer.der),
      null,
    );
  }

  static List<LanEndpoint> _winnerFirst(
    List<LanEndpoint> endpoints,
    LanEndpoint winner,
  ) {
    return [winner, ...endpoints.where((e) => e != winner)];
  }

  HttpClient _newClient() {
    return HttpClient()
      ..connectionTimeout = LanConstants.connectTimeout
      ..badCertificateCallback = ((cert, host, port) => pinMatches(cert, _pin))
      ..connectionFactory = (uri, proxyHost, proxyPort) async {
        return ConnectionTask.fromSocket(
          connectTls(_current, pin: _pin),
          () {},
        );
      };
  }

  Uri _uri(String path) {
    return Uri(
      scheme: 'https',
      host: LanConstants.tlsHost,
      port: _current.port,
      path: path,
    );
  }

  /// With a [session], the request carries `Authorization: Bearer` and the
  /// device header.
  Future<Map<String, dynamic>> getJson(
    String path, {
    LanSessionHeaders? session,
  }) => _send('GET', path, null, session);

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body, {
    LanSessionHeaders? session,
  }) => _send('POST', path, body, session);

  Future<Map<String, dynamic>> _send(
    String method,
    String path,
    Map<String, dynamic>? body,
    LanSessionHeaders? session,
  ) async {
    try {
      return await _sendOnce(method, path, body, session);
    } on LanHttpException {
      rethrow;
    } on FormatException {
      rethrow;
    } catch (_) {
      if (_closed || !await failover()) rethrow;
      return _sendOnce(method, path, body, session);
    }
  }

  Future<Map<String, dynamic>> _sendOnce(
    String method,
    String path,
    Map<String, dynamic>? body,
    LanSessionHeaders? session,
  ) async {
    final request = await _client
        .openUrl(method, _uri(path))
        .timeout(LanConstants.requestTimeout);
    session?.headers.forEach(request.headers.set);
    if (body != null) {
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(body));
    }
    final response = await request.close().timeout(
      LanConstants.requestTimeout,
    );
    final text = await utf8
        .decodeStream(response)
        .timeout(LanConstants.requestTimeout);
    final decoded = text.isEmpty ? <String, dynamic>{} : jsonDecode(text);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected a JSON object');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LanHttpException(response.statusCode, decoded);
    }
    return decoded;
  }

  Future<WebSocket> openWebSocket({LanSessionHeaders? session}) async {
    final ws = await WebSocket.connect(
      'wss://${LanConstants.tlsHost}:${_current.port}/v1/ws',
      headers: session?.headers,
      customClient: _client,
    ).timeout(LanConstants.requestTimeout);
    ws.pingInterval = LanConstants.wsPing;
    return ws;
  }

  /// Re-races the other addresses (the current one last), then, if they
  /// all fail, addresses refreshed from discovery. Returns whether a
  /// working address was found.
  Future<bool> failover() async {
    if (_closed) return false;
    final ordered = [..._endpoints.where((e) => e != _current), _current];
    var winner = await raceConnect(ordered, pin: _pin);
    if (winner == null && _refresh != null) {
      final fresh = await _refresh();
      if (fresh.isNotEmpty) {
        _endpoints = [
          ...fresh,
          ..._endpoints.where((e) => !fresh.contains(e)),
        ];
        winner = await raceConnect(fresh, pin: _pin);
      }
    }
    if (winner == null) return false;
    winner.socket.destroy();
    _current = winner.endpoint;
    _endpoints = _winnerFirst(_endpoints, winner.endpoint);
    // Pooled keep-alive sockets may point at the dead address.
    _client.close(force: true);
    _client = _newClient();
    return true;
  }

  void close() {
    _closed = true;
    _client.close(force: true);
  }
}

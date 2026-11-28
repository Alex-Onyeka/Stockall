import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:stockall/services/lan/lan_access_policy.dart';
import 'package:stockall/services/lan/lan_auth_server.dart';
import 'package:stockall/services/lan/lan_constants.dart';
import 'package:stockall/services/lan/lan_device_admission.dart';
import 'package:stockall/services/lan/lan_handoffs.dart';
import 'package:stockall/services/lan/lan_pairing.dart';
import 'package:stockall/services/lan/lan_tls.dart';
import 'package:stockall/services/lan/rest/lan_logo_storage.dart';
import 'package:stockall/services/lan/rest/lan_rest_handler.dart';
import 'package:stockall/services/lan/rest/postgrest_request.dart';
import 'package:stockall/services/lan/rest/postgrest_response.dart';

/// The LAN server's HTTPS + WebSocket endpoint:
/// `GET /v1/hello`, `GET /v1/server`, `POST /v1/pair/{start,reveal,confirm,abort}`,
/// `POST /v1/auth/{login,logout,verify-password}`, `GET /v1/ws` and, with a
/// session, `GET /v1/handoff/status` and `POST /v1/handoff/handed-over`.
/// With [auth], `/v1/ws` needs a session and `/v1/server` returns the full
/// record to a session. Callers decide whether this device may serve; this
/// class only binds and answers.
class LanServer {
  LanServer({
    required this.identity,
    required this.deviceId,
    required this.serverView,
    this.fullServerView,
    this.auth,
    this.rest,
    this.storage,
    this.handoffStatus,
    this.onPairingChanged,
    this.onDeviceOnline,
    this.onDeviceOffline,
    this.peerProof,
    this.onSuperseded,
    this.onHandedOver,
    this.handedOver,
    this.admission,
    this.acceptMoved,
    this.onSteppingDown,
    this.onRefreshCredentials,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       pairing = LanPairingServer(
         fingerprint: identity.fingerprint,
         clock: clock,
       );

  final LanTlsIdentity identity;
  final String deviceId;

  /// The reduced record for `GET /v1/server` and ws events.
  final Map<String, dynamic> Function() serverView;

  /// The full record for `GET /v1/server` with a session.
  final Map<String, dynamic> Function()? fullServerView;
  final LanAuthService? auth;

  /// Answers `/rest/v1/*` (PostgREST subset) for signed-in members.
  final LanRestHandler? rest;

  /// `/storage/v1/...` (the shop logo).
  final LanStorageHandler? storage;

  /// Whether what the server acknowledged has reached Supabase
  /// (handoffs); its `now()` stamps every `/rest/v1` answer.
  final LanHandoffStatusSource? handoffStatus;
  final void Function()? onPairingChanged;

  /// A signed-in device's WebSocket opened / closed (each socket; the
  /// stock service counts them).
  final void Function(String deviceId)? onDeviceOnline;
  final void Function(String deviceId)? onDeviceOffline;

  /// `POST /v1/peer/prove {nonce}` → `{view, mac}`, for another
  /// server of the shop (no session). Null: not offered.
  final Map<String, dynamic>? Function(String nonce)? peerProof;

  /// `POST /v1/server/superseded`: a device says another server
  /// outranks this one. The handler proves that server itself; the notice
  /// is never trusted alone.
  final void Function(Map<String, dynamic> body)? onSuperseded;

  /// `POST /v1/handoff/handed-over {epoch}` from a former server
  /// of the shop, signed in here as a client: everything it acknowledged
  /// while it served at that epoch is here or in Supabase. Only the device
  /// itself says so (its session's device). Then tills are told
  /// (`{type: handed_over}`).
  final Future<void> Function(String deviceId, int epoch)? onHandedOver;

  /// The former servers that handed over, for `GET /v1/handoff/status`.
  final List<Map<String, dynamic>> Function()? handedOver;
  final LanPairingServer pairing;

  /// The devices that paired here. With it, only they may call
  /// `/v1/auth/login` (with the secret they got when they paired); null:
  /// anyone may.
  final LanDeviceAdmission? admission;

  /// Whether a `moved` event presented at login lets [deviceId] in: signed
  /// by a former server of the shop this one outranks, naming this server
  /// and listing the device as paired there.
  final bool Function(Map<String, dynamic> moved, String deviceId)? acceptMoved;

  /// `POST /v1/server/stepping-down`: a server of the shop stops for this
  /// one. Awaited before the answer, so it can be proven while it still
  /// serves.
  final Future<void> Function(Map<String, dynamic> body)? onSteppingDown;

  /// `POST /v1/auth/refresh`: a paired till signed in with a password this
  /// server refused (the cloud took it), so the logins are fetched again.
  /// At most once per [LanConstants.credentialRefreshGap]; not awaited.
  final Future<void> Function()? onRefreshCredentials;
  DateTime? _lastRefresh;

  final DateTime Function() _clock;

  /// Tokens shown in the pairing QR code, until they expire.
  final Map<String, DateTime> _qrTokens = {};
  static const Duration qrTokenFor = Duration(minutes: 10);

  /// A token for the pairing QR code: a device that scans it may pair for
  /// [qrTokenFor].
  String issueQrToken() {
    final now = _clock();
    _qrTokens.removeWhere((_, until) => !until.isAfter(now));
    final random = Random.secure();
    final token = base64Url
        .encode([for (var i = 0; i < 24; i++) random.nextInt(256)])
        .replaceAll('=', '');
    _qrTokens[token] = now.add(qrTokenFor);
    return token;
  }

  HttpServer? _server;
  final Set<WebSocket> _sockets = {};

  bool get isRunning => _server != null;
  int? get port => _server?.port;
  int get connectedSockets => _sockets.length;

  /// Binds dual-stack on every interface, on the first free port of
  /// [ports]. Returns the port.
  Future<int> start({List<int> ports = LanConstants.allPorts}) async {
    if (_server != null) return _server!.port;
    final context = identity.serverContext();
    HttpServer? bound;
    for (final candidate in ports) {
      try {
        bound = await HttpServer.bindSecure(
          InternetAddress.anyIPv6,
          candidate,
          context,
          v6Only: false,
        );
        break;
      } on SocketException {
        continue;
      }
    }
    if (bound == null) {
      throw StateError('No free LAN server port in $ports');
    }
    bound.autoCompress = true;
    bound.listen(_handle, onError: (Object _) {});
    _server = bound;
    return bound.port;
  }

  /// Sends a `server` event to every connected WebSocket.
  void broadcastServerEvent() => broadcast(_serverEvent());

  /// Sends [event] to every connected WebSocket (e.g. `{type: synced}`
  /// when the server's queues have reached Supabase).
  void broadcast(Map<String, dynamic> event) {
    final message = jsonEncode(event);
    for (final ws in _sockets.toList()) {
      try {
        ws.add(message);
      } catch (_) {
        _sockets.remove(ws);
      }
    }
  }

  Future<void> stop() async {
    final server = _server;
    _server = null;
    for (final ws in _sockets.toList()) {
      try {
        await ws.close(WebSocketStatus.goingAway);
      } catch (_) {}
    }
    _sockets.clear();
    pairing.cancel();
    await server?.close(force: true);
  }

  Map<String, dynamic> _serverEvent() {
    final view = serverView();
    return {
      'type': 'server',
      'epoch': view['epoch'],
      'cleared': view['cleared'],
    };
  }

  Future<void> _handle(HttpRequest request) async {
    try {
      final path = request.uri.path;
      if (path == '/v1/ws') {
        await _upgrade(request);
        return;
      }
      if (request.method == 'GET' && path == '/v1/hello') {
        await _json(request, 200, {
          'v': LanConstants.protocolVersion,
          'device_id': deviceId,
          'tls_name': LanConstants.tlsHost,
        });
        return;
      }
      if (request.method == 'GET' && path == '/v1/server') {
        final full = fullServerView;
        final principal = await _principal(request);
        await _json(
          request,
          200,
          principal != null && full != null ? full() : serverView(),
        );
        return;
      }
      if (request.method == 'POST' && path == '/v1/peer/prove') {
        final prove = peerProof;
        final body = await _readJson(request);
        final nonce = body['nonce'];
        if (nonce is! String || nonce.isEmpty || nonce.length > 128) {
          await _json(request, 400, {'error': 'bad_nonce'});
          return;
        }
        final answer = prove?.call(nonce);
        await _json(
          request,
          answer == null ? 404 : 200,
          answer ?? {'error': 'not_found'},
        );
        return;
      }
      if (request.method == 'POST' && path == '/v1/server/stepping-down') {
        final handler = onSteppingDown;
        if (handler == null) {
          await _json(request, 404, {'error': 'not_found'});
          return;
        }
        await handler(await _readJson(request));
        await _json(request, 200, {'ok': true});
        return;
      }
      if (request.method == 'POST' && path == '/v1/server/superseded') {
        final handler = onSuperseded;
        if (handler == null) {
          await _json(request, 404, {'error': 'not_found'});
          return;
        }
        handler(await _readJson(request));
        await _json(request, 202, {'ok': true});
        return;
      }
      if (request.method == 'GET' && path == '/v1/handoff/status') {
        final source = handoffStatus;
        if (source == null) {
          await _json(request, 404, {'error': 'not_found'});
        } else if (await _principal(request) == null) {
          await _json(request, 401, {'error': 'session_invalid'});
        } else {
          final view = serverView();
          await _json(request, 200, {
            ...source.status(
              serverDeviceId: deviceId,
              epoch: view['epoch'] as int? ?? 0,
            ),
            if (handedOver case final list?) 'handed_over': list(),
          });
        }
        return;
      }
      if (request.method == 'POST' && path == '/v1/handoff/handed-over') {
        final handler = onHandedOver;
        final principal = handler == null ? null : await _principal(request);
        if (handler == null) {
          await _json(request, 404, {'error': 'not_found'});
          return;
        }
        if (principal == null) {
          await _json(request, 401, {'error': 'session_invalid'});
          return;
        }
        final body = await _readJson(request);
        final epoch = body['epoch'];
        final from = principal.deviceId;
        if (epoch is! int ||
            epoch < 1 ||
            from == null ||
            from.isEmpty ||
            from == deviceId) {
          await _json(request, 400, {'error': 'bad_request'});
          return;
        }
        await handler(from, epoch);
        broadcast({
          'type': LanConstants.handedOverEvent,
          'server_device_id': from,
          'epoch': epoch,
        });
        await _json(request, 200, {'ok': true});
        return;
      }
      if (request.method == 'POST' && path.startsWith('/v1/auth/')) {
        await _auth(request, path.substring('/v1/auth/'.length));
        return;
      }
      if (path.startsWith('/rest/v1/')) {
        await _rest(request, path.substring('/rest/v1/'.length));
        return;
      }
      if (path.startsWith('/storage/v1/')) {
        await _storage(request, path.substring('/storage/v1/'.length));
        return;
      }
      if (request.method == 'POST' && path.startsWith('/v1/pair/')) {
        await _pair(request, path.substring('/v1/pair/'.length));
        return;
      }
      await _json(request, 404, {'error': 'not_found'});
    } catch (_) {
      try {
        await _json(request, 500, {'error': 'internal'});
      } catch (_) {}
    }
  }

  Future<void> _upgrade(HttpRequest request) async {
    if (!WebSocketTransformer.isUpgradeRequest(request)) {
      await _json(request, 426, {'error': 'upgrade_required'});
      return;
    }
    final principal = auth == null ? null : await _principal(request);
    if (auth != null && principal == null) {
      await _json(request, 401, {'error': 'session_invalid'});
      return;
    }
    final ws = await WebSocketTransformer.upgrade(request);
    ws.pingInterval = LanConstants.wsPing;
    _sockets.add(ws);
    // The session's device: its stock holds last while it has a socket.
    final device = principal?.deviceId;
    if (device != null) onDeviceOnline?.call(device);
    var closed = false;
    void gone() {
      _sockets.remove(ws);
      if (closed) return;
      closed = true;
      if (device != null) onDeviceOffline?.call(device);
    }

    ws.add(jsonEncode(_serverEvent()));
    ws.listen(
      (_) {},
      onDone: gone,
      onError: (Object _) => gone(),
      cancelOnError: true,
    );
  }

  Future<void> _pair(HttpRequest request, String action) async {
    try {
      final body = await _readJson(request);
      switch (action) {
        case 'start':
          final started = pairing.start(
            deviceId: _string(body, 'device_id'),
            commit: _string(body, 'commit'),
          );
          onPairingChanged?.call();
          await _json(request, 200, {
            'session_id': started.sessionId,
            'ns': started.ns,
          });
          return;
        case 'reveal':
          pairing.reveal(
            sessionId: _string(body, 'session_id'),
            nc: _string(body, 'nc'),
          );
          onPairingChanged?.call();
          await _json(request, 200, {'ok': true});
          return;
        case 'confirm':
          final device = pairing.confirm(
            sessionId: _string(body, 'session_id'),
            proof: _string(body, 'proof'),
          );
          final secret = await admission?.admit(device);
          onPairingChanged?.call();
          await _json(request, 200, {
            'ok': true,
            if (secret != null) 'pair_secret': secret,
          });
          return;
        case 'qr':
          // A device that scanned the QR code shown here.
          final admitted = admission;
          final token = _string(body, 'token');
          final device = _string(body, 'device_id');
          final until = _qrTokens[token];
          if (admitted == null ||
              until == null ||
              !until.isAfter(_clock()) ||
              device.length > 128) {
            await _json(request, 403, {'error': 'not_paired'});
            return;
          }
          final secret = await admitted.admit(device);
          onPairingChanged?.call();
          await _json(request, 200, {'ok': true, 'pair_secret': secret});
          return;
        case 'abort':
          pairing.abort(sessionId: _string(body, 'session_id'));
          onPairingChanged?.call();
          await _json(request, 200, {'ok': true});
          return;
      }
      await _json(request, 404, {'error': 'not_found'});
    } on LanPairingError catch (e) {
      onPairingChanged?.call();
      await _json(request, e.httpStatus, {'error': e.code});
    } on FormatException {
      await _json(request, 400, {'error': 'bad_request'});
    }
  }

  /// Only a paired device may ask, and not more often than the gap.
  Future<void> _refreshCredentials(
    HttpRequest request,
    Map<String, dynamic> body,
  ) async {
    final admitted = admission;
    final refresh = onRefreshCredentials;
    if (admitted == null || refresh == null) {
      await _json(request, 404, {'error': 'not_found'});
      return;
    }
    final device = body['device_id'];
    final secret = body['pair_secret'];
    if (device is! String ||
        !admitted.admitted(device, secret is String ? secret : null)) {
      await _json(request, 403, {'error': 'not_paired'});
      return;
    }
    final now = _clock();
    final last = _lastRefresh;
    if (last != null &&
        now.difference(last) < LanConstants.credentialRefreshGap) {
      await _json(request, 429, {'error': 'rate_limited'});
      return;
    }
    _lastRefresh = now;
    // The callback logs its own failures.
    unawaited(refresh().catchError((Object _) {}));
    await _json(request, 202, {'refreshing': true});
  }

  Future<void> _auth(HttpRequest request, String action) async {
    final service = auth;
    if (service == null) {
      await _json(request, 404, {'error': 'not_found'});
      return;
    }
    final Map<String, dynamic> body;
    try {
      body = await _readJson(request);
    } on LanPairingError {
      await _json(request, 400, {'error': 'bad_request'});
      return;
    } on FormatException {
      await _json(request, 400, {'error': 'bad_request'});
      return;
    }
    final remote = request.connectionInfo?.remoteAddress.address ?? '';
    if (action == 'refresh') {
      await _refreshCredentials(request, body);
      return;
    }
    if (action == 'login') {
      // Only a paired device: its secret, or a move signed by a former
      // server it was paired with (then it gets a secret here).
      final admitted = admission;
      final device = body['device_id'];
      var viaMove = false;
      if (admitted != null) {
        final secret = body['pair_secret'];
        final moved = body['moved'];
        final paired =
            device is String &&
            admitted.admitted(device, secret is String ? secret : null);
        viaMove =
            !paired &&
            device is String &&
            moved is Map &&
            (acceptMoved?.call(Map<String, dynamic>.from(moved), device) ??
                false);
        if (!paired && !viaMove) {
          await _json(request, 403, {'error': 'not_paired'});
          return;
        }
      }
      final answer = await service.login(body, remoteAddress: remote);
      if (viaMove && answer.status == 200 && admitted != null) {
        final secret = await admitted.admit(device as String);
        onPairingChanged?.call();
        await _send(
          request,
          LanAuthResponse(200, {...answer.body, 'pair_secret': secret}),
        );
        return;
      }
      await _send(request, answer);
      return;
    }
    final principal = await _principal(request);
    if (principal == null) {
      await _json(request, 401, {'error': 'session_invalid'});
      return;
    }
    switch (action) {
      case 'logout':
        await _send(request, await service.logout(_bearer(request)!));
        return;
      case 'verify-password':
        await _send(
          request,
          await service.verifyPasswordFor(
            principal,
            body,
            remoteAddress: remote,
          ),
        );
        return;
    }
    await _json(request, 404, {'error': 'not_found'});
  }

  /// PostgREST subset. Every error goes out in PostgREST's JSON shape, so
  /// postgrest-dart throws the matching `PostgrestException`.
  Future<void> _rest(HttpRequest request, String path) async {
    PgResponse response;
    try {
      final handler = rest;
      if (handler == null) throw PgError.unknownTable(path);
      final principal = await _principal(request);
      if (principal == null) throw PgError.unauthorized();
      final pgRequest = parsePgRequest(
        method: request.method,
        path: path,
        query: request.uri.queryParametersAll,
        rawQuery: request.uri.query,
        headers: {
          for (final name in const ['prefer', 'accept'])
            if (request.headers.value(name) != null)
              name: request.headers.value(name)!,
        },
        body: await _readRestBody(request),
      );
      response = await handler.handle(pgRequest, principal);
    } on PgError catch (e) {
      response = PgResponse.error(e);
    } catch (_) {
      response = PgResponse.error(
        const PgError(500, 'LAN500', 'LAN server error'),
      );
    }
    final out = request.response..statusCode = response.status;
    response.headers.forEach(out.headers.set);
    // After the write was queued: a handoff stamped with this time is
    // covered once the server's queues were empty at or after it.
    final clock = handoffStatus;
    if (clock != null) {
      out.headers.set(LanConstants.serverTimeHeader, '${clock.now()}');
    }
    final body = response.body;
    if (body != null && request.method != 'HEAD') {
      out.headers.contentType = ContentType.json;
      out.write(jsonEncode(body));
    }
    await out.close();
  }

  Future<void> _storage(HttpRequest request, String path) async {
    LanStorageResponse response;
    try {
      final handler = storage;
      final principal = await _principal(request);
      if (handler == null) {
        response = LanStorageResponse.error(404, 'not_found', 'No storage');
      } else if (principal == null) {
        response = LanStorageResponse.error(
          401,
          'Unauthorized',
          'LAN session missing or invalid',
        );
      } else {
        final body = BytesBuilder(copy: false);
        var tooLarge = false;
        await for (final chunk in request) {
          body.add(chunk);
          if (body.length > LanConstants.maxRestBodyBytes) {
            tooLarge = true;
            break;
          }
        }
        if (tooLarge) {
          response = LanStorageResponse.error(
            413,
            'Payload too large',
            'Request body too large',
          );
        } else {
          final headers = <String, String>{};
          request.headers.forEach((name, values) {
            headers[name.toLowerCase()] = values.join(',');
          });
          response = await handler.handle(
            LanStorageRequest(
              method: request.method,
              path: Uri.decodeFull(path),
              headers: headers,
              body: body.takeBytes(),
            ),
            principal,
          );
        }
      }
    } catch (_) {
      response = LanStorageResponse.error(500, 'LAN500', 'LAN server error');
    }
    final out = request.response..statusCode = response.status;
    final type = response.contentType;
    if (type != null) out.headers.set(HttpHeaders.contentTypeHeader, type);
    if (request.method != 'HEAD') out.add(response.body);
    await out.close();
  }

  Future<Object?> _readRestBody(HttpRequest request) async {
    final builder = BytesBuilder(copy: false);
    await for (final chunk in request) {
      builder.add(chunk);
      if (builder.length > LanConstants.maxRestBodyBytes) {
        throw const PgError(413, 'PGRST413', 'Request body too large');
      }
    }
    if (builder.isEmpty) return null;
    try {
      return jsonDecode(utf8.decode(builder.takeBytes()));
    } on FormatException {
      throw const PgError(400, 'PGRST102', 'Invalid JSON body');
    }
  }

  String? _bearer(HttpRequest request) {
    final header = request.headers.value(HttpHeaders.authorizationHeader);
    if (header == null || !header.startsWith('Bearer ')) return null;
    final token = header.substring('Bearer '.length).trim();
    return token.isEmpty ? null : token;
  }

  Future<LanPrincipal?> _principal(HttpRequest request) async {
    final service = auth;
    if (service == null) return null;
    return service.principal(
      token: _bearer(request),
      deviceId: request.headers.value(LanConstants.deviceHeader),
    );
  }

  Future<void> _send(HttpRequest request, LanAuthResponse response) {
    return _json(request, response.status, response.body);
  }

  String _string(Map<String, dynamic> body, String key) {
    final value = body[key];
    if (value is! String || value.isEmpty || value.length > 256) {
      throw const LanPairingError('bad_request');
    }
    return value;
  }

  Future<Map<String, dynamic>> _readJson(HttpRequest request) async {
    final builder = BytesBuilder(copy: false);
    await for (final chunk in request) {
      builder.add(chunk);
      if (builder.length > LanConstants.maxRequestBodyBytes) {
        throw const LanPairingError('bad_request');
      }
    }
    if (builder.isEmpty) return {};
    final decoded = jsonDecode(utf8.decode(builder.takeBytes()));
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected a JSON object');
    }
    return decoded;
  }

  Future<void> _json(
    HttpRequest request,
    int status,
    Map<String, dynamic> body,
  ) async {
    request.response
      ..statusCode = status
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(body));
    await request.response.close();
  }
}

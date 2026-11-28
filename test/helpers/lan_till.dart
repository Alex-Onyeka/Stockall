/// A till of the shop seen only from the network: it pairs with a
/// store server over the real protocol (typing the code the server shows),
/// signs in, keeps its WebSocket's events, and holds, releases and checks
/// out stock through the LAN API, as the app's client does. In-process, so
/// a test can run several next to the app.
library;

import 'dart:convert';
import 'dart:io';

import 'package:stockall/services/lan/lan_connection.dart';
import 'package:stockall/services/lan/lan_constants.dart';
import 'package:stockall/services/lan/lan_pairing.dart';
import 'package:stockall/services/remote/lan_remote.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LanTill {
  LanTill(this.deviceId);

  final String deviceId;

  /// What the server gave this till when it paired (it signs in with it).
  String? pairSecret;

  /// The server's certificate, once paired.
  String? pin;
  String? token;
  SupabaseClient? lan;

  /// Every event its socket received, oldest first.
  final events = <Map<String, dynamic>>[];

  LanConnection? _pairingConnection;
  LanPairingClient? _pairing;
  LanConnection? _connection;
  WebSocket? _socket;

  /// Starts pairing with the server at 127.0.0.1:[port]. Returns the code
  /// this till expects the server to show.
  Future<String> startPairing(int port) async {
    _pairingConnection?.close();
    final connection = (await LanConnection.openUnpinned([
      LanEndpoint('127.0.0.1', port),
    ]))!;
    _pairingConnection = connection;
    final pairing = LanPairingClient(
      deviceId: deviceId,
      fingerprintSeen: connection.pin,
    );
    final started = await connection.postJson('/v1/pair/start', {
      'device_id': deviceId,
      'commit': pairing.commit,
    });
    pairing.started(
      sessionId: started['session_id'] as String,
      ns: started['ns'] as String,
    );
    await connection.postJson('/v1/pair/reveal', {
      'session_id': pairing.sessionId,
      'nc': pairing.nc,
    });
    _pairing = pairing;
    return pairing.expectedCode;
  }

  /// Types [code] (read off the server): when it matches, the pairing is
  /// confirmed and the server's certificate kept; otherwise the attempt
  /// ends and nothing is kept, as in the app.
  Future<bool> typeCode(String code) async {
    final pairing = _pairing!;
    final connection = _pairingConnection!;
    _pairing = null;
    _pairingConnection = null;
    try {
      if (!pairing.matches(code)) {
        // As the app does: the server ends the session at once.
        await connection.postJson('/v1/pair/abort', {
          'session_id': pairing.sessionId,
        });
        return false;
      }
      final confirmed = await connection.postJson('/v1/pair/confirm', {
        'session_id': pairing.sessionId,
        'proof': pairing.proof,
      });
      pin = connection.pin;
      pairSecret = confirmed['pair_secret'] as String?;
      return true;
    } finally {
      connection.close();
    }
  }

  /// Signs in on the paired server at 127.0.0.1:[port]. Null when signed
  /// in, else the server's error code.
  Future<String?> signIn(
    int port, {
    String email = 'ada@shop.test',
    String password = 'right',
  }) async {
    _connection?.close();
    final connection = (await LanConnection.open([
      LanEndpoint('127.0.0.1', port),
    ], pin: pin!))!;
    _connection = connection;
    try {
      final login = await connection.postJson('/v1/auth/login', {
        'email': email,
        'password': password,
        'device_id': deviceId,
        if (pairSecret != null) 'pair_secret': pairSecret,
      });
      token = login['token'] as String;
    } on LanHttpException catch (e) {
      return e.errorCode ?? 'HTTP ${e.statusCode}';
    }
    lan = createLanRemote(
      connection: connection,
      token: token!,
      deviceId: deviceId,
    );
    return null;
  }

  LanSessionHeaders get session =>
      LanSessionHeaders(token: token!, deviceId: deviceId);

  Future<Map<String, dynamic>> serverView() =>
      _connection!.getJson('/v1/server', session: session);

  /// Opens its socket (the server counts it connected).
  Future<void> openSocket() async {
    final socket = await _connection!.openWebSocket(session: session);
    _socket = socket;
    socket.listen(
      (m) => events.add(jsonDecode(m as String) as Map<String, dynamic>),
      onError: (_) {},
    );
  }

  /// The till goes away: its socket closes without a word.
  Future<void> dropSocket() async {
    await _socket?.close();
    _socket = null;
  }

  bool heard(bool Function(Map<String, dynamic> event) matches) =>
      events.any(matches);

  /// Whether a `stock` event said [product]'s held total is [total].
  bool heardHeld(String product, double total) => heard(
    (e) =>
        e['type'] == 'stock' &&
        (e['reserved'] as Map?)?[product] == total,
  );

  /// Holds [quantity] of [product] for [cart]: the server's answer for it.
  Future<Map<String, dynamic>> hold(
    String cart,
    String product,
    double quantity,
  ) async {
    final res =
        await lan!.rpc(
              LanConstants.stockReserveRpc,
              params: {
                'holds': [
                  {
                    'cart_id': cart,
                    'product_uuid': product,
                    'quantity': quantity,
                  },
                ],
              },
            )
            as Map;
    return Map<String, dynamic>.from((res['holds'] as List).single as Map);
  }

  /// Releases [cart]'s holds, or all of this till's.
  Future<void> release({String? cart}) => lan!.rpc(
    LanConstants.stockReleaseRpc,
    params: {if (cart != null) 'cart_id': cart},
  );

  /// Checks out [cart] as a sale of [quantity] of [product], with the
  /// stock change [changeUuid].
  Future<Map<String, dynamic>> checkout(
    String cart, {
    required String changeUuid,
    required String product,
    required double quantity,
  }) async =>
      Map<String, dynamic>.from(
        await lan!.rpc(
              LanConstants.stockCheckoutRpc,
              params: {
                'cart_id': cart,
                'receipt_uuid': cart,
                'updates': [
                  {
                    'hiveUuid': changeUuid,
                    'itemUuid': product,
                    'quantity': quantity,
                    'isIncrement': false,
                  },
                ],
              },
            )
            as Map,
      );

  Future<void> close() async {
    await dropSocket();
    await lan?.dispose();
    lan = null;
    _connection?.close();
    _connection = null;
    _pairingConnection?.close();
    _pairingConnection = null;
  }
}

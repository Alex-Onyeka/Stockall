/// Another store server of the same shop, in its own isolate and Hive (as
/// on another machine), for the two-server tests: it serves `products`, the
/// quantity RPCs and cart stock holds, signs in ada@shop.test / right,
/// proves its claim, can look for and notify an outranked server itself,
/// and can hand its clients over to another server (`moved`) or vanish.
library;

import 'dart:io';
import 'dart:isolate';

import 'package:hive/hive.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/local_database/hive_adapters_registry.dart';
import 'package:stockall/local_database/lan/lan_applied_deltas_func.dart';
import 'package:stockall/local_database/lan/lan_credentials_func.dart';
import 'package:stockall/local_database/lan/lan_deleted_items_func.dart';
import 'package:stockall/local_database/lan/lan_server_sessions_func.dart';
import 'package:stockall/local_database/lan/lan_shop_keys_func.dart';
import 'package:stockall/local_database/lan/lan_stock_holds_func.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/quantity_update/quantity_update_func.dart';
import 'package:stockall/services/lan/lan_auth_server.dart';
import 'package:stockall/services/lan/lan_codes.dart';
import 'package:stockall/services/lan/lan_connection.dart';
import 'package:stockall/services/lan/lan_handoffs.dart';
import 'package:stockall/services/lan/lan_peer_client.dart';
import 'package:stockall/services/lan/lan_move_proof.dart';
import 'package:stockall/services/lan/lan_peer_proof.dart';
import 'package:stockall/services/lan/lan_server.dart';
import 'package:stockall/services/lan/lan_server_watch.dart';
import 'package:stockall/services/lan/lan_tls.dart';
import 'package:stockall/services/lan/lan_transport_types.dart';
import 'package:stockall/services/lan/lan_user_backfill.dart';
import 'package:stockall/services/lan/rest/hive_rest_engine.dart';
import 'package:stockall/services/lan/rest/lan_delta_registry.dart';
import 'package:stockall/services/lan/rest/lan_delta_rpcs.dart';
import 'package:stockall/services/lan/rest/lan_table_registry.dart';
import 'package:stockall/services/lan/stock/lan_stock_service.dart';

import 'lan_fixtures.dart';

class PeerServer {
  PeerServer._(this.port, this.fingerprint, this._commands, this._isolate);

  final int port;
  final String fingerprint;
  final SendPort _commands;
  final Isolate _isolate;

  static Future<PeerServer> spawn({
    required String shopKey,
    required String deviceId,
    required int epoch,
    required DateTime claimedAt,
    double stock = 5,
    List<String> access = const ['Make Sale'],
  }) async {
    final ready = ReceivePort();
    final dir = Directory.systemTemp.createTempSync('stockall_peer').path;
    final isolate = await Isolate.spawn(_peerMain, [
      ready.sendPort,
      dir,
      shopKey,
      deviceId,
      epoch,
      claimedAt.toUtc().millisecondsSinceEpoch,
      stock,
      access,
    ]);
    final hello = await ready.first as Map;
    return PeerServer._(
      hello['port'] as int,
      hello['fingerprint'] as String,
      hello['commands'] as SendPort,
      isolate,
    );
  }

  Future<Object?> _ask(Map<String, Object?> message) async {
    final reply = ReceivePort();
    _commands.send({...message, 'reply': reply.sendPort});
    return reply.first;
  }

  /// `quantity` (of p1), `queued` (its queue keys), `notices` (superseded
  /// notices received), `holds` (`device|cart|product`: quantity),
  /// `products` (uuid: name), `handed_over` (`device|epoch` of former
  /// servers that said their queue is here), `last_notice` (the body of
  /// the last superseded notice).
  Future<Map<String, Object?>> state() async =>
      Map<String, Object?>.from(await _ask({'cmd': 'state'}) as Map);

  Future<List<bool>> applied(List<String> keys) async =>
      (await _ask({'cmd': 'applied', 'keys': keys}) as List).cast<bool>();

  /// Changes the claim it serves and proves.
  Future<void> setClaim({required int epoch, required DateTime claimedAt}) =>
      _ask({
        'cmd': 'claim',
        'epoch': epoch,
        'claimed_at': claimedAt.toUtc().millisecondsSinceEpoch,
      });

  /// Its own watch, once: proves the server at 127.0.0.1:[port] and, when
  /// it outranks that one, sends it a superseded notice. Returns what it
  /// decided: `outranks`, `outranked` or `none`.
  Future<String> watchOnce(int port) async =>
      await _ask({'cmd': 'watch', 'port': port}) as String;

  /// Sets p1's stock (sales made on this side of a split).
  Future<void> setQuantity(double quantity) =>
      _ask({'cmd': 'quantity', 'quantity': quantity});

  /// Steps down for [to] (a candidate's JSON): tells its clients `moved`,
  /// then stops serving (unless [stop] is false).
  /// [signWith]: 'self' (its own certificate, as the real server does),
  /// 'none' (unsigned) or 'other' (another key: a forgery).
  Future<void> moveTo(
    Map<String, dynamic> to, {
    bool stop = true,
    String signWith = 'self',
  }) => _ask({'cmd': 'move', 'to': to, 'stop': stop, 'signWith': signWith});

  /// Stops serving without a word (the machine went away).
  Future<void> halt() => _ask({'cmd': 'halt'});

  /// Its record is cleared at [epoch] (it was told the shop's server was
  /// force-cleared): its clients get the `server` event.
  Future<void> clearClaim(int epoch) => _ask({'cmd': 'clear', 'epoch': epoch});

  /// Whether it says it reaches the internet, with a `server` event.
  Future<void> setOnline(bool online) =>
      _ask({'cmd': 'online', 'online': online});

  /// Its backfill: on [table], or done. Not announced (clients read
  /// it again while it runs).
  Future<void> setBackfill({String? table, bool done = false}) =>
      _ask({'cmd': 'backfill', 'table': table, 'done': done});

  /// Serves again after [halt] (the machine came back), on a new port.
  Future<int> resume() async => await _ask({'cmd': 'resume'}) as int;

  /// The code it shows while a device pairs with it, or null.
  Future<String?> pairingCode() async =>
      await _ask({'cmd': 'pairing_code'}) as String?;

  /// While [refuse], every sign-in gets 503 (as if the server were busy).
  Future<void> refuseLogins(bool refuse) =>
      _ask({'cmd': 'refuse_logins', 'refuse': refuse});

  /// As if [device] said its queue from [epoch] is all here.
  Future<void> recordHandedOver(String device, int epoch) =>
      _ask({'cmd': 'handed_over', 'device': device, 'epoch': epoch});

  Future<void> stop() async {
    await _ask({'cmd': 'stop'});
    _isolate.kill();
  }
}

@pragma('vm:entry-point')
Future<void> _peerMain(List<Object?> args) async {
  final ready = args[0] as SendPort;
  Hive.init(args[1] as String);
  final shopKey = args[2] as String;
  final deviceId = args[3] as String;
  var epoch = args[4] as int;
  var claimedAt = DateTime.fromMillisecondsSinceEpoch(
    args[5] as int,
    isUtc: true,
  );
  registerAllHiveAdapters();
  await LanCredentialsFunc().init();
  await LanServerSessionsFunc().init();
  await LanShopKeysFunc().init();
  await ProductsFunc().init();
  await QuantityUpdateFunc().init();
  await LanAppliedDeltasFunc().init();
  await LanDeletedItemsFunc().init();
  await LanStockHoldsFunc().init();
  await LanShopKeysFunc().put(7, shopKey);
  await LanUserBackfill().apply(
    7,
    const LanBackfillShop(ownerId: 'owner', employees: ['cashier']),
    [
      TempUserClass(
        userId: 'cashier',
        name: 'Ada',
        email: 'ada@shop.test',
        password: 'right',
        role: 'Cashier',
        departmentUuids: const [],
        access: (args[7] as List).cast<String>(),
      ),
    ],
    iterations: 1000,
  );
  await ProductsFunc().productBox.put(
    'p1',
    product('p1')..quantity = args[6] as double,
  );

  final identity = LanTlsIdentity.generate();
  var cleared = false;
  var online = true;
  Map<String, dynamic> backfill = {
    'running': false,
    'done': true,
    'table': null,
    'at': null,
  };
  LanServerView view() => LanServerView(
    shopTag: shopTag(shopKey),
    epoch: epoch,
    serverDeviceId: cleared ? null : deviceId,
    cleared: cleared,
    claimedAt: claimedAt,
  );
  final notices = <Map<String, dynamic>>[];
  final handedOver = <Map<String, dynamic>>[];
  final deltas = LanDeltaRpcs(
    rpcs: lanDeltaRpcs(shopId: () => 7),
    applied: const HiveAppliedDeltas(),
  );
  LanServer? live;
  final stock = LanStockService(
    exclusive: deltas.runExclusive,
    product: (uuid) => ProductsFunc().productBox.get(uuid),
    prepareCheckout:
        (body) => deltas.prepare('update_product_quantities', body),
    applyCheckout:
        (body) => deltas.applyHoldingLock(
          'update_product_quantities',
          body,
          skipUnknown: true,
        ),
    ownDeviceId: () => deviceId,
    send: (event) => live?.broadcast(event),
  )..start();
  final engine = HiveRestEngine(
    tables: [
      for (final t in lanTables(shopId: () => 7))
        if (t.name == 'products') t,
    ],
    shopId: () => 7,
    manageDepartments: () => false,
    rpcs: deltas,
    stock: stock,
  );
  final server = LanServer(
    identity: identity,
    deviceId: deviceId,
    serverView: () => view().toJson(),
    fullServerView: () => {
      ...view().toJson(),
      'online': online,
      'backfill': backfill,
    },
    auth: _CountingAuth(
      shopId: () => 7,
      shopJson:
          (_) => {
            'shop_id': 7,
            'user_id': 'owner',
            'name': 'Shop',
            'currency': 'NGN',
            'is_verified': true,
            'created_at': '2026-01-01T00:00:00Z',
          },
    ),
    rest: engine,
    peerProof:
        (nonce) => {
          'view': view().toJson(),
          'mac': LanPeerProof.mac(
            shopKey: shopKey,
            nonce: nonce,
            fingerprint: identity.fingerprint,
            view: view(),
          ),
        },
    onSuperseded: notices.add,
    handoffStatus: LanHandoffStatusSource(
      queuesEmpty: () => QuantityUpdateFunc().quantityUpdateBox.isEmpty,
    ),
    onHandedOver: (device, epoch) async =>
        handedOver.add({'device': device, 'epoch': epoch}),
    handedOver: () => handedOver,
    onDeviceOnline: stock.deviceOnline,
    onDeviceOffline: stock.deviceOffline,
  );
  final port = await server.start(ports: const [0]);
  live = server;

  final commands = ReceivePort();
  ready.send({
    'port': port,
    'fingerprint': identity.fingerprint,
    'commands': commands.sendPort,
  });
  await for (final message in commands) {
    final m = message as Map;
    final reply = m['reply'] as SendPort;
    switch (m['cmd']) {
      case 'state':
        reply.send({
          'quantity': ProductsFunc().productBox.get('p1')?.quantity,
          'queued': [
            for (final k in QuantityUpdateFunc().quantityUpdateBox.keys) '$k',
          ],
          'notices': notices.length,
          // Every sign-in attempt it received (a password sent to it).
          'logins': _CountingAuth.logins,
          // Those that presented a move signed by a former server.
          'moved_logins': _CountingAuth.movedLogins,
          'holds': {for (final h in stock.holds) h.key: h.quantity},
          'products': {
            for (final p in ProductsFunc().productBox.values) p.uuid: p.name,
          },
          'handed_over': [
            for (final h in handedOver) '${h['device']}|${h['epoch']}',
          ],
          'last_notice': notices.isEmpty ? null : notices.last,
        });
      case 'applied':
        reply.send([
          for (final k in m['keys'] as List)
            const HiveAppliedDeltas().contains(k as String),
        ]);
      case 'claim':
        epoch = m['epoch'] as int;
        claimedAt = DateTime.fromMillisecondsSinceEpoch(
          m['claimed_at'] as int,
          isUtc: true,
        );
        reply.send(null);
      case 'watch':
        var decided = 'none';
        final watch = LanServerWatch(
          find: () async {
            final found = await proveLanServer(
              shopKey: shopKey,
              endpoints: [LanEndpoint('127.0.0.1', m['port'] as int)],
            );
            return found == null ? <LanServerCandidate>[] : [found];
          },
          self: view,
          onOutranked: (_) async => decided = 'outranked',
          onOutranks: (loser) async {
            decided = 'outranks';
            await notifyLanServerSuperseded(
              loser: loser,
              selfAddresses: const ['127.0.0.1'],
              selfPort: port,
              selfFingerprint: identity.fingerprint,
            );
          },
        );
        await watch.check();
        reply.send(decided);
      case 'quantity':
        final p1 = ProductsFunc().productBox.get('p1')!;
        await ProductsFunc().productBox.put(
          'p1',
          p1..quantity = m['quantity'] as double,
        );
        reply.send(null);
      case 'move':
        // Signed with this server's certificate key, as the real server
        // does; [signWith] 'none' sends it unsigned, 'other' signs it with
        // another key (a forgery).
        final to = LanServerCandidate.fromJson(m['to'])!;
        final text = LanMoveProof.message(
          shopTag: shopTag(shopKey),
          fromDeviceId: deviceId,
          fromEpoch: epoch,
          to: to,
        );
        final signer = m['signWith'] == 'other'
            ? LanTlsIdentity.generate()
            : identity;
        server.broadcast({
          'type': 'moved',
          'to': m['to'],
          if (m['signWith'] != 'none') ...{
            'from_device_id': deviceId,
            'from_epoch': epoch,
            'cert': signer.certificatePem,
            'sig': LanMoveProof.sign(signer.privateKeyPem, text),
          },
        });
        // Let the event leave before the sockets close.
        await Future<void>.delayed(const Duration(milliseconds: 200));
        if (m['stop'] == true) await server.stop();
        reply.send(null);
      case 'halt':
        await server.stop();
        reply.send(null);
      case 'refuse_logins':
        _CountingAuth.refuse = m['refuse'] as bool;
        reply.send(null);
      case 'online':
        online = m['online'] as bool;
        server.broadcastServerEvent();
        reply.send(null);
      case 'backfill':
        final done = m['done'] as bool;
        backfill = {
          'running': !done,
          'done': done,
          'table': m['table'],
          'at': DateTime.now().toUtc().toIso8601String(),
        };
        reply.send(null);
      case 'clear':
        epoch = m['epoch'] as int;
        cleared = true;
        server.broadcastServerEvent();
        reply.send(null);
      case 'resume':
        reply.send(await server.start(ports: const [0]));
      case 'pairing_code':
        reply.send(server.pairing.pendingCode);
      case 'handed_over':
        handedOver.add({'device': m['device'], 'epoch': m['epoch']});
        server.broadcast({
          'type': 'handed_over',
          'server_device_id': m['device'],
          'epoch': m['epoch'],
        });
        reply.send(null);
      case 'stop':
        await stock.stop();
        await server.stop();
        await engine.dispose();
        reply.send(null);
        commands.close();
    }
  }
}

/// Counts the sign-in attempts this server receives.
class _CountingAuth extends LanAuthService {
  _CountingAuth({required super.shopId, super.shopJson});

  static int logins = 0;
  static int movedLogins = 0;
  static bool refuse = false;

  @override
  Future<LanAuthResponse> login(
    Map<String, dynamic> body, {
    required String remoteAddress,
  }) async {
    logins++;
    if (body['moved'] is Map) movedLogins++;
    if (refuse) return const LanAuthResponse(503, {'error': 'busy'});
    return super.login(body, remoteAddress: remoteAddress);
  }
}

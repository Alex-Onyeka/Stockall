import 'dart:async';

import 'package:bonsoir/bonsoir.dart';
import 'package:stockall/services/lan/lan_constants.dart';
import 'package:stockall/services/lan/lan_transport_types.dart';

/// mDNS / DNS-SD advertising and browsing. An interface so the transport
/// can be tested without the platform plugin.
abstract class LanDiscoveryBackend {
  Future<void> advertiseServer({
    required String name,
    required int port,
    required Map<String, String> txt,
  });
  Future<void> stopServerAdvert();

  Future<void> advertisePeer({
    required String name,
    required Map<String, String> txt,
  });
  Future<void> stopPeerAdvert();

  /// Resolved services of [type] seen within [timeout]; the stream closes
  /// when the time is up.
  Stream<LanFound> browse(String type, Duration timeout);
}

class BonsoirDiscoveryBackend implements LanDiscoveryBackend {
  BonsoirBroadcast? _server;
  BonsoirBroadcast? _peer;

  Future<BonsoirBroadcast> _broadcast(BonsoirService service) async {
    final broadcast = BonsoirBroadcast(service: service, printLogs: false);
    await broadcast.initialize();
    await broadcast.start();
    return broadcast;
  }

  @override
  Future<void> advertiseServer({
    required String name,
    required int port,
    required Map<String, String> txt,
  }) async {
    await stopServerAdvert();
    _server = await _broadcast(
      BonsoirService(
        name: name,
        type: LanConstants.serverServiceType,
        port: port,
        attributes: txt,
      ),
    );
  }

  @override
  Future<void> stopServerAdvert() async {
    final server = _server;
    _server = null;
    await server?.stop();
  }

  @override
  Future<void> advertisePeer({
    required String name,
    required Map<String, String> txt,
  }) async {
    await stopPeerAdvert();
    // Peers don't listen; the port is nominal.
    _peer = await _broadcast(
      BonsoirService(
        name: name,
        type: LanConstants.peerServiceType,
        port: LanConstants.port,
        attributes: txt,
      ),
    );
  }

  @override
  Future<void> stopPeerAdvert() async {
    final peer = _peer;
    _peer = null;
    await peer?.stop();
  }

  @override
  Stream<LanFound> browse(String type, Duration timeout) {
    final controller = StreamController<LanFound>();
    final discovery = BonsoirDiscovery(type: type, printLogs: false);
    StreamSubscription<BonsoirDiscoveryEvent>? subscription;
    Timer? timer;
    var finished = false;

    Future<void> finish() async {
      if (finished) return;
      finished = true;
      timer?.cancel();
      await subscription?.cancel();
      try {
        await discovery.stop();
      } catch (_) {}
      if (!controller.isClosed) await controller.close();
    }

    void emit(BonsoirService service) {
      if (service.hostAddresses.isEmpty || controller.isClosed) return;
      controller.add(
        LanFound(
          name: service.name,
          addresses: List<String>.from(service.hostAddresses),
          port: service.port,
          txt: Map<String, String>.from(service.attributes),
        ),
      );
    }

    controller.onListen = () async {
      try {
        await discovery.initialize();
        subscription = discovery.eventStream?.listen((event) async {
          switch (event) {
            case BonsoirDiscoveryServiceFoundEvent(:final service):
              try {
                await service.resolve(discovery.serviceResolver);
              } catch (_) {}
            case BonsoirDiscoveryServiceResolvedEvent(:final service):
              emit(service);
            case BonsoirDiscoveryServiceUpdatedEvent(:final service):
              emit(service);
            default:
              break;
          }
        });
        await discovery.start();
        timer = Timer(timeout, finish);
      } catch (_) {
        await finish();
      }
    };
    controller.onCancel = finish;
    return controller.stream;
  }
}

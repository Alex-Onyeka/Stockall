import 'package:hive/hive.dart';
import 'package:stockall/classes/lan/lan_paired_server.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/main.dart';

/// Paired LAN servers, keyed by server device id. Not part of
/// `clearAllShopData`: pairing is trust in a machine, not shop data.
class LanPairedServersFunc {
  static final LanPairedServersFunc instance =
      LanPairedServersFunc._internal();
  factory LanPairedServersFunc() => instance;
  LanPairedServersFunc._internal();

  late Box<LanPairedServer> pairedServersBox;
  final String pairedServersBoxName = 'lanPairedServersBoxStockall';

  /// How each server certificate (by fingerprint) came to be trusted:
  /// [trustByPerson] after a person paired it with the code or QR,
  /// [trustVouched] after a server already trusted here signed a move to
  /// it. A fingerprint with no entry is not trusted with this device's
  /// stored password. No adapter: a plain `Box<int>`. Device-level, like
  /// the paired servers: never cleared with shop data.
  late Box<int> trustBox;
  final String trustBoxName = 'lanPairedTrustBoxStockall';

  static const int trustByPerson = 1;
  static const int trustVouched = 2;

  Future<void> init() async {
    try {
      safeRegisterAdapter(LanPairedServerAdapter());
      pairedServersBox = await openBoxSafely<LanPairedServer>(
        pairedServersBoxName,
      );
      trustBox = await openBoxSafely<int>(trustBoxName);
      await mainLocalLog('✅ LAN Paired Servers Box Initialized');
    } catch (e, s) {
      await mainLocalLog(
        'Error Initializing LAN Paired Servers Box: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
    }
  }

  List<LanPairedServer> all() {
    return pairedServersBox.values.toList();
  }

  LanPairedServer? get(String serverDeviceId) {
    return pairedServersBox.get(serverDeviceId);
  }

  /// The most recently paired server, if any.
  LanPairedServer? latest() {
    final servers = all();
    if (servers.isEmpty) return null;
    servers.sort((a, b) => b.pairedAt.compareTo(a.pairedAt));
    return servers.first;
  }

  Future<void> put(LanPairedServer server) async {
    await pairedServersBox.put(server.serverDeviceId, server);
  }

  bool _trustOpen() => Hive.isBoxOpen(trustBoxName);

  /// Whether this device may send its stored password to the server whose
  /// certificate has [fingerprint].
  bool isTrusted(String fingerprint) {
    if (!_trustOpen()) return false;
    final trust = trustBox.get(fingerprint.toLowerCase());
    return trust == trustByPerson || trust == trustVouched;
  }

  /// A person paired with [fingerprint] (code or QR).
  Future<void> markPairedByPerson(String fingerprint) async {
    if (!_trustOpen()) return;
    await trustBox.put(fingerprint.toLowerCase(), trustByPerson);
  }

  /// A server trusted here signed a move to [fingerprint]. Never lowers a
  /// person's pairing.
  Future<void> markVouched(String fingerprint) async {
    if (!_trustOpen()) return;
    final key = fingerprint.toLowerCase();
    if (trustBox.get(key) == trustByPerson) return;
    await trustBox.put(key, trustVouched);
  }
}

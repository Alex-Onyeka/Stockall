import 'dart:async';

import 'package:stockall/main.dart';
import 'package:stockall/services/lan/lan_constants.dart';
import 'package:stockall/services/lan/lan_transport_types.dart';

/// The proven server in [found] that outranks [self] most, if any.
/// Cleared claims and this server's own are skipped.
LanServerCandidate? pickOutranking(
  Iterable<LanServerCandidate> found,
  LanServerView self,
) {
  LanServerCandidate? best;
  for (final c in found) {
    if (c.view.cleared || c.view.serverDeviceId == self.serverDeviceId) {
      continue;
    }
    if (c.rankAgainstView(self) <= 0) continue;
    if (best == null || c.rankAgainstView(best.view) > 0) best = c;
  }
  return best;
}

/// While this device serves, looks for another server of the same shop:
/// every [every], [find] browses for a few seconds and proves
/// what it finds. An outranking server ends this one's serving
/// ([onOutranked]); one this server outranks is told ([onOutranks]),
/// because mDNS can be seen one way only.
class LanServerWatch {
  LanServerWatch({
    required this.find,
    required this.self,
    required this.onOutranked,
    required this.onOutranks,
    this.every = LanConstants.serverWatchEvery,
    Timer Function(Duration, void Function(Timer))? periodic,
  }) : _periodic = periodic ?? Timer.periodic;

  /// One look: the proven servers of the shop (others than this one).
  final Future<List<LanServerCandidate>> Function() find;

  /// This server's claim now.
  final LanServerView Function() self;
  final Future<void> Function(LanServerCandidate winner) onOutranked;
  final Future<void> Function(LanServerCandidate loser) onOutranks;
  final Duration every;
  final Timer Function(Duration, void Function(Timer)) _periodic;

  Timer? _timer;
  Future<void>? _running;
  bool _stopped = false;

  void start() {
    _stopped = false;
    _timer ??= _periodic(every, (_) => unawaited(check()));
  }

  void stop() {
    _stopped = true;
    _timer?.cancel();
    _timer = null;
  }

  /// One check now (one at a time; a call during one waits for it).
  Future<void> check() =>
      _running ??= _check().whenComplete(() {
        _running = null;
      });

  Future<void> _check() async {
    try {
      final found = await find();
      if (_stopped) return;
      final self = this.self();
      final winner = pickOutranking(found, self);
      if (winner != null) {
        await mainLocalLog(
          'LAN server watch: ${winner.view.serverDeviceId} (epoch '
          '${winner.view.epoch}) outranks this server',
        );
        await onOutranked(winner);
        return;
      }
      for (final c in found) {
        if (c.view.cleared || c.view.serverDeviceId == self.serverDeviceId) {
          continue;
        }
        if (c.rankAgainstView(self) < 0) await onOutranks(c);
      }
    } catch (e) {
      await mainLocalLog('LAN server watch failed: $e');
    }
  }
}

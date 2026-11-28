import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/lan_password_dialog.dart';
import 'package:stockall/pages/lan_settings/components/lan_section.dart';
import 'package:stockall/pages/lan_settings/components/lan_settings_model.dart';
import 'package:stockall/providers/local_server_provider.dart';
import 'package:stockall/services/lan/lan_constants.dart';
import 'package:stockall/services/lan/lan_transport.dart';

/// What making this desktop the server, or removing it, came to.
String serverChangeMessage(LocalServerChange change, {required bool made}) {
  switch (change) {
    case LocalServerChange.applied:
      return made
          ? 'This desktop is now the store server. Pair the store\'s other '
                'devices with it below.'
          : 'The store server was removed. Devices work on their own until '
                'a desktop is made the store server.';
    case LocalServerChange.refusedNotCleared:
      return 'Another device is the store server. Remove it on that desktop '
          'first.';
    case LocalServerChange.alreadyCleared:
      return 'This store has no store server to remove.';
    case LocalServerChange.notDesktop:
      return 'Only a desktop can be the store server.';
    case LocalServerChange.notNewer:
      return 'Nothing changed.';
    case LocalServerChange.liveServerFound:
      return 'Another desktop already serves this store.';
    case LocalServerChange.notAvailable:
      return 'The store network isn\'t available on this device.';
    case LocalServerChange.serverStartFailed:
      return 'This desktop couldn\'t start serving, so it wasn\'t made the '
          'store server. Try again.';
    case LocalServerChange.needsInternet:
      return 'Connect this desktop to the internet once with this store, '
          'then try again.';
  }
}

/// What clearing a server that stopped answering came to.
String forceClearMessage(LanForceClearResult result) {
  switch (result) {
    case LanForceClearResult.applied:
      return 'The store server was cleared. Make another desktop the store '
          'server to use the store network again.';
    case LanForceClearResult.noPermission:
      return 'You need the Manage Local Server permission.';
    case LanForceClearResult.wrongPassword:
      return 'That password isn\'t right. Nothing was cleared.';
    case LanForceClearResult.alreadyCleared:
      return 'The store server is already cleared.';
    case LanForceClearResult.notOnLan:
      return 'Connect to the store\'s network first: from anywhere else a '
          'working server can\'t be told from a stopped one.';
    case LanForceClearResult.tooSoon:
      return 'The store server answered less than a minute ago. Try again '
          'shortly.';
    case LanForceClearResult.liveServerFound:
      return 'The store server is answering again. Nothing was cleared.';
    case LanForceClearResult.notAvailable:
      return 'This can\'t be done from this device.';
  }
}

/// The server role, for a user with `Manage Local Server`:
/// make this desktop the server, remove it (on the serving desktop), or
/// clear a server that has stopped answering for a minute. Each asks for
/// the password first.
class ServerRoleSection extends StatefulWidget {
  const ServerRoleSection({super.key, required this.model});

  final LanSettingsModel model;

  @override
  State<ServerRoleSection> createState() => _ServerRoleSectionState();
}

class _ServerRoleSectionState extends State<ServerRoleSection> {
  bool _busy = false;
  String? _note;
  bool _noteOk = true;

  LanSettingsModel get model => widget.model;

  Future<String?> _checkPassword(String password) async {
    final result = await model.confirmPassword(password);
    return result == LanAuthResult.ok ? null : lanPasswordProblem(result);
  }

  Future<void> _run(Future<(String, bool)> Function() action) async {
    setState(() {
      _busy = true;
      _note = null;
    });
    (String, bool) outcome;
    try {
      outcome = await action();
    } catch (e) {
      outcome = ('That didn\'t work: $e', false);
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _note = outcome.$1;
      _noteOk = outcome.$2;
    });
  }

  Future<void> _makeServer() async {
    final password = await showLanPasswordDialog(
      context,
      title: 'Make this desktop the store server',
      message:
          'The store\'s other devices will pair with this desktop and work '
          'through it, even when the internet is down. Keep it on while '
          'the store is open. Type your password to go ahead.',
      actionText: 'Make server',
      check: _checkPassword,
    );
    if (password == null) return;
    await _run(() async {
      final change = await model.makeServer();
      return (
        serverChangeMessage(change, made: true),
        change == LocalServerChange.applied,
      );
    });
  }

  Future<void> _removeServer() async {
    final password = await showLanPasswordDialog(
      context,
      title: 'Remove the store server',
      message:
          'This desktop stops serving the store. Its devices work on their '
          'own, and send their changes to the cloud when online, until a '
          'desktop is made the store server again. Type your password to '
          'go ahead.',
      actionText: 'Remove',
      check: _checkPassword,
    );
    if (password == null) return;
    await _run(() async {
      final change = await model.removeServer();
      return (
        serverChangeMessage(change, made: false),
        change == LocalServerChange.applied,
      );
    });
  }

  Future<void> _forceClear() async {
    final password = await showLanPasswordDialog(
      context,
      title: 'Clear the store server',
      message:
          'Only do this if the store server is broken or gone. Stock changes '
          'it hadn\'t sent to the cloud are listed for you to check by '
          'hand. If it comes back, it stops serving. Type your password to '
          'go ahead.',
      actionText: 'Clear server',
      check: _checkPassword,
    );
    if (password == null) return;
    await _run(() async {
      final result = await model.forceClear(password);
      return (forceClearMessage(result), result == LanForceClearResult.applied);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!model.available || !model.mayManage) return const SizedBox.shrink();
    final record = model.record;
    final hasServer = record != null && !record.isCleared;
    final children = <Widget>[];
    if (model.isServing) {
      children.addAll([
        const LanText(
          'The store\'s devices work through this desktop. Keep it on while '
          'the store is open.',
        ),
        LanButton(
          label: 'Remove the store server',
          danger: true,
          outlined: true,
          busy: _busy,
          onPressed: _removeServer,
        ),
      ]);
    } else if (hasServer) {
      children.add(
        LanText(
          'The store server is device ${lanShortId(record.serverDeviceId)}. '
          'To move it, remove it on that desktop first.',
        ),
      );
      if (model.status.kind == LanStatusKind.serverUnreachable) {
        children.addAll(_forceClearPart());
      }
    } else if (model.isDesktop) {
      children.addAll([
        const LanText(
          'This store has no store server. A desktop that stays on in the '
          'store can serve the other devices.',
        ),
        LanButton(
          label: 'Make this desktop the store server',
          icon: Icons.dns_outlined,
          busy: _busy,
          onPressed: _makeServer,
        ),
      ]);
    } else {
      children.add(
        const LanText(
          'This store has no store server. Make one on a desktop: Settings › '
          'Store Network.',
        ),
      );
    }
    if (_note != null) children.add(LanNote(_note!, ok: _noteOk));
    return LanSection(
      title: 'Store server',
      icon: Icons.dns_outlined,
      children: children,
    );
  }

  List<Widget> _forceClearPart() {
    final waited = model.unreachableFor ?? Duration.zero;
    final left = LanConstants.forceClearAfter - waited;
    final seconds = left.isNegative ? 0 : (left.inMilliseconds / 1000).ceil();
    return [
      const LanText(
        'The store server isn\'t answering. If it is broken or gone, you '
        'can clear it once it has been silent for a minute, then make '
        'another desktop the store server.',
        color: Colors.black87,
      ),
      LanButton(
        label: seconds > 0
            ? 'Clear the store server (in $seconds s)'
            : 'Clear the store server',
        danger: true,
        busy: _busy,
        onPressed: seconds > 0 ? null : _forceClear,
      ),
    ];
  }
}

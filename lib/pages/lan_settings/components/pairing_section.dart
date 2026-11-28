import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/lan_password_dialog.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/lan_settings/components/lan_section.dart';
import 'package:stockall/pages/lan_settings/components/lan_settings_model.dart';
import 'package:stockall/services/lan/lan_constants.dart';
import 'package:stockall/services/lan/lan_transport.dart';

/// Pairing. On the store server, for a user with `Manage Local
/// Server`: the code a pairing device shows, and the server's QR code. On
/// any other device, for any signed-in user: find the server (or type its
/// address) and type its code, or scan its QR code on a phone; then sign
/// in there.
class PairingSection extends StatelessWidget {
  const PairingSection({super.key, required this.model});

  final LanSettingsModel model;

  @override
  Widget build(BuildContext context) {
    if (!model.available) return const SizedBox.shrink();
    if (model.isServing) {
      return model.mayManage
          ? _ServerPairing(model: model)
          : const SizedBox.shrink();
    }
    return _ClientPairing(model: model);
  }
}

class _ServerPairing extends StatefulWidget {
  const _ServerPairing({required this.model});

  final LanSettingsModel model;

  @override
  State<_ServerPairing> createState() => _ServerPairingState();
}

class _ServerPairingState extends State<_ServerPairing> {
  Future<String?>? _qr;

  /// [LanSettingsModel.qrPairings] when [_qr] was asked for.
  int _qrPairings = 0;

  void _showQr() {
    _qrPairings = widget.model.qrPairings;
    _qr = widget.model.pairingQrPayload();
  }

  @override
  void didUpdateWidget(covariant _ServerPairing oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A device paired with the code shown, which used it up: a fresh one.
    if (_qr != null && widget.model.qrPairings != _qrPairings) _showQr();
  }

  @override
  void dispose() {
    // Left the page with the code shown: it stops working.
    if (_qr != null) widget.model.cancelPairingQr();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    final code = widget.model.pendingPairingCode;
    return LanSection(
      title: 'Pair a device',
      icon: Icons.phonelink_setup_outlined,
      children: [
        const LanText(
          'On the device, open Settings › Store Network and find this '
          'server. Check that the code it asks for matches the one here.',
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: code == null
              ? const Center(
                  child: LanText('No device is pairing right now.'),
                )
              : Center(
                  child: SelectableText(
                    code,
                    style: TextStyle(
                      fontSize: theme.mobileTexts.h2.fontSize,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 6,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
        ),
        if (code != null)
          LanButton(
            label: 'Cancel this pairing',
            outlined: true,
            danger: true,
            onPressed: () {
              widget.model.cancelServerPairing();
              setState(() {});
            },
          ),
        LanButton(
          label: _qr == null ? 'Show QR code' : 'Hide QR code',
          icon: Icons.qr_code_2,
          outlined: true,
          onPressed: () => setState(() {
            // Hidden: the code shown stops working.
            if (_qr != null) {
              widget.model.cancelPairingQr();
              _qr = null;
            } else {
              _showQr();
            }
          }),
        ),
        if (_qr != null)
          FutureBuilder<String?>(
            future: _qr,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const SizedBox(
                  height: 40,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final payload = snapshot.data;
              if (payload == null) {
                return const LanText('The QR code isn\'t available right now.');
              }
              return Center(
                child: Column(
                  spacing: 8,
                  children: [
                    BarcodeWidget(
                      key: const ValueKey('lan-pairing-qr'),
                      barcode: Barcode.qrCode(),
                      data: payload,
                      width: 200,
                      height: 200,
                      drawText: false,
                    ),
                    const LanText(
                      'Scan it from Settings › Store Network on a phone.',
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

enum _Step { start, found, code }

class _ClientPairing extends StatefulWidget {
  const _ClientPairing({required this.model});

  final LanSettingsModel model;

  @override
  State<_ClientPairing> createState() => _ClientPairingState();
}

class _ClientPairingState extends State<_ClientPairing> {
  _Step _step = _Step.start;
  bool _busy = false;
  bool _typingAddress = false;
  List<LanFound> _found = const [];
  final _code = TextEditingController();
  final _address = TextEditingController();
  String? _note;
  bool _noteOk = true;

  LanSettingsModel get model => widget.model;

  @override
  void dispose() {
    _code.dispose();
    _address.dispose();
    super.dispose();
  }

  void _say(String note, {bool ok = false}) {
    if (!mounted) return;
    setState(() {
      _busy = false;
      _note = note;
      _noteOk = ok;
    });
  }

  void _working() => setState(() {
    _busy = true;
    _note = null;
  });

  Future<void> _find() async {
    _working();
    final found = await model.browseServers();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _found = found;
      _step = _Step.found;
      if (found.isEmpty) {
        _note =
            'No store server found on this network. Check the server is on '
            'and this device is on the store\'s Wi-Fi, or type its address.';
        _noteOk = false;
      }
    });
  }

  Future<void> _begin(List<String> addresses, int port) async {
    _working();
    final outcome = await model.beginPairing(addresses, port);
    if (!mounted) return;
    if (outcome.result == LanPairResult.awaitingCode) {
      _code.clear();
      setState(() {
        _busy = false;
        _step = _Step.code;
      });
      return;
    }
    _say(_pairProblem(outcome));
  }

  Future<void> _beginTyped() async {
    final text = _address.text.trim();
    if (text.isEmpty) {
      _say('Type the store server\'s address.');
      return;
    }
    final colon = text.lastIndexOf(':');
    var host = text;
    var port = LanConstants.port;
    if (colon > 0 && !text.contains(']') && text.indexOf(':') == colon) {
      final parsed = int.tryParse(text.substring(colon + 1));
      if (parsed == null) {
        _say('That address isn\'t right. Type it like 192.168.1.20.');
        return;
      }
      host = text.substring(0, colon);
      port = parsed;
    }
    await _begin([host], port);
  }

  Future<void> _submitCode() async {
    final code = _code.text.trim();
    if (code.isEmpty) {
      _say('Type the code shown on the store server.');
      return;
    }
    _working();
    final outcome = await model.submitPairingCode(code);
    if (!mounted) return;
    if (outcome.result == LanPairResult.paired && outcome.server != null) {
      await _signIn(outcome.server!.serverDeviceId);
      return;
    }
    setState(() => _step = _Step.start);
    _say(_pairProblem(outcome));
  }

  Future<void> _scan() async {
    final payload = await model.scanQr(context);
    if (payload == null || !mounted) return;
    _working();
    final outcome = await model.pairFromQr(payload);
    if (!mounted) return;
    if (outcome.result == LanPairResult.paired && outcome.server != null) {
      await _signIn(outcome.server!.serverDeviceId);
      return;
    }
    _say(_pairProblem(outcome));
  }

  Future<void> _cancel() async {
    await model.cancelPairing();
    if (!mounted) return;
    setState(() {
      _step = _Step.start;
      _note = null;
    });
  }

  Future<void> _signIn(String serverDeviceId) async {
    final result = await model.signInAfterPairing(serverDeviceId);
    if (!mounted) return;
    setState(() => _step = _Step.start);
    if (result == LanAuthResult.ok) {
      _say(_paired, ok: true);
      return;
    }
    if (result != LanAuthResult.invalidCredentials) {
      _say('Paired, but signing in on the store server failed: '
          '${lanPasswordProblem(result)}');
      return;
    }
    setState(() => _busy = false);
    final password = await showLanPasswordDialog(
      context,
      title: 'Sign in on the store server',
      message: 'Paired. Type your password to sign in on the store server.',
      actionText: 'Sign in',
      check: (password) async {
        final r = await model.signInWithPassword(password);
        return r == LanAuthResult.ok ? null : lanPasswordProblem(r);
      },
    );
    if (password == null) {
      _say('Paired, but not signed in on the store server. Sign out and in '
          'again to use it.');
      return;
    }
    _say(_paired, ok: true);
  }

  static const _paired =
      'Paired and signed in. This device now works through the store server.';

  String _pairProblem(LanPairOutcome outcome) {
    switch (outcome.result) {
      case LanPairResult.codeMismatch:
        return 'The code doesn\'t match: this may not be your store server. '
            'Nothing was saved. Try again, and check the code on the server.';
      case LanPairResult.failed:
        final message = outcome.message;
        if (message == null) return 'Couldn\'t pair.';
        return 'Couldn\'t pair: $message${message.endsWith('.') ? '' : '.'}';
      case LanPairResult.awaitingCode:
      case LanPairResult.paired:
        return 'Couldn\'t pair.';
    }
  }

  static String _serverName(LanFound found) {
    final name = found.name.replaceFirst(RegExp(r'^Stockall-?'), '');
    return name.isEmpty ? found.name : 'Store server $name';
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    if (_step == _Step.code) {
      children.addAll([
        const LanText(
          'Type the 8-character code now shown on the store server.',
          color: Colors.black87,
        ),
        TextField(
          key: const ValueKey('lan-pairing-code'),
          controller: _code,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          enabled: !_busy,
          onSubmitted: (_) => _submitCode(),
          decoration: const InputDecoration(
            labelText: 'Code',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: LanButton(
                label: 'Cancel',
                outlined: true,
                onPressed: _busy ? null : _cancel,
              ),
            ),
            Expanded(
              child: LanButton(label: 'Pair', busy: _busy, onPressed: _submitCode),
            ),
          ],
        ),
      ]);
    } else {
      children.add(
        const LanText(
          'Pair this device with the store server so it keeps working with '
          'the other devices when the internet is down.',
        ),
      );
      if (_step == _Step.found) {
        for (final found in _found) {
          children.add(
            Material(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(6),
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.dns_outlined),
                title: Text(_serverName(found)),
                subtitle: Text(found.addresses.join(', ')),
                trailing: const Icon(Icons.chevron_right),
                onTap: _busy
                    ? null
                    : () => _begin(found.addresses, found.port),
              ),
            ),
          );
        }
      }
      if (_typingAddress) {
        children.addAll([
          TextField(
            key: const ValueKey('lan-pairing-address'),
            controller: _address,
            enabled: !_busy,
            keyboardType: TextInputType.url,
            onSubmitted: (_) => _beginTyped(),
            decoration: const InputDecoration(
              labelText: 'Server address, e.g. 192.168.1.20',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          LanButton(
            label: 'Connect',
            busy: _busy,
            onPressed: _beginTyped,
          ),
        ]);
      }
      children.add(
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            LanButton(
              label: _step == _Step.found
                  ? 'Look again'
                  : 'Find the store server',
              icon: Icons.search,
              busy: _busy && !_typingAddress,
              onPressed: _find,
            ),
            if (!_typingAddress)
              LanButton(
                label: 'Type its address',
                outlined: true,
                onPressed: _busy
                    ? null
                    : () => setState(() => _typingAddress = true),
              ),
            if (model.canScan)
              LanButton(
                label: 'Scan QR code',
                icon: Icons.qr_code_scanner,
                outlined: true,
                onPressed: _busy ? null : _scan,
              ),
          ],
        ),
      );
    }
    if (_note != null) children.add(LanNote(_note!, ok: _noteOk));
    return LanSection(
      title: 'Pair with the store server',
      icon: Icons.phonelink_setup_outlined,
      children: children,
    );
  }
}

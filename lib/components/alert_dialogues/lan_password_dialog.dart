import 'package:flutter/material.dart';
import 'package:stockall/main.dart';
import 'package:stockall/services/lan/lan_transport.dart';

/// The words for a password check that didn't pass.
String lanPasswordProblem(LanAuthResult result) {
  switch (result) {
    case LanAuthResult.ok:
      return '';
    case LanAuthResult.invalidCredentials:
      return 'That password isn\'t right.';
    case LanAuthResult.rateLimited:
      return 'Too many tries. Wait a minute and try again.';
    case LanAuthResult.unreachable:
      return 'The store server can\'t be reached.';
    case LanAuthResult.failed:
      return 'The password couldn\'t be checked. Try again.';
  }
}

/// The password re-entry before a store server change. The
/// dialog stays open, saying what's wrong, until [check] passes (it
/// returns null) or it is cancelled; nothing is changed before that.
/// Completes with the password, or null when cancelled.
Future<String?> showLanPasswordDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String actionText,
  required Future<String?> Function(String password) check,
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (_) => LanPasswordDialog(
      title: title,
      message: message,
      actionText: actionText,
      check: check,
    ),
  );
}

class LanPasswordDialog extends StatefulWidget {
  const LanPasswordDialog({
    super.key,
    required this.title,
    required this.message,
    required this.actionText,
    required this.check,
  });

  final String title;
  final String message;
  final String actionText;

  /// Null when the password passes, otherwise what to tell the user.
  final Future<String?> Function(String password) check;

  @override
  State<LanPasswordDialog> createState() => _LanPasswordDialogState();
}

class _LanPasswordDialogState extends State<LanPasswordDialog> {
  final _password = TextEditingController();
  String? _problem;
  bool _checking = false;
  bool _hidden = true;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final password = _password.text;
    if (_checking) return;
    if (password.isEmpty) {
      setState(() => _problem = 'Type your password.');
      return;
    }
    setState(() {
      _checking = true;
      _problem = null;
    });
    String? problem;
    try {
      problem = await widget.check(password);
    } catch (_) {
      problem = 'The password couldn\'t be checked. Try again.';
    }
    if (!mounted) return;
    if (problem == null) {
      Navigator.of(context).pop(password);
      return;
    }
    setState(() {
      _checking = false;
      _problem = problem;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      contentPadding: const EdgeInsets.all(18),
      backgroundColor: Colors.white,
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: theme.mobileTexts.h4.fontSize,
                fontWeight: theme.mobileTexts.h3.fontWeightBold,
              ),
            ),
            Text(
              widget.message,
              style: TextStyle(
                fontSize: theme.mobileTexts.b2.fontSize,
                color: Colors.grey.shade700,
              ),
            ),
            TextField(
              controller: _password,
              obscureText: _hidden,
              autofocus: true,
              enabled: !_checking,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Your password',
                border: const OutlineInputBorder(),
                isDense: true,
                errorText: _problem,
                suffixIcon: IconButton(
                  icon: Icon(
                    _hidden ? Icons.visibility_off : Icons.visibility,
                    size: 18,
                  ),
                  onPressed: () => setState(() => _hidden = !_hidden),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 8,
              children: [
                TextButton(
                  onPressed: _checking
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.lightModeColor.prColor300,
                  ),
                  onPressed: _checking ? null : _submit,
                  child: _checking
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(widget.actionText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

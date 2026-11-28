import 'package:flutter/material.dart';
import 'package:stockall/main.dart';

/// One titled card of the Store Network page.
class LanSection extends StatelessWidget {
  const LanSection({
    super.key,
    required this.title,
    required this.children,
    this.icon,
  });

  final String title;
  final IconData? icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Row(
            spacing: 8,
            children: [
              if (icon != null)
                Icon(icon, size: 18, color: theme.lightModeColor.prColor300),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b1.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          ...children,
        ],
      ),
    );
  }
}

/// A line of explanation in a section.
class LanText extends StatelessWidget {
  const LanText(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: returnTheme(context).mobileTexts.b3.fontSize,
        color: color ?? Colors.grey.shade700,
      ),
    );
  }
}

/// What the last action came to, under a section's buttons.
class LanNote extends StatelessWidget {
  const LanNote(this.text, {super.key, this.ok = true});

  final String text;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    final color = ok ? Colors.green.shade700 : Colors.red.shade700;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: returnTheme(context).mobileTexts.b3.fontSize,
          color: color,
        ),
      ),
    );
  }
}

/// A section's button: filled, or outlined for the lesser choice; red for
/// one that removes something.
class LanButton extends StatelessWidget {
  const LanButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
    this.outlined = false,
    this.danger = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final bool outlined;
  final bool danger;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    final color = danger ? Colors.red.shade600 : theme.lightModeColor.prColor300;
    final child = busy
        ? SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: outlined ? color : Colors.white,
            ),
          )
        : Text(label, textAlign: TextAlign.center);
    final onTap = busy ? null : onPressed;
    if (outlined) {
      return OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
        ),
        onPressed: onTap,
        icon: icon == null ? null : Icon(icon, size: 18),
        label: child,
      );
    }
    return FilledButton.icon(
      style: FilledButton.styleFrom(backgroundColor: color),
      onPressed: onTap,
      icon: icon == null ? null : Icon(icon, size: 18),
      label: child,
    );
  }
}

/// A short form of a device id for people to read.
String lanShortId(String? deviceId) {
  if (deviceId == null || deviceId.isEmpty) return 'unknown';
  return deviceId.length > 8 ? deviceId.substring(0, 8) : deviceId;
}

String lanWhen(DateTime at) {
  final t = at.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${t.year}-${two(t.month)}-${two(t.day)} ${two(t.hour)}:${two(t.minute)}';
}

/// Asks before something that can't be undone; true to go ahead.
Future<bool> lanConfirm(
  BuildContext context, {
  required String title,
  required String message,
  required String action,
}) async {
  final go = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      backgroundColor: Colors.white,
      title: Text(title),
      content: SizedBox(width: 420, child: Text(message)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(c).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
          onPressed: () => Navigator.of(c).pop(true),
          child: Text(action),
        ),
      ],
    ),
  );
  return go == true;
}

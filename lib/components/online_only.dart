import 'package:flutter/material.dart';
import 'package:stockall/main.dart';

/// Shows [child] only while screens that need the internet can be used:
/// on the store's network, only while its server
/// reaches the internet; anywhere else as before. Rebuilds when that
/// changes.
class OnlineOnly extends StatelessWidget {
  const OnlineOnly({
    super.key,
    required this.child,
    this.replacement = const SizedBox.shrink(),
  });

  /// [child], or a short note that it comes back when the store server is
  /// online (for a button a page is built around).
  const OnlineOnly.withNote({super.key, required this.child})
    : replacement = const _OfflineNote();

  final Widget child;

  /// Shown instead while they can't.
  final Widget replacement;

  @override
  Widget build(BuildContext context) {
    final available =
        returnLocalServerProvider(context: context).onlineFeaturesAvailable;
    return available ? child : replacement;
  }
}

class _OfflineNote extends StatelessWidget {
  const _OfflineNote();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        'Available when the store server is back online.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: returnTheme(context).mobileTexts.b3.fontSize,
          color: Colors.grey.shade600,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

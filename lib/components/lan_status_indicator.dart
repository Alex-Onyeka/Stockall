import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/local_server_provider.dart';

/// Where this device stands with the store server: a coloured
/// dot and a short label, with the server's internet and its first load
/// from the cloud. [compact] (the dashboard app bar) shows nothing for a
/// device that doesn't use a store server; the full form (the Store
/// Network page) also explains it.
class LanStatusIndicator extends StatelessWidget {
  const LanStatusIndicator({super.key, this.compact = true, this.status});

  final bool compact;

  /// Shown instead of the provider's (the Store Network page's model).
  final LanStatus? status;

  static String label(LanStatus status) {
    if (status.mustPairAgain) return 'Pair again';
    if (status.needsCloudSignIn) return 'Sign in to sync';
    switch (status.kind) {
      case LanStatusKind.server:
        return 'Store server';
      case LanStatusKind.connected:
        return 'Connected';
      case LanStatusKind.serverUnreachable:
        return 'Server not answering';
      case LanStatusKind.offLan:
        return 'Off store network';
      case LanStatusKind.standalone:
        return 'No store server';
    }
  }

  /// One line on what this means for the user.
  static String detail(LanStatus status) {
    final notes = [
      if (status.loading)
        status.backfill?.table == null
            ? 'Loading store data from the cloud…'
            : 'Loading store data from the cloud (${status.backfill!.table})…',
      if (status.serverOnline == false)
        'The store server is offline: payments, notifications, updates and '
            'password reset are unavailable until it is back online.',
      if (status.mustPairAgain)
        'The store server changed. Pair this device with it again using the '
            'code it shows (Settings › Store Network).',
      if (status.needsCloudSignIn)
        'This device signed in through the store server, so it can\'t reach '
            'the cloud by itself. Sales are kept here; sign in to sync them.',
    ];
    switch (status.kind) {
      case LanStatusKind.server:
        notes.insert(0, 'This desktop is the store server.');
      case LanStatusKind.connected:
        notes.insert(0, 'Connected to the store server.');
      case LanStatusKind.serverUnreachable:
        notes.insert(
          0,
          'The store server isn\'t answering. Sales are kept on this device '
          'and sent when it is back.',
        );
      case LanStatusKind.offLan:
        notes.insert(
          0,
          'Away from the store\'s network: changes go straight to the cloud '
          'when online.',
        );
      case LanStatusKind.standalone:
        notes.insert(0, 'This device doesn\'t use a store server.');
    }
    return notes.join(' ');
  }

  static Color colorOf(LanStatus status) {
    if (status.mustPairAgain || status.needsCloudSignIn) {
      return Colors.orange.shade700;
    }
    switch (status.kind) {
      case LanStatusKind.server:
      case LanStatusKind.connected:
        return status.serverOnline == false || status.loading
            ? Colors.orange.shade700
            : Colors.green.shade600;
      case LanStatusKind.serverUnreachable:
        return Colors.red.shade600;
      case LanStatusKind.offLan:
      case LanStatusKind.standalone:
        return Colors.grey.shade500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status =
        this.status ?? returnLocalServerProvider(context: context).status;
    if (compact &&
        status.kind == LanStatusKind.standalone &&
        !status.mustPairAgain) {
      return const SizedBox.shrink();
    }
    final theme = returnTheme(context);
    final color = colorOf(status);
    final dot = Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
    final text = Text(
      status.loading ? '${label(status)} · loading' : label(status),
      style: TextStyle(
        fontSize: theme.mobileTexts.b4.fontSize,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade800,
      ),
    );
    if (compact && screenWidth(context) < mobileScreen) {
      // A phone's app bar: the dot only.
      return Tooltip(
        message: '${label(status)}. ${detail(status)}',
        child: Padding(padding: const EdgeInsets.all(6), child: dot),
      );
    }
    if (compact) {
      return Tooltip(
        message: detail(status),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [dot, text],
          ),
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Row(spacing: 8, children: [dot, text]),
          Text(
            detail(status),
            style: TextStyle(
              fontSize: theme.mobileTexts.b3.fontSize,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

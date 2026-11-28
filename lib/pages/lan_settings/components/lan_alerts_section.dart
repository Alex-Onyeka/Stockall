import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/lan_server_alert.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/lan_settings/components/lan_section.dart';
import 'package:stockall/pages/lan_settings/components/lan_settings_model.dart';
import 'package:stockall/services/lan/lan_alerts.dart';

/// The store server alerts kept on this device, newest first,
/// for a user with `Manage Local Server`. Each opens in the alert dialog.
class LanAlertsSection extends StatelessWidget {
  const LanAlertsSection({super.key, required this.model});

  final LanSettingsModel model;

  static String kindLabel(LanAlertKind kind) => switch (kind) {
    LanAlertKind.conflict => 'Two servers',
    LanAlertKind.demoted => 'Stopped serving',
    LanAlertKind.merged => 'Changes handed over',
    LanAlertKind.forceCleared => 'Server cleared',
    LanAlertKind.otherStoreServed => 'Serves another store',
  };

  @override
  Widget build(BuildContext context) {
    if (!model.available || !model.mayManage) return const SizedBox.shrink();
    final alerts = model.alerts;
    return LanSection(
      title: 'Store server alerts',
      icon: Icons.notifications_active_outlined,
      children: [
        if (alerts.isEmpty)
          const LanText('No store server alerts.')
        else
          for (final alert in alerts)
            Material(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(6),
              child: ListTile(
                dense: true,
                title: Text(alert.title),
                subtitle: Text(
                  '${kindLabel(alert.kind)} · ${lanWhen(alert.createdAt)}'
                  '${alert.rows.isEmpty ? '' : ' · ${alert.rows.length} '
                            '${alert.rows.length == 1 ? 'item' : 'items'}'}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showDialog<void>(
                  context: context,
                  builder: (c) => LanServerAlertDialog(
                    theme: returnTheme(c, listen: false),
                    alert: alert,
                  ),
                ),
              ),
            ),
      ],
    );
  }
}

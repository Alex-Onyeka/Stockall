import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/lan_password_dialog.dart';
import 'package:stockall/components/lan_status_indicator.dart';
import 'package:stockall/pages/lan_settings/components/lan_settings_model.dart';

/// The top of the Store Network page: where this device
/// stands, the server's internet, and its first load from the cloud.
class LanStatusCard extends StatelessWidget {
  const LanStatusCard({super.key, required this.model});

  final LanSettingsModel model;

  @override
  Widget build(BuildContext context) {
    final status = model.status;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        spacing: 6,
        children: [
          LanStatusIndicator(compact: false, status: status),
          if (status.loading)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                minHeight: 4,
                color: LanStatusIndicator.colorOf(status),
                backgroundColor: Colors.grey.shade200,
              ),
            ),
          if (status.needsCloudSignIn)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                key: const Key('lan-cloud-sign-in'),
                icon: const Icon(Icons.cloud_outlined, size: 18),
                label: const Text('Sign in to sync'),
                onPressed: () => showLanPasswordDialog(
                  context,
                  title: 'Sign in to the cloud',
                  message:
                      'Type your password to send what this device kept '
                      'while away from the store\'s network.',
                  actionText: 'Sign in',
                  check: model.signInToCloud,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

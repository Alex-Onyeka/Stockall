import 'package:flutter/material.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/pages/lan_settings/components/devices_section.dart';
import 'package:stockall/pages/lan_settings/components/lan_alerts_section.dart';
import 'package:stockall/pages/lan_settings/components/lan_section.dart';
import 'package:stockall/pages/lan_settings/components/lan_settings_model.dart';
import 'package:stockall/pages/lan_settings/components/lan_status_card.dart';
import 'package:stockall/pages/lan_settings/components/pairing_section.dart';
import 'package:stockall/pages/lan_settings/components/server_role_section.dart';

/// The Store Network page on a phone: its sections in one column.
class LanSettingsMobile extends StatelessWidget {
  const LanSettingsMobile({super.key, required this.model});

  final LanSettingsModel model;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: appBar(context: context, title: 'Store Network'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 40),
        children: [
          LanStatusCard(model: model),
          if (!model.available)
            const LanSection(
              title: 'Store network',
              children: [
                LanText('The store network isn\'t available on the web.'),
              ],
            ),
          ServerRoleSection(model: model),
          PairingSection(model: model),
          DevicesSection(model: model),
          LanAlertsSection(model: model),
        ],
      ),
    );
  }
}

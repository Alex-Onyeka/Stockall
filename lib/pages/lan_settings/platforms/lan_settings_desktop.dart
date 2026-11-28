import 'package:flutter/material.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/lan_settings/components/devices_section.dart';
import 'package:stockall/pages/lan_settings/components/lan_alerts_section.dart';
import 'package:stockall/pages/lan_settings/components/lan_section.dart';
import 'package:stockall/pages/lan_settings/components/lan_settings_model.dart';
import 'package:stockall/pages/lan_settings/components/lan_status_card.dart';
import 'package:stockall/pages/lan_settings/components/pairing_section.dart';
import 'package:stockall/pages/lan_settings/components/server_role_section.dart';

/// The Store Network page on a desktop: where this device stands and the
/// server role on the left; pairing, devices and alerts on the right.
class LanSettingsDesktop extends StatelessWidget {
  const LanSettingsDesktop({super.key, required this.model});

  final LanSettingsModel model;

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    return DesktopCenterContainer(
      width: 1100,
      mainWidget: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  mouseCursor: SystemMouseCursors.click,
                  onTap: () => Navigator.of(context).pop(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 15),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  spacing: 8,
                  children: [
                    Text(
                      'Store Network',
                      style: TextStyle(
                        color: theme.lightModeColor.shadesColorBlack,
                        fontSize: theme.mobileTexts.h4.fontSize,
                        fontWeight: theme.mobileTexts.h3.fontWeightBold,
                      ),
                    ),
                    Text(
                      'Keep the store\'s devices working together when the '
                      'internet is down.',
                      style: theme.mobileTexts.b3.textStyleNormal,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 50),
            ],
          ),
          const SizedBox(height: 15),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 30),
                      children: [
                        LanStatusCard(model: model),
                        if (!model.available)
                          const LanSection(
                            title: 'Store network',
                            children: [
                              LanText(
                                'The store network isn\'t available on the '
                                'web.',
                              ),
                            ],
                          ),
                        ServerRoleSection(model: model),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 30),
                      children: [
                        PairingSection(model: model),
                        DevicesSection(model: model),
                        LanAlertsSection(model: model),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

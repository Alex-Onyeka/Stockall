import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/settings/platforms/settings_page_desktop.dart';
import 'package:stockall/pages/settings/platforms/settings_page_mobile.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= mobileScreen) {
          return SettingsPageMobile();
        } else {
          return SettingsPageDesktop();
        }
      },
    );
  }
}

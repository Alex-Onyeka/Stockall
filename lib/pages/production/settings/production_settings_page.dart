import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/production/settings/platforms/production_settings_page_desktop.dart';
import 'package:stockall/pages/production/settings/platforms/production_settings_page_mobile.dart';

class ProductionSettingsPage extends StatelessWidget {
  const ProductionSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= mobileScreen) {
          return ProductionSettingsPageMobile();
        } else {
          return ProductionSettingsPageDesktop();
        }
      },
    );
  }
}

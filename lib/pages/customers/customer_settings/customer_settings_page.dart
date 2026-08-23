import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/customers/customer_settings/platforms/customer_settings_page_desktop.dart';
import 'package:stockall/pages/customers/customer_settings/platforms/customer_settings_page_mobile.dart';

class CustomerSettingsPage extends StatelessWidget {
  const CustomerSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= mobileScreen) {
          return CustomerSettingsPageMobile();
        } else {
          return CustomerSettingsPageDesktop();
        }
      },
    );
  }
}

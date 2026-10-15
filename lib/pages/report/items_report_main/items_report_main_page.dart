import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/items_report_main/platforms/items_report_main_desktop.dart';
import 'package:stockall/pages/report/items_report_main/platforms/items_report_main_mobile.dart';

class ItemsReportMainPage extends StatelessWidget {
  const ItemsReportMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreen) {
          return const ItemsReportMainMobile();
        } else {
          return const ItemsReportMainDesktop();
        }
      },
    );
  }
}


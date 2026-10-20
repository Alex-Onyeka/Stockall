import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/items_report_/items_report/platforms/items_report_desktop.dart';
import 'package:stockall/pages/report/items_report_/items_report/platforms/items_report_mobile.dart';

class ItemsReportPage extends StatelessWidget {
  const ItemsReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return const ItemsReportMobile();
        } else {
          return const ItemsReportDesktop();
        }
      },
    );
  }
}

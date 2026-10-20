import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/items_report_/item_history_report/platforms/item_history_report_desktop.dart';
import 'package:stockall/pages/report/items_report_/item_history_report/platforms/item_history_report_mobile.dart';

class ItemHistoryReportPage extends StatelessWidget {
  const ItemHistoryReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreen) {
          return const ItemHistoryReportMobile();
        } else {
          return const ItemHistoryReportDesktop();
        }
      },
    );
  }
}

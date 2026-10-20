import 'package:flutter/material.dart';
import 'package:stockall/pages/report/items_report_/item_history_report/components/item_history_report_view.dart';

class ItemHistoryReportDesktop extends StatelessWidget {
  const ItemHistoryReportDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return const ItemHistoryReportView(isDesktop: true);
  }
}

import 'package:flutter/material.dart';
import 'package:stockall/pages/report/item_history_report/components/item_history_report_view.dart';

class ItemHistoryReportMobile extends StatelessWidget {
  const ItemHistoryReportMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return const ItemHistoryReportView(isDesktop: false);
  }
}


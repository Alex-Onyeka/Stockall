import 'package:flutter/material.dart';
import 'package:stockall/pages/report/items_report_/item_history_summary/components/item_history_summary_view.dart';

class ItemHistorySummaryMobile extends StatelessWidget {
  const ItemHistorySummaryMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return const ItemHistorySummaryView(isDesktop: false);
  }
}

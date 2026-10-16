import 'package:flutter/material.dart';
import 'package:stockall/pages/report/item_history_summary/components/item_history_summary_view.dart';

class ItemHistorySummaryDesktop extends StatelessWidget {
  const ItemHistorySummaryDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return const ItemHistorySummaryView(isDesktop: true);
  }
}


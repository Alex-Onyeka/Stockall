import 'package:flutter/material.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_item_history_summary/components/storage_item_history_summary_view.dart';

class StorageItemHistorySummaryMobile extends StatelessWidget {
  const StorageItemHistorySummaryMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return const StorageItemHistorySummaryView(isDesktop: false);
  }
}

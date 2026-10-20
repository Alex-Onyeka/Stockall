import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_item_history_summary/platforms/storage_item_history_summary_desktop.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_item_history_summary/platforms/storage_item_history_summary_mobile.dart';

class StorageItemHistorySummaryPage extends StatelessWidget {
  const StorageItemHistorySummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreen) {
          return const StorageItemHistorySummaryMobile();
        } else {
          return const StorageItemHistorySummaryDesktop();
        }
      },
    );
  }
}

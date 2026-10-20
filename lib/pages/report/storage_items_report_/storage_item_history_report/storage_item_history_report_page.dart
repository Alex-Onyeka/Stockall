import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_item_history_report/platforms/storage_item_history_report_desktop.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_item_history_report/platforms/storage_item_history_report_mobile.dart';

class StorageItemHistoryReportPage extends StatelessWidget {
  /// Opens the table filtered to one storage item.
  final String? initialStorageItemUuid;

  /// Defaults to today's business day.
  final ReceiptsReportPeriod? initialPeriod;

  const StorageItemHistoryReportPage({
    super.key,
    this.initialStorageItemUuid,
    this.initialPeriod,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreen) {
          return StorageItemHistoryReportMobile(
            initialStorageItemUuid: initialStorageItemUuid,
            initialPeriod: initialPeriod,
          );
        } else {
          return StorageItemHistoryReportDesktop(
            initialStorageItemUuid: initialStorageItemUuid,
            initialPeriod: initialPeriod,
          );
        }
      },
    );
  }
}

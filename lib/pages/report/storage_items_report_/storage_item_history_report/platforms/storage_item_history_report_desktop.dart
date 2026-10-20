import 'package:flutter/material.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_item_history_report/components/storage_item_history_report_view.dart';

class StorageItemHistoryReportDesktop extends StatelessWidget {
  final String? initialStorageItemUuid;
  final ReceiptsReportPeriod? initialPeriod;

  const StorageItemHistoryReportDesktop({
    super.key,
    this.initialStorageItemUuid,
    this.initialPeriod,
  });

  @override
  Widget build(BuildContext context) {
    return StorageItemHistoryReportView(
      isDesktop: true,
      initialStorageItemUuid: initialStorageItemUuid,
      initialPeriod: initialPeriod,
    );
  }
}

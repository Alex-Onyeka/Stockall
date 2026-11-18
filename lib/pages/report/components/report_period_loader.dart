import 'package:flutter/material.dart';
import 'package:stockall/constants/refresh_functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

/// Loads receipts for a report [period] from Supabase (on refresh or when
/// the date window has not been fetched yet) and saves them to local cache.
Future<void> loadReceiptsForReportPeriod(
  BuildContext context, {
  required ReceiptsReportPeriod period,
  required bool refreshFromStore,
}) async {
  final provider = returnReceiptProviderSingle();
  final sid = shopSingle()?.shopId;
  final startDate = period.start;
  final endDate = period.end ?? period.start;
  if (refreshFromStore) {
    await RefreshFunctions(context).refreshReceipts(
      context,
      startDate: startDate,
      endDate: endDate,
      fetchAll: period.isAllTime,
      forceRefresh: true,
    );
    return;
  }
  if (sid != null) {
    if (provider.receipts.isEmpty) {
      await provider.loadReceiptsOffline(sid);
    }
    if (provider.mainSales.isEmpty) {
      await provider.loadProductSalesRecordOffline(sid);
    }
    if (!period.isAllTime) {
      await provider.loadReceipts(
        sid,
        startDate: startDate,
        endDate: endDate,
        forceRefresh: false,
      );
    }
  }
}

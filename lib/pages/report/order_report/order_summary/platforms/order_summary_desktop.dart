import 'package:flutter/material.dart';
import 'package:stockall/pages/report/order_report/order_summary/components/order_summary_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

class OrderSummaryDesktop extends StatelessWidget {
  final ReceiptsReportPeriod? initialPeriod;

  const OrderSummaryDesktop({super.key, this.initialPeriod});

  @override
  Widget build(BuildContext context) {
    return OrderSummaryView(
      isDesktop: true,
      initialPeriod: initialPeriod,
    );
  }
}

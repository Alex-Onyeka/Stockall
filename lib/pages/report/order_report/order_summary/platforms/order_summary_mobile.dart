import 'package:flutter/material.dart';
import 'package:stockall/pages/report/order_report/order_summary/components/order_summary_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

class OrderSummaryMobile extends StatelessWidget {
  final ReceiptsReportPeriod? initialPeriod;

  const OrderSummaryMobile({super.key, this.initialPeriod});

  @override
  Widget build(BuildContext context) {
    return OrderSummaryView(
      isDesktop: false,
      initialPeriod: initialPeriod,
    );
  }
}

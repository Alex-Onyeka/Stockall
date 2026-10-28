import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/order_report/order_summary/platforms/order_summary_desktop.dart';
import 'package:stockall/pages/report/order_report/order_summary/platforms/order_summary_mobile.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

class OrderSummaryPage extends StatelessWidget {
  final ReceiptsReportPeriod? initialPeriod;

  const OrderSummaryPage({super.key, this.initialPeriod});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreen) {
          return OrderSummaryMobile(initialPeriod: initialPeriod);
        } else {
          return OrderSummaryDesktop(initialPeriod: initialPeriod);
        }
      },
    );
  }
}

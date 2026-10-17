import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/invoice_report_table/platforms/invoice_report_table_desktop.dart';
import 'package:stockall/pages/report/invoice_report_table/platforms/invoice_report_table_mobile.dart';

class InvoiceReportTablePage extends StatelessWidget {
  const InvoiceReportTablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreen) {
          return const InvoiceReportTableMobile();
        } else {
          return const InvoiceReportTableDesktop();
        }
      },
    );
  }
}


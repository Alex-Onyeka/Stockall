import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/invoice_report_table/class/invoice_report_table_logic.dart';
import 'package:stockall/pages/report/invoice_report_table/platforms/invoice_report_table_desktop.dart';
import 'package:stockall/pages/report/invoice_report_table/platforms/invoice_report_table_mobile.dart';

class InvoiceReportTablePage extends StatelessWidget {
  final InvoiceReportFilters? initialFilters;

  const InvoiceReportTablePage({
    super.key,
    this.initialFilters,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreen) {
          return InvoiceReportTableMobile(
            initialFilters: initialFilters,
          );
        } else {
          return InvoiceReportTableDesktop(
            initialFilters: initialFilters,
          );
        }
      },
    );
  }
}

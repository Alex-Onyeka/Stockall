import 'package:flutter/material.dart';
import 'package:stockall/pages/report/invoice_report/invoice_report_table/class/invoice_report_table_logic.dart';
import 'package:stockall/pages/report/invoice_report/invoice_report_table/components/invoice_report_table_view.dart';

class InvoiceReportTableDesktop extends StatelessWidget {
  final InvoiceReportFilters? initialFilters;

  const InvoiceReportTableDesktop({
    super.key,
    this.initialFilters,
  });

  @override
  Widget build(BuildContext context) {
    return InvoiceReportTableView(
      isDesktop: true,
      initialFilters: initialFilters,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:stockall/pages/report/invoice_report_table/components/invoice_report_table_view.dart';

class InvoiceReportTableMobile extends StatelessWidget {
  const InvoiceReportTableMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return const InvoiceReportTableView(isDesktop: false);
  }
}

// The customer page's Print Record pill: the staff page's Print
// Report button (the shared report Export menu: Print 80mm / 58mm,
// Download PDF, Export Excel) on the customer's record. The data is
// the Customer Report's (CustomerReportEnv), loaded once after the
// first frame and read again each time the menu opens.

import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/customers/customer_details_page/components/customer_record_data.dart';
import 'package:stockall/pages/report/components/export/report_export_actions.dart';
import 'package:stockall/pages/report/components/export/report_export_backend.dart';
import 'package:stockall/pages/report/components/export/report_export_button.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/class/customer_report_table_logic.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/components/customer_report_table_view.dart';

class CustomerPrintRecordButton extends StatefulWidget {
  final TempCustomersClass customer;

  /// Null in the app: [CustomerReportEnv.live] is used.
  final CustomerReportEnv? env;
  final ReportExportBackend exportBackend;

  /// A print icon with a "Print Record" tooltip instead of the pill.
  final bool iconOnly;

  const CustomerPrintRecordButton({
    super.key,
    required this.customer,
    this.env,
    this.exportBackend = const DefaultReportExportBackend(),
    this.iconOnly = false,
  });

  @override
  State<CustomerPrintRecordButton> createState() =>
      _CustomerPrintRecordButtonState();
}

class _CustomerPrintRecordButtonState
    extends State<CustomerPrintRecordButton> {
  late final CustomerReportEnv _env;

  @override
  void initState() {
    super.initState();
    _env = widget.env ?? CustomerReportEnv.live();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _env.load(context, refreshFromStore: false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ReportExportButton(
      label: 'Print Record',
      iconOnly: widget.iconOnly,
      backend: widget.exportBackend,
      buildSpec: () {
        final source = _env.source();
        final uuid = widget.customer.uuid;
        // The stored customer, so balances changed elsewhere show.
        final customer = source.customers.firstWhere(
          (c) => uuid != null && c.uuid == uuid,
          orElse: () => widget.customer,
        );
        return customerRecordSpec(
          base: CustomerReportBase.build(
            source: source,
            access: _env.access(),
          ),
          customer: customer,
          currency: currencySymbol(context: context),
        );
      },
    );
  }
}

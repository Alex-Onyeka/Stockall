import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/invoices/invoice_list/platforms/invoice_list_desktop.dart';
import 'package:stockall/pages/invoices/invoice_list/platforms/invoice_list_mobile.dart';

class InvoiceListPage extends StatefulWidget {
  final String? agentUuid;
  final String? customerUuid;
  const InvoiceListPage({
    super.key,
    this.agentUuid,
    this.customerUuid,
  });

  @override
  State<InvoiceListPage> createState() =>
      _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnNavProvider(context, listen: false).navigate(5);
      returnInvoicesProvider().loadInvoices(shopId());
    });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnInvoicesProvider().clearDate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return InvoiceListMobile(
            agentUuid: widget.agentUuid,
            customerUuid: widget.customerUuid,
          );
        } else {
          return InvoiceListDesktop(
            customerUuid: widget.customerUuid,
            agentUuid: widget.agentUuid,
          );
        }
      },
    );
  }
}

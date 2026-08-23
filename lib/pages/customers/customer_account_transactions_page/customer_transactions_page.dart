import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/customers/customer_account_transactions_page/platforms/customer_transactions_desktop.dart';
import 'package:stockall/pages/customers/customer_account_transactions_page/platforms/customer_transactions_mobile.dart';

class CustomerTransactionsPage extends StatefulWidget {
  final String? customerUuid;
  const CustomerTransactionsPage({
    super.key,
    this.customerUuid,
  });

  @override
  State<CustomerTransactionsPage> createState() =>
      _CustomerTransactionsPageState();
}

class _CustomerTransactionsPageState
    extends State<CustomerTransactionsPage> {
  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   returnCustomerAccountReceiptsProvider()
    // });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnCustomerAccountReceiptsProvider().clearDate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreenSmall) {
          return CustomerTransactionsMobile(
            customerUuid: widget.customerUuid,
          );
        } else {
          return CustomerTransactionsDesktop(
            customerUuid: widget.customerUuid,
          );
        }
      },
    );
  }
}

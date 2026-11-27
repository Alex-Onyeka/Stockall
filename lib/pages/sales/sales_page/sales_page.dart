import 'package:flutter/material.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/sales/total_sales/total_sales_page.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  void clearDate() {
    returnReceiptProvider(
      context,
      listen: false,
    ).clearDate();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        returnNavProvider(
          context,
          listen: false,
        ).navigate(0);
      },
      child: TotalSalesPage(turnOff: true, isMainTab: true),
    );
  }
}

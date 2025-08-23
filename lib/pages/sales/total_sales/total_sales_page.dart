import 'package:flutter/material.dart';
import 'package:stockall/pages/sales/total_sales/platforms/total_sales_desktop.dart';
import 'package:stockall/pages/sales/total_sales/platforms/total_sales_mobile.dart';

class TotalSalesPage extends StatelessWidget {
  final String? id;
  final int? customerId;
  final bool? isInvoice;
  const TotalSalesPage({
    super.key,
    this.id,
    this.customerId,
    this.isInvoice,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 550) {
          return TotalSalesMobile(
            id: id,
            customerId: customerId,
            isInvoice: isInvoice,
          );
        } else {
          return TotalSalesDesktop(
            customerId: customerId,
            id: id,
            isInvoice: isInvoice,
          );
        }
      },
    );
  }
}

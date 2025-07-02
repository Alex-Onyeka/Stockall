import 'package:flutter/material.dart';
import 'package:stockall/pages/sales/total_sales/platforms/total_sales_mobile.dart';

class TotalSalesPage extends StatelessWidget {
  final String? id;
  final int? customerId;
  const TotalSalesPage({
    super.key,
    this.id,
    this.customerId,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 550) {
          return TotalSalesMobile(
            id: id,
            customerId: customerId,
          );
        } else if (constraints.maxWidth > 550 &&
            constraints.maxWidth < 1000) {
          return Scaffold();
        } else {
          return Scaffold();
        }
      },
    );
  }
}

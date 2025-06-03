import 'package:flutter/material.dart';
import 'package:storrec/pages/sales/total_sales/platforms/total_sales_mobile.dart';

class TotalSalesPage extends StatelessWidget {
  const TotalSalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 550) {
          return TotalSalesMobile();
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

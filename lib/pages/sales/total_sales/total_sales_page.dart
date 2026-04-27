import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/sales/total_sales/platforms/total_sales_desktop.dart';
import 'package:stockall/pages/sales/total_sales/platforms/total_sales_mobile.dart';

class TotalSalesPage extends StatefulWidget {
  final String? id;
  final bool? turnOff;
  final String? customerUuid;
  final String? subStaffId;
  // final bool? isInvoice;
  const TotalSalesPage({
    super.key,
    this.id,
    this.customerUuid,
    this.subStaffId,
    // this.isInvoice,
    this.turnOff,
  });

  @override
  State<TotalSalesPage> createState() =>
      _TotalSalesPageState();
}

class _TotalSalesPageState extends State<TotalSalesPage> {
  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnReceiptProviderSingle().selectPaymentMethod(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return TotalSalesMobile(
            id: widget.id,
            customerUuid: widget.customerUuid,
            subStaffId: widget.subStaffId,
            // isInvoice: isInvoice,
          );
        } else {
          return TotalSalesDesktop(
            customerUuid: widget.customerUuid,
            turnOff: widget.turnOff,
            subStaffId: widget.subStaffId,
            id: widget.id,
            // isInvoice: isInvoice,
          );
        }
      },
    );
  }
}

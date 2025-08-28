import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/sales/make_sales/page2/platforms/make_sales_desktop_two.dart';
import 'package:stockall/pages/sales/make_sales/page2/platforms/make_sales_mobile_two.dart';

class MakeSalesTwo extends StatefulWidget {
  final double totalAmount;
  const MakeSalesTwo({
    super.key,
    required this.totalAmount,
  });

  @override
  State<MakeSalesTwo> createState() =>
      _MakeSalesPageState();
}

class _MakeSalesPageState extends State<MakeSalesTwo> {
  TextEditingController searchController =
      TextEditingController();
  TextEditingController cashController =
      TextEditingController();
  TextEditingController bankController =
      TextEditingController();
  TextEditingController customerController =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () =>
              FocusManager.instance.primaryFocus?.unfocus(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < mobileScreen) {
            return MakeSalesMobileTwo(
              totalAmount: widget.totalAmount,
              customerController: customerController,
              bankController: bankController,
              cashController: cashController,
              searchController: searchController,
            );
          } else {
            return MakeSalesDesktopTwo(
              totalAmount: widget.totalAmount,
              customerController: customerController,
              bankController: bankController,
              cashController: cashController,
              searchController: searchController,
            );
          }
        },
      ),
    );
  }
}

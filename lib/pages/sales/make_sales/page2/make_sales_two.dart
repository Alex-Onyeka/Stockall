import 'package:flutter/material.dart';
import 'package:stockitt/pages/sales/make_sales/page2/platforms/make_sales_mobile_two.dart';

class MakeSalesTwo extends StatefulWidget {
  const MakeSalesTwo({super.key});

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
      onTap: FocusManager.instance.primaryFocus?.unfocus,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 550) {
            return MakeSalesMobileTwo(
              customerController: customerController,
              bankController: bankController,
              cashController: cashController,
              searchController: searchController,
            );
          } else if (constraints.maxWidth > 550 &&
              constraints.maxWidth < 1000) {
            return Scaffold();
          } else {
            return Scaffold();
          }
        },
      ),
    );
  }
}

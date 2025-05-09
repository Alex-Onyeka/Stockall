import 'package:flutter/material.dart';
import 'package:stockitt/pages/sales/make_sales/page1/platforms/make_sales_mobile.dart';

class MakeSalesPage extends StatefulWidget {
  const MakeSalesPage({super.key});

  @override
  State<MakeSalesPage> createState() =>
      _MakeSalesPageState();
}

class _MakeSalesPageState extends State<MakeSalesPage> {
  TextEditingController searchController =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 550) {
          return MakeSalesMobile(
            searchController: searchController,
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

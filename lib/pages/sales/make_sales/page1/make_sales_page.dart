import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/sales/make_sales/page1/platforms/make_sales_desktop.dart';
import 'package:stockall/pages/sales/make_sales/page1/platforms/make_sales_mobile.dart';

class MakeSalesPage extends StatefulWidget {
  final bool? isMain;
  final bool? isInvoice;
  const MakeSalesPage({
    super.key,
    this.isMain,
    this.isInvoice,
  });

  @override
  State<MakeSalesPage> createState() =>
      _MakeSalesPageState();
}

class _MakeSalesPageState extends State<MakeSalesPage> {
  TextEditingController searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await returnNavProvider(
        context,
        listen: false,
      ).validate(context);

      setState(() {
        // stillLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return MakeSalesMobile(
            isInvoice: widget.isInvoice,
            isMain: widget.isMain,
            searchController: searchController,
          );
        } else {
          return MakeSalesDesktop(
            isInvoice: widget.isInvoice,
            isMain: widget.isMain,
            searchController: searchController,
          );
        }
      },
    );
  }
}

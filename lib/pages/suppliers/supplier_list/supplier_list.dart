import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/suppliers/supplier_list/platforms/supplier_list_desktop.dart';
import 'package:stockall/pages/suppliers/supplier_list/platforms/supplier_list_mobile.dart';

class SupplierList extends StatefulWidget {
  final bool? isPurchase;
  const SupplierList({super.key, this.isPurchase});

  @override
  State<SupplierList> createState() => _SupplierListState();
}

class _SupplierListState extends State<SupplierList> {
  TextEditingController searchContoller =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    returnNavProvider(context, listen: false).navigate(4);
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
    return GestureDetector(
      onTap:
          () =>
              FocusManager.instance.primaryFocus?.unfocus(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < mobileScreen) {
            return SupplierListMobile(
              searchController: searchContoller,
              isPurchase: widget.isPurchase,
            );
          } else {
            return SupplierListDesktop(
              searchController: searchContoller,
              isPurchase: widget.isPurchase,
            );
          }
        },
      ),
    );
  }
}

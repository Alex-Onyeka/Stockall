import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/purchases/purchase_list/platforms/purchase_list_desktop.dart';
import 'package:stockall/pages/purchases/purchase_list/platforms/purchase_list_mobile.dart';

class PurchaseList extends StatefulWidget {
  final String? id;
  final String? supplierUuid;
  const PurchaseList({
    super.key,
    this.id,
    this.supplierUuid,
  });

  @override
  State<PurchaseList> createState() => _PurchaseListState();
}

class _PurchaseListState extends State<PurchaseList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnNavProvider(context, listen: false).navigate(5);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return PurchaseListMobile(
            id: widget.id,
            supplierId: widget.supplierUuid,
          );
        } else {
          return PurchaseListDesktop(
            supplierUuid: widget.supplierUuid,
            id: widget.id,
          );
        }
      },
    );
  }
}

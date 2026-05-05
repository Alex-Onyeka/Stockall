import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/purchases/purchase_page/platforms/purchase_page_desktop.dart';
import 'package:stockall/pages/purchases/purchase_page/platforms/purchase_page_mobile.dart';

class PurchasePage extends StatefulWidget {
  final String purchaseUuid;
  const PurchasePage({
    super.key,
    required this.purchaseUuid,
  });

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnPurchaseProvider().loadPurchases(shopId());
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return PurchasePageMobile(
            purchaseUuid: widget.purchaseUuid,
          );
        } else {
          return PurchasePageDesktop(
            purchaseUuid: widget.purchaseUuid,
          );
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/suppliers/supplier_page/platform/supplier_page_desktop.dart';
import 'package:stockall/pages/suppliers/supplier_page/platform/supplier_page_mobile.dart';

class SupplierPage extends StatelessWidget {
  final String uuid;
  const SupplierPage({super.key, required this.uuid});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return SupplierPageMobile(uuid: uuid);
        } else {
          return SupplierPageDesktop(uuid: uuid);
        }
      },
    );
  }
}

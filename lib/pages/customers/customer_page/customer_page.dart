import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/customers/customer_page/platform/customer_page_desktop.dart';
import 'package:stockall/pages/customers/customer_page/platform/customer_page_mobile.dart';

class CustomerPage extends StatelessWidget {
  final String uuid;
  const CustomerPage({super.key, required this.uuid});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return CustomerPageMobile(uuid: uuid);
        } else {
          return CustomerPageDesktop(uuid: uuid);
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/customers/customer_page/platform/customer_page_desktop.dart';
import 'package:stockall/pages/customers/customer_page/platform/customer_page_mobile.dart';

class CustomerPage extends StatelessWidget {
  final int id;
  const CustomerPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return CustomerPageMobile(id: id);
        } else {
          return CustomerPageDesktop(id: id);
        }
      },
    );
  }
}

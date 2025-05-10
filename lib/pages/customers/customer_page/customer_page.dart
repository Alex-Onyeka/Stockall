import 'package:flutter/material.dart';
import 'package:stockitt/pages/customers/customer_page/platform/customer_page_mobile.dart';

class CustomerPage extends StatelessWidget {
  final int customerId;
  const CustomerPage({super.key, required this.customerId});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 550) {
          return CustomerPageMobile(customerId: customerId);
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

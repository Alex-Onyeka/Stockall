import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_customers_class.dart';
import 'package:stockall/pages/customers/customer_page/platform/customer_page_mobile.dart';

class CustomerPage extends StatelessWidget {
  final TempCustomersClass customer;
  const CustomerPage({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 550) {
          return CustomerPageMobile(customer: customer);
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

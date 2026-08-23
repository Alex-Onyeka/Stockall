import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/customers/customer_details_page/platforms/customer_details_desktop.dart';
import 'package:stockall/pages/customers/customer_details_page/platforms/customer_details_mobile.dart';

class CustomerDetails extends StatelessWidget {
  final String customerUuid;
  const CustomerDetails({
    super.key,
    required this.customerUuid,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreenSmall) {
          return CustomerDetailsMobile(
            customerUuid: customerUuid,
          );
        } else {
          return CustomerDetailsDesktop(
            customerUuid: customerUuid,
          );
        }
      },
    );
  }
}

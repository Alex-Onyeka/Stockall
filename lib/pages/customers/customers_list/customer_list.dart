import 'package:flutter/material.dart';
import 'package:stockall/pages/customers/customers_list/platforms/customer_list_mobile.dart';

class CustomerList extends StatefulWidget {
  final bool? isSales;
  const CustomerList({super.key, this.isSales});

  @override
  State<CustomerList> createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> {
  TextEditingController searchContoller =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () =>
              FocusManager.instance.primaryFocus?.unfocus(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 550) {
            return CustomerListMobile(
              searchController: searchContoller,
              isSales: widget.isSales,
            );
          } else if (constraints.maxWidth > 550 &&
              constraints.maxWidth < 1000) {
            return Scaffold();
          } else {
            return Scaffold();
          }
        },
      ),
    );
  }
}

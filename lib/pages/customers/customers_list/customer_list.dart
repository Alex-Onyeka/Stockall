import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/customers/customers_list/platforms/customer_list_desktop.dart';
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
  void initState() {
    super.initState();
    returnNavProvider(context, listen: false).navigate(3);
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
            return CustomerListMobile(
              searchController: searchContoller,
              isSales: widget.isSales,
            );
          } else {
            return CustomerListDesktop(
              searchController: searchContoller,
              isSales: widget.isSales,
            );
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_customers_class.dart';
import 'package:stockitt/pages/customers/add_customer/platforms/add_customer_mobile.dart';

class AddCustomer extends StatefulWidget {
  final TempCustomersClass? customer;
  const AddCustomer({super.key, this.customer});

  @override
  State<AddCustomer> createState() => _AddCustomerState();
}

class _AddCustomerState extends State<AddCustomer> {
  TextEditingController nameController =
      TextEditingController();
  TextEditingController phoneController =
      TextEditingController();
  TextEditingController emailController =
      TextEditingController();
  TextEditingController stateController =
      TextEditingController();
  TextEditingController cityController =
      TextEditingController();
  TextEditingController countryController =
      TextEditingController();
  TextEditingController addressController =
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
            return AddCustomerMobile(
              emailController: emailController,
              nameController: nameController,
              phoneController: phoneController,
              addressController: addressController,
              cityController: cityController,
              countryController: countryController,
              stateController: stateController,
              customer: widget.customer,
            );
          } else if (constraints.maxWidth > 500 &&
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

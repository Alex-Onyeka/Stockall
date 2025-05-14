import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_employee_class.dart';
import 'package:stockitt/pages/employees/add_employee_page/platforms/add_employee_mobile.dart';

class AddEmployeePage extends StatefulWidget {
  final TempEmployeeClass? employee;
  const AddEmployeePage({super.key, this.employee});

  @override
  State<AddEmployeePage> createState() =>
      _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
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
  void dispose() {
    super.dispose();
    addressController.dispose();
    countryController.dispose();
    cityController.dispose();
    stateController.dispose();
    emailController.dispose();
    nameController.dispose();
    phoneController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () =>
              FocusManager.instance.primaryFocus?.unfocus(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 550) {
            return AddEmployeeMobile(
              nameController: nameController,
              phoneController: phoneController,
              addressController: addressController,
              cityController: cityController,
              countryController: countryController,
              stateController: stateController,
              employee: widget.employee,
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

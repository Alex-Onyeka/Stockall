import 'package:flutter/material.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/employees/add_employee_page/platforms/add_employee_desktop.dart';
import 'package:stockall/pages/employees/add_employee_page/platforms/add_employee_mobile.dart';

class AddEmployeePage extends StatefulWidget {
  final TempUserClass? employee;
  const AddEmployeePage({super.key, this.employee});

  @override
  State<AddEmployeePage> createState() =>
      _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  TextEditingController idC = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    idC.dispose();
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
            return AddEmployeeMobile(
              idC: idC,
              employee: widget.employee,
            );
          } else {
            return AddEmployeeDesktop(
              idC: idC,
              employee: widget.employee,
            );
          }
        },
      ),
    );
  }
}

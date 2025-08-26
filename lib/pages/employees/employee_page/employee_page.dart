import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/employees/employee_page/platforms/employee_page_desktop.dart';
import 'package:stockall/pages/employees/employee_page/platforms/employee_page_mobile.dart';

class EmployeePage extends StatelessWidget {
  final String employeeId;
  const EmployeePage({super.key, required this.employeeId});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return EmployeePageMobile(employeeId: employeeId);
        } else {
          return EmployeePageDesktop(
            employeeId: employeeId,
          );
        }
      },
    );
  }
}

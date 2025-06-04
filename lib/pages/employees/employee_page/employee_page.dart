import 'package:flutter/material.dart';
import 'package:stockall/pages/employees/employee_page/platforms/employee_page_mobile.dart';

class EmployeePage extends StatelessWidget {
  final String employeeId;
  const EmployeePage({super.key, required this.employeeId});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 550) {
          return EmployeePageMobile(employeeId: employeeId);
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

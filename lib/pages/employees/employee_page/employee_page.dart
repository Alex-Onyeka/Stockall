import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/employees/employee_page/components/staff_page_env.dart';
import 'package:stockall/pages/employees/employee_page/platforms/employee_page_desktop.dart';
import 'package:stockall/pages/employees/employee_page/platforms/employee_page_mobile.dart';

class EmployeePage extends StatelessWidget {
  final String employeeId;

  /// Null in the app: [StaffPageEnv.live] is used.
  final StaffPageEnv? env;

  const EmployeePage({super.key, required this.employeeId, this.env});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // The customer details page's breakpoint.
        if (constraints.maxWidth < tabletScreenSmall) {
          return EmployeePageMobile(employeeId: employeeId, env: env);
        } else {
          return EmployeePageDesktop(employeeId: employeeId, env: env);
        }
      },
    );
  }
}

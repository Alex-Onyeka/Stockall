import 'package:flutter/material.dart';
import 'package:stockall/pages/employees/employee_list/platforms/employee_list_mobile.dart';

class EmployeeListPage extends StatelessWidget {
  final String role;
  final String empId;
  const EmployeeListPage({
    super.key,
    required this.empId,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 550) {
          return EmployeeListMobile(
            empId: empId,
            role: role,
          );
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

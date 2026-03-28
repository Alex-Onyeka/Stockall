import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/departments/platforms/departments_dashboard_desktop.dart';
import 'package:stockall/pages/departments/platforms/departments_dashboard_mobile.dart';

class DepartmentsDashboard extends StatefulWidget {
  const DepartmentsDashboard({super.key});

  @override
  State<DepartmentsDashboard> createState() =>
      _DepartmentsDashboardState();
}

class _DepartmentsDashboardState
    extends State<DepartmentsDashboard> {
  TextEditingController nameController =
      TextEditingController();
  TextEditingController descController =
      TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      returnDepartmentsDashboardProvider().clearDate();
      if (returnDepartmentsDashboardProvider()
          .allReceipts
          .isEmpty) {
        await returnDepartmentsDashboardProvider()
            .fetchAllData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreenSmall) {
          return DepartmentsDashboardMobile(
            nameController: nameController,
            descController: descController,
          );
        } else {
          return DepartmentsDashboardDesktop(
            nameController: nameController,
            descController: descController,
          );
        }
      },
    );
  }
}

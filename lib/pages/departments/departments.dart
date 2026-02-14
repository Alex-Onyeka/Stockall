import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/departments/platforms/departments_desktop.dart';
import 'package:stockall/pages/departments/platforms/departments_mobile.dart';

class Departments extends StatefulWidget {
  const Departments({super.key});

  @override
  State<Departments> createState() => _DepartmentsState();
}

class _DepartmentsState extends State<Departments> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await returnNavProvider(
        context,
        listen: false,
      ).validate(context);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return DepartmentsMobile();
        } else {
          return DepartmentsDesktop();
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/employees/customize_role/platforms/customize_role_desktop.dart';
import 'package:stockall/pages/employees/customize_role/platforms/customize_role_mobile.dart';

class CustomizeRolePage extends StatelessWidget {
  final TempUserClass user;
  const CustomizeRolePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= mobileScreen) {
          return CustomizeRoleMobile(user: user);
        } else {
          return CustomizeRoleDesktop(user: user);
        }
      },
    );
  }
}

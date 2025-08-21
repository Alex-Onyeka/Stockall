import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_user_class.dart';
import 'package:stockall/pages/profile/edit/platforms/edit_desktop.dart';
import 'package:stockall/pages/profile/edit/platforms/edit_mobile.dart';

class Edit extends StatefulWidget {
  final TempUserClass user;
  final bool? main;
  final String action;
  const Edit({
    super.key,
    required this.user,
    required this.action,
    this.main,
  });

  @override
  State<Edit> createState() => _EditState();
}

class _EditState extends State<Edit> {
  TextEditingController nameController =
      TextEditingController();
  TextEditingController phoneController =
      TextEditingController();
  TextEditingController passwordController =
      TextEditingController();
  TextEditingController confirmPasswordController =
      TextEditingController();
  TextEditingController emailController =
      TextEditingController();
  TextEditingController oldEmailController =
      TextEditingController();
  TextEditingController oldPassordController =
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
            return EditMobile(
              user: widget.user,
              nameController: nameController,
              phoneController: phoneController,
              action: widget.action,
              emailController: emailController,
              passwordController: passwordController,
              oldEmailController: oldEmailController,
              oldPasswordController: oldPassordController,
              confirmPasswordController:
                  confirmPasswordController,
              main: widget.main,
            );
          } else {
            return EditDesktop(
              user: widget.user,
              nameController: nameController,
              phoneController: phoneController,
              action: widget.action,
              emailController: emailController,
              passwordController: passwordController,
              oldEmailController: oldEmailController,
              oldPasswordController: oldPassordController,
              confirmPasswordController:
                  confirmPasswordController,
              main: widget.main,
            );
          }
        },
      ),
    );
  }
}

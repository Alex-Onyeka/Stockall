import 'package:flutter/material.dart';
import 'package:storrec/classes/temp_user_class.dart';
import 'package:storrec/pages/profile/edit/platforms/edit_mobile.dart';

class Edit extends StatefulWidget {
  final TempUserClass user;
  final String action;
  const Edit({
    super.key,
    required this.user,
    required this.action,
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
    return LayoutBuilder(
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

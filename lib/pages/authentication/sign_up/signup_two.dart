import 'package:flutter/material.dart';
import 'package:stockitt/pages/authentication/sign_up/platforms/signup_two_desktop.dart';
import 'package:stockitt/pages/authentication/sign_up/platforms/signup_two_mobile.dart';

class SignupTwo extends StatefulWidget {
  const SignupTwo({super.key});

  @override
  State<SignupTwo> createState() => _SignupTwoState();
}

class _SignupTwoState extends State<SignupTwo> {
  TextEditingController phoneController =
      TextEditingController();
  TextEditingController nameController =
      TextEditingController();
  TextEditingController idController =
      TextEditingController();

  @override
  void dispose() {
    super.dispose();
    phoneController.dispose();
    idController.dispose();
    nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () =>
              FocusManager.instance.primaryFocus?.unfocus(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return SignupTwoMobile(
              nameController: nameController,
              idController: idController,
              phoneController: phoneController,
            );
          } else {
            return SignupTwoDesktop(
              nameController: nameController,
              idController: idController,
              phoneController: phoneController,
            );
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockitt/pages/authentication/sign_up/platforms/signup_desktop.dart';
import 'package:stockitt/pages/authentication/sign_up/platforms/signup_mobile.dart';
import 'package:stockitt/providers/theme_provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController =
      TextEditingController();
  TextEditingController confirmPasswordController =
      TextEditingController();
  TextEditingController passwordController =
      TextEditingController();
  TextEditingController nameController =
      TextEditingController();
  TextEditingController phoneNumberController =
      TextEditingController();

  bool checked = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    confirmPasswordController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneNumberController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Provider.of<ThemeProvider>(context);
    return GestureDetector(
      onTap:
          () =>
              FocusManager.instance.primaryFocus?.unfocus(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 500) {
            return SignupMobile(
              checked: checked,
              onTap: () {
                FocusManager.instance.primaryFocus
                    ?.unfocus();
                setState(() {
                  checked = !checked;
                });
              },
              onChanged: (value) {
                FocusManager.instance.primaryFocus
                    ?.unfocus();
                setState(() {
                  checked = value!;
                });
              },
              nameController: nameController,
              phoneNumberController: phoneNumberController,
              confirmPasswordController:
                  confirmPasswordController,
              emailController: emailController,
              passwordController: passwordController,
              theme: theme,
            );
          } else {
            return SignupDesktop(
              theme: theme,
              confirmPasswordController:
                  confirmPasswordController,
              emailController: emailController,
              onChanged: (p0) {
                setState(() {
                  checked = p0!;
                });
              },
              onTap: () {
                setState(() {
                  checked = !checked;
                });
              },
              passwordController: passwordController,
              checked: checked,
            );
          }
        },
      ),
    );
  }
}

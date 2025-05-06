import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockitt/pages/authentication/login/platforms/login_desktop.dart';
import 'package:stockitt/pages/authentication/login/platforms/login_mobile.dart';
import 'package:stockitt/providers/theme_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController =
      TextEditingController();
  TextEditingController passwordController =
      TextEditingController();

  bool checked = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
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
            return LoginMobile(
              theme: theme,
              emailController: emailController,
              passwordController: passwordController,
            );
          } else {
            return LoginDesktop(
              theme: theme,
              emailController: emailController,
              passwordController: passwordController,
            );
          }
        },
      ),
    );
  }
}

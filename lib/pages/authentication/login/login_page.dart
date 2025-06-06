import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockall/components/major/unsupported_platform.dart';
import 'package:stockall/pages/authentication/login/platforms/login_mobile.dart';
import 'package:stockall/providers/theme_provider.dart';

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
          if (constraints.maxWidth < 550) {
            return LoginMobile(
              theme: theme,
              emailController: emailController,
              passwordController: passwordController,
            );
          } else {
            return UnsupportedPlatform();
            // return LoginDesktop(
            //   theme: theme,
            //   emailController: emailController,
            //   passwordController: passwordController,
            // );
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:stockall/components/major/unsupported_platform.dart';
import 'package:stockall/pages/authentication/forgot_password_page/platforms/forgot_password_mobile.dart';

class ForgotPasswordPage extends StatefulWidget {
  final bool? isMain;
  const ForgotPasswordPage({super.key, this.isMain});

  @override
  State<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState
    extends State<ForgotPasswordPage> {
  TextEditingController emailController =
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
            return ForgotPasswordMobile(
              emailController: emailController,
              isMain: widget.isMain,
            );
          } else if (constraints.maxWidth > 550 &&
              constraints.maxWidth < 1000) {
            // return Scaffold();
            return UnsupportedPlatform();
          } else {
            return UnsupportedPlatform();
            // return Scaffold();
          }
        },
      ),
    );
  }
}

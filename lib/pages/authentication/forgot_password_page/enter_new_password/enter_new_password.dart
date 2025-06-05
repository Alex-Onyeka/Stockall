import 'package:flutter/material.dart';
import 'package:stockall/pages/authentication/forgot_password_page/enter_new_password/platforms/enter_new_password_mobile.dart';

class EnterNewPassword extends StatefulWidget {
  const EnterNewPassword({super.key});

  @override
  State<EnterNewPassword> createState() =>
      _EnterNewPasswordState();
}

class _EnterNewPasswordState
    extends State<EnterNewPassword> {
  TextEditingController passwordC = TextEditingController();
  TextEditingController confirmPasswordC =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 550) {
          return EnterNewPasswordMobile(
            passwordC: passwordC,
            confirmPasswordC: confirmPasswordC,
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

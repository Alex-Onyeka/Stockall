import 'package:flutter/material.dart';
import 'package:stockall/components/major/unsupported_platform.dart';
import 'package:stockall/pages/authentication/forgot_password_page/enter_new_password/platforms/enter_new_password_mobile.dart';

class EnterNewPassword extends StatefulWidget {
  const EnterNewPassword({super.key});

  @override
  State<EnterNewPassword> createState() =>
      _EnterNewPasswordState();
}

class _EnterNewPasswordState
    extends State<EnterNewPassword> {
  String? accessToken;
  @override
  void initState() {
    super.initState();

    final uri = Uri.base;
    final token = uri.queryParameters['access_token'];
    setState(() {
      accessToken = token;
    });
  }

  TextEditingController passwordC = TextEditingController();
  TextEditingController confirmPasswordC =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // return Scaffold(
        //   body: Center(
        //     child: Text(
        //       textAlign: TextAlign.center,
        //       'Unauthorized Access. Check your email to reset your password.',
        //     ),
        //   ),
        // );

        if (constraints.maxWidth < 550) {
          return EnterNewPasswordMobile(
            passwordC: passwordC,
            confirmPasswordC: confirmPasswordC,
            accessToken: accessToken,
          );
        } else if (constraints.maxWidth > 550 &&
            constraints.maxWidth < 1000) {
          return UnsupportedPlatform();
        } else {
          return UnsupportedPlatform();
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/profile/change_email/enter_new_email/platforms/enter_new_email_desktop.dart';
import 'package:stockall/pages/profile/change_email/enter_new_email/platforms/enter_new_email_mobile.dart';

class EnterNewEmail extends StatefulWidget {
  const EnterNewEmail({super.key});

  @override
  State<EnterNewEmail> createState() =>
      EnterNewEmailState();
}

class EnterNewEmailState extends State<EnterNewEmail> {
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
          if (constraints.maxWidth < mobileScreen) {
            return EnterNewEmailMobile(
              emailController: emailController,
            );
          } else {
            return EnterNewEmailDesktop(
              emailController: emailController,
            );
            // return Scaffold();
          }
        },
      ),
    );
  }
}

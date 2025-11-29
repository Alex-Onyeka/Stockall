import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/pages/authentication/sign_up/verify_email/platforms/verify_email_desktop.dart';
import 'package:stockall/pages/authentication/sign_up/verify_email/platforms/verify_email_mobile.dart';
import 'package:stockall/providers/theme_provider.dart';

class VerifyEmailPage extends StatefulWidget {
  final bool isFirstTime;
  final TempUserClass user;

  const VerifyEmailPage({
    super.key,
    required this.isFirstTime,
    required this.user,
  });

  @override
  State<VerifyEmailPage> createState() =>
      _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final pinController = TextEditingController();
  @override
  void dispose() {
    super.dispose();
    pinController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Provider.of<ThemeProvider>(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (screenWidth(context) < mobileScreen) {
          return VerifyEmailMobile(
            theme: theme,
            isFirstTime: widget.isFirstTime,
            pinController: pinController,
            user: widget.user,
            userId: widget.user.userId!,
          );
        } else {
          return VerifyEmailDesktop(
            theme: theme,
            isFirstTime: widget.isFirstTime,
            pinController: pinController,
            user: widget.user,
            userId: widget.user.userId!,
          );
        }
      },
    );
  }
}

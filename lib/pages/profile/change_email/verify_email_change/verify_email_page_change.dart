import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/pages/profile/change_email/verify_email_change/platforms/verify_email_desktop_change.dart';
import 'package:stockall/pages/profile/change_email/verify_email_change/platforms/verify_email_mobile_change.dart';
import 'package:stockall/providers/theme_provider.dart';

class VerifyEmailPageChange extends StatefulWidget {
  final bool isFirstTime;
  final TempUserClass user;
  final String newEmail;

  const VerifyEmailPageChange({
    super.key,
    required this.isFirstTime,
    required this.user,
    required this.newEmail,
  });

  @override
  State<VerifyEmailPageChange> createState() =>
      _VerifyEmailPageChangeState();
}

class _VerifyEmailPageChangeState
    extends State<VerifyEmailPageChange> {
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
          return VerifyEmailMobileChange(
            theme: theme,
            isFirstTime: widget.isFirstTime,
            pinController: pinController,
            user: widget.user,
            userId: widget.user.userId!,
            newEmail: widget.newEmail,
          );
        } else {
          return VerifyEmailDesktopChange(
            theme: theme,
            isFirstTime: widget.isFirstTime,
            pinController: pinController,
            user: widget.user,
            userId: widget.user.userId!,
            newEmail: widget.newEmail,
          );
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/pages/profile/change_email/code_sent_change/platforms/code_sent_desktop_change.dart';
import 'package:stockall/pages/profile/change_email/code_sent_change/platforms/code_sent_mobile_change.dart';
import 'package:stockall/pages/profile/change_email/verify_email_change/verify_email_page_change.dart';
import 'package:stockall/providers/theme_provider.dart';

class CodeSentPageChange extends StatefulWidget {
  const CodeSentPageChange({
    super.key,
    required this.user,
    required this.newEmail,
  });
  final TempUserClass user;
  final String newEmail;

  @override
  State<CodeSentPageChange> createState() =>
      _CodeSentPageChangeState();
}

class _CodeSentPageChangeState
    extends State<CodeSentPageChange> {
  List<Widget> circles = [
    Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: Colors.pink,
        shape: BoxShape.circle,
      ),
    ),
    Container(
      height: 30,
      width: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(253, 200, 48, 1),
            Color.fromRGBO(243, 115, 53, 1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    ),
    Container(
      height: 20,
      width: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color.fromRGBO(82, 213, 186, 1),
      ),
    ),
    Container(
      height: 15,
      width: 15,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(25, 43, 117, 1),
            Color.fromRGBO(47, 80, 219, 1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    ),
    Container(
      height: 15,
      width: 15,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.amber,
      ),
    ),
  ];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: 3), () {
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) {
              return VerifyEmailPageChange(
                isFirstTime: true,
                user: widget.user,
                newEmail: widget.newEmail,
              );
            },
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Provider.of<ThemeProvider>(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (screenWidth(context) < mobileScreen) {
          return CodeSentMobileChange(
            circles: circles,
            theme: theme,
          );
        } else {
          return CodeSentDesktopChange(
            circles: circles,
            theme: theme,
          );
        }
      },
    );
  }
}

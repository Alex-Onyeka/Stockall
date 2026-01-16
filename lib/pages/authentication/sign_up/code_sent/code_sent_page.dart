import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/pages/authentication/sign_up/code_sent/platforms/code_sent_desktop.dart';
import 'package:stockall/pages/authentication/sign_up/code_sent/platforms/code_sent_mobile.dart';
import 'package:stockall/pages/authentication/sign_up/verify_email/verify_email_page.dart';
import 'package:stockall/providers/theme_provider.dart';

class CodeSentPage extends StatefulWidget {
  const CodeSentPage({super.key, required this.user});
  final TempUserClass user;

  @override
  State<CodeSentPage> createState() => _CodeSentPageState();
}

class _CodeSentPageState extends State<CodeSentPage> {
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
      Future.delayed(Duration(seconds: 2), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return VerifyEmailPage(
                isFirstTime: true,
                user: widget.user,
              );
            },
          ),
        ).then((_) {
          if (context.mounted) {
            Navigator.of(context).pop();
          } else {
            print('Context Not Mounted');
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Provider.of<ThemeProvider>(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (screenWidth(context) < mobileScreen) {
          return CodeSentMobile(
            email: widget.user.email,
            circles: circles,
            theme: theme,
          );
        } else {
          return CodeSentDesktop(
            circles: circles,
            email: widget.user.email,
            theme: theme,
          );
        }
      },
    );
  }
}
